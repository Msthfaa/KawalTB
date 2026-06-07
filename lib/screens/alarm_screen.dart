import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/app_colors.dart';
import '../models/medication_schedule.dart';
import '../services/hive_service.dart';
import '../services/medication_repository.dart';
import 'add_alarm_screen.dart';
import 'notification_history_screen.dart';

class AlarmScreen extends StatefulWidget {
  final String? initialTab;
  const AlarmScreen({super.key, this.initialTab});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late String _selectedTab;
  List<MedicationSchedule> _schedules = [];
  String? _avatarPath;
  bool _isLoading = true;
  StreamSubscription? _scheduleSubscription;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab ?? 'Obat';
    _loadSchedules();

    // Set up database listener for auto-refresh
    _scheduleSubscription = Hive.box<MedicationSchedule>('medication_schedules').watch().listen((_) {
      _loadSchedules();
    });
  }

  @override
  void dispose() {
    _scheduleSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    try {
      final schedules = await HiveService.instance.getAllSchedules();
      final prefs = await SharedPreferences.getInstance();
      final avatar = prefs.getString('avatar_path');
      setState(() {
        _schedules = schedules;
        _avatarPath = avatar;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSchedule(MedicationSchedule schedule, bool value) async {
    await MedicationRepository.instance.toggleScheduleActive(schedule.id!, value);
    _loadSchedules();
  }

  Future<void> _deleteSchedule(MedicationSchedule schedule) async {
    await MedicationRepository.instance.deleteSchedule(schedule.id!, schedule.supabaseId);
    _loadSchedules();
  }

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
            backgroundImage: _avatarPath != null 
                ? (kIsWeb ? NetworkImage(_avatarPath!) as ImageProvider : FileImage(File(_avatarPath!))) 
                : const AssetImage('assets/images/profile_avatar.png') as ImageProvider,
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddAlarmScreen(
                initialCategory: _selectedTab == 'Air Minum' ? 'Air' : 'Obat',
              ),
            ),
          );
          if (result == true) {
            _loadSchedules();
          }
        },
        backgroundColor: const Color(0xFF006C45),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.add, color: AppColors.white, size: 28),
      ),
      ),
      body: _isLoading
          ? const SizedBox.expand(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF006C45)),
              ),
            )
          : SingleChildScrollView(
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
                  if (_selectedTab == 'Obat')
                  _schedules.where((s) => s.category == 'Obat' || s.category == null).isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(Icons.alarm_off, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                const Text(
                                  'Belum ada jadwal obat',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _schedules.where((s) => s.category == 'Obat' || s.category == null).length,
                          itemBuilder: (context, index) {
                            final obatSchedules = _schedules.where((s) => s.category == 'Obat' || s.category == null).toList();
                            final schedule = obatSchedules[index];
                            final timeText = '${schedule.hour.toString().padLeft(2, '0')}:${schedule.minute.toString().padLeft(2, '0')}';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Dismissible(
                                  key: Key('schedule_${schedule.id}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  onDismissed: (direction) {
                                    _deleteSchedule(schedule);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Jadwal "${schedule.medicationName}" dihapus'),
                                      ),
                                    );
                                  },
                                  child: _AlarmCard(
                                    time: timeText,
                                    label: schedule.medicationName,
                                    isActive: schedule.isActive,
                                    onToggle: (val) => _toggleSchedule(schedule, val),
                                  ),
                                ),
                              );
                            },
                          )
                else
                  // Air Minum Tab
                  _schedules.where((s) => s.category == 'Air').isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(Icons.water_drop, size: 64, color: Colors.blue[300]),
                                const SizedBox(height: 16),
                                const Text(
                                  'Belum ada jadwal minum air',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tambahkan jadwal untuk mengingatkan Anda minum air.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _schedules.where((s) => s.category == 'Air').length,
                          itemBuilder: (context, index) {
                            final waterSchedules = _schedules.where((s) => s.category == 'Air').toList();
                            final schedule = waterSchedules[index];
                            final timeText = '${schedule.hour.toString().padLeft(2, '0')}:${schedule.minute.toString().padLeft(2, '0')}';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Dismissible(
                                key: Key('schedule_${schedule.id}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  _deleteSchedule(schedule);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Jadwal "${schedule.medicationName}" dihapus'),
                                    ),
                                  );
                                },
                                child: _AlarmCard(
                                  time: timeText,
                                  label: schedule.medicationName,
                                  isActive: schedule.isActive,
                                  isWater: true,
                                  onToggle: (val) => _toggleSchedule(schedule, val),
                                ),
                              ),
                            );
                          },
                        ),
                
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
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
    this.isWater = false,
  });

  final String time;
  final String label;
  final bool isActive;
  final ValueChanged<bool> onToggle;
  final bool isWater;

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
              color: isActive 
                  ? (isWater ? const Color(0xFFE0F2FE) : AppColors.primarySurface)
                  : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isWater ? Icons.water_drop : Icons.medical_services_rounded,
              color: isActive 
                  ? (isWater ? Colors.blue[600] : const Color(0xFF006C45))
                  : const Color(0xFF94A3B8),
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
            activeTrackColor: isWater ? Colors.blue[600] : const Color(0xFF006C45),
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: const Color(0xFFE2E8F0),
          ),
        ],
      ),
    );
  }
}
