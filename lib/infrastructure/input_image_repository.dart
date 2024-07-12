import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/core/shared/logging_service.dart';
import 'package:rice_fertile_ai/domain/camera_failure.dart';
import 'package:rice_fertile_ai/infrastructure/camera_datasource.dart';

class InputImageRepository {
  final CameraDataSource _cameraService;

  InputImageRepository(this._cameraService);

  Future<Either<Uint8List, CameraFailure>> takePicture(
      {required CameraController controller}) async {
    try {
      final XFile xFileImage =
          await _cameraService.takePicture(controller: controller);
      xFileImage.readAsBytes();
      logger.i('[Repository] Returning image bytes');
      final Uint8List imageBytes = await xFileImage.readAsBytes();
      return left(imageBytes);
    } on CameraException catch (e) {
      return right(
          CameraFailure.cameraException(e.description ?? 'Unknown Error!'));
    } on CameraInitializationException catch (e) {
      return right(CameraFailure.cameraException(e.message));
    }
  }
}

// * ImageProcessingRepositoryProvider
final imageProcessingRepositoryProvider =
    Provider.autoDispose<InputImageRepository>((ref) {
  final cameraService = ref.watch(cameraDataSourceProvider);
  return InputImageRepository(cameraService);
});
