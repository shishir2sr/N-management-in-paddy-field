import 'package:flutter/material.dart';

class CameraScreenIconButton extends StatelessWidget {
  const CameraScreenIconButton({
    super.key,
    required this.icon,
    this.iconColor,
    required this.onPressed,
  });

  final IconData icon;
  final Color? iconColor;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all(const Size(60, 60)),
        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: iconColor ?? Colors.black,
        size: 35,
      ),
    );
  }
}
