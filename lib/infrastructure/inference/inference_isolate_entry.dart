import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'inference_protocol.dart';

/// Entry point for the dedicated inference isolate.
///
/// This isolate is the sole owner of both `Interpreter`s for its whole
/// lifetime. Requests are handled strictly sequentially, so the tensor arenas
/// can never be reallocated underneath an in-flight `invoke()`.
///
/// Uses only `dart:io`, `package:image` and FFI — no Flutter bindings, no
/// MethodChannels, no asset bundle. The models arrive as already-extracted file
/// paths (see `ModelAssetCache`) precisely so that stays true.
///
/// Must be a top-level function — `Isolate.spawn` cannot take a closure.
Future<void> inferenceIsolateEntry(InferenceInit init) async {
  final commandPort = ReceivePort();

  // Hand the command port back first so the client can wire up even if model
  // loading subsequently fails.
  init.replyPort.send(commandPort.sendPort);

  Interpreter? segmentation;
  Interpreter? classification;

  try {
    final segmentationFile = _requireModelFile(init.segmentationModelPath);
    final classificationFile = _requireModelFile(init.classificationModelPath);

    // `fromFile` maps the model with `TfLiteModelCreateFromFile`. `fromAsset`
    // would route through `Model.fromBuffer`, which `calloc`s the entire
    // flatbuffer and never frees it — a permanent ~24 MB native leak per load.
    // No `InterpreterOptions` — deliberately. Calling
    // `TfLiteInterpreterOptionsSetNumThreads` at all wrecks this segmentation
    // graph on the 2.11.0 runtime: measured on device, 4 threads produced an
    // all-zero mask, 1 thread produced a mask covering 0.1% of the frame, and
    // leaving the option unset (what `Interpreter.fromAsset` used to do)
    // produced a clean leaf silhouette at 8-10% coverage with max 0.997.
    // ponytail: do not add options here without re-running that comparison.
    segmentation = Interpreter.fromFile(segmentationFile);
    classification = Interpreter.fromFile(classificationFile);

    final segIn = segmentation.getInputTensor(0);
    final segOut = segmentation.getOutputTensor(0);
    final clsIn = classification.getInputTensor(0);
    final clsOut = classification.getOutputTensor(0);

    _requireFloat32(segIn, 'segmentation input');
    _requireFloat32(segOut, 'segmentation output');
    _requireFloat32(clsIn, 'classification input');
    _requireFloat32(clsOut, 'classification output');

    // Fail loudly at startup rather than with a cryptic RangeError or a
    // byte-size mismatch on the first capture.
    _requireShape(segIn, 'segmentation input', rank: 4, channels: 3);
    _requireShape(segOut, 'segmentation output', rank: 4, channels: 1);
    _requireShape(clsIn, 'classification input', rank: 4, channels: 3);
    if (clsOut.shape.last != _classificationLabels.length) {
      throw StateError(
        'Classification model has ${clsOut.shape.last} output classes but '
        '${_classificationLabels.length} labels are defined '
        '($_classificationLabels).',
      );
    }

    init.replyPort.send(IsolateReady(
      segmentationInputShape: segIn.shape,
      segmentationOutputShape: segOut.shape,
      classificationInputShape: clsIn.shape,
      classificationOutputShape: clsOut.shape,
    ));
  } catch (e, st) {
    segmentation?.close();
    classification?.close();
    init.replyPort.send(InferenceFailure(
      id: IsolateReady.readyResponseId,
      message: e.toString(),
      stage: InferenceStage.init,
      stackTrace: st.toString(),
    ));
    commandPort.close();
    Isolate.exit();
  }

  await for (final message in commandPort) {
    if (message is! InferenceRequest) continue;

    if (message is ShutdownRequest) {
      // Freeing the arenas requires closing the interpreters. `Isolate.kill()`
      // alone leaks them — they are process-level allocations, not
      // isolate-owned.
      segmentation.close();
      classification.close();
      commandPort.close();
      init.replyPort.send(ShutdownComplete(message.id));
      Isolate.exit();
    }

    if (message is AnalyzeImageRequest) {
      // Never let a throw escape this loop: that kills the isolate and hangs
      // every pending completer on the UI side.
      try {
        init.replyPort.send(_analyze(
          request: message,
          segmentation: segmentation,
          classification: classification,
        ));
      } catch (e, st) {
        init.replyPort.send(InferenceFailure(
          id: message.id,
          message: e.toString(),
          stage: e is _StagedException ? e.stage : InferenceStage.decode,
          stackTrace: st.toString(),
        ));
      }
    }
  }
}

