import 'package:flutter/material.dart';
import 'package:rice_fertile_ai/core/presentation/Home/Widget/custom_svg_icon.dart';
import 'package:rice_fertile_ai/core/shared/string_constants.dart';

class LccIcons {
  /// Leaf Icon
  static Widget leafIcon = const CustomSvgIcon(
    assetPath: StringConstants.cameraIconPath,
    semanticsLabel: 'Leaf Icon',
    color: Colors.white,
  );
}
