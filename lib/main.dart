import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

import 'core/app_theme.dart';
import 'screens/login_screen.dart';

Future<void> main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize Supabase here:
  await Supabase.initialize(
    url: 'https://lkodhofqxftavmawoefe.supabase.co',
    anonKey: 'sb_publishable_yyZjO-fAICLYBWk4qbsZHg_vD0hvgfk', 
  );

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
    return MaterialApp(
      title: 'Kawal TB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}