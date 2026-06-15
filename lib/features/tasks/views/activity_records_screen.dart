import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../../app/models/task_model.dart';
import '../../../app/models/activity_record_model.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/api/api_client.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_style.dart';
import '../../../constants/app_sizes.dart';
import '../../../common/widgets/common_loader.dart';
import '../../../common/widgets/app_toast.dart';
import '../cubit/activity_records_cubit.dart';
import '../cubit/activity_records_state.dart';
import '../components/activity_record_card.dart';
import '../components/activity_guidelines_empty.dart';
import 'package:get/get.dart';
import '../../../routes/route_names.dart';

class ActivityRecordsScreen extends StatelessWidget {
  final TaskModel task;
  const ActivityRecordsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActivityRecordsCubit(sl<ApiClient>())..fetchActivityRecords(task.id),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text('${task.taskTitle.toUpperCase()} — Activities'),
        ),
        body: _ActivityRecordsView(task: task),
      ),
    );
  }
}

class _ActivityRecordsView extends StatelessWidget {
  final TaskModel task;
  const _ActivityRecordsView({required this.task});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ActivityRecordsCubit>().fetchActivityRecords(task.id),
      child: BlocBuilder<ActivityRecordsCubit, ActivityRecordsState>(
        builder: (context, state) {
          if (state is ActivityRecordsLoading) {
            return const Center(child: CommonLoader());
          }

          if (state is ActivityRecordsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.body.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ActivityRecordsCubit>().fetchActivityRecords(task.id),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ActivityRecordsLoaded) {
            final activities = state.activities;

            if (activities.isEmpty) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p48),
                children: const [
                  SizedBox(height: 40),
                  ActivityGuidelinesEmpty(),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSizes.p16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ActivityRecordCard(
                  activity: activity,
                  displayIndex: index + 1,
                  onTap: () => _showActivityDetailsBottomSheet(context, activity),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showActivityDetailsBottomSheet(BuildContext screenContext, ActivityRecordModel activity) {
    showModalBottomSheet(
      context: screenContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Activity Photos (${activity.photos.length})',
                          style: AppTextStyle.heading.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Grid of captured print photos
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        activity.photos.isEmpty
                            ? Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text('No photos captured for this print.'),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.1,
                                ),
                                itemCount: activity.photos.length,
                                itemBuilder: (context, index) {
                                  final photoUrl = activity.photos[index];
                                  return GestureDetector(
                                    onTap: () => _openFullScreenPhoto(screenContext, photoUrl, activity),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: AppColors.backgroundLight,
                                          child: const Icon(Icons.broken_image_rounded, color: AppColors.textSecondary),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        const SizedBox(height: 32),

                        // Map navigation at bottom of photo grid
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () {
                            Navigator.pop(sheetContext); // Close sheet
                            Get.toNamed(RouteNames.activityLocationMap, arguments: activity);
                          },
                          icon: const Icon(Icons.map_rounded, color: Colors.white),
                          label: Text(
                            'Go to Print Location',
                            style: AppTextStyle.buttonText.copyWith(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openFullScreenPhoto(BuildContext context, String url, ActivityRecordModel activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenPhotoViewer(
          imageUrl: url,
          activity: activity,
        ),
      ),
    );
  }
}

class FullScreenPhotoViewer extends StatefulWidget {
  final String imageUrl;
  final ActivityRecordModel activity;
  const FullScreenPhotoViewer({super.key, required this.imageUrl, required this.activity});

  @override
  State<FullScreenPhotoViewer> createState() => _FullScreenPhotoViewerState();
}class _FullScreenPhotoViewerState extends State<FullScreenPhotoViewer> {
  bool _isSharing = false;
  final GlobalKey _boundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _resolveImageOrientation();
  }

  void _resolveImageOrientation() {
    final ImageStream stream = NetworkImage(widget.imageUrl).resolve(const ImageConfiguration());
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

  Future<void> _sharePhoto() async {
    setState(() => _isSharing = true);
    try {
      // Find the render boundary to capture the widget
      final RenderRepaintBoundary? boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        throw Exception("Render boundary was not found.");
      }

      // Convert boundary to high resolution Image (pixel ratio 3.0 for premium quality)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/watermarked_photo_${widget.activity.id}_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await tempFile.writeAsBytes(pngBytes);

        final text = 'Activity Print details:\n'
            'Ref No: ${widget.activity.activityRefNo ?? widget.activity.id}\n'
            'Address: ${widget.activity.gpsAddress ?? "Spacemakerz"}\n'
            'Coordinates: ${widget.activity.latitude ?? ""}, ${widget.activity.longitude ?? ""}';

        await Share.shareXFiles([XFile(tempFile.path)], text: text);
      } else {
        throw Exception("Failed to convert image byte data.");
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Could not share: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = double.tryParse(widget.activity.latitude ?? '');
    final lng = double.tryParse(widget.activity.longitude ?? '');

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.activity.activityRefNo != null ? 'Ref: ${widget.activity.activityRefNo}' : 'Photo View',
          style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black45)]),
        ),
        actions: [
          _isSharing
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.share_rounded, shadows: [Shadow(blurRadius: 4, color: Colors.black45)]),
                  onPressed: _sharePhoto,
                ),
        ],
      ),
      body: RepaintBoundary(
        key: _boundaryKey,
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: SizedBox.expand(
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                  ),
                ),
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
                address: widget.activity.gpsAddress ?? 'Print Location',
                date: widget.activity.createdDate ?? '',
                role: 'Operator',
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
    if (address.isEmpty || address == 'Fetching address...') {
      return 'India 🇮🇳';
    }
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
                    // Static map image via Google Maps Static API
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    Text(
                      '$latStr  $lngStr',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
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
