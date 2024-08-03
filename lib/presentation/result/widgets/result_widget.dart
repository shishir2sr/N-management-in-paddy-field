import 'package:flutter/material.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';

import 'circle_widget.dart';

class ResultWidget extends StatelessWidget {
  const ResultWidget({
    super.key,
    required this.resultText,
  });

  final String resultText;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return CircleWidget(
      circleWidth: deviceWidth * 0.6,
      child: CircleWidget(
        circleWidth: (deviceWidth * 0.6) - 20,
        isShadowEnabled: false,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            resultText,
            textAlign: TextAlign.center,
            style: resultTextStyle,
          ),
        ),
      ),
    );
  }
}

TextStyle resultTextStyle = const TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: ColorConstants.primaryGreen,
  shadows: [
    Shadow(
      blurRadius: 2.0,
      color: Colors.grey,
      offset: Offset(0, 0),
    ),
  ],
);
