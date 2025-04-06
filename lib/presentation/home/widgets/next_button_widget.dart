// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:LCC/Utils/app_fonts.dart';
import 'package:LCC/core/shared/color_constants.dart';

class NextButtonWidget extends StatefulWidget {
  const NextButtonWidget({
    super.key,
    required this.onPressed,
  });

  final Function() onPressed;

  @override
  _NextButtonWidgetState createState() => _NextButtonWidgetState();
}

class _NextButtonWidgetState extends State<NextButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final buttonSize = deviceWidth * 0.3;

    return GestureDetector(
      onTap: widget.onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          ScaleTransition(
            scale: _animation,
            child: Container(
              height: buttonSize + 10,
              width: buttonSize + 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(
                    0.3), // Adjust the color and opacity of the pulsing effect
              ),
            ),
          ),
          Container(
            height: buttonSize,
            width: buttonSize,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
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
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.MANROPE,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
