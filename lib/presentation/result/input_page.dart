import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/application/result_notifier_provider.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';
import 'package:rice_fertile_ai/core/shared/logging_service.dart';
import 'package:rice_fertile_ai/infrastructure/land_conversion_service.dart';
import 'package:rice_fertile_ai/presentation/home/home_page.dart';
import 'package:rice_fertile_ai/presentation/result/result_page.dart';
import 'package:rice_fertile_ai/presentation/result/widgets/amount_of_land_text_form_field_widget.dart';
import 'package:rice_fertile_ai/presentation/result/widgets/land_conversion_selection_widget.dart';

class LandInputPage extends ConsumerWidget {
  LandInputPage({super.key})
      : landInputTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController landInputTextEditingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultNotifier = ref.read(resultNotifierProvider.notifier);

    final List<LandConversionStrategy> conversionStrategies = [
      ref.read(bighaConverterProvicer),
      ref.read(acresConverterProvicer),
      ref.read(decimalsConverterProvicer),
      ref.read(shotokConverterProvicer),
      ref.read(kathaConverterProvicer),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getAppBar(title: "Land Input"),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 4,
                    child: AmountOfLandTextFormField(
                      controller: landInputTextEditingController,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: LandConversionSelectionWidget(
                      dropdownItemList: _getDropDownItems(conversionStrategies),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: ColorConstants.primaryGreen,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    logger.d(
                        "Land Input Page: ${landInputTextEditingController.text}");
                    final landAmount =
                        num.parse(landInputTextEditingController.text)
                            .toDouble();
                    resultNotifier.calculateNitrogenRequirement(
                        landAmount: landAmount);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResultScreen(),
                      ),
                    );
                  }
                },
                child: const Text('Get Recommendation'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<LandConversionStrategy>> _getDropDownItems(
    List<LandConversionStrategy> conversionStrategies,
  ) {
    return conversionStrategies
        .map(
          (e) => DropdownMenuItem<LandConversionStrategy>(
            value: e,
            child: Text(e.unitId),
          ),
        )
        .toList();
  }
}
