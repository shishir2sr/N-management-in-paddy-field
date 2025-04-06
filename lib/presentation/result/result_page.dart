import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:LCC/Utils/app_fonts.dart';
import 'package:LCC/application/result_notifier_provider.dart';
import 'package:LCC/core/shared/color_constants.dart';
import 'package:LCC/presentation/home/home_page.dart';
import 'package:LCC/presentation/result/widgets/result_widget.dart';

// ignore: must_be_immutable
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendation = ref.watch(resultNotifierProvider).recommendation;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: getAppBar(title: "Recommendation"),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: ResultWidget(
                resultText: recommendation,
              ),
            ),
            const Spacer(),
            Container(
              height: 60, // Set height
              decoration: BoxDecoration(
                color: ColorConstants.primaryGreen,
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(20), // Match container's borderRadius
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Center(
                  child: Text(
                    'Done',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: AppFonts.MANROPE),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
