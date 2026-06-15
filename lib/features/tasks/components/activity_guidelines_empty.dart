import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_style.dart';
import '../../../constants/app_sizes.dart';

class ActivityGuidelinesEmpty extends StatelessWidget {
  const ActivityGuidelinesEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.p16),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.warning,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Activity Records Found',
            textAlign: TextAlign.center,
            style: AppTextStyle.heading.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'To create an activity record and display updates here, you need to capture photos of the print location and complete a submit print transaction.',
            textAlign: TextAlign.center,
            style: AppTextStyle.body.copyWith(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _guidelineRow(Icons.camera_alt_outlined, 'Open the details page of this task.'),
          _guidelineRow(Icons.add_location_alt_outlined, 'Capture real-time site photos at print location.'),
          _guidelineRow(Icons.cloud_upload_outlined, 'Submit and upload your print activity details.'),
        ],
      ),
    );
  }

  Widget _guidelineRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
