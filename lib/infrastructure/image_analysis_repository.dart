import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:LCC/core/shared/logging_service.dart';
import 'package:LCC/domain/analysis_failure.dart';
import 'package:LCC/domain/segmentation_result.dart';
import 'package:LCC/infrastructure/camera_datasource.dart';
import 'package:LCC/infrastructure/inference/inference_isolate_client.dart';
import 'package:LCC/infrastructure/inference/inference_providers.dart';

/// Captures an image and runs it through the inference isolate.
///
/// Only file paths cross into the isolate, so a full-resolution JPEG is never
/// held on the UI isolate's heap, and no `Interpreter` is ever passed around.
class ImageAnalysisRepository {
  ImageAnalysisRepository(this._cameraService, this._inference);

  final CameraDataSource _cameraService;
  final InferenceIsolateClient _inference;

  Future<Either<AnalysisFailure, SegmentationResult>> captureAndAnalyze({
    required CameraController controller,
  }) async {
    final XFile captured;
    try {
      captured = await _cameraService.takePicture(controller: controller);
    } on AnalysisFailure catch (failure) {
      return left(failure);
    } on CameraException catch (e) {
      return left(CameraFailure(e.description ?? e.code));
    } catch (e, st) {
      logger.e('Unexpected capture failure', error: e, stackTrace: st);
      return left(const CameraFailure('Could not capture the photo.'));
    }

    return analyzeImageAt(
      imagePath: captured.path,
      // The camera plugin writes to the cache directory and never cleans up.
      deleteSourceWhenDone: true,
    );
  }

  Future<Either<AnalysisFailure, SegmentationResult>> analyzeImageAt({
    required String imagePath,
    bool deleteSourceWhenDone = false,
  }) async {
    try {
      final result = await _inference.analyze(
        imagePath,
        deleteSourceWhenDone: deleteSourceWhenDone,
      );

      logger.i('Analysis finished in ${result.elapsedMs}ms — '
          'LCC ${result.lccLabel}');

      return right(SegmentationResult(
        originalImage: result.originalPng,
        outputImage: result.maskedPng,
        lccLabel: result.lccLabel,
      ));
    } on InferenceException catch (e) {
      logger.e('Inference failed: $e');
      return left(ProcessingFailure(
        _userMessageFor(e),
        stage: e.stage,
      ));
    } catch (e, st) {
      logger.e('Unexpected analysis failure', error: e, stackTrace: st);
      return left(const ProcessingFailure(
        'Could not analyse this image. Please try again.',
      ));
    }
  }

  /// Keeps native/FFI detail out of the snackbar while still distinguishing the
  /// cases a user can act on.
  String _userMessageFor(InferenceException e) {
    switch (e.stage) {
      case 'read':
        return 'The photo could not be read. Please capture it again.';
      case 'decode':
        return 'That image format is not supported. Try a JPEG or PNG photo.';
      case 'init':
        return 'The analysis models could not be loaded on this device.';
      default:
        return 'Could not analyse this image. Please try again.';
    }
  }
}

// * ImageProcessingRepositoryProvider
final imageProcessingRepositoryProvider =
    Provider<ImageAnalysisRepository>((ref) {
  return ImageAnalysisRepository(
    ref.watch(cameraDataSourceProvider),
    ref.watch(inferenceClientProvider),
  );
});
