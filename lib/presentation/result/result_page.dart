import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/application/result_notifier_provider.dart';
import 'package:rice_fertile_ai/presentation/home/home_page.dart';
import 'package:rice_fertile_ai/presentation/result/widgets/result_widget.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ResultWidget(
            resultText: recommendation,
          ),
        ),
      ),
    );
  }
}
