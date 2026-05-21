import 'package:hive/hive.dart';

part 'medication_schedule.g.dart';

@HiveType(typeId: 1)
class MedicationSchedule extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? supabaseId; // Reference ID to the schedule in Supabase

  @HiveField(2)
  late String medicationName;

  @HiveField(3)
  late int hour;

  @HiveField(4)
  late int minute;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  String? category;

  MedicationSchedule({
    this.id,
    this.supabaseId,
    required this.medicationName,
    required this.hour,
    required this.minute,
    this.isActive = true,
    this.category = 'Obat',
  });
}
