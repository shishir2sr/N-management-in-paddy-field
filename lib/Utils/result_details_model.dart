import 'package:hive/hive.dart';

/// The adapter below is hand-written, so the `@HiveType`/`@HiveField`
/// annotations are deliberately omitted — with them present `hive_generator`
/// warns on every build that a `part 'result_details_model.g.dart'` directive
/// is missing, for a generated adapter that is never used.
class ResultStateDetails extends HiveObject {
  final double landAmountInBigha;

  final String recommendation;

  final DateTime date;

  final double averageLLC;

  final double ureaNeeded;

  ResultStateDetails({
    required this.landAmountInBigha,
    required this.recommendation,
    required this.date,
    required this.averageLLC,
    required this.ureaNeeded,
  });

  @override
  String toString() {
    return 'ResultStateDetails(landAmountInBigha: $landAmountInBigha, recommendation: $recommendation, date: $date, averageLLC: $averageLLC, ureaNeeded: $ureaNeeded)';
  }
}

class ResultStateDetailsAdapter extends TypeAdapter<ResultStateDetails> {
  @override
  final int typeId = 0;

  @override
  ResultStateDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    // Nullable casts with defaults. Straight `as double` casts meant a record
    // written by a build with a different field set threw
    // `_TypeError: null is not a subtype of double` from inside the History
    // page's ValueListenableBuilder, red-screening the whole screen with no way
    // to recover short of clearing app data.
    return ResultStateDetails(
      landAmountInBigha: (fields[0] as num?)?.toDouble() ?? 0.0,
      recommendation: fields[1] as String? ?? '',
      date: fields[2] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0),
      averageLLC: (fields[3] as num?)?.toDouble() ?? 0.0,
      ureaNeeded: (fields[4] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  void write(BinaryWriter writer, ResultStateDetails obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.landAmountInBigha)
      ..writeByte(1)
      ..write(obj.recommendation)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.averageLLC)
      ..writeByte(4)
      ..write(obj.ureaNeeded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultStateDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
