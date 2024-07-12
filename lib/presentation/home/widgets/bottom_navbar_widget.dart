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
          LccButtonWidget(
            onPressFunction: selectFromGallery,
            buttonColor: ColorConstants.secondaryBackgroundColor,
            buttonIcon: Icon(
              Icons.photo_library_outlined,
              color: ColorConstants.primaryGreen.withOpacity(0.8),
              size: 26,
              weight: FontWeight.bold.value.toDouble(),
            ),
            borderSide: const BorderSide(
                color: ColorConstants.secondaryBackgroundColor),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CaptureImageButton(selectFromCamera: selectFromCamera),
          ),
          LccButtonWidget(
            onPressFunction: restartProgress,
            buttonColor: ColorConstants.secondaryBackgroundColor,
            buttonIcon: Icon(
              Icons.restart_alt_outlined,
              color: ColorConstants.primaryGreen.withOpacity(0.8),
              size: 30,
              weight: FontWeight.bold.value.toDouble(),
            ),
            borderSide: const BorderSide(
                color: ColorConstants.secondaryBackgroundColor),
          ),
        ],
      ),
    );
  }
}

class CaptureImageButton extends StatelessWidget {
  const CaptureImageButton({
    super.key,
    required this.selectFromCamera,
  });

  final OnPressCallBackFunction selectFromCamera;

  @override
  Widget build(BuildContext context) {
    return LccButtonWidget(
      onPressFunction: selectFromCamera,
      buttonColor: ColorConstants.primaryGreen,
      buttonIcon: LccIcons.leafIcon,
      borderSide: const BorderSide(
          width: 0.70, color: ColorConstants.secondaryGreen, strokeAlign: 15),
    );
  }
}
