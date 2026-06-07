import 'package:flutter/material.dart';

/// Holds global states using ValueNotifier to allow distant widgets
/// (like DashboardScreen and ProfileScreen) to react to changes immediately
/// without complex state management libraries.
class GlobalState {
  static final ValueNotifier<String> userNameNotifier = ValueNotifier<String>('Pengguna');
  static final ValueNotifier<String?> avatarPathNotifier = ValueNotifier<String?>(null);
}
