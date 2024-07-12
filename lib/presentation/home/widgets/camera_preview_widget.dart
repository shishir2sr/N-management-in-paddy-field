import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CameraPreviewWidget extends ConsumerWidget {
  const CameraPreviewWidget({
    super.key,
    required this.controller,
    required this.onImageCapture,
  });
  final CameraController? controller;
  final Function() onImageCapture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (controller != null)
            Expanded(
              flex: 7,
              child: Center(
                child: CameraPreview(controller!),
              ),
            ),
        ],
      ),
    );
  }
}
