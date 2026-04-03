import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Ensures location permission is granted and services are enabled.
  Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Returns the device's current position, requesting permission if needed.
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await ensurePermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      return null;
    }
  }

  /// Reverse-geocodes [latitude]/[longitude] into a human-readable name
  /// (e.g. "Brussels, Belgium"). Returns a coordinate string as fallback.
  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
          if (p.administrativeArea != null &&
              p.administrativeArea!.isNotEmpty &&
              p.administrativeArea != p.locality)
            p.administrativeArea!,
          if (p.country != null && p.country!.isNotEmpty) p.country!,
        ];
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {
      // Fall through to coordinate string.
    }
    return '${latitude.toStringAsFixed(3)}, ${longitude.toStringAsFixed(3)}';
  }

  /// Quick check: does the app have location permission?
  Future<bool> hasPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final perm = await Geolocator.checkPermission();
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }
}
