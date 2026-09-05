import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:LCC/Utils/result_details_model.dart';

/// Minimal in-memory BinaryWriter/Reader pair.
///
/// Hive's own `BinaryWriterImpl` is library-private, so the adapter's field
/// framing is exercised directly here: `writeByte` for the count and the field
/// indices, `write` for the values.
class _FakeWriter implements BinaryWriter {
  final List<int> bytes = [];
  final List<Object?> values = [];

  @override
  void writeByte(int value) => bytes.add(value);

  @override
  void write<T>(T value, {bool writeTypeId = true}) => values.add(value);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used');
}

class _FakeReader implements BinaryReader {
  _FakeReader(this._bytes, this._values);

  final List<int> _bytes;
  final List<Object?> _values;
  int _byteIndex = 0;
  int _valueIndex = 0;

  @override
  int readByte() => _bytes[_byteIndex++];

  @override
  dynamic read([int? typeId]) => _values[_valueIndex++];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used');
}

void main() {
  final adapter = ResultStateDetailsAdapter();

  group('ResultStateDetailsAdapter', () {
    test('round-trips every field', () {
      final original = ResultStateDetails(
        landAmountInBigha: 2.75,
        recommendation: 'Recommended\nUrea:\n0.62 kg',
        date: DateTime.utc(2026, 3, 14, 9, 26, 53),
        averageLLC: 3.4,
        ureaNeeded: 0.625,
      );

      final writer = _FakeWriter();
      adapter.write(writer, original);

      final restored = adapter.read(
        _FakeReader(writer.bytes, writer.values),
      );

      expect(restored.landAmountInBigha, original.landAmountInBigha);
      expect(restored.recommendation, original.recommendation);
      expect(restored.date, original.date);
      expect(restored.averageLLC, original.averageLLC);
      expect(restored.ureaNeeded, original.ureaNeeded);
    });

    test('writes the declared field count', () {
      final writer = _FakeWriter();
      adapter.write(
        writer,
        ResultStateDetails(
          landAmountInBigha: 1,
          recommendation: 'x',
          date: DateTime.utc(2026),
          averageLLC: 1,
          ureaNeeded: 1,
        ),
      );

      // One count byte followed by one index byte per value.
      expect(writer.bytes.first, writer.values.length);
      expect(writer.bytes.length, writer.values.length + 1);
    });

    test('a record missing fields falls back to defaults instead of throwing',
        () {
      // Previously every cast was an unguarded `as double`/`as String`, so a
      // record written by a build with a different field set threw a TypeError
      // from inside the History page's ValueListenableBuilder and red-screened
      // the whole screen.
      final restored = adapter.read(_FakeReader(
        [2, 0, 1],
        [4.0, 'Good nitrogen level!'],
      ));

      expect(restored.landAmountInBigha, 4.0);
      expect(restored.recommendation, 'Good nitrogen level!');
      expect(restored.averageLLC, 0.0);
      expect(restored.ureaNeeded, 0.0);
      expect(restored.date, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('accepts ints where doubles are expected', () {
      // Hive writes a whole-valued double back as an int, so `as double` would
      // throw on a value that round-tripped as 4 rather than 4.0.
      final restored = adapter.read(_FakeReader(
        [5, 0, 1, 2, 3, 4],
        [3, 'x', DateTime.utc(2026), 4, 5],
      ));

      expect(restored.landAmountInBigha, 3.0);
      expect(restored.averageLLC, 4.0);
      expect(restored.ureaNeeded, 5.0);
    });

    test('typeId is stable', () {
      // Changing this would orphan every record already on disk.
      expect(adapter.typeId, 0);
    });
  });
}
