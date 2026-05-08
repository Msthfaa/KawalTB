import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class DiagnosaDetailScreen extends StatelessWidget {
  const DiagnosaDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.3),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Banner Image ──────────────────────────────────────
            Image.asset(
              'assets/images/banner_gejala.png',
              width: double.infinity,
              height: 320,
              fit: BoxFit.cover,
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tags ──────────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF64748B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Edukasi',
                          style: TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '5 Min Baca',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // ── Title ──────────────────────────────────────────────
                  const Text(
                    'Memahami Gejala\nAwal TBC',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // ── Author ──────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_box_rounded, color: AppColors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Tim Medis Kawal TB',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '12 Oktober 2023',
                              style: TextStyle(fontSize: 11, color: AppColors.textHint),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
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
              icon: Icons.coronavirus_rounded,
              iconColor: const Color(0xFFE53935),
              iconBg: const Color(0xFFFFEBEE),
              title: 'Batuk Berkepanjangan',
              description: 'Batuk terus-menerus yang berlangsung lebih dari 2-3 minggu, terkadang disertai dahak atau darah.',
            ),
            const SizedBox(height: 12),
            _SymptomCard(
              icon: Icons.thermostat_rounded,
              iconColor: const Color(0xFF00796B),
              iconBg: const Color(0xFFE0F2F1),
              title: 'Demam Terutama Sore Hari',
              description: 'Suhu tubuh meningkat, seringkali dirasakan pada sore hingga malam hari secara konsisten.',
            ),
            const SizedBox(height: 12),
            _SymptomCard(
              icon: Icons.water_drop_outlined,
              iconColor: const Color(0xFF475569),
              iconBg: const Color(0xFFF1F5F9),
              title: 'Keringat Malam',
              description: 'Berkeringat berlebihan di malam hari meskipun cuaca tidak panas atau ruangan bersuhu sejuk.',
            ),
            const SizedBox(height: 12),
            _SymptomCard(
              icon: Icons.monitor_weight_outlined,
              iconColor: const Color(0xFF475569),
              iconBg: const Color(0xFFF1F5F9),
              title: 'Penurunan Berat Badan',
              description: 'Nafsu makan menurun drastis yang mengakibatkan penurunan berat badan tanpa sebab yang jelas.',
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

            // ── CTA Card ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF006C45), // Dark green
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.medical_services_outlined, color: AppColors.white, size: 32),
                  const SizedBox(height: 16),
                  const Text(
                    'Butuh Konsultasi?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gunakan fitur Diagnosa awal di aplikasi\nKawal TB untuk panduan lebih lanjut.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: const Color(0xFF006C45),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Mulai Screening',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SymptomCard extends StatelessWidget {
  const _SymptomCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
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
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
