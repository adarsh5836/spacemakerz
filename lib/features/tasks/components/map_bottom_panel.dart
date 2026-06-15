import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_style.dart';

class MapBottomPanel extends StatelessWidget {
  final String destinationAddress;
  final double distanceInKm;
  final double durationInMins;
  final bool isWalking;
  final Function(bool) onModeChanged;

  const MapBottomPanel({
    super.key,
    required this.destinationAddress,
    required this.distanceInKm,
    required this.durationInMins,
    required this.isWalking,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Address Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pin_drop_rounded,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destination Print Location',
                      style: AppTextStyle.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destinationAddress,
                      style: AppTextStyle.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Distance / Duration Stats Blocks
          Row(
            children: [
              Expanded(
                child: _statBlock(
                  icon: Icons.directions_bike_rounded,
                  label: 'REMAINING',
                  value: distanceInKm > 0
                      ? '${distanceInKm.toStringAsFixed(2)} km'
                      : 'Calculating...',
                  color: AppColors.accentIndigoDeep,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statBlock(
                  icon: Icons.access_time_rounded,
                  label: 'EST. TIME',
                  value: durationInMins > 0
                      ? '${durationInMins.toStringAsFixed(0)} mins'
                      : 'Calculating...',
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 20),

          // Mode selection row (Commented out for now; by default driving is used)
          /*
          Row(
            children: [
              Expanded(
                child: _modeButton(
                  icon: Icons.motorcycle_rounded,
                  label: 'Driving (Bike)',
                  isSelected: !isWalking,
                  color: AppColors.accentIndigoDeep,
                  onTap: () => onModeChanged(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _modeButton(
                  icon: Icons.directions_walk_rounded,
                  label: 'Walking (Pedestrian)',
                  isSelected: isWalking,
                  color: AppColors.success,
                  onTap: () => onModeChanged(true),
                ),
              ),
            ],
          ),
          */
        ],
      ),
    );
  }

  Widget _statBlock({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.24),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
