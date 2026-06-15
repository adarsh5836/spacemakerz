import 'package:flutter/material.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../constants/app_colors.dart';

class ProfileMetadataRow extends StatelessWidget {
  final LocalStorage session;
  const ProfileMetadataRow({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _item(
            label: 'Location',
            value: session.currentCity ?? 'N/A',
            icon: Icons.location_on_rounded,
            iconColor: Colors.blue,
          ),
          const SizedBox(width: 12),
          _item(
            label: 'State',
            value: session.currentState ?? 'N/A',
            icon: Icons.map_rounded,
            iconColor: Colors.purple,
          ),
          const SizedBox(width: 12),
          _item(
            label: 'Mobile',
            value: session.currentMobile ?? 'N/A',
            icon: Icons.phone_android_rounded,
            iconColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _item({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
