import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:LCC/application/image_processror_notifier_provider.dart';
import 'package:LCC/core/shared/color_constants.dart';
import 'package:LCC/domain/analysis_failure.dart';
import 'package:LCC/infrastructure/camera_datasource.dart';
import 'package:LCC/infrastructure/inference/inference_providers.dart';
import 'package:LCC/presentation/home/home_page.dart';
import 'package:LCC/presentation/home/image_preview_page.dart';
import 'package:LCC/presentation/home/widgets/camera_preview_widget.dart';
import 'package:LCC/presentation/home/widgets/camera_screen_bottom_bar_widget.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  /// Local re-entry guard so the shutter can be visually disabled. The notifier
  /// and the inference client both guard as well; this one is what stops a
  /// second `ImagePreviewPage` from being pushed.
  bool _isCapturing = false;

  Future<void> _onCapture(CameraController controller) async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final result = await ref
          .read(imageProcessorProvider.notifier)
          .captureAndSegmentImage(controller: controller);

      if (!mounted || result == null) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImagePreviewPage(segmentationResult: result),
        ),
      );
    } catch (e) {
      // The capture used to run as an unawaited future nested inside a
      // synchronous `maybeWhen`, so anything thrown here vanished.
      if (mounted) {
        _showMessage(context, 'Could not capture the photo. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = ref.watch(cameraControllerProviderProvider);
    final models = ref.watch(inferenceWarmupProvider);

    _listenForFailures();

    final canCapture = !_isCapturing &&
        models.hasValue &&
        cameraController.hasValue &&
        !cameraController.isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: getAppBar(
        title: "Capture Paddy Image",
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: CameraScreenBottomBarWidget(
        iconColor: canCapture ? ColorConstants.primaryGreen : Colors.grey,
        onImageCapture: canCapture
            ? () => _onCapture(cameraController.requireValue)
            : null,
      ),
      body: cameraController.when(
        loading: () => const Center(
          child: CupertinoActivityIndicator(
            color: ColorConstants.secondaryGreen,
          ),
        ),
        error: (error, _) => _CameraMessage(failure: error),
        data: (controller) => Stack(
          fit: StackFit.expand,
          children: [
            CameraPreviewWidget(controller: controller),
            if (models.isLoading)
              const ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(color: Colors.white),
                      SizedBox(height: 12),
                      Text(
                        'Preparing the analysis models…',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            if (models.hasError)
              _CameraMessage(failure: models.error!),
          ],
        ),
      ),
    );
  }

  void _listenForFailures() {
    ref.listen(cameraControllerProviderProvider, (_, next) {
      next.whenOrNull(
        error: (error, _) => _showFailure(context, error),
      );
    });

    ref.listen(imageProcessorProvider, (_, next) {
      next.whenOrNull(
        error: (error, _) => _showFailure(context, error),
      );
    });
  }
}

void _showFailure(BuildContext context, Object error) {
  if (error is AnalysisFailure) {
    _showMessage(
      context,
      error.message,
      actionLabel: error.needsSettings ? 'Settings' : null,
      onAction: error.needsSettings ? openAppSettings : null,
    );
    return;
  }
  _showMessage(context, 'Something went wrong. Please try again.');
}

void _showMessage(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      action: actionLabel == null || onAction == null
          ? null
          : SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction,
            ),
    ),
  );
}

class _CameraMessage extends StatelessWidget {
  const _CameraMessage({required this.failure});

  final Object failure;

  @override
  Widget build(BuildContext context) {
    final message = failure is AnalysisFailure
        ? (failure as AnalysisFailure).message
        : 'The camera could not be started on this device.';
    final needsSettings =
        failure is AnalysisFailure && (failure as AnalysisFailure).needsSettings;

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_photography_outlined,
                  color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              if (needsSettings) ...[
                const SizedBox(height: 16),
                const TextButton(
                  onPressed: openAppSettings,
                  child: Text('Open settings'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
