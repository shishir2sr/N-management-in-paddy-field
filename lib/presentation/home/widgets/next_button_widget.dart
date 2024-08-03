import 'package:flutter/material.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';

class NextButtonWidget extends StatelessWidget {
  const NextButtonWidget({
    super.key,
    required this.onPressed,
  });

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: deviceWidth * 0.25,
        width: deviceWidth * 0.25,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade400,
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 1))
          ],
          shape: BoxShape.circle,
          gradient: ColorConstants.appGradient,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: const Center(
          child: Text(
            "Next",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
