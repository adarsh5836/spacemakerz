import 'package:flutter/material.dart';
import '../../../common/widgets/common_app_bar.dart';
import '../../../common/widgets/common_card.dart';
import '../../../common/widgets/common_button.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_text_style.dart';

class AttendanceScreen extends StatelessWidget {
  final bool showBackButton;
  
  const AttendanceScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showBackButton 
          ? const CommonAppBar(title: 'Mark Attendance')
          : null, // AppBar handled by HomeScreen if used in BottomNav
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Camera Preview Container (Mock)
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(AppSizes.r16),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                  Positioned(
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Live Selfie Preview',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.p24),

            // Location Section
            Text('Current Location', style: AppTextStyle.heading),
            const SizedBox(height: AppSizes.p16),
            
            Row(
              children: [
                Expanded(
                  child: CommonCard(
                    padding: const EdgeInsets.all(AppSizes.p16),
                    child: Column(
                      children: [
                        const Icon(Icons.explore, color: AppColors.primaryBlue),
                        const SizedBox(height: 8),
                        Text('Latitude', style: AppTextStyle.caption),
                        Text('28.6139', style: AppTextStyle.subheading),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: CommonCard(
                    padding: const EdgeInsets.all(AppSizes.p16),
                    child: Column(
                      children: [
                        const Icon(Icons.explore_outlined, color: AppColors.primaryYellow),
                        const SizedBox(height: 8),
                        Text('Longitude', style: AppTextStyle.caption),
                        Text('77.2090', style: AppTextStyle.subheading),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSizes.p16),
            CommonCard(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.error, size: 32),
                  const SizedBox(width: AppSizes.p16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address', style: AppTextStyle.caption),
                        Text(
                          'Connaught Place, New Delhi, Delhi 110001, India',
                          style: AppTextStyle.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSizes.p32),
            CommonButton(
              text: 'Capture Attendance',
              onPressed: () {
                // Handle attendance marking
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attendance Marked Successfully')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
