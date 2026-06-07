import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../core/app_colors.dart';

/// A floating bottom navigation bar that matches the new design
/// using google_nav_bar package.
class KawalBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const KawalBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(milliseconds: 300),
            tabBackgroundColor: AppColors.primary, // Using the old primary color
            color: AppColors.textSecondary, // Unselected icon color
            tabs: const [
              GButton(
                icon: Icons.home_outlined,
                text: 'Beranda',
              ),
              GButton(
                icon: Icons.alarm_outlined, // Restored the old alarm icon
                text: 'Alarm',
              ),
              GButton(
                icon: Icons.location_on_outlined,
                text: 'Maps',
              ),
              GButton(
                icon: Icons.person_outline_rounded, // Restored the old profile icon
                text: 'Profil',
              ),
            ],
            selectedIndex: currentIndex,
            onTabChange: onTap,
          ),
        ),
      ),
    );
  }
}
