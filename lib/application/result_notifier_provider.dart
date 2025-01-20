import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/core/shared/logging_service.dart';
import 'package:rice_fertile_ai/infrastructure/land_conversion_service.dart';
part 'result_notifier_provider.freezed.dart';

@freezed
class ResultState with _$ResultState {
  const ResultState._();
  factory ResultState({
    required double result,
    required LandConversionStrategy selectedStrategy,
  }) = _ResultState;
  factory ResultState.initial(LandConversionStrategy strategy) => ResultState(
        result: 0.0,
        selectedStrategy: strategy,
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

  void convertToBigha(LandConversionStrategy converter, double amount) {
    logger.i('Converting to $amount Bigha');
    state = state.copyWith(result: converter.convertToBigha(amount));
  }
}

final resultNotifierProvider =
    NotifierProvider<ResultStateNotifier, ResultState>(ResultStateNotifier.new);
