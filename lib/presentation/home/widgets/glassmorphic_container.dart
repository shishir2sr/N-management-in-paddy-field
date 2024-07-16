import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Color color; // Add color parameter

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.color = const Color(0xFFFFFFFF), // Default color is white with opacity
  });

  @override
  Widget build(BuildContext context) {
    // Determine if the color is light or dark
    bool isLightColor = color.computeLuminance() > 0.5;

    // Adjust the opacity based on the color brightness
    double backgroundOpacity =
        isLightColor ? 0.2 : 0.2; // Less opacity for dark colors
    double borderOpacity =
        isLightColor ? 0.2 : 0.2; // More opacity for dark borders

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        child: BackdropFilter(
          filter:
              ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Increased blur
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(backgroundOpacity), // Adjusted opacity
              border: Border.all(
                color: Colors.white
                    .withOpacity(borderOpacity), // Adjusted opacity for border
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
