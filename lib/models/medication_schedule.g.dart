// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicationScheduleAdapter extends TypeAdapter<MedicationSchedule> {
  @override
  final int typeId = 1;

  @override
  MedicationSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationSchedule(
      id: fields[0] as int?,
      supabaseId: fields[1] as String?,
      medicationName: fields[2] as String,
      hour: fields[3] as int,
      minute: fields[4] as int,
      isActive: fields[5] as bool,
      category: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationSchedule obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.supabaseId)
      ..writeByte(2)
      ..write(obj.medicationName)
      ..writeByte(3)
      ..write(obj.hour)
      ..writeByte(4)
      ..write(obj.minute)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
