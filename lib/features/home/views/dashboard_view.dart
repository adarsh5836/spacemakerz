import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/local_storage.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_text_style.dart';
import '../components/greeting_section.dart';
import '../components/statistics_section.dart';
import '../components/main_menu_grid.dart';
import '../components/regional_dealers_section.dart';

import '../../../core/enums/app_enums.dart';
import '../../tasks/cubit/tasks_cubit.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Reset dashboard task status filter when visiting Dashboard!
    TasksCubit.dashboardStatusFilter = null;

    final session = context.read<LocalStorage>();

    return Container(
      color: const Color(0xFFF8FAFC),
      constraints: const BoxConstraints.expand(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p24,
          vertical: AppSizes.p16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Hero Section
            // GreetingSection(session: session),
            // const SizedBox(height: AppSizes.p32),

            // Attendance Warning (Alert Style)
            // _buildAttendanceWarning(),

            // Check-In Action Card
            // const CheckInCard(),

            // Dashboard Quick Actions
            // Text(
            //   'QUICK ACTIONS',
            //   style: AppTextStyle.caption.copyWith(
            //     fontWeight: FontWeight.bold,
            //     letterSpacing: 1.2,
            //     color: AppColors.textSecondary,
            //   ),
            // ),
            // const DashboardQuickActions(),
            const StatisticsSection(),
            const SizedBox(height: AppSizes.p24),
            const MainMenuGrid(),
            // const SizedBox(height: AppSizes.p24),
            // const CurrentFocusSection(),
            // const SizedBox(height: AppSizes.p32),

            // Regional Dealers Directory (Only visible for Manager roles)
            if (session.currentRole == UserRole.manager) ...[
              const SizedBox(height: AppSizes.p32),
              RegionalDealersSection(managerState: session.currentState),
            ],
            const SizedBox(height: AppSizes.p32),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceWarning() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: AppColors.error.withValues(alpha: 0.5)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "You haven't marked attendance yet. Please mark attendance before continuing.",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
