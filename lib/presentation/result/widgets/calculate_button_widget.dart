import 'package:flutter/material.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';

class CalculateButton extends StatelessWidget {
  const CalculateButton({
    super.key,
    this.onPressed,
  });
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 5,
        fixedSize: Size(deviceWidth * 0.7, 50),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))),
        backgroundColor: ColorConstants.secondaryGreen,
      ),
      child: const Text(
        "Calculate",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
