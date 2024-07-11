// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/core/shared/logging_service.dart';
import 'package:rice_fertile_ai/domain/camera_failure.dart';

abstract class CameraService {
  /// Takes a picture using the camera and returns the captured image file.
  ///
  /// Returns a [Future] that completes with an [XFile] object representing the captured image file.
  /// The returned [XFile] object contains information about the image file, such as its path and metadata.
  Future<XFile> takePicture();

  /// Disposes the camera service and releases any resources used.
  void dispose();

  /// camera controller getter
  CameraController get controller;
}

class LccCameraService extends CameraService {
  late CameraController _controller;
  LccCameraService() {
    _initializeController();
  }

  @override
  CameraController get controller => _controller;

  Future<void> _initializeController() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      try {
        await _controller.initialize();
      } on CameraException catch (e) {
        logger.e('CameraException: ${e.description}');
        rethrow;
      }
    } else {
      throw CameraInitializationException('No cameras available');
    }
  }

  @override
  Future<XFile> takePicture() async {
    try {
      await _controller.setFocusMode(FocusMode.locked);
      await _controller.setExposureMode(ExposureMode.locked);
      final image = await _controller.takePicture();
      logger.i('Image captrued');
      return image;
    } on CameraException catch (e) {
      logger.e('CameraException: ${e.description}');
      rethrow;
    }
  }

  // dispose the camera controller
  @override
  void dispose() async {
    await _controller.dispose();
  }
}

// * CameraServiceProvider
final cameraServiceProvider = Provider.autoDispose<CameraService>((ref) {
  return LccCameraService();
});
