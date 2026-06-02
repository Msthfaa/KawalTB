import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/medication_log.dart';
import 'hive_service.dart';
import 'sync_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  // Ensure Flutter engine bindings are initialized for background execution
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive storage inside the separate background Isolate
  await HiveService.initialize();
  
  // Initialize notification service to setup location/timezone data
  await NotificationService.instance.initialize();
  
  // Process the quick action
  await NotificationService.handleNotificationAction(response);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  NotificationService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Initialize timezone data
    tz.initializeTimeZones();
    try {
      // Default to Indonesia's WIB timezone (Asia/Jakarta)
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      // Fallback in case of error
    }

    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux)) return;

    try {
      // 2. Initialize Android notification settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. Initialize iOS notification settings
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap action here in the foreground
          NotificationService.handleNotificationAction(response);
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Check if the app was launched via a notification action click (cold start)
      final NotificationAppLaunchDetails? launchDetails =
          await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final NotificationResponse? response = launchDetails.notificationResponse;
        if (response != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            NotificationService.handleNotificationAction(response);
          });
        }
      }

      // Request permissions for Android 13+
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
          
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    } catch (e) {
      print('Error initializing Local Notifications: $e');
    }
  }

  Future<void> scheduleDailyMedication({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String category = 'Obat',
    required String medicationName,
    String? supabaseScheduleId,
  }) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux)) return;
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If scheduled time is in the past, move it to tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final List<AndroidNotificationAction> androidActions = [];
      if (category == 'Air') {
        androidActions.add(
          const AndroidNotificationAction(
            'action_sudah_air',
            'Sudah Minum',
            cancelNotification: true,
            showsUserInterface: true,
          ),
        );
      } else {
        androidActions.addAll([
          const AndroidNotificationAction(
            'action_sudah_obat',
            'Sudah Minum',
            cancelNotification: true,
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'action_tunda_obat',
            'Tunda (15 Menit)',
            cancelNotification: true,
            showsUserInterface: true,
          ),
        ]);
      }

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'medication_reminder_channel',
        'Medication Reminders',
        channelDescription: 'Channel for daily medication reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        actions: androidActions,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final String payload = jsonEncode({
        'id': id,
        'category': category,
        'medicationName': medicationName,
        'supabaseScheduleId': supabaseScheduleId,
      });

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformChannelSpecifics,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Error scheduling daily medication: $e');
    }
  }

  Future<void> scheduleOneOffNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String category,
    required String medicationName,
    String? supabaseScheduleId,
  }) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux)) return;
    try {
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      final List<AndroidNotificationAction> androidActions = [];
      if (category == 'Air') {
        androidActions.add(
          const AndroidNotificationAction(
            'action_sudah_air',
            'Sudah Minum',
            cancelNotification: true,
            showsUserInterface: true,
          ),
        );
      } else {
        androidActions.addAll([
          const AndroidNotificationAction(
            'action_sudah_obat',
            'Sudah Minum',
            cancelNotification: true,
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'action_tunda_obat',
            'Tunda (15 Menit)',
            cancelNotification: true,
            showsUserInterface: true,
          ),
        ]);
      }

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'medication_reminder_channel',
        'Medication Reminders',
        channelDescription: 'Channel for daily medication reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        actions: androidActions,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final String payload = jsonEncode({
        'id': id,
        'category': category,
        'medicationName': medicationName,
        'supabaseScheduleId': supabaseScheduleId,
      });

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        platformChannelSpecifics,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling one off notification: $e');
    }
  }

  static Future<void> handleNotificationAction(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      final String actionId = response.actionId ?? '';
      final String category = data['category'] ?? 'Obat';
      final String medicationName = data['medicationName'] ?? '';
      final String? supabaseScheduleId = data['supabaseScheduleId']?.toString();

      if (actionId == 'action_sudah_air' || actionId == 'action_sudah_obat' || actionId.isEmpty) {
        final log = MedicationLog(
          medicationName: medicationName,
          supabaseScheduleId: supabaseScheduleId,
          takenAt: DateTime.now(),
          isSynced: false,
        );
        await HiveService.instance.saveLog(log);

        await SyncService.instance.initialize();
        await SyncService.instance.triggerImmediateSync();
      } else if (actionId == 'action_tunda_obat') {
        final int snoozeId = DateTime.now().millisecondsSinceEpoch.remainder(1000000) + 100000;
        final DateTime snoozeTime = DateTime.now().add(const Duration(minutes: 15));

        await NotificationService.instance.scheduleOneOffNotification(
          id: snoozeId,
          title: 'Tunda: Waktunya Minum Obat!',
          body: 'Pengingat tunda untuk obat Anda: $medicationName',
          scheduledDate: snoozeTime,
          category: category,
          medicationName: medicationName,
          supabaseScheduleId: supabaseScheduleId,
        );
      }
    } catch (e) {
      print('Error handling notification action: $e');
    }
  }

  Future<void> cancelSchedule(int id) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux)) return;
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      print('Error cancelling notification schedule: $e');
    }
  }

  Future<void> cancelAllSchedules() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux)) return;
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      print('Error cancelling all notification schedules: $e');
    }
  }
}

