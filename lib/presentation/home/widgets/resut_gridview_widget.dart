import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/application/image_processror_notifier_provider.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';

class ResultGridViewWidget extends ConsumerWidget {
  const ResultGridViewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final lccResult = ref.watch(imageProcessorProvider).value?.lccResult;
    var listContentWidth = (deviceWidth - 60) / 10;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          lccResult?.length ?? 0,
          (index) => Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              width: 50,
              decoration: BoxDecoration(
                gradient: ColorConstants.appGradient,
                borderRadius: BorderRadius.circular(listContentWidth / 2),
              ),
              child: Center(
                child: Text(
                  '${lccResult?[index]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
