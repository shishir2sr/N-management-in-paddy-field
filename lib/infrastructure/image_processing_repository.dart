import 'package:camera/camera.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/domain/camera_failure.dart';
import 'package:rice_fertile_ai/infrastructure/camera_service.dart';

class ImageProcessingRepository {
  final CameraService _cameraService;

  ImageProcessingRepository(this._cameraService);

  CameraController get cameraController => _cameraService.controller;

  void disposeCameraService() {
    _cameraService.dispose();
  }

  Future<void> takePicture() async {
    try {
      await _cameraService.takePicture();
    } on CameraException catch (_) {
      rethrow;
    } on CameraInitializationException catch (_) {
      rethrow;
    }
  }
}

// * ImageProcessingRepositoryProvider
final imageProcessingRepositoryProvider =
    Provider.autoDispose<ImageProcessingRepository>((ref) {
  final cameraService = ref.watch(cameraServiceProvider);
  return ImageProcessingRepository(cameraService);
});
