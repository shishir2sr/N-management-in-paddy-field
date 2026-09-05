// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:camera/camera.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:LCC/core/shared/logging_service.dart';
import 'package:LCC/domain/analysis_failure.dart';

abstract class CameraDataSource {
  Future<XFile> takePicture({required CameraController controller});
  Future<CameraController> initializeController();
}

class LccCameraDataSource extends CameraDataSource {
  @override
  Future<CameraController> initializeController() async {
    await _ensureCameraPermission();

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw CameraInitializationException('No cameras available');
    }

    final controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      // The app never records audio. Leaving this on makes iOS prompt for
      // microphone access, which the Info.plist has no usage description for.
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      // Release the native session ourselves — the provider's onDispose is only
      // wired up once this method returns successfully.
      await controller.dispose();
      logger.e('CameraException during initialize: ${e.description}');
      throw _mapCameraException(e);
    } catch (_) {
      await controller.dispose();
      rethrow;
    }

    return controller;
  }

  @override
  Future<XFile> takePicture({required CameraController controller}) async {
    // Locking focus and exposure improves consistency for the model, but plenty
    // of CameraX implementations reject it. It is an optimisation, not a
    // requirement, so a failure here must not fail the capture.
    await _tryLock(
      () => controller.setFocusMode(FocusMode.locked),
      'focus',
    );
    await _tryLock(
      () => controller.setExposureMode(ExposureMode.locked),
      'exposure',
    );

    try {
      final image = await controller.takePicture();
      logger.i('Image captured: ${image.path}');
      return image;
    } on CameraException catch (e) {
      logger.e('CameraException during capture: ${e.description}');
      throw _mapCameraException(e);
    }
  }

  Future<void> _tryLock(Future<void> Function() action, String label) async {
    try {
      await action();
    } on CameraException catch (e) {
      logger.w('Could not lock $label (${e.code}) — continuing');
    } on UnsupportedError {
      logger.w('Locking $label is unsupported on this device — continuing');
    }
  }

  Future<void> _ensureCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isGranted || status.isLimited) return;

    if (status.isPermanentlyDenied || status.isRestricted) {
      throw const CameraAccessBlockedFailure();
    }

    status = await Permission.camera.request();

    if (status.isGranted || status.isLimited) return;

    if (status.isPermanentlyDenied || status.isRestricted) {
      throw const CameraAccessBlockedFailure();
    }

    throw const CameraAccessDeniedFailure();
  }

  AnalysisFailure _mapCameraException(CameraException e) {
    final description = e.description ?? e.code;
    switch (e.code) {
      case 'CameraAccessDenied':
      case 'AudioAccessDenied':
        return CameraAccessDeniedFailure(description);
      case 'CameraAccessDeniedWithoutPrompt':
      case 'AudioAccessDeniedWithoutPrompt':
      case 'CameraAccessRestricted':
      case 'AudioAccessRestricted':
        return CameraAccessBlockedFailure(description);
      default:
        return CameraFailure(description);
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
    logger.i('Initializing camera controller');

    final controller = await cameraDataSource.initializeController();

    // Registered only after a successful initialize, and synchronous —
    // onDispose discards a returned Future, so an async callback here never
    // actually gets awaited.
    ref.onDispose(() {
      logger.i('Disposing camera controller');
      controller.dispose();
    });

    return controller;
  },
);
