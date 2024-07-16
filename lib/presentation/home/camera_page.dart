import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/application/image_processror_notifier_provider.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';
import 'package:rice_fertile_ai/core/shared/string_constants.dart';
import 'package:rice_fertile_ai/infrastructure/camera_datasource.dart';
import 'package:rice_fertile_ai/infrastructure/tflite_service.dart';
import 'package:rice_fertile_ai/presentation/home/home_page.dart';
import 'package:rice_fertile_ai/presentation/home/image_preview_page.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/camera_preview_widget.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/camera_screen_bottom_bar_widget.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraController = ref.watch(cameraControllerProviderProvider);
    final interpreter =
        ref.watch(interpreterProvider(StringConstants.segmentationModelPath));
    // listen to the controller initialization error
    ref.listen(cameraControllerProviderProvider, (state, next) {
      if (state == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initialize camera'),
          ),
        );
      } else {
        state.maybeWhen(
          orElse: () {},
          error: (error, stackTrace) =>
              ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to initialize camera'),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: getAppBar(
        title: "Capture Paddy Image",
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: CameraScreenBottomBarWidget(
        iconColor:
            interpreter.isLoading ? Colors.grey : ColorConstants.primaryGreen,
        onImageCapture: !interpreter.isLoading
            ? () async {
                final notifier = ref.read(imageProcessorProvider.notifier);
                final cameraImage = await notifier.captureImage(
                  controller: cameraController.value!,
                  interpreter: interpreter.asData!.value,
                );

                final segmentedImage = await notifier.removeBackgroundFromImage(
                  imageBytes: cameraImage!,
                  interpreter: interpreter.asData!.value,
                );

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreviewPage(
                        imageBytes: segmentedImage.outputImage,
                      ),
                    ),
                  );
                }
              }
            : () {},
      ),
      body: !interpreter.isLoading
          ? cameraController.maybeMap(
              orElse: () => const Text('Camera controller not initialized'),
              loading: (_) => const Center(
                child: CupertinoActivityIndicator(
                  color: ColorConstants.secondaryGreen,
                ),
              ),
              data: (controller) {
                return CameraPreviewWidget(
                  controller: controller.value,
                );
              },
            )
          : const CupertinoActivityIndicator(),
    );
  }
}
