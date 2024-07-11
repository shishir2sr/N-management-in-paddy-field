import 'package:flutter/material.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/camera_screen_icon_button.dart';

class CameraScreenBottomBarWidget extends StatelessWidget {
  const CameraScreenBottomBarWidget({
    super.key,
    required this.onImageCapture,
  });

  final Function() onImageCapture;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: const Color.fromARGB(130, 0, 0, 0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CameraScreenIconButton(
              icon: Icons.camera_alt_rounded,
              onPressed: onImageCapture,
            ),
          ],
        ),
      ),
    );
  }
}
