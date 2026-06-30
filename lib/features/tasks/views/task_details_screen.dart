import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/repositories/tasks_repository.dart';
import '../../../app/models/activity_record_model.dart';
import '../../../core/storage/local_storage.dart';
import '../../../common/widgets/app_toast.dart';
import '../../../common/widgets/common_loader.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_text_style.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/distance_calculator.dart';
import '../cubit/task_detail_cubit.dart';
import '../cubit/task_detail_state.dart';
import 'photo_capture_screen.dart';
import 'activity_location_map_screen.dart';

part '../components/info_components.dart';
part '../components/activity_components.dart';
part '../components/geo_photo_full_screen.dart';
part '../components/activity_bottom_sheets.dart';

class TaskDetailsScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          TaskDetailCubit(ctx.read<TasksRepository>())..loadTask(taskId),
      child: _TaskDetailsView(taskId: taskId),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TaskDetailsView extends StatelessWidget {
  final String taskId;
  const _TaskDetailsView({required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskDetailCubit, TaskDetailState>(
      listenWhen: (_, s) => s is TaskDetailError,
      listener: (context, state) {
        if (state is TaskDetailError) {
          AppToast.show(context, state.message, type: ToastType.error);
        }
      },
      builder: (context, state) {
        if (state is TaskDetailLoading || state is TaskDetailInitial) {
          return const Scaffold(body: CommonLoader());
        }

        if (state is TaskDetailError) {
          return Scaffold(
            appBar: const _GradientAppBar(title: 'Task Details'),
            body: Center(
              child: Text(
                state.message,
                style: AppTextStyle.body.copyWith(color: AppColors.error),
              ),
            ),
          );
        }

        final loaded = state is TaskDetailLoaded
            ? state
            : TaskDetailLoaded(
                task: (state as TaskDetailUpdating).task,
                photos: state.photos,
                canUpload: false,
                canChangeStatus: false,
              );
        final isUpdating = state is TaskDetailUpdating;
        final task = loaded.task;
        final photos = loaded.photos;
        final session = context.read<LocalStorage>();

        final groupedPhotos = <String, List<dynamic>>{};
        for (var p in photos) {
          final actId = p.activityId ?? p.id;
          groupedPhotos.putIfAbsent(actId, () => []).add(p);
        }
        final activityEntries = groupedPhotos.entries.toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _GradientAppBar(title: task.taskTitle),
          body: Stack(
            children: [
              // ── Scrollable content ────────────────────────────────────────
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.p24,
                  AppSizes.p16,
                  AppSizes.p24,
                  120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Project Details Card
                    _ProjectDetailsCard(task: task),
                    const SizedBox(height: AppSizes.p16),

                    // 2. Stats row  (NDS / Range)
                    // _StatsRow(
                    //   ndsTotal: task.nds,
                    //   ndsDone: activityEntries.length,
                    //   range: task.rangeInMeter?.toInt() ?? 100,
                    // ),
                    // const SizedBox(height: AppSizes.p16),

                    // 3. Status / distance alert
                    // _StatusAlert(state: loaded),
                    // const SizedBox(height: AppSizes.p16),

                    // Total Print Path Distance Card
                    _TotalDistanceCard(activities: loaded.activities),
                    const SizedBox(height: AppSizes.p16),

                    // 4. Location bar (live GPS)
                    // _LocationBar(state: loaded),
                    // const SizedBox(height: AppSizes.p16),

                    // 5. Task Activity Cards (from backend API)
                    if (loaded.activities.isNotEmpty) ...[
                      Text(
                        'Task Activity',
                        style: AppTextStyle.subheading.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p12),
                      Column(
                        children: loaded.activities.asMap().entries.map((e) {
                          final idx = e.key + 1;
                          final activity = e.value;
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSizes.p12,
                            ),
                            child: _ActivityCard(
                              index: idx,
                              activity: activity,
                              session: session,
                              taskStatus: task.status,
                              task: task,
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // 6. Action buttons
                    // if (loaded.canChangeStatus) ...[
                    //   const SizedBox(height: AppSizes.p8),
                    //   _ActionRow(
                    //     taskId: taskId,
                    //     onReject: () => _confirm(
                    //       context,
                    //       'Reject Task',
                    //       'Mark this task as rejected?',
                    //       () => context.read<TaskDetailCubit>().updateStatus(
                    //         taskId,
                    //         TaskStatus.rejected,
                    //       ),
                    //     ),
                    //     onComplete: () => _confirm(
                    //       context,
                    //       'Mark Complete',
                    //       'Mark this task as completed?',
                    //       () => context.read<TaskDetailCubit>().updateStatus(
                    //         taskId,
                    //         TaskStatus.completed,
                    //       ),
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
              ),

              // ── Loading overlay ───────────────────────────────────────────
              if (isUpdating)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black12,
                    child: CommonLoader(),
                  ),
                ),
            ],
          ),

          floatingActionButton: loaded.canUpload
              ? ((loaded.currentLat == null || loaded.currentLng == null)
                    ? const _CameraFabLoading()
                    : _CameraFab(
                        ready: true,
                        onTap: () {
                          // if (!loaded.readyToCapture) {
                          //   final dist = loaded.distanceFromLastPhoto;
                          //   final range = task.rangeInMeter ?? 100.0;
                          //   final remaining = (range - (dist ?? 0))
                          //       .clamp(0, range)
                          //       .toStringAsFixed(0);
                          //   AppToast.show(
                          //     context,
                          //     'Move ${remaining}m more to take next photo',
                          //     type: ToastType.warning,
                          //   );
                          //   return;
                          // }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PhotoCaptureScreen(
                                task: task,
                                initialLatitude: loaded.currentLat,
                                initialLongitude: loaded.currentLng,
                                initialAddress: loaded.currentAddress,
                                activities: loaded.activities,
                              ),
                            ),
                          ).then((_) {
                            context.read<TaskDetailCubit>().loadTask(taskId);
                          });
                        },
                      ))
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  void _confirm(
    BuildContext ctx,
    String title,
    String body,
    VoidCallback action,
  ) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r16),
        ),
        title: Text(title, style: AppTextStyle.subheading),
        content: Text(body, style: AppTextStyle.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              action();
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Total Print Path Distance Card ───────────────────────────────────────────

class _TotalDistanceCard extends StatelessWidget {
  final List<ActivityRecordModel> activities;

  const _TotalDistanceCard({required this.activities});

  double _calculateTotalDistance() {
    double total = 0.0;
    for (final activity in activities) {
      final distStr = activity.distanceFromLast;
      if (distStr == null || distStr.isEmpty) continue;
      final cleaned = distStr.replaceAll(RegExp(r'[a-zA-Z\s]'), '').trim();
      final value = double.tryParse(cleaned);
      if (value != null) {
        total += value;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalDistance = _calculateTotalDistance();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.route_outlined,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Print Path Distance',
                  style: AppTextStyle.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sum of print distance logs from first to last print',
                  style: AppTextStyle.caption.copyWith(
                    color: Colors.black54,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${totalDistance.toStringAsFixed(2)} KM',
            style: AppTextStyle.subheading.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBlue,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
