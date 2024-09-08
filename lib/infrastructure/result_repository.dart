import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/infrastructure/land_conversion_service.dart';

class ResultRepository {
  final LandConversionStrategy _bighaConverter;
  ResultRepository({required LandConversionStrategy bighaConverter})
      : _bighaConverter = bighaConverter;
  double convertToBigha(double amount) {
    return _bighaConverter.convertToBigha(amount);
  }
}

// Make result repository autodispose provider recives LandConversionStrategy
final resultRepositoryProvider = AutoDisposeProviderFamily(
  (ref, LandConversionStrategy converter) {
    return ResultRepository(bighaConverter: converter);
  },
);
