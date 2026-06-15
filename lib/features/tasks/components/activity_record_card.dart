import 'package:flutter/material.dart';
import '../../../app/models/activity_record_model.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_style.dart';
import '../../../constants/app_sizes.dart';
import '../../../core/utils/date_formatter.dart';

class ActivityRecordCard extends StatelessWidget {
  final ActivityRecordModel activity;
  final int displayIndex;
  final VoidCallback onTap;

  const ActivityRecordCard({
    super.key,
    required this.activity,
    required this.displayIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = activity.createdDate ?? '';
    final formattedDate = AppDateFormatter.formatDateTime(dateStr);
    final refNo = activity.activityRefNo ?? activity.id.toString();
    final shortRef = refNo.length > 8 ? refNo.substring(refNo.length - 8) : refNo;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.r16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Row(
              children: [
                // Index Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                  ),
                  child: Center(
                    child: Text(
                      '$displayIndex',
                      style: AppTextStyle.subheading.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ref No: $shortRef',
                        style: AppTextStyle.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formattedDate,
                        style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _badge(
                            'By: ${activity.empId ?? "Operator"}',
                            AppColors.primaryBlue.withOpacity(0.1),
                            AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          _badge(
                            activity.flexSize ?? 'Standard',
                            AppColors.success.withOpacity(0.1),
                            AppColors.success,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyle.caption.copyWith(
          color: text,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
