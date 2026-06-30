part of '../views/task_details_screen.dart';

// ── Activity Card (minimal enterprise style) ─────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final int index;
  final ActivityRecordModel activity;
  final dynamic session; // LocalStorage
  final TaskStatus taskStatus;
  final dynamic task; // TaskModel

  const _ActivityCard({
    required this.index,
    required this.activity,
    required this.session,
    required this.taskStatus,
    required this.task,
  });

  String get _shortId {
    final id = activity.activityRefNo ?? activity.id.toString();
    return id.length > 8 ? id.substring(id.length - 8) : id;
  }

  @override
  Widget build(BuildContext context) {
    final createdStr = activity.createdDate ?? '';
    final date = AppDateFormatter.formatDateTime(createdStr);

    final currentUserId =
        int.tryParse(session.currentUser?.id.toString() ?? '0') ?? 0;
    final role = session.currentRole;
    final isUser = role == UserRole.user;
    final isDealer = role == UserRole.dealer;

    // bool isOwner = false;
    // if (isUser) {
    //   isOwner = activity.empId == currentUserId;
    // } else if (isDealer) {
    //   isOwner = activity.dealerId == currentUserId;
    // }

    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppSizes.r16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Row(
          children: [
            // Status dot + index badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.accentAmber.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: AppTextStyle.subheading.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSizes.p12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   'Ref No: $_shortId',
                  //   style: AppTextStyle.body.copyWith(
                  //     fontWeight: FontWeight.w700,
                  //     color: AppColors.textPrimary,
                  //   ),
                  // ),
                  Text(
                    '${activity.village ?? "--"}, ${activity.tehsil ?? "--"}',
                    style: AppTextStyle.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // _pill(
                      //   'By: ${activity.task?.empId?.name ?? activity.empId ?? "User"}',
                      //   AppColors.primaryBlue.withValues(alpha: 0.1),
                      //   AppColors.primaryBlue,
                      // ),
                      // const SizedBox(width: 6),
                      _pill(
                        activity.flexSize ?? 'Standard Size',
                        AppColors.accentGreen.withValues(alpha: 0.12),
                        AppColors.accentGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // if (isOwner)
            //   IconButton(
            //     icon: const Icon(
            //       Icons.delete_outline_rounded,
            //       color: Colors.redAccent,
            //       size: 22,
            //     ),
            //     onPressed: () => _showDeleteConfirmation(context),
            //   ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void showDeleteConfirmation(BuildContext context) {
    final cubit = context.read<TaskDetailCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Activity?'),
        content: const Text(
          'Are you sure you want to permanently delete this activity record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await cubit.deleteActivity(activity.id);
              if (success && context.mounted) {
                AppToast.show(
                  context,
                  'Activity deleted successfully',
                  type: ToastType.success,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color bg, Color text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: AppTextStyle.caption.copyWith(
        color: text,
        fontWeight: FontWeight.w700,
        fontSize: 10,
      ),
    ),
  );

  void _openSheet(BuildContext context) {
    final cubit = context.read<TaskDetailCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: NetworkActivityBottomSheet(activity: activity, task: task),
      ),
    );
  }
}

// ── Action Row ───────────────────────────────────────────────────────────────

class ActionRow extends StatelessWidget {
  final String taskId;
  final VoidCallback onReject, onComplete;
  const ActionRow({
    required this.taskId,
    required this.onReject,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.r12),
              ),
            ),
            icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
            label: Text(
              'Reject',
              style: AppTextStyle.body.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: onReject,
          ),
        ),
        const SizedBox(width: AppSizes.p12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.r12),
              ),
            ),
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            label: Text(
              'Complete',
              style: AppTextStyle.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: onComplete,
          ),
        ),
      ],
    );
  }
}

// ── Camera FAB ───────────────────────────────────────────────────────────────

class _CameraFab extends StatelessWidget {
  final bool ready;
  final VoidCallback onTap;
  const _CameraFab({required this.ready, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ready
                ? AppColors.accentIndigoLight
                : AppColors.textSecondary,
            boxShadow: [
              BoxShadow(
                color:
                    (ready
                            ? AppColors.accentIndigoLight
                            : AppColors.textSecondary)
                        .withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.photo_camera,
            color: Colors.white,
            size: ready ? 32 : 28,
          ),
        ),
      ),
    );
  }
}

// ── Camera FAB Loading ───────────────────────────────────────────────────────

class _CameraFabLoading extends StatelessWidget {
  const _CameraFabLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade300,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppColors.primaryBlue,
              strokeWidth: 2.5,
            ),
          ),
        ),
      ),
    );
  }
}
