import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_text_style.dart';
import '../../../../common/widgets/app_toast.dart';
import '../cubit/home_cubit.dart';

class MainMenuGrid extends StatelessWidget {
  const MainMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildMenuButton(
            icon: Icons.assignment,
            title: 'All Tasks',
            color: AppColors.primaryBlue,
            bgColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            onTap: () {
              context.read<HomeCubit>().changeTab(
                2,
              ); // Switch to Tasks tab (actual index 2)
            },
          ),
        ),
        // const SizedBox(width: AppSizes.p16),
        // Expanded(
        //   child: _buildMenuButton(
        //     icon: Icons.schedule,
        //     title: 'Photo History',
        //     color: AppColors.accentGreen,
        //     bgColor: AppColors.accentGreen.withValues(alpha: 0.1),
        //     onTap: () {
        //       AppToast.show(context, 'Coming soon');
        //     },
        //   ),
        // ),
        const SizedBox(width: AppSizes.p16),
        Expanded(
          child: _buildMenuButton(
            icon: Icons.account_circle,
            title: 'My Profile',
            color: AppColors.secondaryBlue,
            bgColor: AppColors.secondaryBlue.withValues(alpha: 0.1),
            onTap: () {
              context.read<HomeCubit>().changeTab(
                3,
              ); // Switch to Profile tab (actual index 3)
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.r12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.p16,
          horizontal: AppSizes.p8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppSizes.r12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: AppSizes.p12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyle.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
