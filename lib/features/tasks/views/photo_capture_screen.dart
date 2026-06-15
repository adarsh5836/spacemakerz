import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../app/models/task_model.dart';
import '../../../app/models/activity_record_model.dart';
import '../../../app/repositories/tasks_repository.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_text_style.dart';
import '../../../common/widgets/app_toast.dart';
import '../../../common/widgets/common_loader.dart';
import '../cubit/photo_capture_cubit.dart';
import '../cubit/photo_capture_state.dart';

class PhotoCaptureScreen extends StatelessWidget {
  final TaskModel task;
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;
  final List<ActivityRecordModel> activities;

  const PhotoCaptureScreen({
    Key? key,
    required this.task,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PhotoCaptureCubit(
        repo: context.read<TasksRepository>(),
        localStorage: context.read<LocalStorage>(),
      ),
      child: _PhotoCaptureView(
        task: task,
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
        initialAddress: initialAddress,
        activities: activities,
      ),
    );
  }
}

class _PhotoCaptureView extends StatefulWidget {
  final TaskModel task;
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;
  final List<ActivityRecordModel> activities;

  const _PhotoCaptureView({
    Key? key,
    required this.task,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
    required this.activities,
  }) : super(key: key);

  @override
  State<_PhotoCaptureView> createState() => _PhotoCaptureViewState();
}

class _PhotoCaptureViewState extends State<_PhotoCaptureView> {
  final TextEditingController _remarkController = TextEditingController(
    text: "Flex installed successfully",
  );
  final TextEditingController _remark1Controller = TextEditingController(
    text: "Site visit completed and verified",
  );

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _remarkController.dispose();
    _remark1Controller.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto(BuildContext context) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked == null) return;

      if (context.mounted) {
        context.read<PhotoCaptureCubit>().uploadPhoto(
          taskId: widget.task.id,
          latitude: widget.initialLatitude ?? 28.6139,
          longitude: widget.initialLongitude ?? 77.2090,
          filePath: picked.path,
        );
      }
    } catch (e) {
      AppToast.show(context, 'Error picking photo: $e', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = '${widget.task.taskTitle} | ${widget.task.sizeOfFlex}';

    return BlocConsumer<PhotoCaptureCubit, PhotoCaptureState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppToast.show(context, state.errorMessage!, type: ToastType.error);
        }
        if (state.successMessage != null && !state.submitSuccess) {
          AppToast.show(
            context,
            state.successMessage!,
            type: ToastType.success,
          );
        }
        if (state.submitSuccess) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final hasEnoughPhotos = state.uploadedUrls.length >= 3;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(
              title,
              style: AppTextStyle.subheading.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.primaryBlue,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(AppSizes.p20),
                children: [
                  // Photo Upload Section
                  if (state.uploadedUrls.isEmpty)
                    GestureDetector(
                      onTap: state.isUploading
                          ? null
                          : () => _pickAndUploadPhoto(context),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.55,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.r24),
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.3),
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.photo_camera_rounded,
                                color: AppColors.primaryBlue,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Take Photo',
                              style: AppTextStyle.subheading.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Minimum 3 photos required',
                              style: AppTextStyle.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Captured Photos (${state.uploadedUrls.length})',
                              style: AppTextStyle.body.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (state.uploadedUrls.length < 5)
                              TextButton.icon(
                                onPressed: state.isUploading
                                    ? null
                                    : () => _pickAndUploadPhoto(context),
                                icon: const Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 16,
                                ),
                                label: const Text('Add More'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primaryBlue,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1,
                              ),
                          itemCount: state.uploadedUrls.length,
                          itemBuilder: (context, index) {
                            final url = state.uploadedUrls[index];
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.r12,
                                    ),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.black12,
                                              child: const Icon(
                                                Icons.broken_image,
                                              ),
                                            ),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      context
                                          .read<PhotoCaptureCubit>()
                                          .removePhoto(index);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Inputs Section
                  // Text(
                  //   'Activity Information',
                  //   style: AppTextStyle.body.copyWith(
                  //     fontWeight: FontWeight.bold,
                  //     color: AppColors.textPrimary,
                  //   ),
                  // ),
                  // const SizedBox(height: 12),

                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(AppSizes.r16),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.03),
                  //         blurRadius: 10,
                  //         offset: const Offset(0, 4),
                  //       ),
                  //     ],
                  //   ),
                  //   padding: const EdgeInsets.all(AppSizes.p16),
                  //   child: Column(
                  //     children: [
                  //       TextField(
                  //         controller: _remarkController,
                  //         decoration: InputDecoration(
                  //           labelText: 'Remark',
                  //           labelStyle: AppTextStyle.caption.copyWith(
                  //             color: AppColors.textSecondary,
                  //           ),
                  //           border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(AppSizes.r12),
                  //           ),
                  //           filled: true,
                  //           fillColor: const Color(0xFFF8FAFC),
                  //         ),
                  //         style: AppTextStyle.body,
                  //       ),
                  //       const SizedBox(height: 16),
                  //       TextField(
                  //         controller: _remark1Controller,
                  //         decoration: InputDecoration(
                  //           labelText: 'Additional Remark',
                  //           labelStyle: AppTextStyle.caption.copyWith(
                  //             color: AppColors.textSecondary,
                  //           ),
                  //           border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(AppSizes.r12),
                  //           ),
                  //           filled: true,
                  //           fillColor: const Color(0xFFF8FAFC),
                  //         ),
                  //         style: AppTextStyle.body,
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  // const SizedBox(height: 24),

                  // GPS Info Card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(AppSizes.r16),
                      border: Border.all(color: Colors.black12),
                    ),
                    padding: const EdgeInsets.all(AppSizes.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primaryBlue,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Watermark Metadata',
                              style: AppTextStyle.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Date: ${AppDateFormatter.formatDateTimeSlash(DateTime.now())}',
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Latitude: ${widget.initialLatitude?.toStringAsFixed(6) ?? "28.6139"}, Longitude: ${widget.initialLongitude?.toStringAsFixed(6) ?? "77.2090"}',
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Address: ${widget.initialAddress ?? "Fetching address..."}',
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Spacing for bottom button
                ],
              ),

              // Uploading overlay
              if (state.isUploading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black12,
                    child: CommonLoader(),
                  ),
                ),

              if (state.isSubmitting)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black26,
                    child: CommonLoader(),
                  ),
                ),
            ],
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p20,
              vertical: AppSizes.p16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: hasEnoughPhotos && !state.isSubmitting
                    ? () {
                        context.read<PhotoCaptureCubit>().submitActivity(
                          task: widget.task,
                          latitude: widget.initialLatitude ?? 28.6139,
                          longitude: widget.initialLongitude ?? 77.2090,
                          address: widget.initialAddress,
                          remark: _remarkController.text,
                          remark1: _remark1Controller.text,
                          activities: widget.activities,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                  ),
                ),
                child: Text(
                  hasEnoughPhotos
                      ? 'Submit Activity'
                      : 'Capture at least 3 photos (${state.uploadedUrls.length}/3)',
                  style: AppTextStyle.body.copyWith(
                    color: hasEnoughPhotos ? Colors.white : Colors.black38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
