import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class LandConversionStrategy {
  final String unitId = "Hectares";
  double convertToBigha(double amount);
}

class AcresConversion implements LandConversionStrategy {
  @override
  double convertToBigha(double amount) {
    // 1 acre  = 100 shotok
    // 1 bigha  = 33 shotok
    // 1 acre to bigha = 100/33 = 3.03
    return amount * 3.03;
  }

  @override
  String get unitId => "Acres";
}

class DecimalsConversion implements LandConversionStrategy {
  @override
  double convertToBigha(double amount) {
    // 1 decimal = 1 shotok
    // 1 bigha  = 33 shotok
    // 1 decimal to bigha = 1/33 = 0.03
    return amount * 0.03;
  }

  @override
  String get unitId => "Decimals";
}

class ShotoklsConversion implements LandConversionStrategy {
  @override
  double convertToBigha(double amount) {
    // 1 bigha  = 33 shotok
    // 1 shotok to bigha = 1/33 = 0.03
    return amount * 0.03;
  }

  @override
  String get unitId => "Shotok";
}

class KathaConversion implements LandConversionStrategy {
  @override
  double convertToBigha(double amount) {
    // 1 katha = 1.65 shotok
    // 1 bigha  = 33 shotok
    // 1 katha to bigha = 1.65/33 = 0.05
    return amount * 0.05;
  }

  @override
  String get unitId => "Katha";
}

class BighaConversion implements LandConversionStrategy {
  @override
  double convertToBigha(double amount) {
    return amount;
  }

  @override
  String get unitId => "Bigha";
}

// ? *** *** *** Providers for the conversion strategy *** *** ***
final acresConverterProvicer =
    Provider<LandConversionStrategy>((ref) => AcresConversion());
final decimalsConverterProvicer =
    Provider<LandConversionStrategy>((ref) => DecimalsConversion());
final shotokConverterProvicer =
    Provider<LandConversionStrategy>((ref) => ShotoklsConversion());
final kathaConverterProvicer =
    Provider<LandConversionStrategy>((ref) => KathaConversion());
final bighaConverterProvicer =
    Provider<LandConversionStrategy>((ref) => BighaConversion());
