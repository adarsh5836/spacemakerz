import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/repositories/auth_repository.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../constants/app_colors.dart';
import '../../../../routes/route_names.dart';
import '../../../../common/widgets/app_toast.dart';

class SettingsList extends StatelessWidget {
  final LocalStorage session;
  const SettingsList({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('Account Information', AppColors.primaryBlue),
        const SizedBox(height: 12),
        _card([
          _item(
            icon: Icons.location_on_outlined,
            title: 'Primary Location',
            subtitle: '${session.currentCity}, ${session.currentState}',
            iconBg: Colors.blue.shade50,
            iconColor: Colors.blue.shade600,
          ),
          _item(
            icon: Icons.mail_outline,
            title: 'Mobile Number',
            subtitle: session.currentMobile ?? '',
            iconBg: Colors.teal.shade50,
            iconColor: Colors.teal.shade600,
            isLast: true,
          ),
        ]),
        const SizedBox(height: 32),
        _header('Security & Privacy', AppColors.error),
        const SizedBox(height: 12),
        _card([
          _item(
            icon: Icons.lock_reset,
            title: 'Change Password',
            subtitle: 'Update your account security',
            iconBg: Colors.indigo.shade50,
            iconColor: Colors.indigo.shade600,
            onTap: () => AppToast.show(context, 'Coming soon'),
            isLast: true,
          ),
        ]),
        const SizedBox(height: 32),
        _logoutBtn(context),
      ],
    );
  }

  Widget _header(String title, Color accent) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 4, height: 16,
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w900,
                color: AppColors.textSecondary, letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(children: children),
      );

  Widget _item({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _logoutBtn(BuildContext context) {
    return InkWell(
      onTap: () async {
        final auth = context.read<AuthRepository>();
        await auth.logout();
        Get.offAllNamed(RouteNames.login);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: AppColors.error.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: const Icon(Icons.logout, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Log Out',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.error)),
                  Text('Sign out from this device',
                      style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
