import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:LCC/Utils/app_fonts.dart';

import 'package:LCC/core/shared/color_constants.dart';

/// Accepts digits and at most one `.`, rejecting everything else at the input
/// layer. `keyboardType` alone is only a hint — a hardware keyboard, a paste,
/// or a locale that uses `,` as the decimal separator all get through it, and
/// the old unguarded `num.parse` then threw `FormatException`.
final _decimalFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'^\d*\.?\d*'),
);

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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [_decimalFormatter],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter amount of land!';
        }
        final amount = double.tryParse(value.trim());
        if (amount == null) {
          return 'Enter a number, for example 1.5';
        }
        if (amount <= 0) {
          return 'Amount of land must be greater than zero';
        }
        return null;
      },
    );
  }
}