/// The models are extracted on the root isolate before this isolate is
/// spawned, so here they only need to be checked for existence — a clear error
/// at init beats a native crash on the first capture.
File _requireModelFile(String path) {
  final file = File(path);
  if (!file.existsSync() || file.lengthSync() == 0) {
    throw StateError('Model file is missing or empty: $path');
  }
  return file;
}

void _requireShape(
  Tensor tensor,
  String label, {
  required int rank,
  required int channels,
}) {
  final shape = tensor.shape;
  if (shape.length != rank || shape.last != channels) {
    throw StateError(
      'Expected $label to be rank-$rank NHWC with $channels channel(s), '
      'but the model declares $shape.',
    );
  }
}

void _requireFloat32(Tensor tensor, String label) {
  if (tensor.type != TensorType.float32) {
    throw StateError(
      'Expected $label to be float32 but the model declares ${tensor.type}. '
      'The preprocessing in this isolate writes normalised float32 bytes '
      'directly into the tensor and would silently corrupt a quantised model.',
    );
  }
}

/// Labels the classification model's four output units map onto.
const List<int> _classificationLabels = [2, 3, 4, 5];

AnalyzeSuccess _analyze({
  required AnalyzeImageRequest request,
  required Interpreter segmentation,
  required Interpreter classification,
}) {
  final stopwatch = Stopwatch()..start();

  final segInputShape = segmentation.getInputTensor(0).shape;
  final segHeight = segInputShape[1];
  final segWidth = segInputShape[2];

  final Uint8List sourceBytes;
  try {
    sourceBytes = File(request.imagePath).readAsBytesSync();
  } catch (e) {
    throw _StagedException(InferenceStage.read, e.toString());
  }

  final decoded = img.decodeImage(sourceBytes);
  if (decoded == null) {
    throw _StagedException(
      InferenceStage.decode,
      'Could not decode image at ${request.imagePath}',
    );
  }

  // `Interpolation.nearest` is `copyResize`'s default and is what the models
  // were validated against — do not "improve" it, every input pixel changes.
  var resized = img.copyResize(decoded, width: segWidth, height: segHeight);

  // A JPEG decodes to 3 channels, a PNG to 4. `setPixelRgba(..,0,0,0,0)` only
  // writes alpha when numChannels > 3, so the old code produced a *black*
  // background for camera captures and a *transparent* one for gallery PNGs —
  // two different inputs to the classifier for the same leaf. Normalising to 3
  // channels makes both paths black, matching the camera path the model was
  // used with.
  if (resized.numChannels != 3) {
    resized = resized.convert(numChannels: 3);
  }

  Uint8List originalPng;
  try {
    originalPng = Uint8List.fromList(img.encodePng(resized));
  } catch (e) {
    throw _StagedException(InferenceStage.encode, e.toString());
  }

  // Owned copy, offset 0 — safe to hand `.buffer` to `Image.fromBytes` and to
  // mutate in place for the mask.
  final rgb = Uint8List.fromList(resized.toUint8List());

  // --- segmentation ---
  final Float32List mask;
  try {
    final input = Float32List(rgb.length);
    for (var i = 0; i < rgb.length; i++) {
      input[i] = rgb[i] / 255.0;
    }
    // The `data` setter memcpys into the tensor's native buffer. Passing the
    // `Float32List` to `setTo` instead would take
    // `ByteConversionUtils`' per-element path — ~200k tiny allocations.
    segmentation.getInputTensor(0).data = input.buffer.asUint8List();
    segmentation.invoke();
    mask = _readFloat32Output(segmentation.getOutputTensor(0));
  } catch (e) {
    throw _StagedException(InferenceStage.segment, e.toString());
  }

  final pixelCount = rgb.length ~/ 3;
  if (mask.length < pixelCount) {
    throw _StagedException(
      InferenceStage.segment,
      'Mask has ${mask.length} values for $pixelCount pixels',
    );
  }

  for (var p = 0, o = 0; p < pixelCount; p++, o += 3) {
    if (mask[p] <= request.maskThreshold) {
      rgb[o] = 0;
      rgb[o + 1] = 0;
      rgb[o + 2] = 0;
    }
  }

  final masked = img.Image.fromBytes(
    width: segWidth,
    height: segHeight,
    bytes: rgb.buffer,
    numChannels: 3,
  );

  final Uint8List maskedPng;
  try {
    maskedPng = Uint8List.fromList(img.encodePng(masked));
  } catch (e) {
    throw _StagedException(InferenceStage.encode, e.toString());
  }

  // --- classification ---
  // Fed straight from `rgb`. The old code encoded a PNG and decoded it again
  // here; PNG is lossless and both sides are 3-channel uint8, so skipping the
  // round-trip is bit-identical.
  final List<double> scores;
  final int label;
  try {
    final clsInputShape = classification.getInputTensor(0).shape;
    final clsHeight = clsInputShape[1];
    final clsWidth = clsInputShape[2];

    final Uint8List clsSource;
    if (clsWidth == segWidth && clsHeight == segHeight) {
      clsSource = rgb;
    } else {
      clsSource = Uint8List.fromList(
        img.copyResize(masked, width: clsWidth, height: clsHeight).toUint8List(),
      );
    }

    final input = Float32List(clsSource.length);
    for (var i = 0; i < clsSource.length; i++) {
      input[i] = clsSource[i] / 255.0;
    }
    classification.getInputTensor(0).data = input.buffer.asUint8List();
    classification.invoke();

    final output = _readFloat32Output(classification.getOutputTensor(0));
    scores = List<double>.unmodifiable(output);
    label = _classificationLabels[argmaxOfScores(output)];
  } catch (e) {
    throw _StagedException(InferenceStage.classify, e.toString());
  }

  if (request.deleteSourceWhenDone) {
    try {
      File(request.imagePath).deleteSync();
    } catch (_) {
      // A leftover temp file is not worth failing the analysis over.
    }
  }

  return AnalyzeSuccess(
    id: request.id,
    originalPng: originalPng,
    maskedPng: maskedPng,
    lccLabel: label,
    scores: scores,
    elapsedMs: stopwatch.elapsedMilliseconds,
  );
}

