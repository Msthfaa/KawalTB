import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../widgets/kawal_bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'faskes_map_screen.dart';

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
    _PlaceholderScreen(label: 'Diagnosa', icon: Icons.medical_information_rounded),
    _PlaceholderScreen(label: 'Alarm', icon: Icons.alarm_rounded),
    FaskesMapScreen(),          // 3 – Maps
    _PlaceholderScreen(label: 'Profil', icon: Icons.person_rounded),
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

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder tabs (replace with real screens later)
// ─────────────────────────────────────────────────────────────────────────────

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Segera hadir',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
