import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:LCC/Utils/app_fonts.dart';
import 'package:LCC/application/result_notifier_provider.dart';
import 'package:LCC/core/shared/color_constants.dart';
import 'package:LCC/core/shared/logging_service.dart';
import 'package:LCC/infrastructure/land_conversion_service.dart';
import 'package:LCC/presentation/home/home_page.dart';
import 'package:LCC/presentation/result/result_page.dart';
import 'package:LCC/presentation/result/widgets/amount_of_land_text_form_field_widget.dart';
import 'package:LCC/presentation/result/widgets/land_conversion_selection_widget.dart';

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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: getAppBar(title: "Land Input"),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // add a image widget here to show the land image
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset('assets/images/paddy.png'),
                ),
                const SizedBox(
                  height: 20,
                ),

                AmountOfLandTextFormField(
                  controller: landInputTextEditingController,
                ),
                const SizedBox(height: 20),
                LandConversionSelectionWidget(
                  dropdownItemList: _getDropDownItems(conversionStrategies),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: ColorConstants.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
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
                  child: const Text('Get Recommendation',
                      style: TextStyle(
                          fontFamily: AppFonts.MANROPE,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
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
