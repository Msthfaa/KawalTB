import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// App logo mark — the green rounded-square with a medical cross icon,
/// matching the design reference.
class KawalLogo extends StatelessWidget {
  const KawalLogo({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.medical_services_rounded,
        color: AppColors.white,
        size: size * 0.48,
      ),
    );
  }
}
