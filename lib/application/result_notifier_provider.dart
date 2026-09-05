import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:LCC/Utils/result_details_model.dart';
import 'package:LCC/application/image_processror_notifier_provider.dart';
import 'package:LCC/core/shared/hive_boxes.dart';
import 'package:LCC/core/shared/logging_service.dart';
import 'package:LCC/core/shared/notification_service.dart';
import 'package:LCC/infrastructure/land_conversion_service.dart';

part 'result_notifier_provider.freezed.dart';

@freezed
class ResultState with _$ResultState {
  const ResultState._();
  factory ResultState({
    required double landAmountInBigha,
    required LandConversionStrategy selectedStrategy,
    required String recommendation,
    required double averageLcc,
    required double ureaNeeded,
  }) = _ResultState;

  factory ResultState.initial(LandConversionStrategy strategy) => ResultState(
        landAmountInBigha: 0.0,
        selectedStrategy: strategy,
        recommendation: "No recommendation yet",
        averageLcc: 0.0,
        ureaNeeded: 0.0,
      );
}

/// Outcome of a calculation attempt, so the UI knows whether to navigate.
enum CalculationOutcome { success, noReadings, invalidAmount }

class ResultStateNotifier extends Notifier<ResultState> {
  @override
  ResultState build() {
    // `ref.read`, not `ref.watch` — see calculateNitrogenRequirement.
    return ResultState.initial(ref.read(acresConverterProvicer));
  }

  void setSelectedStrategy(LandConversionStrategy strategy) {
    state = state.copyWith(selectedStrategy: strategy);
  }

  Future<CalculationOutcome> calculateNitrogenRequirement({
    required double landAmount,
  }) async {
    if (!landAmount.isFinite || landAmount <= 0) {
      return CalculationOutcome.invalidAmount;
    }

    // `ref.read`, not `ref.watch`. Watching here registered a permanent
    // dependency from a method, so deleting a captured reading re-ran `build()`
    // and silently reset the land amount and recommendation the user had just
    // produced.
    final readings =
        ref.read(imageProcessorProvider).value?.lccResult ?? const <int>[];

    if (readings.isEmpty) {
      logger.w('Cannot calculate a recommendation with no readings');
      return CalculationOutcome.noReadings;
    }

    final landInBigha = state.selectedStrategy.convertToBigha(landAmount);
    final average = _average(readings);
    final ureaRequired = _ureaRequired(
      averageLcc: average,
      landAmountInBigha: landInBigha,
    );

    final recommendation = ureaRequired <= 0
        ? "Good nitrogen level!"
        : "Recommended\nUrea:\n${ureaRequired.toStringAsFixed(2)} kg";

    // One state write for the whole calculation — the old code emitted the
    // recommendation twice and the land amount separately, producing three
    // rebuilds of the result screen.
    state = state.copyWith(
      landAmountInBigha: landInBigha,
      recommendation: recommendation,
      averageLcc: average,
      ureaNeeded: ureaRequired,
    );
    logger.i('Average LCC $average -> $recommendation');

    final resultData = ResultStateDetails(
      landAmountInBigha: landInBigha,
      recommendation: recommendation,
      date: DateTime.now(),
      ureaNeeded: ureaRequired,
      averageLLC: average,
    );

    await _saveResultHistory(resultData);
    await _scheduleReminder();

    return CalculationOutcome.success;
  }

  Future<void> _saveResultHistory(ResultStateDetails resultData) async {
    try {
      final box = Hive.box<ResultStateDetails>(HiveBoxes.resultState);
      await box.add(resultData);
      logger.i('Saved result to history');
    } catch (e, st) {
      // Losing a history row must not take down the recommendation the user
      // asked for.
      logger.e('Could not save result history', error: e, stackTrace: st);
    }
  }

  Future<void> _scheduleReminder() async {
    // This used to be `void ... async`, called unawaited, with no try/catch —
    // so the LateInitializationError from an uninitialised timezone database
    // escaped as an unhandled async error and the reminder silently never
    // worked.
    try {
      await NotificationService.instance.scheduleReminder(
        id: 0,
        title: 'Nitrogen Requirement Calculated',
        body: 'Check the latest nitrogen requirement details.',
        when: tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
      );
    } catch (e, st) {
      logger.e('Could not schedule the reminder', error: e, stackTrace: st);
    }
  }

  double _ureaRequired({
    required double averageLcc,
    required double landAmountInBigha,
  }) {
    if (averageLcc > 3.5) return 0.0;
    return landAmountInBigha * 0.227273;
  }

  /// `fold`, not `reduce`: `reduce` throws `StateError: No element` on an empty
  /// list, and the division would have produced NaN.
  double _average(List<int> readings) {
    if (readings.isEmpty) return 0.0;
    final total = readings.fold<int>(0, (sum, value) => sum + value);
    return total / readings.length;
  }
}

// resultNotifierProvider is a provider that returns a ResultStateNotifier
final resultNotifierProvider =
    NotifierProvider<ResultStateNotifier, ResultState>(ResultStateNotifier.new);
