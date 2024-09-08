import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/core/shared/logging_service.dart';
import 'package:rice_fertile_ai/infrastructure/land_conversion_service.dart';
import 'package:rice_fertile_ai/presentation/home/home_page.dart';
import 'package:rice_fertile_ai/presentation/result/result_page.dart';
import 'package:rice_fertile_ai/presentation/result/widgets/amount_of_land_text_form_field_widget.dart';

class LandInputPage extends ConsumerWidget {
  LandInputPage({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<LandConversionStrategy> conversionStrategies = [
      ref.read(acresConverterProvicer),
      ref.read(decimalsConverterProvicer),
      ref.read(shotokConverterProvicer),
      ref.read(kathaConverterProvicer),
      ref.read(bighaConverterProvicer),
    ];
    return Scaffold(
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
                      onSaved: (p0) {
                        logger.d('Amount of land: $p0');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButton<LandConversionStrategy>(
                      items: _getDropDownItems(conversionStrategies),
                      value: conversionStrategies[2],
                      onChanged: (selectedStrategy) {},
                      selectedItemBuilder: (context) {
                        return conversionStrategies
                            .map((e) => Text(e.unitId))
                            .toList();
                      },
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResultScreen(lccResult: 7),
                      ),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<LandConversionStrategy>> _getDropDownItems(
      List<LandConversionStrategy> conversionStrategies) {
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
