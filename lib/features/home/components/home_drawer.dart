import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/repositories/auth_repository.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_style.dart';
import '../../../../routes/route_names.dart';
import '../../../../common/widgets/app_toast.dart';
import '../cubit/home_cubit.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<LocalStorage>();

    return Drawer(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Stack(
        children: [
          // Glass Effect Background
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite.withValues(alpha: 0.85),
                  border: const Border(
                    right: BorderSide(color: Colors.white24, width: 1),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    context.read<HomeCubit>().changeTab(3); // Switch to Profile tab
                  },
                  behavior: HitTestBehavior.opaque,
                  child: _buildHeader(session),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(
                    color: AppColors.border.withValues(alpha: 0.3),
                    height: 1,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        _item(
                          icon: Icons.policy_outlined,
                          title: 'Privacy Policy',
                          onTap: () => AppToast.show(context, 'Coming soon'),
                        ),
                        _item(
                          icon: Icons.gavel_outlined,
                          title: 'Terms & Conditions',
                          onTap: () => AppToast.show(context, 'Coming soon'),
                        ),
                        _item(
                          icon: Icons.share_outlined,
                          title: 'Share App',
                          onTap: () => AppToast.show(context, 'Coming soon'),
                        ),
                        _item(
                          icon: Icons.system_update_outlined,
                          title: 'Check App Update',
                          showBadge: true,
                          onTap: () => AppToast.show(context, 'Coming soon'),
                        ),
                        const SizedBox(height: 24),
                        Divider(
                          color: AppColors.border.withValues(alpha: 0.3),
                          height: 1,
                        ),
                        const SizedBox(height: 24),
                        _item(
                          icon: Icons.logout,
                          title: 'Log out',
                          isDestructive: true,
                          onTap: () async {
                            await context.read<AuthRepository>().logout();
                            Get.offAllNamed(RouteNames.login);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(LocalStorage session) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.backgroundLight,
                  backgroundImage: NetworkImage(
                    'https://api.dicebear.com/7.x/avataaars/png?seed=Jitendra',
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.currentUserName?.toUpperCase() ?? 'USER',
                  style: AppTextStyle.heading.copyWith(
                    fontSize: 16,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    session.currentRole.displayName.toUpperCase(),
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showBadge = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.backgroundLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.body.copyWith(
                  color: color.withValues(alpha: 0.8),
                  fontWeight: isDestructive ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (showBadge)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              )
            else if (!isDestructive)
              Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textSecondary.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'v2.5.0',
            style: AppTextStyle.caption.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Spacemakerz',
            style: AppTextStyle.caption.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              letterSpacing: 2,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
