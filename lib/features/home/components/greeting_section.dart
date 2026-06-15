import 'package:flutter/material.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';

class GreetingSection extends StatelessWidget {
  final LocalStorage session;
  const GreetingSection({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            children: [
              const TextSpan(text: 'Hello, '),
              TextSpan(
                text: session.currentUserName?.toUpperCase() ?? 'USER',
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Opacity(
        //   opacity: 0.7,
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         'Role: ${session.currentRole.displayName}',
        //         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        //       ),
        //       Text(
        //         AppDateFormatter.formatDateTimeSlash(DateTime.now()),
        //         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
