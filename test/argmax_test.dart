import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:LCC/infrastructure/inference/inference_isolate_entry.dart';

/// The old argmax was
/// `flattenedOutput.indexWhere((e) => e == flattenedOutput.reduce(max))`:
/// O(n^2), and `indexWhere` returns -1 when any value is NaN because every
/// `==` comparison against NaN is false — which then threw
/// `RangeError: index -1` on the label lookup.
void main() {
  Float32List scores(List<double> values) => Float32List.fromList(values);

  group('argmaxOfScores', () {
    test('picks the highest score', () {
      expect(argmaxOfScores(scores([0.1, 0.2, 0.6, 0.1])), 2);
      expect(argmaxOfScores(scores([0.9, 0.05, 0.03, 0.02])), 0);
      expect(argmaxOfScores(scores([0.0, 0.0, 0.0, 1.0])), 3);
    });

    test('returns the first index on a tie', () {
      expect(argmaxOfScores(scores([0.25, 0.25, 0.25, 0.25])), 0);
    });

    test('skips NaN instead of throwing RangeError', () {
      expect(argmaxOfScores(scores([double.nan, 0.2, 0.7, 0.1])), 2);
      expect(argmaxOfScores(scores([0.7, double.nan, 0.2, 0.1])), 0);
    });

    test('handles negative logits', () {
      expect(argmaxOfScores(scores([-5.0, -1.0, -3.0, -9.0])), 1);
    });

    test('throws a descriptive error when every value is NaN', () {
      expect(
        () => argmaxOfScores(
          scores([double.nan, double.nan, double.nan, double.nan]),
        ),
        throwsA(predicate((e) => e.toString().contains('NaN'))),
      );
    });

    test('throws on empty output rather than returning a bogus index', () {
      expect(() => argmaxOfScores(scores([])), throwsA(isA<Exception>()));
    });

    test('rejects an output wider than the label table', () {
      // Guards against a model swap silently mapping class 4 onto label 2.
      expect(
        () => argmaxOfScores(scores([0.0, 0.0, 0.0, 0.0, 1.0])),
        throwsA(isA<Exception>()),
      );
    });

    test('every index maps onto a declared label', () {
      for (var i = 0; i < classificationLabels.length; i++) {
        final values = List<double>.filled(classificationLabels.length, 0.0);
        values[i] = 1.0;
        expect(classificationLabels[argmaxOfScores(scores(values))],
            classificationLabels[i]);
      }
      expect(classificationLabels, [2, 3, 4, 5]);
    });
  });
}
