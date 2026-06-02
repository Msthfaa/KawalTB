import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:workmanager/workmanager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'hive_service.dart';

const String syncTaskName = "com.kawaltb.medication_sync_task";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // 1. Initialize Supabase in the background isolate
      await Supabase.initialize(
        url: 'https://lkodhofqxftavmawoefe.supabase.co',
        anonKey: 'sb_publishable_yyZjO-vAICLYBWk4qbsZHg_vD0hvgfk',
      );

      // 2. Initialize Hive database in the background isolate
      await HiveService.initialize();
      final hiveService = HiveService.instance;

      // 3. Query all unsynced logs
      final unsyncedLogs = await hiveService.getUnsyncedLogs();
      if (unsyncedLogs.isEmpty) {
        return Future.value(true);
      }

      final supabaseClient = Supabase.instance.client;

      // 4. Push logs to Supabase
      for (final log in unsyncedLogs) {
        final data = {
          'medication_name': log.medicationName,
          'taken_at': log.takenAt.toIso8601String(),
          'supabase_schedule_id': log.supabaseScheduleId,
        };

        // Insert into Supabase table 'medication_logs'
        final response = await supabaseClient
            .from('medication_logs')
            .insert(data)
            .select()
            .maybeSingle();
        
        if (response != null) {
          final logId = log.id;
          if (logId != null) {
            log.isSynced = true;
            log.supabaseId = response['id'].toString();
            // Store updated sync status and remote ID back in Hive
            await hiveService.saveLog(log);
          }
        }
      }

      return Future.value(true);
    } catch (e) {
      // Print error for debugging
      print('Sync Task Failed: $e');
      return Future.value(false);
    }
  });
}

class SyncService {
  static final SyncService _instance = SyncService._();
  static SyncService get instance => _instance;

  SyncService._();

  Future<void> initialize() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
    } catch (e) {
      print('Error initializing Workmanager: $e');
    }
  }

  // Schedule a periodic background task to run every 15 minutes (minimum interval)
  Future<void> registerPeriodicSync() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    try {
      await Workmanager().registerPeriodicTask(
        "periodic-sync-id",
        syncTaskName,
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    } catch (e) {
      print('Error registering periodic sync task: $e');
    }
  }

  // Trigger a one-off sync task to run immediately
  Future<void> triggerImmediateSync() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    try {
      await Workmanager().registerOneOffTask(
        "oneoff-sync-${DateTime.now().millisecondsSinceEpoch}",
        syncTaskName,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    } catch (e) {
      print('Error triggering immediate sync task: $e');
    }
  }
}
