import 'package:flutter/material.dart';
import '../../../app/models/project_model.dart';
import '../../../constants/app_colors.dart';
import '../../../../core/enums/app_enums.dart';

/// Reusable project list card.
class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;

  const ProjectCard({super.key, required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCompleted = project.status.name == 'completed';
    final statusColor = isCompleted ? AppColors.success : AppColors.secondaryBlue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Coloured top strip ──────────────────────────────────
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: _priorityColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Status chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          project.projectName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          project.status.displayName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Code + City row
                  Row(
                    children: [
                      const Icon(Icons.qr_code,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(project.projectCode,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 14),
                      const Icon(Icons.location_city,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text('${project.city}, ${project.state}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Date range
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '${project.startDate}  →  ${project.endDate}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    project.description,
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
                        height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _priorityBadge,
                      const Row(
                        children: [
                          Text('View Details',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryBlue)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward,
                              size: 14, color: AppColors.primaryBlue),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _priorityColor {
    switch (project.priority) {
      case ProjectPriority.critical: return const Color(0xFFEF4444);
      case ProjectPriority.high:     return const Color(0xFFF59E0B);
      case ProjectPriority.medium:   return AppColors.secondaryBlue;
      case ProjectPriority.low:      return AppColors.success;
    }
  }

  Widget get _priorityBadge => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _priorityColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${project.priority.name.toUpperCase()} PRIORITY',
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w800, color: _priorityColor),
        ),
      );
}
