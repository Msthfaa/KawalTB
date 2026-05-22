import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';
import '../services/hive_service.dart';
import '../models/medication_log.dart';
import '../models/medication_schedule.dart';

class HealthHistoryScreen extends StatefulWidget {
  const HealthHistoryScreen({super.key});

  @override
  State<HealthHistoryScreen> createState() => _HealthHistoryScreenState();
}

class _HealthHistoryScreenState extends State<HealthHistoryScreen> {
  late int _selectedMonthIndex;
  int? _selectedDay;
  late int _year;

  List<MedicationLog> _logs = [];
  List<MedicationSchedule> _schedules = [];
  bool _isLoading = true;

  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedMonthIndex = today.month - 1; // 0-indexed
    _selectedDay = today.day;
    _year = today.year;
    
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Bersihkan log sebelum tanggal daftar pengguna
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.createdAt.isNotEmpty) {
        final createdAt = DateTime.parse(user.createdAt);
        final startOfRegistrationDay = DateTime(createdAt.year, createdAt.month, createdAt.day);
        await HiveService.instance.deleteLogsBeforeDate(startOfRegistrationDay);
      }

      // 2. Ambil log & jadwal
      final logs = await HiveService.instance.getAllLogs();
      final schedules = await HiveService.instance.getAllSchedules();

      if (mounted) {
        setState(() {
          _logs = logs;
          _schedules = schedules;
        });
      }
    } catch (e) {
      debugPrint('Error loading health history: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _getDaysInMonth(int monthIndex) {
    if (monthIndex == 1) {
      return (_year % 4 == 0 && (_year % 100 != 0 || _year % 400 == 0)) ? 29 : 28;
    }
    if ([3, 5, 8, 10].contains(monthIndex)) return 30;
    return 31;
  }

  List<MedicationLog> _getLogsForDate(int day, int monthIndex) {
    return _logs.where((log) {
      return log.takenAt.year == _year &&
             log.takenAt.month == monthIndex + 1 &&
             log.takenAt.day == day;
    }).toList();
  }

  bool _isMedicineTaken(int day, int monthIndex) {
    final logsForDay = _getLogsForDate(day, monthIndex);
    return logsForDay.any((log) {
      final schedule = _schedules.cast<MedicationSchedule?>().firstWhere(
        (s) => s?.medicationName == log.medicationName,
        orElse: () => null,
      );
      if (schedule != null) {
        return schedule.category == 'Obat' || schedule.category == null;
      }
      return log.medicationName != 'Minum Air'; // heuristic
    });
  }

  bool _isWaterTaken(int day, int monthIndex) {
    final logsForDay = _getLogsForDate(day, monthIndex);
    return logsForDay.any((log) {
      final schedule = _schedules.cast<MedicationSchedule?>().firstWhere(
        (s) => s?.medicationName == log.medicationName,
        orElse: () => null,
      );
      if (schedule != null) {
        return schedule.category == 'Air';
      }
      return log.medicationName == 'Minum Air'; // heuristic
    });
  }

  String _calculateMedicationPercentage() {
    if (_schedules.where((s) => s.category == 'Obat' || s.category == null).isEmpty) return '0';
    
    int daysPassed = 0;
    int daysTaken = 0;
    final today = DateTime.now();
    
    final daysToCalculate = (_year == today.year && _selectedMonthIndex == today.month - 1) 
        ? today.day 
        : (_year < today.year || (_year == today.year && _selectedMonthIndex < today.month - 1)) 
            ? _getDaysInMonth(_selectedMonthIndex) 
            : 0;

    if (daysToCalculate == 0) return '0';

    for (int i = 1; i <= daysToCalculate; i++) {
      daysPassed++;
      if (_isMedicineTaken(i, _selectedMonthIndex)) {
        daysTaken++;
      }
    }
    
    return ((daysTaken / daysPassed) * 100).round().toString();
  }

  String _calculateWaterPercentage() {
    if (_schedules.where((s) => s.category == 'Air').isEmpty) return '0';

    int daysPassed = 0;
    int daysTaken = 0;
    final today = DateTime.now();
    
    final daysToCalculate = (_year == today.year && _selectedMonthIndex == today.month - 1) 
        ? today.day 
        : (_year < today.year || (_year == today.year && _selectedMonthIndex < today.month - 1)) 
            ? _getDaysInMonth(_selectedMonthIndex) 
            : 0;

    if (daysToCalculate == 0) return '0';

    for (int i = 1; i <= daysToCalculate; i++) {
      daysPassed++;
      if (_isWaterTaken(i, _selectedMonthIndex)) {
        daysTaken++;
      }
    }
    
    return ((daysTaken / daysPassed) * 100).round().toString();
  }

  Widget _buildSummaryCard({
    required String title,
    required String percentage,
    required IconData icon,
    required bool isPrimary,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF006C45) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Stack(
          children: [
            if (isPrimary)
              Positioned(
                right: -10,
                top: -10,
                child: Icon(
                  Icons.medical_services,
                  size: 64,
                  color: const Color(0xFFA7F3D0).withOpacity(0.2),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? const Color(0xFFA7F3D0) : const Color(0xFF006C45),
                  size: 20,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? const Color(0xFFA7F3D0) : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      percentage,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isPrimary ? const Color(0xFFA7F3D0) : const Color(0xFF006C45),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isPrimary ? const Color(0xFFA7F3D0) : const Color(0xFF006C45),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'KONSISTENSI',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.5,
                    color: isPrimary
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthChip(int index) {
    bool isSelected = index == _selectedMonthIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMonthIndex = index;
          _selectedDay = null; // reset selected day when month changes
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          '${_months[index]} $_year',
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDayGrid() {
    int days = _getDaysInMonth(_selectedMonthIndex);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        int day = index + 1;
        bool isSelected = day == _selectedDay;
        bool medTaken = _isMedicineTaken(day, _selectedMonthIndex);
        bool waterTaken = _isWaterTaken(day, _selectedMonthIndex);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = day;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primarySurface : AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      medTaken ? Icons.medication : Icons.medication_outlined,
                      size: 10,
                      color: medTaken ? AppColors.primary : AppColors.error,
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      waterTaken ? Icons.water_drop : Icons.water_drop_outlined,
                      size: 10,
                      color: waterTaken ? Colors.blue : AppColors.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyDetail() {
    if (_selectedDay == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Pilih tanggal untuk melihat detail',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    bool medTaken = _isMedicineTaken(_selectedDay!, _selectedMonthIndex);
    bool waterTaken = _isWaterTaken(_selectedDay!, _selectedMonthIndex);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monitoring $_selectedDay ${_months[_selectedMonthIndex]} $_year',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: medTaken ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  medTaken ? Icons.check : Icons.close,
                  color: medTaken ? AppColors.primary : AppColors.error,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Minum Obat',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      medTaken ? 'Obat telah diminum' : 'Obat belum diminum',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: waterTaken ? const Color(0xFFDBEAFE) : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  waterTaken ? Icons.check : Icons.close,
                  color: waterTaken ? Colors.blue : AppColors.error,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Minum Air',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      waterTaken ? 'Kebutuhan air terpenuhi' : 'Kebutuhan air belum terpenuhi',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Riwayat Kesehatan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          centerTitle: false,
          titleSpacing: 0,
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Kesehatan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Chips (Months)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(12, (index) => _buildMonthChip(index)),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Format Tanggal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Grid of days
            _buildDayGrid(),

            const SizedBox(height: 24),

            // Summary Cards
            Row(
              children: [
                _buildSummaryCard(
                  title: 'Minum Obat',
                  percentage: _calculateMedicationPercentage(),
                  icon: Icons.medical_services,
                  isPrimary: true,
                ),
                const SizedBox(width: 16),
                _buildSummaryCard(
                  title: 'Minum Air',
                  percentage: _calculateWaterPercentage(),
                  icon: Icons.water_drop,
                  isPrimary: false,
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Detail Harian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Daily Details
            _buildDailyDetail(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
