import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _handleLogout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.medical_services_rounded, color: AppColors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'Kawal TB',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            onPressed: () => _handleLogout(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Success banner ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Login Berhasil!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Selamat datang di Dashboard Kawal TB.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section title ────────────────────────────────────────────
            const Text(
              'Ringkasan Kesehatan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            // ── Stat cards ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.medication_rounded,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.primarySurface,
                    label: 'Obat Hari Ini',
                    value: '3 dari 3',
                    subtitle: 'Selesai ✓',
                    subtitleColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_month_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    iconBg: const Color(0xFFF3EFFF),
                    label: 'Hari Pengobatan',
                    value: '47 Hari',
                    subtitle: 'Dari 180 hari',
                    subtitleColor: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFF0EA5E9),
                    iconBg: const Color(0xFFEFF9FF),
                    label: 'Kepatuhan',
                    value: '94%',
                    subtitle: 'Sangat Baik',
                    subtitleColor: const Color(0xFF0EA5E9),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    icon: Icons.notifications_active_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    iconBg: const Color(0xFFFFFBEB),
                    label: 'Pengingat',
                    value: '08:00',
                    subtitle: 'Jadwal berikut',
                    subtitleColor: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Progress section ─────────────────────────────────────────
            const Text(
              'Progress Pengobatan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _ProgressCard(),
            const SizedBox(height: 24),

            // ── Quick actions ────────────────────────────────────────────
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _QuickActions(),
          ],
        ),
      ),
    );
  }
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String subtitle;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
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
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: subtitleColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double progress = 0.26; // 47/180

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
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
              const Text(
                'Fase Intensif',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Bulan ke-2',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '47 dari 180 hari telah selesai',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% selesai',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.check_box_outlined, 'Catat Obat', AppColors.primary, AppColors.primarySurface),
      (Icons.note_add_outlined, 'Laporan', const Color(0xFF7C3AED), const Color(0xFFF3EFFF)),
      (Icons.person_outline_rounded, 'Profil', const Color(0xFF0EA5E9), const Color(0xFFEFF9FF)),
      (Icons.help_outline_rounded, 'Bantuan', const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) {
        final (icon, label, color, bg) = actions[i];
        return GestureDetector(
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
