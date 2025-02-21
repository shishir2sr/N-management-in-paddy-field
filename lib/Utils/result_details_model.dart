import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class ResultStateDetails extends HiveObject {
  @HiveField(0)
  final double landAmountInBigha;

  @HiveField(1)
  final String recommendation;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final double averageLLC;

  @HiveField(4)
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
    return ResultStateDetails(
      landAmountInBigha: fields[0] as double,
      recommendation: fields[1] as String,
      date: fields[2] as DateTime,
      averageLLC: fields[3] as double,
      ureaNeeded: fields[4] as double,
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
