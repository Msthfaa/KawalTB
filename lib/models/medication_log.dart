import 'package:hive/hive.dart';

part 'medication_log.g.dart';

@HiveType(typeId: 2)
class MedicationLog extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? supabaseId; // Reference ID to the log in Supabase

  @HiveField(2)
  String? supabaseScheduleId; // Reference ID to the schedule in Supabase

  @HiveField(3)
  late String medicationName;

  @HiveField(4)
  late DateTime takenAt;

  @HiveField(5)
  bool isSynced;

  MedicationLog({
    this.id,
    this.supabaseId,
    this.supabaseScheduleId,
    required this.medicationName,
    required this.takenAt,
    this.isSynced = false,
  });
}
