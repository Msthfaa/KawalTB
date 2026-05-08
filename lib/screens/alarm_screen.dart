import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'add_alarm_screen.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  String _selectedTab = 'Obat';

  final List<Map<String, dynamic>> _alarms = [
    {
      'time': '08:00',
      'label': 'Obat Pagi - RHZE',
      'isActive': true,
    },
    {
      'time': '13:00',
      'label': 'Obat Siang - Vitamin',
      'isActive': true,
    },
    {
      'time': '20:00',
      'label': 'Obat Malam',
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: const AssetImage('assets/images/profile_avatar.png'),
            backgroundColor: AppColors.primarySurface,
          ),
        ),
        title: const Text(
          'Kawal TB',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pengingat Saya',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF006C45), // Dark green text
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Atur jadwal minum obat dan aktivitas harian\nAnda.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // ── Segmented Control ───────────────────────────────
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 'Obat'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedTab == 'Obat' ? AppColors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _selectedTab == 'Obat'
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Obat',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: _selectedTab == 'Obat' ? FontWeight.w700 : FontWeight.w600,
                                  color: _selectedTab == 'Obat' ? const Color(0xFF006C45) : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 'Air Minum'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedTab == 'Air Minum' ? AppColors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _selectedTab == 'Air Minum'
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Air Minum',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: _selectedTab == 'Air Minum' ? FontWeight.w700 : FontWeight.w600,
                                  color: _selectedTab == 'Air Minum' ? const Color(0xFF006C45) : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // ── Alarms List ─────────────────────────────────────
                ..._alarms.asMap().entries.map((entry) {
                  final index = entry.key;
                  final alarm = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _AlarmCard(
                      time: alarm['time'],
                      label: alarm['label'],
                      isActive: alarm['isActive'],
                      onToggle: (val) {
                        setState(() {
                          _alarms[index]['isActive'] = val;
                        });
                      },
                    ),
                  );
                }),
                
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),
          
          // ── Floating Action Button ────────────────────────────────
          Positioned(
            bottom: 24,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddAlarmScreen()),
                );
              },
              backgroundColor: const Color(0xFF006C45),
              elevation: 4,
              child: const Icon(Icons.add, color: AppColors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlarmCard extends StatelessWidget {
  const _AlarmCard({
    required this.time,
    required this.label,
    required this.isActive,
    required this.onToggle,
  });

  final String time;
  final String label;
  final bool isActive;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primarySurface : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medical_services_rounded,
              color: isActive ? const Color(0xFF006C45) : const Color(0xFF94A3B8),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isActive ? AppColors.textPrimary : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive ? AppColors.textSecondary : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: onToggle,
            activeThumbColor: AppColors.white,
            activeTrackColor: const Color(0xFF006C45),
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: const Color(0xFFE2E8F0),
          ),
        ],
      ),
    );
  }
}
