import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:LCC/application/image_processror_notifier_provider.dart';
import 'package:LCC/application/result_notifier_provider.dart';
import 'package:LCC/infrastructure/land_conversion_service.dart';

/// Exercises the recommendation logic end to end through the notifier.
///
/// Hive and notifications are both unavailable in a plain test binding; both
/// call sites swallow their failures deliberately, so a calculation still
/// completes — which is itself the behaviour being asserted (losing a history
/// row must not lose the recommendation).
void main() {
  ProviderContainer makeContainer({List<int> readings = const []}) {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    for (final reading in readings) {
      container.read(imageProcessorProvider.notifier).addResult(reading);
    }
    return container;
  }

  group('calculateNitrogenRequirement', () {
    test('refuses to calculate with no readings', () async {
      final container = makeContainer();
      final notifier = container.read(resultNotifierProvider.notifier);

      final outcome =
          await notifier.calculateNitrogenRequirement(landAmount: 1);

      // Previously this path did `resultList!` and then `reduce` on an empty
      // list — a null-check crash or `StateError: No element`.
      expect(outcome, CalculationOutcome.noReadings);
      expect(container.read(resultNotifierProvider).recommendation,
          'No recommendation yet');
    });

    test('rejects non-positive and non-finite land amounts', () async {
      final container = makeContainer(readings: [3, 3, 3]);
      final notifier = container.read(resultNotifierProvider.notifier);

      for (final amount in [0.0, -1.0, double.nan, double.infinity]) {
        expect(
          await notifier.calculateNitrogenRequirement(landAmount: amount),
          CalculationOutcome.invalidAmount,
          reason: 'landAmount=$amount',
        );
      }
    });

    test('recommends urea when the average LCC is at or below 3.5', () async {
      final container = makeContainer(readings: [3, 3, 4, 4]); // average 3.5
      final notifier = container.read(resultNotifierProvider.notifier);
      notifier.setSelectedStrategy(const BighaConversion());

      final outcome =
          await notifier.calculateNitrogenRequirement(landAmount: 10);
      final state = container.read(resultNotifierProvider);

      expect(outcome, CalculationOutcome.success);
      expect(state.averageLcc, 3.5);
      expect(state.landAmountInBigha, 10);
      expect(state.ureaNeeded, closeTo(10 * 0.227273, 1e-9));
      expect(state.recommendation, contains('Urea'));
      expect(state.recommendation, contains('2.27 kg'));
    });

    test('reports a healthy crop when the average LCC is above 3.5', () async {
      final container = makeContainer(readings: [4, 4, 5, 5]); // average 4.5
      final notifier = container.read(resultNotifierProvider.notifier);
      notifier.setSelectedStrategy(const BighaConversion());

      final outcome =
          await notifier.calculateNitrogenRequirement(landAmount: 10);
      final state = container.read(resultNotifierProvider);

      expect(outcome, CalculationOutcome.success);
      expect(state.averageLcc, 4.5);
      expect(state.ureaNeeded, 0.0);
      expect(state.recommendation, 'Good nitrogen level!');
    });

    test('applies the selected unit conversion', () async {
      final container = makeContainer(readings: [2]);
      final notifier = container.read(resultNotifierProvider.notifier);
      notifier.setSelectedStrategy(const ShotokConversion());

      await notifier.calculateNitrogenRequirement(landAmount: 33);

      expect(container.read(resultNotifierProvider).landAmountInBigha,
          closeTo(1.0, 1e-12));
    });

    test('a single reading averages to itself', () async {
      final container = makeContainer(readings: [2]);
      final notifier = container.read(resultNotifierProvider.notifier);

      await notifier.calculateNitrogenRequirement(landAmount: 1);

      expect(container.read(resultNotifierProvider).averageLcc, 2.0);
    });

    test('removing a reading does not reset the recommendation', () async {
      final container = makeContainer(readings: [2, 2, 3]);
      final notifier = container.read(resultNotifierProvider.notifier);
      notifier.setSelectedStrategy(const BighaConversion());

      await notifier.calculateNitrogenRequirement(landAmount: 5);
      final before = container.read(resultNotifierProvider);

      // The notifier used to `ref.watch` imageProcessorProvider from inside
      // this method, which registered a permanent dependency: any change to the
      // readings re-ran build() and silently wiped the land amount and
      // recommendation the user had just produced.
      container.read(imageProcessorProvider.notifier).removeImage(0);

      final after = container.read(resultNotifierProvider);
      expect(after.recommendation, before.recommendation);
      expect(after.landAmountInBigha, before.landAmountInBigha);
      expect(after.ureaNeeded, before.ureaNeeded);
    });
  });

  group('ImageProcessorNotifier', () {
    test('tracks remaining readings and completion', () {
      final container = makeContainer();
      final notifier = container.read(imageProcessorProvider.notifier);

      expect(container.read(imageProcessorProvider).value!.remaining,
          kRequiredReadings);

      for (var i = 0; i < kRequiredReadings; i++) {
        notifier.addResult(3);
      }

      final state = container.read(imageProcessorProvider).value!;
      expect(state.lccResult.length, kRequiredReadings);
      expect(state.remaining, 0);
      expect(state.isComplete, isTrue);
    });

    test('ignores readings once complete', () {
      final container = makeContainer(
        readings: List.filled(kRequiredReadings, 4),
      );
      container.read(imageProcessorProvider.notifier).addResult(5);

      expect(container.read(imageProcessorProvider).value!.lccResult.length,
          kRequiredReadings);
    });

    test('ignores an out-of-range removal instead of throwing', () {
      final container = makeContainer(readings: [3, 4]);
      final notifier = container.read(imageProcessorProvider.notifier);

      notifier.removeImage(7);
      notifier.removeImage(-1);

      expect(container.read(imageProcessorProvider).value!.lccResult, [3, 4]);
    });

    test('resetPrediction clears every reading', () {
      final container = makeContainer(readings: [3, 4, 5]);
      container.read(imageProcessorProvider.notifier).resetPrediction();

      expect(container.read(imageProcessorProvider).value!.lccResult, isEmpty);
    });
  });
}
