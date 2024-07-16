import 'package:flutter/material.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/bottom_navbar_widget.dart';

class ImageSelectionPlaceholderWidget extends StatelessWidget {
  const ImageSelectionPlaceholderWidget({
    super.key,
    required this.onSelectImage,
    required this.onRetakeImage,
  });
  final Function() onSelectImage;
  final Function() onRetakeImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SecondaryLccButtonWidget(
          onPressed: onSelectImage,
          icon: Icons.check,
        ),
        SecondaryLccButtonWidget(
          onPressed: onRetakeImage,
          icon: Icons.close,
          iconColor: Colors.red,
        ),
        // Retake Button
      ],
    );
  }
}
