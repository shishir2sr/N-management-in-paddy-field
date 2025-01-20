import 'package:flutter/material.dart';

import 'package:rice_fertile_ai/core/shared/color_constants.dart';

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
          fontSize: 12.0,
          letterSpacing: 2,
        ),
        labelText: "Amount of Land *",
        helperMaxLines: 2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide(
            color: ColorConstants.secondaryGreen,
            style: BorderStyle.solid,
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
