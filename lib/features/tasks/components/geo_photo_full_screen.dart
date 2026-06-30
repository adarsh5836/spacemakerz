part of '../views/task_details_screen.dart';

// ── Geo Photo Full Screen ─────────────────────────────────────────────────────

class GeoPhotoFullScreen extends StatefulWidget {
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

  const GeoPhotoFullScreen({
    super.key,
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
  State<GeoPhotoFullScreen> createState() => GeoPhotoFullScreenState();
}

class GeoPhotoFullScreenState extends State<GeoPhotoFullScreen> {
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
    stream.addListener(
      ImageStreamListener((ImageInfo info, bool _) {
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
      }),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
            icon: const Icon(
              Icons.share_outlined,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
            ),
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
              child: GeoTagPanel(
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

class GeoTagPanel extends StatelessWidget {
  final double? lat;
  final double? lng;
  final String address;
  final String date;
  final String role;

  const GeoTagPanel({
    super.key,
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
          color: Colors.black.withValues(alpha: 0.25),
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
                             errorBuilder: (_, __, _) =>
                                 MapFallback(lat: lat, lng: lng),
                          )
                        : MapFallback(lat: lat, lng: lng),
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
                          color: Colors.black.withValues(alpha: 0.6),
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
                        color: Colors.white.withValues(alpha: 0.85),
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
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Date & time
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.85),
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

class MapFallback extends StatelessWidget {
  final double? lat;
  final double? lng;

  const MapFallback({super.key, this.lat, this.lng});

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
