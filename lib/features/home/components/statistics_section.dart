import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_text_style.dart';
import '../../tasks/cubit/tasks_cubit.dart';
import '../../tasks/cubit/tasks_state.dart';
import '../../../../app/repositories/tasks_repository.dart';
import '../../../../core/enums/app_enums.dart';
import '../cubit/home_cubit.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TasksCubit(context.read<TasksRepository>())..loadTasks(),
      child: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          int total = 0;
          int pending = 0;
          int completed = 0;
          int rejected = 0;

          if (state is TasksLoaded) {
            final tasks = state.tasks;
            total = tasks.length;
            completed = tasks
                .where((t) => t.status == TaskStatus.completed)
                .length;
            pending = tasks.where((t) => t.status == TaskStatus.pending).length;
            rejected = tasks
                .where((t) => t.status == TaskStatus.rejected)
                .length;
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.assignment_outlined,
                      title: 'Total Tasks',
                      value: total.toString(),
                      iconColor: Colors.deepPurple.shade600,
                      iconBgColor: Colors.deepPurple.shade100,
                      onTap: () {
                        TasksCubit.dashboardStatusFilter = null;
                        context.read<HomeCubit>().changeTab(2);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.p16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.pending_actions,
                      title: 'Assigned Tasks',
                      value: pending.toString(),
                      iconColor: Colors.pink.shade600,
                      iconBgColor: Colors.pink.shade100,
                      onTap: () {
                        TasksCubit.dashboardStatusFilter = TaskStatus.pending;
                        context.read<HomeCubit>().changeTab(2);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.cancel_outlined,
                      title: 'Rejected Tasks',
                      value: rejected.toString(),
                      iconColor: Colors.orange.shade600,
                      iconBgColor: Colors.orange.shade100,
                      onTap: () {
                        TasksCubit.dashboardStatusFilter = TaskStatus.rejected;
                        context.read<HomeCubit>().changeTab(2);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.p16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.task_alt,
                      title: 'Completed Tasks',
                      value: completed.toString(),
                      iconColor: Colors.teal.shade600,
                      iconBgColor: Colors.teal.shade100,
                      onTap: () {
                        TasksCubit.dashboardStatusFilter = TaskStatus.completed;
                        context.read<HomeCubit>().changeTab(2);
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.r16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.p16,
          horizontal: AppSizes.p12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppSizes.r16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                Text(
                  value,
                  style: AppTextStyle.heading.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.caption.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
