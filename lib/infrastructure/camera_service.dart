// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:rice_fertile_ai/core/shared/logging_service.dart';

abstract class CameraService {
  Future<XFile> takePicture();
}

class LccCameraService extends CameraService {
  late CameraController _controller;
  LccCameraService() {
    _initializeController();
  }

  Future<void> _initializeController() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      try {
        await _controller.initialize();
      } on CameraException catch (e) {
        rethrow;
      }
    } else {
      throw Exception('No cameras available');
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
}
