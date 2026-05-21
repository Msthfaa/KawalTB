import 'package:supabase_flutter/supabase_flutter.dart';
import 'hive_service.dart';
import 'notification_service.dart';
import 'sync_service.dart';
import '../models/medication_schedule.dart';
import '../models/medication_log.dart';

class MedicationRepository {
  static final MedicationRepository _instance = MedicationRepository._();
  static MedicationRepository get instance => _instance;

  MedicationRepository._();

  final HiveService _hiveService = HiveService.instance;
  final NotificationService _notificationService = NotificationService.instance;
  final SyncService _syncService = SyncService.instance;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  /// Fetch latest schedules from Supabase and synchronize with Hive local database.
  /// Then, automatically schedules the local notifications for each active schedule.
  Future<void> syncSchedulesFromSupabase() async {
    try {
      final response = await _supabaseClient
          .from('medication_schedules')
          .select();

      final List<dynamic> data = response as List<dynamic>;
      final List<MedicationSchedule> remoteSchedules = data.map((item) {
        return MedicationSchedule(
          supabaseId: item['id']?.toString(),
          medicationName: item['medication_name'] ?? '',
          hour: item['hour'] ?? 0,
          minute: item['minute'] ?? 0,
          isActive: item['is_active'] ?? true,
          category: item['category']?.toString() ?? 'Obat',
        );
      }).toList();

      // Clear local cache and save the latest remote schedules
      await _hiveService.clearSchedules();
      await _hiveService.saveSchedules(remoteSchedules);

      // Re-schedule all local notifications
      await rescheduleAllNotifications();
    } catch (e) {
      print('Error syncing schedules from Supabase: $e');
      // If offline, we keep using the local schedules already saved in Hive.
      // This is the core of offline-first architecture.
    }
  }

  /// Helper method to reschedule all active schedules in the notification engine
  Future<void> rescheduleAllNotifications() async {
    await _notificationService.cancelAllSchedules();
    final schedules = await _hiveService.getAllSchedules();
    for (final schedule in schedules) {
      if (schedule.isActive) {
        await _notificationService.scheduleDailyMedication(
          id: schedule.id!,
          title: schedule.category == 'Air' ? 'Waktunya Minum Air!' : 'Waktunya Minum Obat!',
          body: schedule.category == 'Air'
              ? 'Jangan lupa minum air agar tubuh tetap terhidrasi: ${schedule.medicationName}'
              : 'Silakan minum obat Anda: ${schedule.medicationName}',
          hour: schedule.hour,
          minute: schedule.minute,
          category: schedule.category ?? 'Obat',
          medicationName: schedule.medicationName,
          supabaseScheduleId: schedule.supabaseId,
        );
      }
    }
  }

  /// Triggers when the user clicks "Sudah Minum" (Taken Medication) in the UI.
  /// Saves the log locally with isSynced = false, and immediately starts a sync background task.
  Future<void> recordMedicationTaken(MedicationSchedule schedule) async {
    final log = MedicationLog(
      medicationName: schedule.medicationName,
      supabaseScheduleId: schedule.supabaseId,
      takenAt: DateTime.now(),
      isSynced: false,
    );

    // Save to local Hive database
    await _hiveService.saveLog(log);

    // Trigger immediate background synchronization via Workmanager
    await _syncService.triggerImmediateSync();
  }

  /// Adds a new medication schedule (locally first, then attempts to sync to Supabase)
  Future<void> addNewSchedule(String medicationName, int hour, int minute, {String category = 'Obat'}) async {
    // 1. Create locally in Hive
    final schedule = MedicationSchedule(
      medicationName: medicationName,
      hour: hour,
      minute: minute,
      isActive: true,
      category: category,
    );

    await _hiveService.saveSchedule(schedule);

    // 2. Schedule notification immediately
    await _notificationService.scheduleDailyMedication(
      id: schedule.id!,
      title: category == 'Air' ? 'Waktunya Minum Air!' : 'Waktunya Minum Obat!',
      body: category == 'Air'
          ? 'Jangan lupa minum air agar tubuh tetap terhidrasi: ${schedule.medicationName}'
          : 'Silakan minum obat Anda: ${schedule.medicationName}',
      hour: schedule.hour,
      minute: schedule.minute,
      category: category,
      medicationName: schedule.medicationName,
      supabaseScheduleId: schedule.supabaseId,
    );

    // 3. Attempt to upload to Supabase if connected
    try {
      final insertData = {
        'medication_name': medicationName,
        'hour': hour,
        'minute': minute,
        'is_active': true,
      };

      dynamic response;
      try {
        response = await _supabaseClient
            .from('medication_schedules')
            .insert({
              ...insertData,
              'category': category,
            })
            .select()
            .maybeSingle();
      } catch (dbError) {
        // Fallback if 'category' column doesn't exist on remote table
        final errStr = dbError.toString();
        if (errStr.contains('column') && errStr.contains('category')) {
          response = await _supabaseClient
              .from('medication_schedules')
              .insert(insertData)
              .select()
              .maybeSingle();
        } else {
          rethrow;
        }
      }

      if (response != null) {
        schedule.supabaseId = response['id'].toString();
        // Update local database with Supabase generated ID
        await _hiveService.saveSchedule(schedule);
      }
    } catch (e) {
      print('Warning: Failed to sync new schedule to remote Supabase database. Kept locally: $e');
    }
  }

  /// Deletes a schedule
  Future<void> deleteSchedule(int localId, String? remoteId) async {
    // Cancel notification
    await _notificationService.cancelSchedule(localId);

    // Delete locally
    await _hiveService.deleteSchedule(localId);

    // Try to delete remotely
    if (remoteId != null) {
      try {
        await _supabaseClient
            .from('medication_schedules')
            .delete()
            .eq('id', remoteId);
      } catch (e) {
        print('Warning: Failed to delete remote schedule from Supabase. $e');
      }
    }
  }

  /// Toggles the active state of a schedule
  Future<void> toggleScheduleActive(int localId, bool isActive) async {
    final schedule = await _hiveService.getSchedule(localId);
    if (schedule != null) {
      schedule.isActive = isActive;
      await _hiveService.saveSchedule(schedule);

      if (isActive) {
        await _notificationService.scheduleDailyMedication(
          id: schedule.id!,
          title: schedule.category == 'Air' ? 'Waktunya Minum Air!' : 'Waktunya Minum Obat!',
          body: schedule.category == 'Air'
              ? 'Jangan lupa minum air agar tubuh tetap terhidrasi: ${schedule.medicationName}'
              : 'Silakan minum obat Anda: ${schedule.medicationName}',
          hour: schedule.hour,
          minute: schedule.minute,
          category: schedule.category ?? 'Obat',
          medicationName: schedule.medicationName,
          supabaseScheduleId: schedule.supabaseId,
        );
      } else {
        await _notificationService.cancelSchedule(localId);
      }

      // Try to sync update to Supabase
      if (schedule.supabaseId != null) {
        try {
          await _supabaseClient
              .from('medication_schedules')
              .update({'is_active': isActive})
              .eq('id', schedule.supabaseId!);
        } catch (e) {
          print('Warning: Failed to sync toggle state to Supabase: $e');
        }
      }
    }
  }
}
