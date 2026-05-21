// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicationLogAdapter extends TypeAdapter<MedicationLog> {
  @override
  final int typeId = 2;

  @override
  MedicationLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationLog(
      id: fields[0] as int?,
      supabaseId: fields[1] as String?,
      supabaseScheduleId: fields[2] as String?,
      medicationName: fields[3] as String,
      takenAt: fields[4] as DateTime,
      isSynced: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.supabaseId)
      ..writeByte(2)
      ..write(obj.supabaseScheduleId)
      ..writeByte(3)
      ..write(obj.medicationName)
      ..writeByte(4)
      ..write(obj.takenAt)
      ..writeByte(5)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
