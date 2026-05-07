import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class DiagnosaDetailScreen extends StatelessWidget {
  const DiagnosaDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Memahami Gejala Awal TBC',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: AppColors.textSecondary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Intro Text ────────────────────────────────────────
            const Text(
              'Tuberculosis (TBC) adalah penyakit menular yang disebabkan oleh bakteri Mycobacterium tuberculosis. '
              'Gejala awal TBC seringkali tidak spesifik, sehingga penting untuk mengenali tanda-tanda awal '
              'agar dapat segera mendapatkan penanganan medis.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'sumber: Kementerian Kesehatan RI',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            // ── Section Title ──────────────────────────────────────
            const Text(
              'Gejala Utama yang Perlu Diperhatikan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gejala TBC bisa bervariasi dan sering disalahartikan sebagai penyakit lain. '
              'Penting untuk mengenali gejala-gejala berikut sejak dini.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // ── Symptom Cards ──────────────────────────────────────
            _SymptomCard(
              icon: Icons.thermostat_rounded,
              title: 'Demam Terus-menerus Selama 3 Hari atau Lebih',
              description: 'Suhu tubuh meningkat tanpa ada penyebab jelas.',
            ),
            const SizedBox(height: 12),
            _SymptomCard(
              icon: Icons.sick_rounded,
              title: 'Batuk Berkepanjangan',
              description:
                  'Batuk yang berlangsung lebih dari 2 minggu, seringkali disertai dahak berdarah.',
            ),
            const SizedBox(height: 12),
            _SymptomCard(
              icon: Icons.nights_stay_rounded,
              title: 'Keringat Malam',
              description:
                  'Keringat berlebihan saat tidur, meskipun ruangan tidak panas.',
            ),
            const SizedBox(height: 12),
            _SymptomCard(
              icon: Icons.trending_down_rounded,
              title: 'Penurunan Berat Badan Drastis',
              description:
                  'Hilangnya nafsu makan dan penurunan berat badan tanpa alasan.',
            ),
            const SizedBox(height: 28),

            // ── Next Steps ─────────────────────────────────────────
            const Text(
              'Langkah Selanjutnya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jika Anda mengalami gejala-gejala di atas, segera konsultasikan dengan dokter '
              'untuk mendapatkan pemeriksaan dan penanganan yang tepat.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // ── CTA Button ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Buat Janji Konsultasi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SymptomCard extends StatelessWidget {
  const _SymptomCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
