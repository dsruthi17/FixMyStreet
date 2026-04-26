import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Get current position with permission handling
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(kIsWeb
          ? 'Location access is required. Please allow location access in your browser when prompted.'
          : 'Location services are disabled. Please enable them in your device settings.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(kIsWeb
            ? 'Location permission was denied. Please allow location access in your browser settings.'
            : 'Location permission denied. Please grant location access to continue.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        kIsWeb
            ? 'Location access was blocked. Please enable it in your browser settings (usually found in the address bar).'
            : 'Location permissions are permanently denied. Please enable them in app settings.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      throw Exception(
          'Failed to get location: ${e.toString()}. Please make sure location services are enabled.');
    }
  }

  // Reverse geocode coordinates to address
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          if (place.street != null && place.street!.isNotEmpty) place.street!,
          if (place.subLocality != null && place.subLocality!.isNotEmpty)
            place.subLocality!,
          if (place.locality != null && place.locality!.isNotEmpty)
            place.locality!,
          if (place.postalCode != null && place.postalCode!.isNotEmpty)
            place.postalCode!,
        ];
        return parts.join(', ');
      }
      return 'Unknown location';
    } catch (_) {
      return 'Unable to fetch address';
    }
  }

  // Calculate distance between two points in km
  double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }
}