/// Reads a float32 output tensor into a flat [Float32List].
///
/// `Tensor.copyTo` is deliberately avoided: it compares the tensor's shape
/// against the destination's and throws `ArgumentError: Output object shape
/// mismatch` for any flat list. `Tensor.data` returns an unmodifiable view of
/// native memory that the next `invoke()` overwrites, so it is copied here.
Float32List _readFloat32Output(Tensor tensor) {
  final bytes = Uint8List.fromList(tensor.data);
  return bytes.buffer.asFloat32List();
}

/// Labels the classification model's four output units map onto. Exposed for
/// tests.
List<int> get classificationLabels => _classificationLabels;

/// Single linear scan. The previous implementation used
/// `indexWhere(e => e == reduce(max))`, which is O(n^2) and returns -1 when any
/// logit is NaN — then throws `RangeError` on the label lookup.
///
/// Public so it can be unit tested; it is pure and touches no native state.
int argmaxOfScores(Float32List values) {
  if (values.isEmpty) {
    throw _StagedException(InferenceStage.classify, 'Empty model output');
  }
  var bestIndex = 0;
  var best = double.negativeInfinity;
  var sawFinite = false;
  for (var i = 0; i < values.length; i++) {
    final v = values[i];
    if (v.isNaN) continue;
    sawFinite = true;
    if (v > best) {
      best = v;
      bestIndex = i;
    }
  }
  if (!sawFinite) {
    throw _StagedException(
      InferenceStage.classify,
      'Model output was entirely NaN',
    );
  }
  if (bestIndex >= _classificationLabels.length) {
    throw _StagedException(
      InferenceStage.classify,
      'Model produced ${values.length} classes but '
      '${_classificationLabels.length} labels are defined',
    );
  }
  return bestIndex;
}

class _StagedException implements Exception {
  _StagedException(this.stage, this.message);

  final String stage;
  final String message;

  @override
  String toString() => message;
}
