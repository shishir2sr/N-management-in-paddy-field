import 'dart:isolate';
import 'dart:typed_data';

/// Messages exchanged between the UI isolate and the dedicated inference
/// isolate.
///
/// Nothing in here holds a native resource. The `Interpreter` handles live
/// exclusively inside the inference isolate and never cross a [SendPort] —
/// that is what makes it impossible for a Riverpod `autoDispose` timer to free
/// a native pointer while `invoke()` is still running on it.

/// Spawn payload. Sent once, as the `Isolate.spawn` message.
class InferenceInit {
  const InferenceInit({
    required this.replyPort,
    required this.segmentationModelPath,
    required this.classificationModelPath,
  });

  final SendPort replyPort;

  /// Already-extracted `.tflite` files. Both asset extraction and
  /// `path_provider` need the root isolate's Flutter bindings, so they happen
  /// before the spawn — the isolate only ever touches `dart:io` and FFI, and
  /// therefore needs no binding of its own.
  final String segmentationModelPath;
  final String classificationModelPath;
}

sealed class InferenceRequest {
  const InferenceRequest(this.id);
  final int id;
}

class AnalyzeImageRequest extends InferenceRequest {
  const AnalyzeImageRequest({
    required int id,
    required this.imagePath,
    this.maskThreshold = 0.6,
    this.deleteSourceWhenDone = false,
  }) : super(id);

  /// Path to the captured/picked file. Only the path crosses the port, so the
  /// full-size JPEG never lands on the UI isolate's heap.
  final String imagePath;
  final double maskThreshold;
  final bool deleteSourceWhenDone;
}

class ShutdownRequest extends InferenceRequest {
  const ShutdownRequest(super.id);
}

sealed class InferenceResponse {
  const InferenceResponse(this.id);
  final int id;
}

/// Sent once, unsolicited, when both interpreters are live. `id` is
/// [readyResponseId].
class IsolateReady extends InferenceResponse {
  const IsolateReady({
    required this.segmentationInputShape,
    required this.segmentationOutputShape,
    required this.classificationInputShape,
    required this.classificationOutputShape,
  }) : super(readyResponseId);

  static const int readyResponseId = -1;

  final List<int> segmentationInputShape;
  final List<int> segmentationOutputShape;
  final List<int> classificationInputShape;
  final List<int> classificationOutputShape;

  @override
  String toString() =>
      'IsolateReady(seg: $segmentationInputShape -> $segmentationOutputShape, '
      'cls: $classificationInputShape -> $classificationOutputShape)';
}

/// ponytail: temporary. When true, the preview page shows the exact bytes the
/// segmentation model was fed as the "before" image, and the model's raw mask
/// (grayscale, unthresholded) as the "after" image. Flip to false — and delete
/// everything it guards — once the segmentation output is confirmed good.
class AnalyzeSuccess extends InferenceResponse {
  const AnalyzeSuccess({
    required int id,
    required this.originalPng,
    required this.maskedPng,
    required this.lccLabel,
    required this.scores,
    required this.elapsedMs,
  }) : super(id);

  /// The 256x256 resized source, encoded before the mask was applied.
  final Uint8List originalPng;

  /// Same image with non-foreground pixels blacked out.
  final Uint8List maskedPng;

  /// One of the classification labels (2..5).
  final int lccLabel;

  final List<double> scores;
  final int elapsedMs;
}

/// Which stage of the pipeline failed. Kept as a plain string so the message
/// stays trivially copyable.
class InferenceStage {
  static const String init = 'init';
  static const String read = 'read';
  static const String decode = 'decode';
  static const String segment = 'segment';
  static const String classify = 'classify';
  static const String encode = 'encode';
}

class InferenceFailure extends InferenceResponse {
  const InferenceFailure({
    required int id,
    required this.message,
    required this.stage,
    this.stackTrace,
  }) : super(id);

  final String message;
  final String stage;
  final String? stackTrace;

  @override
  String toString() => 'InferenceFailure[$stage]: $message';
}

class ShutdownComplete extends InferenceResponse {
  const ShutdownComplete(super.id);
}
