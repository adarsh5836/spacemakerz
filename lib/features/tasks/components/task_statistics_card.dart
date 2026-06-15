import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_style.dart';

/// Four-card stats row shown on the Task Details screen.
class TaskStatisticsCard extends StatelessWidget {
  final int total;
  final int completed;
  final int pending;
  final int extraValue;
  final String pendingLabel;
  final String extraLabel;

  const TaskStatisticsCard({
    super.key,
    required this.total,
    required this.completed,
    required this.pending,
    this.extraValue = 0,
    this.pendingLabel = 'Pending',
    this.extraLabel = 'Photos',
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _statCard('Total Tasks', '$total', highlighted: true),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _progressCard('Completed', '$completed', progress),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _statCard(pendingLabel, '$pending')),
              const SizedBox(width: 14),
              Expanded(child: _statCard(extraLabel, '$extraValue')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, {bool highlighted = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: highlighted
            ? const Border(
                left: BorderSide(color: AppColors.primaryBlue, width: 4))
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyle.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value,
              style:
                  AppTextStyle.heading.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _progressCard(String label, String value, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: AppTextStyle.caption
                      .copyWith(color: AppColors.textSecondary)),
              Text('${(progress * 100).toInt()}%',
                  style: AppTextStyle.caption
                      .copyWith(color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style:
                  AppTextStyle.heading.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.backgroundLight,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.success),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
