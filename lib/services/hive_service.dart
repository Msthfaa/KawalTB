import 'package:hive_flutter/hive_flutter.dart';
import '../models/medication_schedule.dart';
import '../models/medication_log.dart';

class HiveService {
  static HiveService? _instance;

  HiveService._();

  static HiveService get instance {
    if (_instance == null) {
      throw StateError('HiveService is not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<void> initialize() async {
    if (_instance != null) return;

    await Hive.initFlutter();

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MedicationScheduleAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MedicationLogAdapter());
    }

    // Open boxes
    await Hive.openBox<MedicationSchedule>('medication_schedules');
    await Hive.openBox<MedicationLog>('medication_logs');

    _instance = HiveService._();
  }

  // --- Medication Schedule Methods ---
  Future<List<MedicationSchedule>> getAllSchedules() async {
    final box = Hive.box<MedicationSchedule>('medication_schedules');
    return box.values.toList();
  }

  Future<MedicationSchedule?> getSchedule(int id) async {
    final box = Hive.box<MedicationSchedule>('medication_schedules');
    return box.get(id);
  }

  Future<void> saveSchedule(MedicationSchedule schedule) async {
    final box = Hive.box<MedicationSchedule>('medication_schedules');
    if (schedule.key == null) {
      final key = await box.add(schedule);
      schedule.id = key;
      await box.put(key, schedule);
    } else {
      schedule.id = schedule.key as int;
      await schedule.save();
    }
  }

  Future<void> deleteSchedule(int id) async {
    final box = Hive.box<MedicationSchedule>('medication_schedules');
    await box.delete(id);
  }

  Future<void> saveSchedules(List<MedicationSchedule> schedules) async {
    final box = Hive.box<MedicationSchedule>('medication_schedules');
    for (final schedule in schedules) {
      if (schedule.key == null) {
        final key = await box.add(schedule);
        schedule.id = key;
        await box.put(key, schedule);
      } else {
        schedule.id = schedule.key as int;
        await schedule.save();
      }
    }
  }

  Future<void> clearSchedules() async {
    final box = Hive.box<MedicationSchedule>('medication_schedules');
    await box.clear();
  }

  // --- Medication Log Methods ---
  Future<List<MedicationLog>> getAllLogs() async {
    final box = Hive.box<MedicationLog>('medication_logs');
    final logs = box.values.toList();
    // Sort by takenAt descending
    logs.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return logs;
  }

  Future<List<MedicationLog>> getUnsyncedLogs() async {
    final box = Hive.box<MedicationLog>('medication_logs');
    return box.values.where((log) => !log.isSynced).toList();
  }

  Future<List<MedicationLog>> getTodayLogs() async {
    final box = Hive.box<MedicationLog>('medication_logs');
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return box.values.where((log) {
      return log.takenAt.isAfter(startOfToday.subtract(const Duration(seconds: 1))) &&
             log.takenAt.isBefore(endOfToday.add(const Duration(seconds: 1)));
    }).toList();
  }

  Future<void> saveLog(MedicationLog log) async {
    final box = Hive.box<MedicationLog>('medication_logs');
    if (log.key == null) {
      final key = await box.add(log);
      log.id = key;
      await box.put(key, log);
    } else {
      log.id = log.key as int;
      await log.save();
    }
  }

  Future<void> markLogsAsSynced(List<int> ids) async {
    final box = Hive.box<MedicationLog>('medication_logs');
    for (final id in ids) {
      final log = box.get(id);
      if (log != null) {
        log.isSynced = true;
        await log.save();
      }
    }
  }
}
