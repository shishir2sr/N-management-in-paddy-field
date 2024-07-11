import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/camera_screen_bottom_bar_widget.dart';

class CameraPreviewWidget extends ConsumerWidget {
  const CameraPreviewWidget({
    super.key,
    required this.controller,
    required this.onImageCapture,
  });
  final CameraController controller;
  final Function() onImageCapture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Column(
        children: [
          Expanded(
            flex: 7,
            child: CameraPreview(controller),
          ),
          Flexible(
            flex: 2,
            child: Center(
              child: CameraScreenBottomBarWidget(
                onImageCapture: onImageCapture,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
