import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'diagnosa_screen.dart';
import 'notification_history_screen.dart';

class DiagnosaDetailScreen extends StatelessWidget {
  const DiagnosaDetailScreen({super.key});

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
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
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Kawal TB',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primaryDark),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 32.0, bottom: 120.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Big Circle Icon
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                // Menggunakan placeholder ikon paru-paru
                Icons.health_and_safety,
                size: 60,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 32),
            
            // Title
            const Text(
              'Kenali Kondisi Paru\nAnda Sejak Dini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            
            // Subtitle
            const Text(
              'Diagnosis dini adalah langkah pertama\nmenuju pemulihan. Evaluasi gejala Anda\nsekarang untuk mendapatkan panduan\nmedis yang tepat dan menjaga\nkesehatan paru-paru Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            
            // Cards
            _buildFeatureCard(
              icon: Icons.speed_rounded,
              title: 'Cepat & Akurat',
              description: 'Hanya butuh 5 menit untuk menjawab pertanyaan terkait gejala Anda saat ini.',
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              icon: Icons.shield_outlined,
              title: 'Aman & Privat',
              description: 'Data kesehatan Anda dienkripsi dan hanya yang bisa melihatnya.',
            ),
            const SizedBox(height: 40),
            
            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DiagnosaScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.medical_services_outlined, color: AppColors.white, size: 20),
                label: const Text(
                  'Mulai Diagnosa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
