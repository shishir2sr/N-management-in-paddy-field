import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({
    super.key,
    required this.controller,
  });

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    // The preview used to sit in a SingleChildScrollView + Column, which gave
    // it unbounded height and let it overflow or scroll. `aspectRatio` from the
    // controller is width/height in the sensor's natural (landscape)
    // orientation, so it is inverted here for the portrait-locked UI.
    return Center(
      child: AspectRatio(
        aspectRatio: 1 / controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }
}
