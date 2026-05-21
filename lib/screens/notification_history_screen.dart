import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/app_colors.dart';
import '../models/medication_log.dart';
import '../services/hive_service.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  List<MedicationLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await HiveService.instance.getAllLogs();
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeString = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (dateToCheck == today) {
      return 'Hari Ini, $timeString WIB';
    } else if (dateToCheck == yesterday) {
      return 'Kemarin, $timeString WIB';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, $timeString WIB';
    }
  }

  Future<void> _clearLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text('Apakah Anda yakin ingin menghapus semua riwayat notifikasi & aktivitas minum obat/air?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final box = Hive.box<MedicationLog>('medication_logs');
      await box.clear();
      await _loadLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Riwayat aktivitas berhasil dihapus.'),
            backgroundColor: Color(0xFF006C45),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006C45)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Aktivitas & Notifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF006C45),
          ),
        ),
        centerTitle: true,
        actions: [
          if (_logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              tooltip: 'Hapus Riwayat',
              onPressed: _clearLogs,
            ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<MedicationLog>('medication_logs').listenable(),
        builder: (context, Box<MedicationLog> box, _) {
          final logs = box.values.toList();
          logs.sort((a, b) => b.takenAt.compareTo(a.takenAt));

          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF006C45)),
            );
          }

          if (logs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[100],
                      child: Icon(Icons.notifications_off_outlined, size: 40, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Belum Ada Riwayat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Riwayat minum obat atau air minum yang Anda catat akan muncul di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadLogs,
            color: const Color(0xFF006C45),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final isWater = log.medicationName == 'Minum Air' || 
                                log.medicationName.toLowerCase().contains('air') ||
                                log.medicationName.toLowerCase().contains('gelas');

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Area
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isWater ? const Color(0xFFE0F2FE) : const Color(0xFFE8F5EE),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isWater ? Icons.water_drop : Icons.medication,
                            color: isWater ? Colors.blue[600] : const Color(0xFF006C45),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Text Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isWater ? 'Sudah Minum Air' : 'Sudah Minum Obat',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                log.medicationName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_filled_rounded,
                                    size: 13,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDateTime(log.takenAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Sync status icon
                        Tooltip(
                          message: log.isSynced ? 'Tersinkronisasi dengan cloud' : 'Menunggu sinkronisasi',
                          child: Icon(
                            log.isSynced ? Icons.cloud_done : Icons.cloud_off,
                            size: 18,
                            color: log.isSynced ? const Color(0xFF006C45) : Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
