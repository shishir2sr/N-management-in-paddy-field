import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/core/shared/logging_service.dart';
import 'package:rice_fertile_ai/infrastructure/land_conversion_service.dart';
part 'result_notifier_provider.freezed.dart';

@freezed
class ResultState with _$ResultState {
  const ResultState._({
    final List<LandConversionStrategy> conversionStrategies = const [],
  });
  const factory ResultState() = _ResultState;
}

class ResultStateNotifier extends StateNotifier<ResultState> {
  ResultStateNotifier() : super(const ResultState());
  double convertToBigha(LandConversionStrategy converter, double amount) {
    logger.i('Converting to $amount Bigha');
    return converter.convertToBigha(amount);
  }
}
