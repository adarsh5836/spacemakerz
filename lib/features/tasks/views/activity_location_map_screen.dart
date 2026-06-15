import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../app/models/activity_record_model.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_style.dart';
import '../../../constants/app_sizes.dart';
import '../cubit/activity_location_map_cubit.dart';
import '../cubit/activity_location_map_state.dart';
import '../components/map_bottom_panel.dart';

class ActivityLocationMapScreen extends StatelessWidget {
  final ActivityRecordModel activity;
  const ActivityLocationMapScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    // Strict parsing of target coordinates - no hardcoded fallbacks as requested
    final targetLat = double.tryParse(activity.latitude ?? '');
    final targetLng = double.tryParse(activity.longitude ?? '');

    // Error UI if target print location coordinates are completely invalid
    if (targetLat == null || targetLng == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Invalid Print Coordinates'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off_rounded, color: AppColors.error, size: 54),
                const SizedBox(height: 16),
                Text(
                  'Invalid Target Print Location',
                  style: AppTextStyle.heading.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'This print record does not contain valid latitude and longitude coordinates, so tracking is unavailable.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => ActivityLocationMapCubit(
        targetLocation: LatLng(targetLat, targetLng),
      )..initLocationTracking(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Live Tracking Print Location'),
        ),
        body: _ActivityLocationMapView(activity: activity, targetLocation: LatLng(targetLat, targetLng)),
      ),
    );
  }
}

class _ActivityLocationMapView extends StatefulWidget {
  final ActivityRecordModel activity;
  final LatLng targetLocation;

  const _ActivityLocationMapView({
    required this.activity,
    required this.targetLocation,
  });

  @override
  State<_ActivityLocationMapView> createState() => _ActivityLocationMapViewState();
}

class _ActivityLocationMapViewState extends State<_ActivityLocationMapView> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// Fit both user marker and target marker on the screen
  void _centerCameraToShowAll(LatLng userLocation) {
    if (_mapController == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        userLocation.latitude < widget.targetLocation.latitude ? userLocation.latitude : widget.targetLocation.latitude,
        userLocation.longitude < widget.targetLocation.longitude ? userLocation.longitude : widget.targetLocation.longitude,
      ),
      northeast: LatLng(
        userLocation.latitude > widget.targetLocation.latitude ? userLocation.latitude : widget.targetLocation.latitude,
        userLocation.longitude > widget.targetLocation.longitude ? userLocation.longitude : widget.targetLocation.longitude,
      ),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80), // 80px padding
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityLocationMapCubit, ActivityLocationMapState>(
      listener: (context, state) {
        // Automatically re-center bounds when a fresh user location lands
        if (state.userLocation != null && _mapController != null) {
          _centerCameraToShowAll(state.userLocation!);
        }
      },
      builder: (context, state) {
        // Map is loaded strictly ONLY when current location (lat/long) is resolved
        if (state.isMapLoading || state.userLocation == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Searching GPS location...',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                SizedBox(height: 6),
                Text(
                  'Map will render once live location is resolved.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        // Generate map markers
        final Set<Marker> markers = {
          // 1. Target marker
          Marker(
            markerId: const MarkerId('target_location'),
            position: widget.targetLocation,
            infoWindow: InfoWindow(
              title: 'Print Location',
              snippet: widget.activity.gpsAddress ?? 'Target Location',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
          // 2. User live location marker
          Marker(
            markerId: const MarkerId('user_location'),
            position: state.userLocation!,
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        };

        // Generate polyline
        final Set<Polyline> polylines = {
          Polyline(
            polylineId: const PolylineId('route_pipeline'),
            points: state.routePoints.isNotEmpty ? state.routePoints : [state.userLocation!, widget.targetLocation],
            color: state.isWalking ? AppColors.success : AppColors.accentIndigoDeep,
            width: 5,
            geodesic: true,
            jointType: JointType.round,
          ),
        };

        return Stack(
          children: [
            // 1. Map Widget (rendered only when userLocation is non-null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: state.userLocation!,
                zoom: 14.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _centerCameraToShowAll(state.userLocation!);
              },
              markers: markers,
              polylines: polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),

            // 2. floating center-focus button
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton.small(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                onPressed: () => _centerCameraToShowAll(state.userLocation!),
                child: const Icon(Icons.center_focus_strong_rounded),
              ),
            ),

            // 3. Routing update status label
            if (state.isRoutingLoading)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Recalculating pipeline...',
                            style: AppTextStyle.caption.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 4. sliding bottom panel stats selector (separated component)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MapBottomPanel(
                destinationAddress: widget.activity.gpsAddress ?? 'Print Site Coordinates',
                distanceInKm: state.distanceInKm,
                durationInMins: state.durationInMins,
                isWalking: state.isWalking,
                onModeChanged: (isWalking) {
                  context.read<ActivityLocationMapCubit>().toggleWalkingMode(isWalking);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
