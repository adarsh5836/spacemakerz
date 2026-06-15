import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OSRMRouteResult {
  final List<LatLng> polylinePoints;
  final double distanceInKm;
  final double durationInMinutes;

  OSRMRouteResult({
    required this.polylinePoints,
    required this.distanceInKm,
    required this.durationInMinutes,
  });
}

class RoutingService {
  /// Fetches routing path, distance, and duration between [start] and [end]
  /// using OSRM API. Supports walking (foot) and driving modes.
  static Future<OSRMRouteResult> getRoute({
    required LatLng start,
    required LatLng end,
    required bool isWalking,
  }) async {
    final mode = isWalking ? 'foot' : 'driving';
    // OSRM accepts coordinates as lon,lat;lon,lat
    final url = 'https://router.project-osrm.org/route/v1/$mode/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final firstRoute = routes[0];
          
          // Parse polyline points
          final geometry = firstRoute['geometry'];
          final coordinates = geometry['coordinates'] as List?;
          final List<LatLng> points = [];
          if (coordinates != null) {
            for (var coord in coordinates) {
              if (coord is List && coord.length >= 2) {
                points.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
              }
            }
          }

          // Parse distance (meters to kilometers)
          final num distanceMeters = firstRoute['distance'] ?? 0;
          final double distanceKm = distanceMeters / 1000.0;

          // Parse duration (seconds to minutes)
          final num durationSeconds = firstRoute['duration'] ?? 0;
          final double durationMins = durationSeconds / 60.0;

          return OSRMRouteResult(
            polylinePoints: points.isNotEmpty ? points : [start, end],
            distanceInKm: distanceKm,
            durationInMinutes: durationMins,
          );
        }
      }
    } catch (e) {
      print("Error in RoutingService.getRoute: $e");
    }

    // Fallback to direct straight line if API call fails
    return OSRMRouteResult(
      polylinePoints: [start, end],
      distanceInKm: 0.0,
      durationInMinutes: 0.0,
    );
  }
}
