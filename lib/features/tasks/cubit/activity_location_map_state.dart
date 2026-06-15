import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ActivityLocationMapState extends Equatable {
  final LatLng? userLocation;
  final bool isWalking;
  final List<LatLng> routePoints;
  final double distanceInKm;
  final double durationInMins;
  final bool isMapLoading;
  final bool isRoutingLoading;
  final String? errorMessage;

  const ActivityLocationMapState({
    this.userLocation,
    this.isWalking = false,
    this.routePoints = const [],
    this.distanceInKm = 0.0,
    this.durationInMins = 0.0,
    this.isMapLoading = true,
    this.isRoutingLoading = false,
    this.errorMessage,
  });

  ActivityLocationMapState copyWith({
    LatLng? userLocation,
    bool? isWalking,
    List<LatLng>? routePoints,
    double? distanceInKm,
    double? durationInMins,
    bool? isMapLoading,
    bool? isRoutingLoading,
    String? errorMessage,
  }) {
    return ActivityLocationMapState(
      userLocation: userLocation ?? this.userLocation,
      isWalking: isWalking ?? this.isWalking,
      routePoints: routePoints ?? this.routePoints,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      durationInMins: durationInMins ?? this.durationInMins,
      isMapLoading: isMapLoading ?? this.isMapLoading,
      isRoutingLoading: isRoutingLoading ?? this.isRoutingLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        userLocation,
        isWalking,
        routePoints,
        distanceInKm,
        durationInMins,
        isMapLoading,
        isRoutingLoading,
        errorMessage,
      ];
}
