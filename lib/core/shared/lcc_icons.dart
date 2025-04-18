import 'package:flutter/material.dart';
import 'package:LCC/core/presentation/Home/Widget/custom_svg_icon.dart';
import 'package:LCC/core/shared/string_constants.dart';

class LccIcons {
  /// Leaf Icon
  static Widget leafIcon = const CustomSvgIcon(
    assetPath: StrConsts.cameraIconPath,
    semanticsLabel: 'Leaf Icon',
    color: Colors.white,
  );
}
