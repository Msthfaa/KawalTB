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
  final int initialIndex;
  final String? initialAlarmTab;
  const MainShell({super.key, this.initialIndex = 0, this.initialAlarmTab});

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

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const DashboardScreen(),          // 0 – Beranda
      const DiagnosaDetailScreen(),     // 1 – Diagnosa
      AlarmScreen(initialTab: widget.initialAlarmTab), // 2 - Alarm (with initial tab dynamic argument)
      const FaskesMapScreen(),          // 3 – Maps
      const ProfileScreen(),            // 4 - Profil
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: KawalBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

