import 'package:flutter/material.dart';
import 'package:LCC/core/shared/color_constants.dart';
import 'package:LCC/presentation/home/widgets/bottom_navbar_widget.dart';

class CameraScreenBottomBarWidget extends StatelessWidget {
  const CameraScreenBottomBarWidget({
    super.key,
    required this.onImageCapture,
    this.iconColor = ColorConstants.primaryGreen,
  });

  final Function() onImageCapture;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: const Color.fromARGB(130, 0, 0, 0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: CaptureImageButton(
          iconColor: iconColor,
          selectFromCamera: onImageCapture,
        ),
      ),
    );
  }
}
