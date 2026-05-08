import 'package:flutter/material.dart';


import '../widgets/kawal_bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'diagnosa_detail_screen.dart';
import 'faskes_map_screen.dart';
import 'alarm_screen.dart';
import 'profile_screen.dart';

/// The main shell that hosts all tab screens and the bottom navigation bar.
/// After a successful login, navigate here instead of [DashboardScreen].
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  /// Which tab to open first (e.g. pass 3 to land directly on Maps).
  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // ── Tab screens ─────────────────────────────────────────────────────────────
  // Keep all screens alive with IndexedStack so state is preserved across tabs.
  static const List<Widget> _screens = [
    DashboardScreen(),          // 0 – Beranda
    DiagnosaDetailScreen(),     // 1 – Diagnosa
    AlarmScreen(),              // 2 - Alarm
    FaskesMapScreen(),          // 3 – Maps
    ProfileScreen(),            // 4 - Profil
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use extendBody so the map / content can bleed under the navbar
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: KawalBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

