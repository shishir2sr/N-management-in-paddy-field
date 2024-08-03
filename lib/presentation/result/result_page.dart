import 'package:flutter/material.dart';
import 'package:rice_fertile_ai/presentation/result/widgets/amount_of_land_text_form_field_widget.dart';
import 'package:rice_fertile_ai/presentation/result/widgets/calculate_button_widget.dart';
import 'package:rice_fertile_ai/presentation/result/widgets/result_widget.dart';

// ignore: must_be_immutable
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.lccResult});
  final double lccResult;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _formKey = GlobalKey<FormState>();

  int amountOfLand = 0;

  String recommendation = "Enter amount of land and press Calculate";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Recommendation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Center(
                  child: AmountOfLandTextFormField(
                    onSaved: (amountOfLand) =>
                        this.amountOfLand = int.parse(amountOfLand ?? "0"),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ResultWidget(
                      resultText: recommendation,
                    ),
                    CalculateButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() {
                            recommendation = getRecommendation();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // calculate recommendation
  String getRecommendation() {
    if (widget.lccResult <= 3.5) {
      double ureaRequired = amountOfLand * 0.227273;
      return "Recommended Urea: ${ureaRequired.toStringAsFixed(2)} kg";
    } else {
      return "Good nitrogen level! \n try again in 10 days later";
    }
  }
}
