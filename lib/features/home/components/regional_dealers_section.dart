import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_text_style.dart';
import '../../../../app/services/json_storage_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/enums/app_enums.dart';
import '../../../../common/widgets/app_toast.dart';

class RegionalDealersSection extends StatelessWidget {
  final String? managerState;
  const RegionalDealersSection({super.key, required this.managerState});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDealerListHeader(context),
        const SizedBox(height: AppSizes.p16),
        _buildDealerListWidget(context),
      ],
    );
  }

  Widget _buildDealerListHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'REGIONAL DEALERS',
          style: AppTextStyle.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'State View',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDealerListWidget(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: di.sl<JsonStorageService>().readAll('users.json'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final allUsers = snapshot.data!;
        // Filter dealers matching manager's state
        final dealers = allUsers
            .where((u) => u['role'] == 'dealer' && u['state'] == managerState)
            .toList();

        if (dealers.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No active dealers found in your state.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        // Fetch tasks to compute pending tasks per dealer
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: di.sl<JsonStorageService>().readAll('tasks.json'),
          builder: (context, taskSnapshot) {
            final tasksList = taskSnapshot.data ?? [];

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dealers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final dealer = dealers[index];
                final dealerId = dealer['id'];

                // Count pending tasks for this dealer
                final pendingTasksCount = tasksList
                    .where(
                      (t) =>
                          t['dealer_id'] == dealerId &&
                          t['status'] == 'pending',
                    )
                    .length;

                return _buildDealerCard(context, dealer, pendingTasksCount);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDealerCard(
    BuildContext context,
    Map<String, dynamic> dealer,
    int pendingCount,
  ) {
    final name = dealer['name'] ?? 'Unknown Dealer';
    final city = dealer['city'] ?? '';
    final state = dealer['state'] ?? '';
    final mobileNo = dealer['mobile_no'] ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Elegant Round Avatar
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Dealer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$city, $state',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      mobileNo,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status Info & Call Trigger
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pendingCount > 0
                      ? Colors.amber.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pendingCount Pending',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: pendingCount > 0
                        ? Colors.amber.shade700
                        : Colors.green.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Call action button
              GestureDetector(
                onTap: () {
                  AppToast.show(
                    context,
                    'Calling $name ($mobileNo)...',
                    type: ToastType.success,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone,
                    size: 14,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
