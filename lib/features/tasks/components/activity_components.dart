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

    bool isOwner = false;
    if (isUser) {
      isOwner = activity.empId == currentUserId;
    } else if (isDealer) {
      isOwner = activity.dealerId == currentUserId;
    }

    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppSizes.r16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
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
                    color: AppColors.accentAmber.withOpacity(0.18),
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
                  Text(
                    'Ref No: $_shortId',
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
                      _pill(
                        'By: ${activity.task?.empId?.name ?? activity.empId ?? "User"}',
                        AppColors.primaryBlue.withOpacity(0.1),
                        AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 6),
                      _pill(
                        activity.flexSize ?? 'Standard Size',
                        AppColors.accentGreen.withOpacity(0.12),
                        AppColors.accentGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isOwner)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
                onPressed: () => _showDeleteConfirmation(context),
              ),
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

  void _showDeleteConfirmation(BuildContext context) {
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
        child: _NetworkActivityBottomSheet(activity: activity, task: task),
      ),
    );
  }
}

// ── Activity Bottom Sheet ─────────────────────────────────────────────────────

class _ActivityBottomSheet extends StatefulWidget {
  final List<dynamic> photos;
  final dynamic task;
  final String? address;
  final int initialIndex;
  final Function(String photoId)? onDeletePhoto;
  final VoidCallback? onAddPhoto;

  const _ActivityBottomSheet({
    required this.photos,
    required this.task,
    required this.initialIndex,
    this.address,
    this.onDeletePhoto,
    this.onAddPhoto,
  });

  @override
  State<_ActivityBottomSheet> createState() => _ActivityBottomSheetState();
}

