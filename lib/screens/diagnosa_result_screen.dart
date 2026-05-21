import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'notification_history_screen.dart';

class DiagnosaResultScreen extends StatelessWidget {
  final bool isPositive;

  const DiagnosaResultScreen({super.key, required this.isPositive});

  Widget _buildActionItem(IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 16),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'Kawal TB',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationHistoryScreen(),
                ),
              );
            },
          )
        ],
        leading: const SizedBox(), // Hide back button
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPositive
                      ? [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)]
                      : [const Color(0xFFE8F5EE), const Color(0xFFC8E6C9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: isPositive ? const Color(0xFFD32F2F) : AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isPositive ? const Color(0xFFD32F2F) : AppColors.primary).withOpacity(0.3),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      isPositive ? Icons.warning_amber_rounded : Icons.check_rounded,
                      color: AppColors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isPositive ? 'Indikasi TBC\nTerdeteksi' : 'Hasil Anda Baik',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isPositive ? const Color(0xFFB71C1C) : AppColors.primaryDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPositive
                        ? 'Berdasarkan hasil analisa gejala, Anda memiliki probabilitas tinggi terpapar Tuberkulosis.'
                        : 'Selamat! Berdasarkan evaluasi terbaru, tidak ditemukan indikasi risiko. Paru-paru Anda dalam kondisi sehat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isPositive ? const Color(0xFFC62828) : AppColors.primaryDark,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (isPositive) ...[
              // Tindakan Segera Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
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
                    Row(
                      children: const [
                        Icon(Icons.emergency, color: Color(0xFFD32F2F), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Tindakan Segera',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Jangan panik. TBC dapat disembuhkan dengan pengobatan yang tepat. Segera kunjungi fasilitas kesehatan untuk pemeriksaan dahak (TCM).',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to hospital finder
                        },
                        icon: const Icon(Icons.add_box_rounded, color: AppColors.white, size: 18),
                        label: const Text(
                          'Cari Rumah Sakit Terdekat',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Langkah Pencegahan Penularan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Langkah Pencegahan Penularan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionItem(
                      Icons.masks_outlined,
                      'Gunakan Masker',
                      'Selalu gunakan masker medis (minimal 3 lapis) saat berinteraksi dengan orang lain.',
                    ),
                    _buildActionItem(
                      Icons.air_outlined,
                      'Buka Ventilasi',
                      'Pastikan sirkulasi udara di rumah berjalan baik. Buka jendela agar sinar matahari masuk.',
                    ),
                    _buildActionItem(
                      Icons.clean_hands_outlined,
                      'Jaga Kebersihan',
                      'Cuci tangan pakai sabun dan tutup mulut saat batuk atau bersin dengan lengan dalam.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Cara Menjaga Kesehatan Paru
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cara Menjaga Kesehatan Paru',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionItem(
                      Icons.air_outlined,
                      'Udara Bersih',
                      'Pastikan ventilasi rumah baik dan hindari paparan asap rokok atau polusi.',
                    ),
                    _buildActionItem(
                      Icons.directions_run_outlined,
                      'Aktivitas Fisik',
                      'Rutin berolahraga 30 menit sehari untuk memperkuat kapasitas pernapasan.',
                    ),
                    _buildActionItem(
                      Icons.restaurant_outlined,
                      'Nutrisi Seimbang',
                      'Konsumsi makanan kaya antioksidan seperti buah dan sayur untuk menjaga daya tahan tubuh tetap optimal.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Kembali ke Beranda',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.home_outlined, color: AppColors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
