import 'package:geolocator/geolocator.dart';

class DistanceCalculator {
  /// Calculates distance in meters between two coordinates using Geolocator API
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Returns distance in KM as a formatted string (e.g. "5.23 KM")
  static String getDistanceInKm(double lat1, double lon1, double lat2, double lon2) {
    final distanceInMeters = calculateDistance(lat1, lon1, lat2, lon2);
    final distanceInKm = distanceInMeters / 1000.0;
    return "${distanceInKm.toStringAsFixed(2)} KM";
  }
}
