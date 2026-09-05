import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:LCC/Utils/app_fonts.dart';
import 'package:LCC/application/result_notifier_provider.dart';
import 'package:LCC/core/shared/color_constants.dart';
import 'package:LCC/infrastructure/land_conversion_service.dart';
import 'package:LCC/presentation/home/home_page.dart';
import 'package:LCC/presentation/result/result_page.dart';
import 'package:LCC/presentation/result/widgets/amount_of_land_text_form_field_widget.dart';
import 'package:LCC/presentation/result/widgets/land_conversion_selection_widget.dart';

/// Was a `ConsumerWidget` that constructed a `TextEditingController` and a
/// `GlobalKey` in its constructor. Route builders can run more than once, so
/// each rebuild allocated a fresh controller that was never disposed, and two
/// live widgets could end up sharing one `GlobalKey`.
class LandInputPage extends ConsumerStatefulWidget {
  const LandInputPage({super.key});

  @override
  ConsumerState<LandInputPage> createState() => _LandInputPageState();
}

class _LandInputPageState extends ConsumerState<LandInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _landInputController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _landInputController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = double.tryParse(_landInputController.text.trim());
    if (amount == null) return;

    setState(() => _submitting = true);
    try {
      final outcome = await ref
          .read(resultNotifierProvider.notifier)
          .calculateNitrogenRequirement(landAmount: amount);

      if (!mounted) return;

      switch (outcome) {
        case CalculationOutcome.noReadings:
          showSnackBar(
            context,
            'Capture at least one leaf reading before getting a '
            'recommendation.',
          );
        case CalculationOutcome.invalidAmount:
          showSnackBar(context, 'Enter a land amount greater than zero.');
        case CalculationOutcome.success:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ResultScreen()),
          );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversionStrategies = <LandConversionStrategy>[
      ref.read(bighaConverterProvicer),
      ref.read(acresConverterProvicer),
      ref.read(decimalsConverterProvicer),
      ref.read(shotokConverterProvicer),
      ref.read(kathaConverterProvicer),
    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset('assets/images/paddy.png'),
                ),
                const SizedBox(height: 20),
                AmountOfLandTextFormField(controller: _landInputController),
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
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Get Recommendation',
                          style: TextStyle(
                            fontFamily: AppFonts.MANROPE,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 40),
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
