import 'package:flutter/material.dart';
import 'package:LCC/Utils/app_fonts.dart';

import 'package:LCC/core/shared/color_constants.dart';

class AmountOfLandTextFormField extends StatelessWidget {
  const AmountOfLandTextFormField({
    super.key,
    this.onSaved,
    required this.controller,
  });
  final TextEditingController controller;
  final void Function(String?)? onSaved;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onSaved: onSaved,
      decoration: const InputDecoration(
        hintText: 'Enter amount of land',
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
          fontFamily: AppFonts.MANROPE,
        ),
        labelText: "Amount of Land *",
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontFamily: AppFonts.MANROPE,
        ),
        helperMaxLines: 2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide(
            color: ColorConstants.secondaryGreen,
            style: BorderStyle.solid,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide(
            color: ColorConstants.secondaryGreen,
            width: 2.0,
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter amount of land!';
        }
        return null;
      },
    );
  }
}
