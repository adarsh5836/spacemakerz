import 'package:flutter/material.dart';
import '../../../app/models/task_model.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_style.dart';
import '../../../core/utils/date_formatter.dart';

/// Grid of task metadata fields in the Task Details screen.
class ProjectDetailsCard extends StatelessWidget {
  final TaskModel task;

  const ProjectDetailsCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Project Details',
                style: AppTextStyle.subheading.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(
                Icons.info_outline,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 2-column grid of details
          _row(
            'Assigned Date',
            AppDateFormatter.formatDateTime(task.createdAt),
            'Dealer',
            task.displayDealerName,
          ),
          const SizedBox(height: 12),
          _row('District', task.district, 'City', task.cityName),
          const SizedBox(height: 12),
          _row('State', task.stateName, 'Site Type', task.siteType.displayName),
          const SizedBox(height: 12),
          _row('NDS Count', '${task.nds} Units', 'Task Code', task.taskCode),
          if (task.installationLocation != null) ...[
            const SizedBox(height: 12),
            _single('Installation Location', task.installationLocation!),
          ],
          if (task.address.isNotEmpty) ...[
            const SizedBox(height: 12),
            _single('Address', task.address),
          ],
          if (task.latitude != null && task.longitude != null) ...[
            const SizedBox(height: 12),
            _row(
              'Latitude',
              '${task.latitude!.toStringAsFixed(4)}° N',
              'Longitude',
              '${task.longitude!.toStringAsFixed(4)}° E',
            ),
          ],
          if (task.rangeInMeter != null) ...[
            const SizedBox(height: 12),
            _single('Range', '${task.rangeInMeter} m'),
          ],
        ],
      ),
    );
  }

  Widget _row(String l1, String v1, String l2, String v2) => Row(
    children: [
      Expanded(child: _item(l1, v1)),
      Expanded(child: _item(l2, v2)),
    ],
  );

  Widget _single(String label, String value) =>
      _item(label, value, fullWidth: true);

  Widget _item(String label, String value, {bool fullWidth = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyle.caption.copyWith(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: AppTextStyle.body.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: fullWidth ? 2 : 1,
      ),
    ],
  );
}
