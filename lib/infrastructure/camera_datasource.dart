// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:LCC/core/shared/logging_service.dart';
import 'package:LCC/domain/camera_failure.dart';

abstract class CameraDataSource {
  /// Takes a picture using the camera and returns the captured image file.
  ///
  /// Returns a [Future] that completes with an [XFile] object representing the captured image file.
  /// The returned [XFile] object contains information about the image file, such as its path and metadata.
  Future<XFile> takePicture({required CameraController controller});

  /// Initializes the camera controller.
  ///
  /// Returns a [Future] that completes with a [CameraController] object once the controller is initialized.
  Future<CameraController> initializeController();
}

class LccCameraDataSource extends CameraDataSource {
  @override
  Future<CameraController> initializeController() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      CameraController controller =
          CameraController(cameras[0], ResolutionPreset.medium);
      try {
        await controller.initialize();
      } on CameraException catch (e) {
        logger.e('CameraException: ${e.description}');
        rethrow;
      }
      return controller;
    } else {
      throw CameraInitializationException('No cameras available');
    }
  }

  @override
  Future<XFile> takePicture({required CameraController controller}) async {
    try {
      await controller.setFocusMode(FocusMode.locked);
      await controller.setExposureMode(ExposureMode.locked);
      final image = await controller.takePicture();
      logger.i('Image captrued');
      return image;
    } on CameraException catch (e) {
      logger.e('CameraException: ${e.description}');
      rethrow;
    }
  }
}

// * CameraServiceProvider
final cameraDataSourceProvider = Provider<CameraDataSource>((ref) {
  return LccCameraDataSource();
});

// * CameraControllerProvider
final cameraControllerProviderProvider =
    FutureProvider.autoDispose<CameraController>(
  (ref) async {
    final cameraDataSource = ref.watch(cameraDataSourceProvider);
    CameraController? controller;
    try {
      logger.i('Initializing camera controller');
      controller = await cameraDataSource.initializeController();
      // Dispose the controller when the provider is disposed
      ref.onDispose(() async {
        logger.i('Disposing camera controller ');
        await controller?.dispose();
      });
      return controller;
    } catch (e) {
      logger.e('Failed to initialize camera controller: $e');
      if (e is CameraInitializationException) {
        rethrow;
      } else {
        throw CameraInitializationException('Failed to initialize camera');
      }
    }
  },
);
