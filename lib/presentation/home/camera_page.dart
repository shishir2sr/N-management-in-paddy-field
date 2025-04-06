import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:LCC/application/image_processror_notifier_provider.dart';
import 'package:LCC/core/shared/color_constants.dart';
import 'package:LCC/core/shared/string_constants.dart';
import 'package:LCC/domain/segmentation_result.dart';
import 'package:LCC/infrastructure/camera_datasource.dart';
import 'package:LCC/infrastructure/tflite_service.dart';
import 'package:LCC/presentation/home/home_page.dart';
import 'package:LCC/presentation/home/image_preview_page.dart';
import 'package:LCC/presentation/home/widgets/camera_preview_widget.dart';
import 'package:LCC/presentation/home/widgets/camera_screen_bottom_bar_widget.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraController = ref.watch(cameraControllerProviderProvider);
    final interpreter =
        ref.watch(interpreterProvider(StrConsts.segmentationModelPath));

    // Show error if there is any
    _showError(ref, context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: getAppBar(
        title: "Capture Paddy Image",
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: CameraScreenBottomBarWidget(
          iconColor: interpreter.isLoading || interpreter.hasError
              ? Colors.grey
              : ColorConstants.primaryGreen,
          onImageCapture: () async {
            SegmentationResult? segmentationResult;
            final notifier = ref.read(imageProcessorProvider.notifier);
            cameraController.maybeWhen(
                orElse: () {},
                data: (controller) {
                  interpreter.maybeWhen(
                      orElse: () {},
                      data: (interpreter) async {
                        segmentationResult =
                            await notifier.captureAndSegmentImage(
                          controller: controller,
                          interpreter: interpreter,
                        );

                        if (context.mounted && segmentationResult != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImagePreviewPage(
                                segmentationResult: segmentationResult!,
                              ),
                            ),
                          );
                        }
                      });
                });
          }),
      body: interpreter.when(
          data: (interpreter) => cameraController.maybeMap(
                orElse: () => const Center(
                  child: Text('Camera controller not initialized'),
                ),
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
              ),
          error: (error, stacktrace) => Center(
                child: Text("Interpreter Error: ${error.toString()}"),
              ),
          loading: () => const Center(child: CupertinoActivityIndicator())),
    );
  }

  void _showError(WidgetRef ref, BuildContext context) {
    ref.listen(
      cameraControllerProviderProvider,
      (state, next) {
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
              SnackBar(
                content: Text(error.toString()),
              ),
            ),
          );
        }
      },
    );
    ref.listen(interpreterProvider(StrConsts.segmentationModelPath),
        (state, next) {
      state?.maybeWhen(
        orElse: () {},
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
            ),
          );
        },
      );
    });
  }
}
