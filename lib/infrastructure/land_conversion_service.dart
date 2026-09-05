import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Converts a land area into bigha, the unit the urea formula expects.
///
/// `unitId` used to be an instance *field* defaulting to `"Hectares"` — which
/// is not even one of the offered units. Every subclass shadowed it with a
/// getter, which only compiled because they use `implements` rather than
/// `extends`, so the default was unreachable dead code. It is now an abstract
/// getter, so a new unit cannot forget to declare its name.
abstract class LandConversionStrategy {
  const LandConversionStrategy();

  String get unitId;

  double convertToBigha(double amount);
}

/// 1 bigha = 33 shotok (decimals). Ratios are derived rather than written as
/// pre-rounded decimals: the old constants (`0.03` for 1/33, `0.05` for 1/20)
/// carried up to ~1% error straight into the urea dosage.
const double _shotokPerBigha = 33.0;
const double _shotokPerAcre = 100.0;
const double _shotokPerKatha = 1.65;

class AcresConversion extends LandConversionStrategy {
  const AcresConversion();

  @override
  String get unitId => "Acres";

  @override
  double convertToBigha(double amount) =>
      amount * (_shotokPerAcre / _shotokPerBigha);
}

class DecimalsConversion extends LandConversionStrategy {
  const DecimalsConversion();

  @override
  String get unitId => "Decimals";

  /// 1 decimal == 1 shotok.
  @override
  double convertToBigha(double amount) => amount / _shotokPerBigha;
}

class ShotokConversion extends LandConversionStrategy {
  const ShotokConversion();

  @override
  String get unitId => "Shotok";

  @override
  double convertToBigha(double amount) => amount / _shotokPerBigha;
}

class KathaConversion extends LandConversionStrategy {
  const KathaConversion();

  @override
  String get unitId => "Katha";

  @override
  double convertToBigha(double amount) =>
      amount * (_shotokPerKatha / _shotokPerBigha);
}

class BighaConversion extends LandConversionStrategy {
  const BighaConversion();

  @override
  String get unitId => "Bigha";

  @override
  double convertToBigha(double amount) => amount;
}

// ? *** *** *** Providers for the conversion strategy *** *** ***
final acresConverterProvicer =
    Provider<LandConversionStrategy>((ref) => const AcresConversion());
final decimalsConverterProvicer =
    Provider<LandConversionStrategy>((ref) => const DecimalsConversion());
final shotokConverterProvicer =
    Provider<LandConversionStrategy>((ref) => const ShotokConversion());
final kathaConverterProvicer =
    Provider<LandConversionStrategy>((ref) => const KathaConversion());
final bighaConverterProvicer =
    Provider<LandConversionStrategy>((ref) => const BighaConversion());
