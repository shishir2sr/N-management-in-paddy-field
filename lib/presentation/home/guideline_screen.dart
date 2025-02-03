import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rice_fertile_ai/Utils/app_fonts.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';

class GuidelineScreen extends StatelessWidget {
  const GuidelineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guidelines',
          style: TextStyle(
            fontFamily: AppFonts.MANROPE,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: ColorConstants.primaryGreen,
      ),
      body: const Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please follow these guidelines:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.MANROPE,
              ),
            ),
            SizedBox(height: 10),
            BulletPoint(text: 'Ensure good lighting when capturing images.'),
            BulletPoint(text: 'Focus on capturing the entire rice plant.'),
            BulletPoint(text: 'Avoid blurry or out-of-focus images.'),
            BulletPoint(text: 'Capture images from a top-down angle.'),
            BulletPoint(
                text: 'Make sure the background is clear and not cluttered.'),
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(fontSize: 16)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: AppFonts.MANROPE,
            ),
          ),
        ),
      ],
    );
  }
}
