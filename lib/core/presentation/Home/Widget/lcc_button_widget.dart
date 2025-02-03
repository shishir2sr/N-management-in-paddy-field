import 'package:flutter/material.dart';

typedef OnPressCallBackFunction = void Function();

class LccButtonWidget extends StatelessWidget {
  const LccButtonWidget(
      {super.key,
      required this.onPressFunction,
      required this.borderSide,
      required this.buttonColor,
      required this.buttonIcon});

  final OnPressCallBackFunction onPressFunction;

  final BorderSide borderSide;
  final Color buttonColor;
  final Widget buttonIcon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressFunction,
      style: ElevatedButton.styleFrom(
          side: borderSide,
          overlayColor: Colors.green,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(60, 60),
          maximumSize: const Size(80, 80),
          backgroundColor: buttonColor),
      child: buttonIcon,
    );
  }
}
