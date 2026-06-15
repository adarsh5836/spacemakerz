import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../../routes/route_names.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _item(
          icon: Icons.event_note,
          title: 'My Attendance',
          color: AppColors.primaryBlue,
          bgColor: const Color(0xFFD3E5F1).withValues(alpha: 0.3),
          onTap: () => Get.toNamed(RouteNames.attendance),
        ),
        _item(
          icon: Icons.time_to_leave,
          title: 'Leave History',
          color: const Color(0xFF416656),
          bgColor: const Color(0xFFC3ECD7).withValues(alpha: 0.3),
          onTap: () => Get.toNamed(RouteNames.leaveHistory),
        ),
        // _item(
        //   icon: Icons.lightbulb_outline,
        //   title: 'My Projects',
        //   color: AppColors.primaryBlue,
        //   bgColor: const Color(0xFF818CF8).withValues(alpha: 0.2),
        //   onTap: () => Get.toNamed(RouteNames.projects),
        // ),
        // _item(
        //   icon: Icons.assignment_outlined,
        //   title: 'Task Report',
        //   color: const Color(0xFF50616B),
        //   bgColor: const Color(0xFFD3E5F1).withValues(alpha: 0.3),
        //   onTap: () => Get.toNamed(RouteNames.tasks),
        // ),
      ],
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
