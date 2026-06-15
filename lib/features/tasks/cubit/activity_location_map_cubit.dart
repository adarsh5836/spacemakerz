import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../app/services/routing_service.dart';
import 'activity_location_map_state.dart';

class ActivityLocationMapCubit extends Cubit<ActivityLocationMapState> {
  StreamSubscription<Position>? _positionSubscription;
  final LatLng targetLocation;

  ActivityLocationMapCubit({required this.targetLocation})
    : super(const ActivityLocationMapState());

  /// Request permissions, retrieve fast last known location, and subscribe to live changes
  Future<void> initLocationTracking() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        emit(
          state.copyWith(
            isMapLoading: false,
            errorMessage: 'Location permission is permanently denied.',
          ),
        );
        return;
      }

      // Fast Load: Get last known position instantly
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final initialLatLng = LatLng(lastKnown.latitude, lastKnown.longitude);
        emit(state.copyWith(userLocation: initialLatLng, isMapLoading: false));
        _fetchRoute(initialLatLng, state.isWalking);
      }

      // Live Stream Subscription: update every 10 meters of movement
      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      );

      _positionSubscription =
          Geolocator.getPositionStream(locationSettings: settings).listen((
            Position position,
          ) {
            final newLatLng = LatLng(position.latitude, position.longitude);
            emit(state.copyWith(userLocation: newLatLng, isMapLoading: false));
            _fetchRoute(newLatLng, state.isWalking);
          });
    } catch (e) {
      emit(
        state.copyWith(
          isMapLoading: false,
          errorMessage: 'Failed to initialize tracking: $e',
        ),
      );
    }
  }

  /// Change between driving/bike mode and walking mode
  Future<void> toggleWalkingMode(bool isWalking) async {
    emit(state.copyWith(isWalking: isWalking));
    if (state.userLocation != null) {
      await _fetchRoute(state.userLocation!, isWalking);
    }
  }

  /// Refetch the route coordinates and stats from OSRM
  Future<void> _fetchRoute(LatLng userLocation, bool isWalking) async {
    emit(state.copyWith(isRoutingLoading: true));
    try {
      final result = await RoutingService.getRoute(
        start: userLocation,
        end: targetLocation,
        isWalking: isWalking,
      );
      emit(
        state.copyWith(
          routePoints: result.polylinePoints,
          distanceInKm: result.distanceInKm,
          durationInMins: result.durationInMinutes,
          isRoutingLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isRoutingLoading: false,
          errorMessage: 'Routing error: $e',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
