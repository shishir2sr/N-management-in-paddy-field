import 'package:flutter/material.dart';

class CircleWidget extends StatelessWidget {
  const CircleWidget({
    super.key,
    this.circleWidth = 100,
    this.isShadowEnabled = true,
    this.child = const SizedBox(),
  });

  final double circleWidth;
  final bool isShadowEnabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: isShadowEnabled
              ? Border.all(color: Colors.white)
              : Border.all(
                  color: Colors.grey.withOpacity(0.4),
                  width: 1.5,
                ),
          boxShadow: isShadowEnabled
              ? [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 0))
                ]
              : [],
          shape: BoxShape.circle,
          color:
              isShadowEnabled ? Colors.green.withOpacity(0.2) : Colors.white),
      height: circleWidth,
      width: circleWidth,
      child: Center(child: child),
    );
  }
}
