import 'package:flutter_test/flutter_test.dart';

import 'package:LCC/infrastructure/land_conversion_service.dart';

/// 1 bigha = 33 shotok (decimals); 1 acre = 100 shotok; 1 katha = 1.65 shotok.
///
/// These ratios feed straight into the urea dosage, so the previous pre-rounded
/// constants (0.03 for 1/33, 0.05 for 1.65/33) carried up to ~1% error into
/// every recommendation.
void main() {
  group('LandConversionStrategy', () {
    test('bigha is the identity conversion', () {
      expect(const BighaConversion().convertToBigha(7.5), 7.5);
    });

    test('acres converts at 100/33', () {
      expect(
        const AcresConversion().convertToBigha(1),
        closeTo(100 / 33, 1e-12),
      );
      // The old constant was 3.03, which is short by ~0.1%.
      expect(const AcresConversion().convertToBigha(1), greaterThan(3.03));
    });

    test('decimals and shotok are the same unit', () {
      const decimals = DecimalsConversion();
      const shotok = ShotokConversion();
      for (final amount in [1.0, 33.0, 100.0]) {
        expect(
          decimals.convertToBigha(amount),
          shotok.convertToBigha(amount),
        );
      }
    });

    test('33 shotok is exactly one bigha', () {
      expect(const ShotokConversion().convertToBigha(33), closeTo(1.0, 1e-12));
    });

    test('katha converts at 1.65/33', () {
      expect(
        const KathaConversion().convertToBigha(1),
        closeTo(1.65 / 33, 1e-12),
      );
      // 20 katha == 33 shotok == 1 bigha.
      expect(const KathaConversion().convertToBigha(20), closeTo(1.0, 1e-12));
    });

    test('zero converts to zero for every unit', () {
      final strategies = <LandConversionStrategy>[
        const BighaConversion(),
        const AcresConversion(),
        const DecimalsConversion(),
        const ShotokConversion(),
        const KathaConversion(),
      ];
      for (final strategy in strategies) {
        expect(strategy.convertToBigha(0), 0, reason: strategy.unitId);
      }
    });

    test('every unit declares a distinct, non-empty name', () {
      final names = <LandConversionStrategy>[
        const BighaConversion(),
        const AcresConversion(),
        const DecimalsConversion(),
        const ShotokConversion(),
        const KathaConversion(),
      ].map((s) => s.unitId).toList();

      expect(names.every((n) => n.isNotEmpty), isTrue);
      expect(names.toSet().length, names.length);
      // The abstract base used to default this field to "Hectares", which is
      // not a unit the app offers.
      expect(names, isNot(contains('Hectares')));
    });
  });
}
