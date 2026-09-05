import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import 'package:LCC/infrastructure/inference/inference_isolate_client.dart';

/// Exercises the real inference pipeline on a device or simulator.
///
/// This is the test that covers what used to break: the models load in a
/// background isolate via `Interpreter.fromFile`, inference runs off the UI
/// thread, and repeated and concurrent requests neither crash natively nor
/// deadlock.
///
/// Run with:
///   flutter test integration_test/inference_pipeline_test.dart -d <device>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late InferenceIsolateClient client;
  late String imagePath;

  setUpAll(() async {
    client = InferenceIsolateClient();

    // A bundled 4-channel PNG, which also exercises the RGBA -> RGB
    // normalisation that makes the gallery path agree with the camera path.
    final bytes = await rootBundle.load('assets/images/paddy.png');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/inference_test_input.png');
    await file.writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      flush: true,
    );
    imagePath = file.path;
  });

  tearDownAll(() async {
    await client.dispose();
  });

  testWidgets('loads both models in a background isolate', (_) async {
    final ready = await client.warmUp();

    expect(ready.segmentationInputShape, [1, 256, 256, 3]);
    expect(ready.segmentationOutputShape, [1, 256, 256, 1]);
    expect(ready.classificationInputShape, [1, 256, 256, 3]);
    expect(ready.classificationOutputShape.last, 4);
  });

  testWidgets('warmUp is idempotent', (_) async {
    final a = await client.warmUp();
    final b = await client.warmUp();
    expect(a.segmentationInputShape, b.segmentationInputShape);
  });

  testWidgets('analyses an image and returns a usable LCC score', (_) async {
    final result = await client.analyze(imagePath);

    expect(result.lccLabel, inInclusiveRange(2, 5));
    expect(result.scores.length, 4);
    expect(result.scores.every((s) => s.isFinite), isTrue,
        reason: 'NaN logits used to make argmax throw RangeError');

    // Both images come back as decodable PNGs of the model's input size.
    expect(result.originalPng, isNotEmpty);
    expect(result.maskedPng, isNotEmpty);
    expect(result.originalPng.sublist(0, 8),
        [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    expect(result.maskedPng.sublist(0, 8),
        [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

    // The mask must actually change something, or segmentation is a no-op.
    expect(result.maskedPng, isNot(equals(result.originalPng)));
  });

  testWidgets('is deterministic across repeated runs', (_) async {
    final first = await client.analyze(imagePath);
    final second = await client.analyze(imagePath);

    expect(second.lccLabel, first.lccLabel);
    expect(second.scores, first.scores);
    // Same interpreter reused — the arena is not being reallocated per call.
    expect(second.maskedPng.length, first.maskedPng.length);
  });

  testWidgets('serialises concurrent requests instead of dropping them',
      (_) async {
    // The double-tap case. tflite_flutter's own IsolateInterpreter silently
    // returns without running when a call is already in flight; every request
    // here has to complete.
    final results = await Future.wait([
      client.analyze(imagePath),
      client.analyze(imagePath),
      client.analyze(imagePath),
    ]);

    expect(results, hasLength(3));
    for (final result in results) {
      expect(result.lccLabel, inInclusiveRange(2, 5));
    }
    expect(results.map((r) => r.id).toSet(), hasLength(3));
  });

  testWidgets('reports a read failure rather than crashing', (_) async {
    await expectLater(
      client.analyze('/definitely/not/a/real/file.jpg'),
      throwsA(isA<InferenceException>()),
    );

    // The isolate must survive a failed request — a throw escaping its message
    // loop would kill it and hang every later call.
    final result = await client.analyze(imagePath);
    expect(result.lccLabel, inInclusiveRange(2, 5));
  });

  testWidgets('reports a decode failure rather than crashing', (_) async {
    final dir = await getTemporaryDirectory();
    final garbage = File('${dir.path}/not_an_image.jpg');
    await garbage.writeAsBytes(List.filled(64, 0x41), flush: true);

    await expectLater(
      client.analyze(garbage.path),
      throwsA(isA<InferenceException>()),
    );

    final result = await client.analyze(imagePath);
    expect(result.lccLabel, inInclusiveRange(2, 5));
  });

  testWidgets('deletes the source file when asked to', (_) async {
    final dir = await getTemporaryDirectory();
    final copy = File('${dir.path}/disposable_capture.png');
    await copy.writeAsBytes(await File(imagePath).readAsBytes(), flush: true);

    await client.analyze(copy.path, deleteSourceWhenDone: true);

    // Camera captures used to accumulate in the cache directory forever.
    expect(await copy.exists(), isFalse);
  });

  testWidgets('releases resources and transparently restarts', (_) async {
    await client.releaseResources();
    expect(client.isRunning, isFalse);

    // Backgrounding the app frees the tensor arenas; the next capture must
    // still work without the caller knowing anything happened.
    final result = await client.analyze(imagePath);
    expect(result.lccLabel, inInclusiveRange(2, 5));
    expect(client.isRunning, isTrue);
  });
}
