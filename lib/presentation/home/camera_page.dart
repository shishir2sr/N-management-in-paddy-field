import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';
import 'package:rice_fertile_ai/infrastructure/camera_datasource.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/camera_preview_widget.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/camera_screen_bottom_bar_widget.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraController = ref.watch(cameraControllerProviderProvider);

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
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      bottomNavigationBar: CameraScreenBottomBarWidget(
        onImageCapture: () {},
      ),
      body: cameraController.maybeMap(
          orElse: () => const Text('Camera controller not initialized'),
          loading: (_) => const Center(
                  child: CupertinoActivityIndicator(
                color: ColorConstants.secondaryGreen,
              )),
          data: (controller) => CameraPreviewWidget(
              controller: controller.value, onImageCapture: () {})),
    );
  }
}