class _ActivityBottomSheetState extends State<_ActivityBottomSheet> {
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
                                color: AppColors.accentIndigoDeep.withOpacity(
                                  0.4,
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
                              builder: (_) => _GeoPhotoFullScreen(
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
                                color: Colors.black.withOpacity(0.06),
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
                                  color: Colors.green.withOpacity(0.85),
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

// ── Geo Photo Full Screen ─────────────────────────────────────────────────────

class _GeoPhotoFullScreen extends StatefulWidget {
  final dynamic photo;
  final dynamic task;
  final String? address;
  final VoidCallback? onDelete;

  // New fields to make it generic for network URLs
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final String? createdAt;
  final String? roleDisplayName;
  final String? heroTag;

  const _GeoPhotoFullScreen({
    this.photo,
    required this.task,
    this.address,
    this.onDelete,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.roleDisplayName,
    this.heroTag,
  });

  @override
  State<_GeoPhotoFullScreen> createState() => _GeoPhotoFullScreenState();
}

class _GeoPhotoFullScreenState extends State<_GeoPhotoFullScreen> {
  final GlobalKey _boundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _resolveImageOrientation();
  }

  void _resolveImageOrientation() {
    ImageProvider provider;
    if (widget.imageUrl != null) {
      provider = NetworkImage(widget.imageUrl!);
    } else if (widget.photo?.localPath != null) {
      provider = FileImage(File(widget.photo.localPath as String));
    } else {
      return;
    }

    final ImageStream stream = provider.resolve(const ImageConfiguration());
    stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      final int width = info.image.width;
      final int height = info.image.height;
      if (mounted) {
        if (width > height) {
          // Landscape (horizontal) -> allow landscape orientations
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        } else {
          // Portrait (vertical) -> lock to portrait
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
        }
      }
    }));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  Future<void> _shareSafe(BuildContext ctx) async {
    try {
      final isLocal = widget.imageUrl == null;
      final path = isLocal ? (widget.photo?.localPath as String?) : null;

      if (isLocal && (path == null || !File(path).existsSync())) {
        AppToast.show(
          ctx,
          'Photo file does not exist locally',
          type: ToastType.error,
        );
        return;
      }

      // Render the RepaintBoundary widget to render the image with the beautiful geo-tag overlay directly on top!
      RenderRepaintBoundary? boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      String? sharePath = path;

      if (boundary != null) {
        // High 3.0 pixelRatio for ultra-sharp premium watermark
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (byteData != null) {
          final Uint8List pngBytes = byteData.buffer.asUint8List();
          final tempDir = await getTemporaryDirectory();
          final tempFile = File(
            '${tempDir.path}/shared_geotagged_${DateTime.now().millisecondsSinceEpoch}.png',
          );
          await tempFile.writeAsBytes(pngBytes);
          sharePath = tempFile.path;
        }
      }

      final lat =
          widget.latitude ??
          (widget.photo != null ? (widget.photo.latitude as double?) : null);
      final lng =
          widget.longitude ??
          (widget.photo != null ? (widget.photo.longitude as double?) : null);
      final photoAddress = widget.photo != null
          ? (widget.photo.address as String?)
          : null;
      final addr = widget.address ?? photoAddress ?? '--';
      final text =
          'Task Activity Photo - Spacemakerz\n'
          'Location: ${lat != null ? "$lat, $lng" : "--"}\n'
          'Address: $addr';

      if (sharePath != null) {
        await Share.shareXFiles([XFile(sharePath)], text: text);
      } else {
        await Share.share(text);
      }
    } catch (e) {
      if (ctx.mounted) {
        AppToast.show(
          ctx,
          'Failed to capture watermarked image, sharing original photo instead.',
          type: ToastType.warning,
        );
        try {
          if (widget.photo?.localPath != null) {
            final path = widget.photo.localPath as String;
            await Share.shareXFiles([
              XFile(path),
            ], text: 'Task Activity Photo – ');
          }
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNetwork = widget.imageUrl != null;
    final file = !isNetwork && widget.photo?.localPath != null
        ? File(widget.photo.localPath as String)
        : null;

    final lat =
        widget.latitude ??
        (widget.photo != null ? (widget.photo.latitude as double?) : null);
    final lng =
        widget.longitude ??
        (widget.photo != null ? (widget.photo.longitude as double?) : null);

    // Fallback to widget.address if photo's address is null/empty
    final photoAddress = widget.photo != null
        ? (widget.photo.address as String?)
        : null;
    final address = (photoAddress != null && photoAddress.isNotEmpty)
        ? photoAddress
        : (widget.address ?? 'Fetching address...');

    final createdStr =
        widget.createdAt ??
        (widget.photo != null ? (widget.photo.createdAt as String) : '');
    final date = AppDateFormatter.formatDateTimeSlash(createdStr);

    final role = widget.roleDisplayName;
    final heroTag =
        widget.heroTag ??
        (widget.photo != null ? (widget.photo.id as String) : null);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black45)]),
            onPressed: () => _shareSafe(context),
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _boundaryKey,
        child: Stack(
          children: [
            // ── Photo (takes all available screen space) ─────────────────────
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: SizedBox.expand(
                child: isNetwork
                    ? (heroTag != null
                          ? Hero(
                              tag: heroTag,
                              child: Image.network(
                                widget.imageUrl!,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.white54,
                                        size: 72,
                                      ),
                                    ),
                              ),
                            )
                          : Image.network(
                              widget.imageUrl!,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white54,
                                      size: 72,
                                    ),
                                  ),
                            ))
                    : (file != null && file.existsSync()
                          ? (heroTag != null
                                ? Hero(
                                    tag: heroTag,
                                    child: Image.file(
                                      file,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Image.file(file, fit: BoxFit.contain))
                          : const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                                size: 72,
                              ),
                            )),
              ),
            ),

            // ── GPS Map Camera-style geo-tag panel (transparent overlay on top of photo) ─
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _GeoTagPanel(
                lat: lat,
                lng: lng,
                address: address,
                date: date,
                role: role!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── GPS Map Camera-style Geo-Tag Panel ────────────────────────────────────────

class _GeoTagPanel extends StatelessWidget {
  final double? lat;
  final double? lng;
  final String address;
  final String date;
  final String role;

  const _GeoTagPanel({
    required this.lat,
    required this.lng,
    required this.address,
    required this.date,
    required this.role,
  });

  /// Extracts a short city/region label from the full address string.
  String _cityLabel() {
    if (address.isEmpty || address == 'Fetching address...')
      return 'India 🇮🇳';
    final parts = address.split(',');
    // Try to return the 2nd-last or 3rd-last meaningful part as "City, State"
    if (parts.length >= 3) {
      final city = parts[parts.length - 3].trim();
      final state = parts[parts.length - 2].trim();
      return '$city, $state 🇮🇳';
    } else if (parts.length == 2) {
      return '${parts[0].trim()} 🇮🇳';
    }
    return '${parts.first.trim()} 🇮🇳';
  }

  @override
  Widget build(BuildContext context) {
    final cityLabel = _cityLabel();
    final latStr = lat != null ? 'Lat ${lat!.toStringAsFixed(5)}°' : 'Lat --';
    final lngStr = lng != null ? 'Long ${lng!.toStringAsFixed(5)}°' : 'Long --';

    return Padding(
      padding: const EdgeInsets.only(left: 28.0, right: 28.0, bottom: 16.0),
      child: Container(
        // Semi-transparent black panel overlaying the image
        // color: Colors.black.withOpacity(0.25),
        height: 105,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 85,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Static map image via Google Maps Static API (no key needed for low-zoom)
                    lat != null && lng != null
                        ? Image.network(
                            'https://maps.googleapis.com/maps/api/staticmap'
                            '?center=${lat!.toStringAsFixed(5)},${lng!.toStringAsFixed(5)}'
                            '&zoom=14&size=180x220&maptype=satellite'
                            '&markers=color:red%7C${lat!.toStringAsFixed(5)},${lng!.toStringAsFixed(5)}'
                            '&key=', // will show gray tile if no key — acceptable fallback
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _MapFallback(lat: lat, lng: lng),
                          )
                        : _MapFallback(lat: lat, lng: lng),
                    // Google-style branding badge
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'Google',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    // Red pin icon
                    const Align(
                      alignment: Alignment(0, -0.15),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 22,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ── Right: text info ──────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // City / Region bold title
                    Text(
                      cityLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Full address
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Lat / Long on one line
                    Text(
                      '$latStr  $lngStr',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Date & time
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Captured by
                    // Row(
                    //   children: [
                    //     const Icon(
                    //       Icons.camera_alt_outlined,
                    //       size: 11,
                    //       color: Color(0xFF90CAF9),
                    //     ),
                    // const SizedBox(width: 3),
                    // Flexible(
                    //   child: Text(
                    //     'GPS Map Camera  •  $role',
                    //     style: const TextStyle(
                    //       fontSize: 9.5,
                    //       fontWeight: FontWeight.w600,
                    //       color: Color(0xFF90CAF9),
                    //     ),
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                    // ),
                    // ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map Fallback Widget (shown when network/API unavailable) ─────────────────

class _MapFallback extends StatelessWidget {
  final double? lat;
  final double? lng;

  const _MapFallback({this.lat, this.lng});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF7B9E78),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, color: Colors.white70, size: 28),
          if (lat != null) ...[
            const SizedBox(height: 4),
            Text(
              '${lat!.toStringAsFixed(3)}\n${lng!.toStringAsFixed(3)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Action Row ───────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final String taskId;
  final VoidCallback onReject, onComplete;
  const _ActionRow({
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
                        .withOpacity(0.4),
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
              color: Colors.black.withOpacity(0.08),
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

// ── Network Activity Bottom Sheet ─────────────────────────────────────────────

class _NetworkActivityBottomSheet extends StatelessWidget {
  final ActivityRecordModel activity;
  final dynamic task;

  const _NetworkActivityBottomSheet({
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
                                  color: AppColors.primaryBlue.withOpacity(
                                    0.04,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.r16,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primaryBlue.withOpacity(
                                      0.3,
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
                                  builder: (_) => _GeoPhotoFullScreen(
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
                                    color: Colors.black.withOpacity(0.05),
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
                              color: Colors.black.withOpacity(0.04),
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
                            const SizedBox(height: 12),
                            _infoItem(
                              'Flex Size',
                              currentActivity.flexSize ?? '--',
                            ),
                            _infoItem(
                              'Distance from Last',
                              currentActivity.distanceFromLast ?? '--',
                            ),
                            _infoItem(
                              'GPS Coordinates',
                              '${currentActivity.latitude ?? "--"}, ${currentActivity.longitude ?? "--"}',
                            ),
                            _infoItem(
                              'GPS Address',
                              currentActivity.gpsAddress ?? '--',
                            ),
                            _infoItem('Remark', currentActivity.remark ?? '--'),
                            _infoItem(
                              'Additional Remark',
                              currentActivity.remark1 ?? '--',
                            ),
                            _infoItem(
                              'Date Time',
                              AppDateFormatter.formatDateTime(
                                currentActivity.createdDate ?? '',
                              ),
                            ),
                          ],
                        ),
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
}
