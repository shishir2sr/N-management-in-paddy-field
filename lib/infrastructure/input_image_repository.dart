import 'package:camera/camera.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/domain/camera_failure.dart';
import 'package:rice_fertile_ai/infrastructure/camera_datasource.dart';

class InputImageRepository {
  final CameraDataSource _cameraService;

  InputImageRepository(this._cameraService);

  Future<void> takePicture({required CameraController controller}) async {
    try {
      await _cameraService.takePicture(controller: controller);
    } on CameraException catch (_) {
      rethrow;
    } on CameraInitializationException catch (_) {
      rethrow;
    }
  }
}

// * ImageProcessingRepositoryProvider
final imageProcessingRepositoryProvider =
    Provider.autoDispose<InputImageRepository>((ref) {
  final cameraService = ref.watch(cameraDataSourceProvider);
  return InputImageRepository(cameraService);
});
