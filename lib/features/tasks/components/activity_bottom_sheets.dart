part of '../views/task_details_screen.dart';

// ── Activity Bottom Sheet ─────────────────────────────────────────────────────

class ActivityBottomSheet extends StatefulWidget {
  final List<dynamic> photos;
  final dynamic task;
  final String? address;
  final int initialIndex;
  final Function(String photoId)? onDeletePhoto;
  final VoidCallback? onAddPhoto;

  const ActivityBottomSheet({
    super.key,
    required this.photos,
    required this.task,
    required this.initialIndex,
    this.address,
    this.onDeletePhoto,
    this.onAddPhoto,
  });

  @override
  State<ActivityBottomSheet> createState() => ActivityBottomSheetState();
}

class ActivityBottomSheetState extends State<ActivityBottomSheet> {
  late List<dynamic> _localPhotos;

  @override
  void initState() {
    super.initState();
    _localPhotos = List.from(widget.photos);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Drag handle ──────────────────────────────────────────────────
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.accentIndigoDeep,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Photos (${_localPhotos.length})',
                          style: AppTextStyle.subheading.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Task ID: ${task.id}',
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),

            // ── Scrollable Body ───────────────────────────────────────────────
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.all(AppSizes.p20),
                children: [
                  // ── 1. Photos Grid/Row Container (Yellow Premium Accent) ─────
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.25,
                        ),
                    itemCount:
                        _localPhotos.length +
                        (widget.onAddPhoto != null ? 1 : 0),
                    itemBuilder: (context, idx) {
                      if (idx == _localPhotos.length) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            widget.onAddPhoto!();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSizes.r16),
                              border: Border.all(
                                color: AppColors.accentIndigoDeep.withValues(
                                  alpha: 0.4,
                                ),
                                style: BorderStyle.solid,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_a_photo,
                                  color: AppColors.accentIndigoDeep,
                                  size: 26,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Add Photo',
                                  style: AppTextStyle.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentIndigoDeep,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final photo = _localPhotos[idx];
                      final pFile = File(photo.localPath as String);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GeoPhotoFullScreen(
                                photo: photo,
                                task: task,
                                address: widget.address,
                                onDelete: widget.onDeletePhoto != null
                                    ? () {
                                        Navigator.pop(
                                          context,
                                        ); // pop full screen
                                        widget.onDeletePhoto!(
                                          photo.id,
                                        ); // delete from DB/Cubit
                                        setState(() {
                                          _localPhotos.removeWhere(
                                            (p) => p.id == photo.id,
                                          ); // delete locally to update bottom sheet immediately!
                                        });
                                        if (_localPhotos.isEmpty) {
                                          Navigator.pop(
                                            context,
                                          ); // close sheet if empty
                                        }
                                      }
                                    : null,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSizes.r24),
                            border: Border.all(
                              color: Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              pFile.existsSync()
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        pFile,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      color: AppColors.backgroundLight,
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 20,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  color: Colors.green.withValues(alpha: 0.85),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),

                                  child: const Text(
                                    'Uploaded',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.p16),

                  const SizedBox(height: AppSizes.p32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Network Activity Bottom Sheet ─────────────────────────────────────────────

class NetworkActivityBottomSheet extends StatelessWidget {
  final ActivityRecordModel activity;
  final dynamic task;

  const NetworkActivityBottomSheet({
    super.key,
    required this.activity,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final localStorage = context.read<LocalStorage>();
    return BlocBuilder<TaskDetailCubit, TaskDetailState>(
      builder: (context, state) {
        if (state is! TaskDetailLoaded) return const SizedBox.shrink();

        // Get the latest instance of this activity from the list to show real-time changes
        final currentActivity = state.activities.firstWhere(
          (a) => a.id == activity.id,
          orElse: () => activity,
        );

        final currentUserId =
            int.tryParse(localStorage.currentUser?.id.toString() ?? '0') ?? 0;
        final role = localStorage.currentRole;
        final isUser = role == UserRole.user;
        final isDealer = role == UserRole.dealer;

        bool canAddPhoto = false;
        if (isUser) {
          canAddPhoto = currentActivity.empId == currentUserId;
        } else if (isDealer) {
          canAddPhoto = currentActivity.dealerId == currentUserId;
        }

        String distanceStr = '--';
        final dLatStr =
            task.dealerName?.latitude ?? '28.5355'; // Dummy latitude
        final dLngStr =
            task.dealerName?.longitude ?? '77.3910'; // Dummy longitude
        final aLatStr = currentActivity.latitude;
        final aLngStr = currentActivity.longitude;

        if (aLatStr != null && aLngStr != null) {
          final dLat = double.tryParse(dLatStr);
          final dLng = double.tryParse(dLngStr);
          final aLat = double.tryParse(aLatStr);
          final aLng = double.tryParse(aLngStr);
          if (dLat != null && dLng != null && aLat != null && aLng != null) {
            distanceStr = DistanceCalculator.getDistanceInKm(
              dLat,
              dLng,
              aLat,
              aLng,
            );
          }
        }

        final assignLocStr = [
          task.cityName,
          task.stateName,
        ].where((e) => e.isNotEmpty).join(', ');
        final finalAssignLoc = assignLocStr.isEmpty ? '--' : assignLocStr;

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.96,
          builder: (_, ctrl) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.accentIndigoDeep,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                        ),
                        child: const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Activity Photos (${currentActivity.photos.length})',
                              style: AppTextStyle.subheading.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Ref No: ${currentActivity.activityRefNo ?? "--"}',
                              style: AppTextStyle.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: ctrl,
                    padding: const EdgeInsets.all(AppSizes.p20),
                    children: [
                      // Photo Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.1,
                            ),
                        itemCount:
                            currentActivity.photos.length +
                            (canAddPhoto ? 1 : 0),
                        itemBuilder: (context, idx) {
                          if (idx == currentActivity.photos.length) {
                            // "+ Add Photo" Card
                            return GestureDetector(
                              onTap: () async {
                                AppToast.show(
                                  context,
                                  'Opening camera to add photo...',
                                  type: ToastType.info,
                                );
                                final newUrl = await context
                                    .read<TaskDetailCubit>()
                                    .addPhotoToActivity(currentActivity);
                                if (newUrl != null && context.mounted) {
                                  AppToast.show(
                                    context,
                                    'Photo added successfully',
                                    type: ToastType.success,
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(
                                    alpha: 0.04,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.r16,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primaryBlue.withValues(
                                      alpha: 0.3,
                                    ),
                                    style: BorderStyle.solid,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_a_photo_outlined,
                                      color: AppColors.primaryBlue,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add Photo',
                                      style: AppTextStyle.caption.copyWith(
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final url = currentActivity.photos[idx];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GeoPhotoFullScreen(
                                    imageUrl: url,
                                    latitude: double.tryParse(
                                      currentActivity.latitude ?? '',
                                    ),
                                    longitude: double.tryParse(
                                      currentActivity.longitude ?? '',
                                    ),
                                    address: currentActivity.gpsAddress,
                                    createdAt: currentActivity.createdDate,
                                    roleDisplayName:
                                        localStorage.currentRole.displayName,
                                    heroTag: url,
                                    task: task,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.r16,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: AppColors.backgroundLight,
                                              child: const Icon(
                                                Icons.broken_image,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Metadata Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.r16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(AppSizes.p16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Activity Details',
                              style: AppTextStyle.body.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // -- GENERAL INFO --
                            _infoItem(
                              'Project Name',
                              currentActivity.task?.projectId?.title ?? '--',
                            ),
                            _infoItem(
                              'Dealer Name',
                              currentActivity.task?.displayDealerName ?? '--',
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _infoItem(
                                    'Flex Size',
                                    currentActivity.flexSize ?? '--',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _infoItem(
                                    'Date Time',
                                    AppDateFormatter.formatDateTime(
                                      currentActivity.createdDate ?? '',
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 24, color: Colors.black12),

                            // -- LOCATION INFO --
                            _buildSectionTitle('Location Information'),
                            Row(
                              children: [
                                Expanded(
                                  child: _infoItem(
                                    'Assign Location',
                                    finalAssignLoc,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _infoItem('Replaced Location', '--'),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _infoItem(
                                    'District',
                                    currentActivity.district ?? '--',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _infoItem(
                                    'Tehsil',
                                    currentActivity.tehsil ?? '--',
                                  ),
                                ),
                              ],
                            ),
                            _infoItem(
                              'Village',
                              currentActivity.village ?? '--',
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _infoItem(
                                    'Dist. from Dealer',
                                    distanceStr,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _infoItem(
                                    'Dist. from Last Print',
                                    currentActivity.distanceFromLast ?? '--',
                                  ),
                                ),
                              ],
                            ),
                            _infoItem(
                              'GPS Address',
                              currentActivity.gpsAddress ?? '--',
                            ),

                            const Divider(height: 24, color: Colors.black12),

                            // -- TRACKING & REMARKS --
                            _buildSectionTitle('Tracking & Remarks'),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _infoItem(
                                    'GPS Coordinates',
                                    '${currentActivity.latitude ?? "--"}, ${currentActivity.longitude ?? "--"}',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildTrackButton(context, currentActivity),
                              ],
                            ),
                            _infoItem('Remark', currentActivity.remark ?? '--'),
                          ],
                        ),
                      ),
                      DealerRecceSection(
                        activity: currentActivity,
                        task: task,
                        isDealer: isDealer,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyle.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyle.caption.copyWith(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTrackButton(
    BuildContext context,
    ActivityRecordModel currentActivity,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 32,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ActivityLocationMapScreen(activity: currentActivity),
              ),
            );
          },
          icon: const Icon(
            Icons.navigation_outlined,
            size: 14,
            color: Colors.white,
          ),
          label: const Text(
            'Track',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            elevation: 0,
            minimumSize: const Size(80, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}

// ── Dealer Recce Section stateful component ───────────────────────────────────

class DealerRecceSection extends StatefulWidget {
  final ActivityRecordModel activity;
  final dynamic task;
  final bool isDealer;

  const DealerRecceSection({
    super.key,
    required this.activity,
    required this.task,
    required this.isDealer,
  });

  @override
  State<DealerRecceSection> createState() => _DealerRecceSectionState();
}

class _DealerRecceSectionState extends State<DealerRecceSection> {
  int? _editingMonth;
  String? _uploadedPhotoUrl;
  String? _selectedStatus;
  final TextEditingController _remarkController = TextEditingController();
  bool _isUploadingPhoto = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  Widget _buildStatusButton(String status, Color color) {
    final isSelected = _selectedStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatus = status;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _captureAndUploadPhoto(int month) async {
    setState(() {
      _isUploadingPhoto = true;
    });
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked == null) {
        setState(() {
          _isUploadingPhoto = false;
        });
        return;
      }

      double lat = 0.0;
      double lng = 0.0;
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (_) {
        lat = double.tryParse(widget.activity.latitude ?? '') ?? 0.0;
        lng = double.tryParse(widget.activity.longitude ?? '') ?? 0.0;
      }

      final repo = context.read<TasksRepository>();
      final response = await repo.uploadActivityPhoto(
        taskId: widget.task.id,
        latitude: lat,
        longitude: lng,
        filePath: picked.path,
      );

      if (response['status'] == true) {
        setState(() {
          _uploadedPhotoUrl = response['image_url'] as String;
          _isUploadingPhoto = false;
        });
      } else {
        setState(() {
          _isUploadingPhoto = false;
        });
        if (mounted) {
          AppToast.show(
            context,
            response['message'] ?? 'Upload failed',
            type: ToastType.error,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingPhoto = false;
      });
      if (mounted) {
        AppToast.show(context, 'Error uploading: $e', type: ToastType.error);
      }
    }
  }

  Future<void> _submitRecce(int month) async {
    if (_uploadedPhotoUrl == null || _selectedStatus == null) return;
    setState(() {
      _isSubmitting = true;
    });

    try {
      final cubit = context.read<TaskDetailCubit>();
      final success = await cubit.submitDealerRecce(
        activity: widget.activity,
        month: month,
        photoUrl: _uploadedPhotoUrl!,
        remark: _remarkController.text.trim(),
        status: _selectedStatus!,
      );

      if (success) {
        setState(() {
          _uploadedPhotoUrl = null;
          _selectedStatus = null;
          _remarkController.clear();
          _editingMonth = null;
          _isSubmitting = false;
        });
        if (mounted) {
          AppToast.show(
            context,
            'Recce review submitted successfully!',
            type: ToastType.success,
          );
        }
      } else {
        setState(() {
          _isSubmitting = false;
        });
        if (mounted) {
          AppToast.show(
            context,
            'Failed to submit review',
            type: ToastType.error,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        AppToast.show(context, 'Error: $e', type: ToastType.error);
      }
    }
  }

  Widget _buildTimelineDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 15),
      height: 20,
      width: 2,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildTimelineIndicator(bool isSubmitted, bool isActive) {
    Color bg;
    Widget icon;

    if (isSubmitted) {
      bg = Colors.green.shade50;
      icon = const Icon(
        Icons.check_circle_outline,
        color: Colors.green,
        size: 20,
      );
    } else if (isActive) {
      bg = AppColors.primaryBlue.withOpacity(0.1);
      icon = const Icon(
        Icons.pending_actions,
        color: AppColors.primaryBlue,
        size: 20,
      );
    } else {
      bg = Colors.grey.shade100;
      icon = Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 18);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(child: icon),
    );
  }

  Widget _buildSubmittedRecceView(Map<String, dynamic> recce) {
    final photoUrl = recce['photo_url'] as String? ?? '';
    final remark = recce['remark'] as String? ?? '';
    final dateStr = recce['date'] as String? ?? '';
    final status = recce['status'] as String? ?? '';

    Color statusColor;
    if (status.toLowerCase().contains('wear')) {
      statusColor = Colors.orange;
    } else if (status.toLowerCase().contains('not')) {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              if (dateStr.isNotEmpty)
                Text(
                  AppDateFormatter.formatDateTime(dateStr),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
            ],
          ),
          if (remark.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              remark,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
          if (photoUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GeoPhotoFullScreen(
                      imageUrl: photoUrl,
                      latitude: double.tryParse(widget.activity.latitude ?? ''),
                      longitude: double.tryParse(
                        widget.activity.longitude ?? '',
                      ),
                      address: widget.activity.gpsAddress,
                      createdAt: dateStr,
                      roleDisplayName: 'Dealer',
                      heroTag: photoUrl,
                      task: widget.task,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  photoUrl,
                  height: 100,
                  width: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 100,
                    width: 150,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingRecceView(int month) {
    if (!widget.isDealer) {
      return Text(
        'Awaiting dealer review',
        style: TextStyle(
          fontSize: 11,
          color: Colors.orange.shade800,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final isEditingThis = _editingMonth == month;

    if (!isEditingThis) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          minimumSize: const Size(120, 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: () {
          setState(() {
            _editingMonth = month;
            _uploadedPhotoUrl = null;
            _selectedStatus = null;
            _remarkController.clear();
          });
        },
        child: const Text(
          'Start Review',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_uploadedPhotoUrl == null) ...[
            GestureDetector(
              onTap: () => _captureAndUploadPhoto(month),
              child: Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue.shade300,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Center(
                  child: _isUploadingPhoto
                      ? const CircularProgressIndicator()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_a_photo,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Capture Recce Photo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ] else ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _uploadedPhotoUrl!,
                    height: 100,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _uploadedPhotoUrl = null;
                      });
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
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            'Dealer Remarks / Status',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildStatusButton('Ok', Colors.green),
              _buildStatusButton('Not there at location', Colors.red),
              _buildStatusButton('Ok but wear', Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _remarkController,
            decoration: InputDecoration(
              hintText: 'Enter additional remark...',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _editingMonth = null;
                  });
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  minimumSize: const Size(80, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:
                    (_uploadedPhotoUrl == null ||
                        _selectedStatus == null ||
                        _isSubmitting)
                    ? null
                    : () => _submitRecce(month),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthItem(int month, int daysDiff, int unlockDays) {
    final recceList = widget.activity.parsedDealerInfo;
    final monthRecce = recceList.firstWhere(
      (item) => item['month'] == month,
      orElse: () => <String, dynamic>{},
    );

    final isSubmitted = monthRecce.isNotEmpty;
    final isActive = daysDiff >= unlockDays;
    final remainingDays = unlockDays - daysDiff;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimelineIndicator(isSubmitted, isActive),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Month $month Recce',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (!isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Unlocks in $remainingDays days',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              if (isSubmitted)
                _buildSubmittedRecceView(monthRecce)
              else if (isActive)
                _buildPendingRecceView(month)
              else
                Text(
                  'Locked until Month $month',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final createdStr = widget.activity.createdDate ?? '';
    final createdTime = DateTime.tryParse(createdStr) ?? DateTime.now();
    final daysDifference = DateTime.now().difference(createdTime).inDays;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dealer Recce Logs',
            style: AppTextStyle.body.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildMonthItem(1, daysDifference, 0),
          _buildTimelineDivider(),
          _buildMonthItem(2, daysDifference, 30),
          _buildTimelineDivider(),
          _buildMonthItem(3, daysDifference, 60),
        ],
      ),
    );
  }
}
