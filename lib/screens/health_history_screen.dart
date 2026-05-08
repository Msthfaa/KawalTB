import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class HealthHistoryScreen extends StatelessWidget {
  const HealthHistoryScreen({super.key});

  Widget _buildChip(String label, {bool isSelected = false}) {
    return Container(
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
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.white : AppColors.textPrimary,
        ),
      ),
    );
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
          color: isPrimary ? AppColors.primary : const Color(0xFFF8FAFC),
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
                  Icons.medication,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? AppColors.white : AppColors.textPrimary,
                  size: 20,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? AppColors.white : AppColors.textPrimary,
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
                        color: isPrimary ? AppColors.white : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isPrimary ? AppColors.white : AppColors.primary,
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
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCircle(String type) {
    if (type == 'check') {
      return Container(
        margin: const EdgeInsets.only(right: 6),
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: AppColors.white, size: 14),
      );
    } else if (type == 'cross') {
      return Container(
        margin: const EdgeInsets.only(right: 6),
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFFFCA5A5), // Light Red
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Color(0xFFDC2626), size: 14), // Red cross
      );
    } else if (type == 'check_light') {
      return Container(
        margin: const EdgeInsets.only(right: 6),
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFFA7F3D0), // Light Green
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: AppColors.primary, size: 14),
      );
    } else {
      // Empty / dots
      return Container(
        margin: const EdgeInsets.only(right: 6),
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_horiz, color: Color(0xFF94A3B8), size: 14),
      );
    }
  }

  Widget _buildWeeklyCard(String title, String badgeText, Color badgeColor, Color badgeTextColor,
      List<String> obatStatuses, List<String> airStatuses) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (badgeText == 'Sangat Baik') ...[
                      Icon(Icons.trending_up, size: 12, color: badgeTextColor),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: badgeTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Obat row
          Row(
            children: [
              SizedBox(
                width: 60,
                child: Row(
                  children: const [
                    Icon(Icons.medication, size: 12, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text('Obat', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: obatStatuses.map((s) => _buildStatusCircle(s)).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Air row
          Row(
            children: [
              SizedBox(
                width: 60,
                child: Row(
                  children: const [
                    Icon(Icons.water_drop, size: 12, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text('Air', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: airStatuses.map((s) => _buildStatusCircle(s)).toList(),
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
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChip('Bulan Ini', isSelected: true),
                  _buildChip('Oktober 2023'),
                  _buildChip('September 2023'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            Row(
              children: [
                _buildSummaryCard(
                  title: 'Minum Obat',
                  percentage: '94',
                  icon: Icons.medication,
                  isPrimary: true,
                ),
                const SizedBox(width: 16),
                _buildSummaryCard(
                  title: 'Minum Air',
                  percentage: '82',
                  icon: Icons.water_drop,
                  isPrimary: false,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Weekly Detail Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Detail Mingguan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Nov 2023',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Week 2
            _buildWeeklyCard(
              'Minggu ke-2',
              'Sangat Baik',
              const Color(0xFFE8F5E9), // Light Green bg
              const Color(0xFF006C45), // Dark Green text
              ['check', 'check', 'check', 'empty', 'empty', 'empty', 'empty'],
              ['check_light', 'cross', 'check_light', 'empty', 'empty', 'empty', 'empty'],
            ),

            // Week 1
            _buildWeeklyCard(
              'Minggu ke-1',
              'Selesai',
              const Color(0xFFE2E8F0), // Grey bg
              AppColors.textSecondary, // Grey text
              ['check', 'check', 'check', 'check', 'cross', 'check', 'check'],
              ['check_light', 'check_light', 'check_light', 'check_light', 'check_light', 'check_light', 'check_light'],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
