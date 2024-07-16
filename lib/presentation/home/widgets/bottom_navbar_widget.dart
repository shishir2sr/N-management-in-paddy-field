import 'package:flutter/material.dart';
import 'package:rice_fertile_ai/core/presentation/Home/Widget/lcc_button_widget.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';
import 'package:rice_fertile_ai/core/shared/lcc_icons.dart';

class BottomNavBar extends StatelessWidget {
  final OnPressCallBackFunction selectFromCamera;
  final OnPressCallBackFunction selectFromGallery;
  final OnPressCallBackFunction restartProgress;
  const BottomNavBar({
    required this.selectFromCamera,
    super.key,
    required this.selectFromGallery,
    required this.restartProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.8),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
        color: ColorConstants.primaryBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SecondaryLccButtonWidget(
              onPressed: selectFromGallery, icon: Icons.photo_library_outlined),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CaptureImageButton(selectFromCamera: selectFromCamera),
          ),
          SecondaryLccButtonWidget(
            onPressed: restartProgress,
            icon: Icons.restart_alt_outlined,
          ),
        ],
      ),
    );
  }
}

class SecondaryLccButtonWidget extends StatelessWidget {
  const SecondaryLccButtonWidget({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconColor = ColorConstants.primaryGreen,
  });
  final IconData icon;

  final OnPressCallBackFunction onPressed;

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return LccButtonWidget(
      onPressFunction: onPressed,
      buttonColor: ColorConstants.secondaryBackgroundColor,
      buttonIcon: Icon(
        icon,
        color: iconColor.withOpacity(0.8),
        size: 26,
        weight: FontWeight.bold.value.toDouble(),
      ),
      borderSide:
          const BorderSide(color: ColorConstants.secondaryBackgroundColor),
    );
  }
}

class CaptureImageButton extends StatelessWidget {
  const CaptureImageButton({
    super.key,
    required this.selectFromCamera,
    this.iconColor = ColorConstants.primaryGreen,
  });

  final OnPressCallBackFunction selectFromCamera;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return LccButtonWidget(
      onPressFunction: selectFromCamera,
      buttonColor: iconColor,
      buttonIcon: LccIcons.leafIcon,
      borderSide: const BorderSide(
          width: 0.70, color: ColorConstants.secondaryGreen, strokeAlign: 15),
    );
  }
}
