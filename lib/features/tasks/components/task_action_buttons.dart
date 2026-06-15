import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

/// Bottom action bar for Task Details. Hidden when [visible] is false
/// (e.g., task is completed/rejected or role has no permission).
class TaskActionButtons extends StatelessWidget {
  final bool visible;
  final VoidCallback? onReject;
  final VoidCallback? onAddPhoto;
  final VoidCallback? onComplete;

  const TaskActionButtons({
    super.key,
    required this.visible,
    this.onReject,
    this.onAddPhoto,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (onReject != null)
            Expanded(
              child: _btn(
                label: 'Reject',
                icon: Icons.close,
                bg: AppColors.backgroundLight,
                fg: AppColors.textSecondary,
                onTap: onReject!,
              ),
            ),
          // if (onReject != null) const SizedBox(width: 8),
          // if (onAddPhoto != null)
          //   Expanded(
          //     child: _btn(
          //       label: 'Add Photo',
          //       icon:  Icons.add_a_photo,
          //       bg:    Colors.transparent,
          //       fg:    AppColors.primaryBlue,
          //       outlined: true,
          //       onTap: onAddPhoto!,
          //     ),
          //   ),
          if (onAddPhoto != null) const SizedBox(width: 8),
          if (onComplete != null)
            Expanded(
              child: _btn(
                label: 'Complete',
                icon: Icons.check_circle_outline,
                bg: AppColors.primaryBlue,
                fg: Colors.white,
                onTap: onComplete!,
              ),
            ),
        ],
      ),
    );
  }

  Widget _btn({
    required String label,
    required IconData icon,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: fg),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          side: outlined
              ? const BorderSide(color: AppColors.primaryBlue)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
