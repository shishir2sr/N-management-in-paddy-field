import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/application/image_processror_notifier_provider.dart';
import 'package:rice_fertile_ai/core/shared/logging_service.dart';
import 'package:rice_fertile_ai/infrastructure/land_conversion_service.dart';
part 'result_notifier_provider.freezed.dart';

@freezed
class ResultState with _$ResultState {
  const ResultState._();
  factory ResultState({
    required double landAmountInBigha,
    required LandConversionStrategy selectedStrategy,
    required String recommendation,
  }) = _ResultState;

  factory ResultState.initial(LandConversionStrategy strategy) => ResultState(
        landAmountInBigha: 0.0,
        selectedStrategy: strategy,
        recommendation: "No recommendation yet",
      );
}

class ResultStateNotifier extends Notifier<ResultState> {
  @override
  ResultState build() {
    final acresConverter = ref.read(acresConverterProvicer);
    return ResultState.initial(acresConverter);
  }

  void setSelectedStrategy(LandConversionStrategy strategy) {
    state = state.copyWith(selectedStrategy: strategy);
  }

  void calculateNitrogenRequirement({required double landAmount}) {
    // set the land amount in bigha
    _convertToBigha(landAmount);
    logger.i('Calculating nitrogen requirement');
    final resultList = ref.watch(imageProcessorProvider).value?.lccResult;
    final average = _getResultAverage(resultList!);
    logger.d('Average LCC: $average');
    final recommendation = _getRecommendation(averageLcc: average);
    state = state.copyWith(recommendation: recommendation);
    logger.i('Recommendation: $recommendation');
  }

  // convert the land amount to bigha
  void _convertToBigha(double amount) {
    logger.i('Converting to $amount ${state.selectedStrategy}');
    final landInBigha = state.selectedStrategy.convertToBigha(amount);
    logger.d('Converted to $landInBigha Bigha');
    state = state.copyWith(landAmountInBigha: landInBigha);
  }

  // get the recommendation based on the average LCC
  String _getRecommendation({required double averageLcc}) {
    if (averageLcc <= 3.5) {
      double ureaRequired = state.landAmountInBigha * 0.227273;
      return "Recommended Urea: ${ureaRequired.toStringAsFixed(2)} kg";
    } else {
      return "Good nitrogen level! \n try again in 10 days later";
    }
  }

  // get the average of the list
  double _getResultAverage(List<int> resultList) {
    return resultList.reduce((value, element) => value + element) /
        resultList.length;
  }
}

// resultNotifierProvider is a provider that returns a ResultStateNotifier
final resultNotifierProvider =
    NotifierProvider<ResultStateNotifier, ResultState>(ResultStateNotifier.new);
