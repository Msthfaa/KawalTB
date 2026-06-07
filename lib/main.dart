import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

import 'core/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'services/medication_repository.dart';

Future<void> main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase remote backend
  await Supabase.initialize(
    url: 'https://lkodhofqxftavmawoefe.supabase.co',
    anonKey: 'sb_publishable_yyZjO-fAICLYBWk4qbsZHg_vD0hvgfk', 
  );

  // Initialize offline-first Hive database
  await HiveService.initialize();

  // Initialize local notifications & timezone alarm engine
  await NotificationService.instance.initialize();

  // Initialize Workmanager sync service and register periodic task
  await SyncService.instance.initialize();
  await SyncService.instance.registerPeriodicSync();

  // Fetch remote updates asynchronously without blocking startup
  MedicationRepository.instance.syncSchedulesFromSupabase().catchError((e) {
    print('Initial schedules sync skipped: $e');
  });
  MedicationRepository.instance.syncLogsFromSupabase().catchError((e) {
    print('Initial logs sync skipped: $e');
  });

  // Set status bar style to match the light background
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const KawalTBApp());
}

class KawalTBApp extends StatelessWidget {
  const KawalTBApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    
    return MaterialApp(
      title: 'Kawal TB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: session != null ? const MainShell() : const LoginScreen(),
    );
  }
}