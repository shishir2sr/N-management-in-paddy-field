import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/CameraPreviewWidget.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage(
      {super.key, required this.controller, required this.onImageCapture});
  final CameraController controller;
  final Function() onImageCapture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: CameraPreviewWidget(
          controller: controller,
          onImageCapture: onImageCapture,
        ),
      ),
    );
  }
}
