// ignore_for_file: depend_on_referenced_packages

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/application/result_notifier_provider.dart';
import 'package:rice_fertile_ai/infrastructure/land_conversion_service.dart';

class LandConversionSelectionWidget extends ConsumerWidget {
  final List<DropdownMenuItem<LandConversionStrategy>> dropdownItemList;
  const LandConversionSelectionWidget(
      {required this.dropdownItemList, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultNotifier = ref.read(resultNotifierProvider.notifier);
    final resultState = ref.watch(resultNotifierProvider);

    return DropdownButtonFormField2<LandConversionStrategy>(
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.green,
            width: 2,
          ),
        ),
        // Add more decoration..
      ),
      value: resultState.selectedStrategy,
      items: dropdownItemList,
      onChanged: (value) {
        resultNotifier.setSelectedStrategy(value!);
      },
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 8),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
