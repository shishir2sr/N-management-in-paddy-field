import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSvgIcon extends StatelessWidget {
  final String assetPath;
  final double height;
  final double width;
  final Color? color;
  final String? semanticsLabel;

  const CustomSvgIcon({
    super.key,
    required this.assetPath,
    this.height = 28.0,
    this.width = 28.0,
    this.color,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      height: height,
      width: width,
      semanticsLabel: semanticsLabel,
      colorFilter: ColorFilter.mode(color ?? Colors.black, BlendMode.srcIn),
    );
  }
}
