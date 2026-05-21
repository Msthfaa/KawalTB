import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_colors.dart';
import '../models/berita_model.dart';
import '../models/medication_schedule.dart';
import '../models/medication_log.dart';
import '../services/hive_service.dart';
import '../services/medication_repository.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import 'article_detail_screen.dart';
import 'berita_list_screen.dart';
import 'diagnosa_detail_screen.dart';
import 'main_shell.dart';
import 'notification_history_screen.dart';
import 'add_alarm_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<MedicationSchedule> _medicationSchedules = [];
  List<MedicationSchedule> _waterSchedules = [];
  List<MedicationLog> _todayLogs = [];
  bool _isLoading = true;
  int _treatmentDay = 42;
  String _userName = 'Budi';
  List<BeritaModel> _newsArticles = dummyBeritaList;

  StreamSubscription? _scheduleSubscription;
  StreamSubscription? _logSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserName();

    // Set up database listeners for auto-refresh
    _scheduleSubscription = Hive.box<MedicationSchedule>('medication_schedules').watch().listen((_) {
      _loadData();
    });
    _logSubscription = Hive.box<MedicationLog>('medication_logs').watch().listen((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _scheduleSubscription?.cancel();
    _logSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fullName = prefs.getString('user_name') ?? 'Budi Santoso';
      final firstName = fullName.split(' ').first;
      setState(() {
        _userName = firstName;
      });
    } catch (e) {
      // fallback
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final schedules = await HiveService.instance.getAllSchedules();
      final logs = await HiveService.instance.getTodayLogs();
      final allLogs = await HiveService.instance.getAllLogs();
      
      int day = 42;
      final medSchedules = schedules.where((s) => s.isActive && (s.category == 'Obat' || s.category == null)).toList();
      if (allLogs.isNotEmpty && medSchedules.isNotEmpty) {
        final medNames = medSchedules.map((s) => s.medicationName).toSet();
        final medLogs = allLogs.where((l) => medNames.contains(l.medicationName)).toList();
        if (medLogs.isNotEmpty) {
          medLogs.sort((a, b) => a.takenAt.compareTo(b.takenAt));
          final firstLogDate = DateTime(medLogs.first.takenAt.year, medLogs.first.takenAt.month, medLogs.first.takenAt.day);
          final todayDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          day = todayDate.difference(firstLogDate).inDays + 1;
        }
      }

      // Load news dynamically to sync with BeritaListScreen
      List<BeritaModel> mappedNews = dummyBeritaList;
      try {
        final List<Article> articles = await NewsService().fetchTBCNews();
        final List<BeritaModel> temp = [];
        for (int i = 0; i < articles.length; i++) {
          final art = articles[i];
          BeritaCategory category = BeritaCategory.edukasi;
          final text = '${art.title} ${art.description}'.toLowerCase();
          if (text.contains('cegah') || text.contains('vaksin') || text.contains('masker') || text.contains('pencegahan')) {
            category = BeritaCategory.pencegahan;
          } else if (text.contains('obat') || text.contains('minum') || text.contains('dosis') || text.contains('terapi') || text.contains('pengobatan')) {
            category = BeritaCategory.pengobatan;
          } else if (text.contains('gejala') || text.contains('tanda') || text.contains('batuk') || text.contains('demam')) {
            category = BeritaCategory.gejala;
          }
          temp.add(BeritaModel(
            id: 'api-$i',
            title: art.title,
            description: art.description,
            date: 'Hari ini',
            category: category,
            imageBgColor: const Color(0xFF00796B),
            imageIcon: Icons.newspaper_rounded,
            imageUrl: art.image,
            articleUrl: art.url,
          ));
        }
        if (temp.isNotEmpty) {
          mappedNews = temp;
        }
      } catch (_) {
        // use fallback dummyBeritaList
      }

      setState(() {
        _medicationSchedules = medSchedules;
        _waterSchedules = schedules.where((s) => s.isActive && s.category == 'Air').toList();
        _todayLogs = logs;
        _treatmentDay = day;
        _newsArticles = mappedNews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _openArticle(BeritaModel berita) {
    final urlString = berita.articleUrl;
    if (urlString == null || urlString.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(
          url: urlString,
          title: berita.title,
          description: berita.description,
          imageUrl: berita.imageUrl,
        ),
      ),
    );
  }

  void _showRecordMedicationSheet(BuildContext context) {
    final untaken = _medicationSchedules.where((s) {
      return !_todayLogs.any((l) => l.medicationName == s.medicationName);
    }).toList();

    if (untaken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua obat hari ini sudah Anda minum!'),
          backgroundColor: Color(0xFF006C45),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catat Minum Obat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF006C45),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih obat yang sudah Anda minum baru saja untuk dicatat.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: untaken.length,
                    itemBuilder: (context, index) {
                      final schedule = untaken[index];
                      final timeText = '${schedule.hour.toString().padLeft(2, '0')}:${schedule.minute.toString().padLeft(2, '0')}';
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primarySurface,
                          child: Icon(Icons.medication, color: Color(0xFF006C45)),
                        ),
                        title: Text(schedule.medicationName),
                        subtitle: Text('Jadwal: $timeText WIB'),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            Navigator.pop(context);
                            await MedicationRepository.instance.recordMedicationTaken(schedule);
                            await _loadData();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Berhasil mencatat "${schedule.medicationName}"'),
                                backgroundColor: const Color(0xFF006C45),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006C45),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Minum'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress
    final totalDoses = _medicationSchedules.length;
    final takenDoses = _medicationSchedules.where((s) {
      return _todayLogs.any((l) => l.medicationName == s.medicationName);
    }).length;
    final progress = totalDoses > 0 ? takenDoses / totalDoses : 0.0;

    String nextScheduleText = 'Semua obat sudah diminum!';
    if (_medicationSchedules.isNotEmpty) {
      final untakenSchedules = _medicationSchedules.where((s) {
        return !_todayLogs.any((l) => l.medicationName == s.medicationName);
      }).toList();

      if (untakenSchedules.isNotEmpty) {
        untakenSchedules.sort((a, b) {
          final cmp = a.hour.compareTo(b.hour);
          if (cmp != 0) return cmp;
          return a.minute.compareTo(b.minute);
        });
        final next = untakenSchedules.first;
        nextScheduleText = 'Jadwal berikutnya: ${next.hour.toString().padLeft(2, '0')}:${next.minute.toString().padLeft(2, '0')} WIB';
      }
    } else {
      nextScheduleText = 'Belum ada jadwal obat aktif.';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF006C45),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              _buildHeader(context),
              const SizedBox(height: 20),

              if (_isLoading && _medicationSchedules.isEmpty && _waterSchedules.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 80.0),
                    child: CircularProgressIndicator(color: Color(0xFF006C45)),
                  ),
                )
              else ...[
                // ── Greeting ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $_userName!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tetap semangat, Anda berada di jalur yang tepat menuju kesembuhan.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Medication Card ───────────────────────────────────────
                _buildMedicationCard(context, takenDoses, totalDoses, progress, nextScheduleText),
                const SizedBox(height: 16),

                // ── Water Intake ──────────────────────────────────────────
                _buildWaterIntakeCard(context),
                const SizedBox(height: 24),

                // ── Health Check CTA ──────────────────────────────────────
                _buildHealthCheckCard(context),
                const SizedBox(height: 20),

                // ── Quick Access Cards ────────────────────────────────────
                _buildQuickAccessCards(context),
                const SizedBox(height: 24),

                // ── News Section ──────────────────────────────────────────
                _buildNewsSection(context),
                const SizedBox(height: 100),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: const AssetImage('assets/images/profile_avatar.png'),
            backgroundColor: AppColors.primarySurface,
          ),
          const SizedBox(width: 10),
          const Text(
            'Kawal TB',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF006C45),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationHistoryScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF1E293B),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(
    BuildContext context,
    int takenDoses,
    int totalDoses,
    double progress,
    String nextScheduleText,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.medical_services_rounded, color: Color(0xFF006C45), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Minum Obat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF006C45),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF475569),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Hari $_treatmentDay',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progres Hari Ini',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$takenDoses/$totalDoses Dosis',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF006C45),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF006C45)),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              nextScheduleText,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddAlarmScreen(initialCategory: 'Obat'),
                    ),
                  );
                  _loadData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D30),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Catat',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordWaterSheet(BuildContext context) {
    final untaken = _waterSchedules.where((s) {
      return !_todayLogs.any((l) => l.medicationName == s.medicationName);
    }).toList();

    if (untaken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua jadwal minum air hari ini sudah terpenuhi!'),
          backgroundColor: Color(0xFF006C45),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catat Minum Air',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF006C45),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih jadwal minum air yang sudah Anda lakukan.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: untaken.length,
                    itemBuilder: (context, index) {
                      final schedule = untaken[index];
                      final timeText = '${schedule.hour.toString().padLeft(2, '0')}:${schedule.minute.toString().padLeft(2, '0')}';
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8F5EE),
                          child: Icon(Icons.water_drop, color: Color(0xFF006C45)),
                        ),
                        title: Text(schedule.medicationName),
                        subtitle: Text('Jadwal: $timeText WIB'),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            Navigator.pop(context);
                            await MedicationRepository.instance.recordMedicationTaken(schedule);
                            await _loadData();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Berhasil mencatat "${schedule.medicationName}"'),
                                backgroundColor: const Color(0xFF006C45),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006C45),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Minum'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaterIntakeCard(BuildContext context) {
    const int total = 8;
    final filled = _todayLogs.where((log) {
      return log.medicationName == 'Minum Air' ||
             _waterSchedules.any((ws) => ws.medicationName == log.medicationName);
    }).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.water_drop, color: Color(0xFF94A3B8), size: 22),
                SizedBox(width: 8),
                Text(
                  'Minum Air',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: 14,
                    height: 36,
                    decoration: BoxDecoration(
                      color: i < filled ? const Color(0xFF006C45) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$filled/$total Gelas',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddAlarmScreen(initialCategory: 'Air'),
                      ),
                    );
                    _loadData();
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5EE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Color(0xFF006C45),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCheckCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cek Kesehatan Paru\nAnda',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Deteksi dini sangat penting. Jawab\nbeberapa pertanyaan untuk\nmengetahui risiko TBC Anda.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monitor_heart_rounded,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DiagnosaDetailScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Mulai Diagnosa Sekarang',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _QuickAccessCard(
              icon: Icons.info_outline_rounded,
              title: 'Apa itu TBC?',
              subtitle: 'Ketahui gejala dan cara pencegahannya.',
              iconBg: AppColors.primarySurface,
              iconColor: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DiagnosaDetailScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickAccessCard(
              icon: Icons.local_hospital_outlined,
              title: 'Fasilitas Medis',
              subtitle: 'Temukan puskesmas terdekat.',
              iconBg: AppColors.primarySurface,
              iconColor: AppColors.primary,
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainShell(initialIndex: 3),
                  ),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Berita Terbaru',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BeritaListScreen(),
                    ),
                  );
                },
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _newsArticles.length > 2 ? 2 : _newsArticles.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final berita = _newsArticles[i];
              return _NewsCard(
                berita: berita,
                onTap: () => _openArticle(berita),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.berita, required this.onTap});

  final BeritaModel berita;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 90,
                width: double.infinity,
                color: berita.imageBgColor,
                child: berita.imageUrl != null && berita.imageUrl!.isNotEmpty
                    ? Image.network(
                        berita.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(berita.imageIcon, color: AppColors.white, size: 36);
                        },
                      )
                    : berita.imageAsset != null
                        ? Image.asset(berita.imageAsset!, fit: BoxFit.cover)
                        : Icon(berita.imageIcon, color: AppColors.white, size: 36),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    berita.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    berita.date,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
