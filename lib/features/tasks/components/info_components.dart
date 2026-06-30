part of '../views/task_details_screen.dart';

// ── Gradient AppBar ──────────────────────────────────────────────────────────

class _GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _GradientAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.accentIndigoDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: AppTextStyle.subheading.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.workspace_premium, color: Colors.white),
        ),
      ],
    );
  }
}

// ── Project Details Card ─────────────────────────────────────────────────────

class _ProjectDetailsCard extends StatelessWidget {
  final dynamic task;
  const _ProjectDetailsCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with golden underline
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Details',
                style: AppTextStyle.subheading.copyWith(
                  color: AppColors.accentIndigoDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 3,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.accentAmber,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p16),
          _infoRow(
            'Start Date',
            AppDateFormatter.formatDate(task.projectId?.startDate),
          ),
          _infoRow(
            'End Date',
            AppDateFormatter.formatDate(task.projectId?.endDate),
          ),
          _infoRow('Dealer', task.displayDealerName),
          _infoRow(
            'District',
            task.district.isNotEmpty
                ? task.district
                : (task.cityName.isNotEmpty ? task.cityName : "-"),
          ),
          _infoRow('State', task.stateName.isNotEmpty ? task.stateName : '-'),
          _infoRowWidget('Status', _StatusBadge(status: task.status)),
          if (task.remarks != null && task.remarks!.isNotEmpty)
            _infoRow('Remarks', task.remarks!),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: AppSizes.p12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyle.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  Widget _infoRowWidget(String label, Widget widget) => Padding(
    padding: const EdgeInsets.only(bottom: AppSizes.p12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyle.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        widget,
      ],
    ),
  );
}

// ── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int ndsTotal, ndsDone, range;
  const _StatsRow({
    required this.ndsTotal,
    required this.ndsDone,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Print Info (NDS)',
                  style: AppTextStyle.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.p12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total', style: AppTextStyle.caption),
                        Text(
                          '$ndsTotal',
                          style: AppTextStyle.heading.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Done', style: AppTextStyle.caption),
                        Text(
                          '$ndsDone',
                          style: AppTextStyle.heading.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSizes.p16),
        Expanded(
          child: _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Range Info',
                  style: AppTextStyle.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.p12),
                Text('Range', style: AppTextStyle.caption),
                Text(
                  '${range} mtr',
                  style: AppTextStyle.heading.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Status Alert ─────────────────────────────────────────────────────────────

class _StatusAlert extends StatelessWidget {
  final TaskDetailLoaded state;
  const _StatusAlert({required this.state});

  @override
  Widget build(BuildContext context) {
    final localStorage = context.read<LocalStorage>();
    if (localStorage.currentRole == UserRole.manager) {
      return const SizedBox.shrink();
    }

    final dist = state.distanceFromLastPhoto;
    final ready = state.readyToCapture;
    final range = state.task.rangeInMeter ?? 100.0;

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (state.activities.isEmpty) {
      statusText = 'Ready to take first photo';
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_outline;
    } else if (ready) {
      final distStr = dist != null ? '${dist.toStringAsFixed(1)}m' : '–';
      statusText = 'Ready to take next photo (Distance: $distStr)';
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_outline;
    } else {
      final distStr = dist != null ? '${dist.toStringAsFixed(1)}m' : '–';
      final remaining = dist != null
          ? (range - dist).clamp(0.0, range).toStringAsFixed(1)
          : '–';
      statusText = 'Move $remaining m more (Current: $distStr)';
      statusColor = AppColors.error;
      statusIcon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.r12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 22),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Current Status: ',
                    style: AppTextStyle.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Required Distance Gap: ${range.toStringAsFixed(0)} meters (defined for this task)',
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Location Bar ─────────────────────────────────────────────────────────────

class _LocationBar extends StatelessWidget {
  final TaskDetailLoaded state;
  const _LocationBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final localStorage = context.read<LocalStorage>();
    if (localStorage.currentRole == UserRole.manager) {
      return const SizedBox.shrink();
    }
    final lat = state.currentLat;
    final lng = state.currentLng;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p12,
      ),
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSizes.r12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latitude',
                    style: AppTextStyle.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    lat != null ? lat.toStringAsFixed(5) : '–',
                    style: AppTextStyle.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.map, color: AppColors.accentGreen, size: 20),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Longitude',
                    style: AppTextStyle.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    lng != null ? lng.toStringAsFixed(5) : '–',
                    style: AppTextStyle.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, text;
    switch (status) {
      case TaskStatus.completed:
        bg = Colors.green.shade100;
        text = Colors.green.shade800;
      case TaskStatus.rejected:
        bg = Colors.red.shade100;
        text = Colors.red.shade800;
      case TaskStatus.inProgress:
        bg = Colors.orange.shade100;
        text = Colors.orange.shade800;
      case TaskStatus.pending:
        bg = Colors.blue.shade100;
        text = Colors.blue.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.displayName,
        style: AppTextStyle.caption.copyWith(
          color: text,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Reusable Card shell ───────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
