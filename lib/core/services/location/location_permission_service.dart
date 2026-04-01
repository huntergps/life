import 'package:geolocator/geolocator.dart';

/// Centralises GPS permission checks across the app.
///
/// Use [ensurePermission] before starting any location stream or one-shot fix.
///
/// Works on iOS, Android, macOS and Web (browser Geolocation API).
class LocationPermissionService {
  const LocationPermissionService._();

  /// Returns `true` when the GPS service is enabled and the app has (or just
  /// obtained) location permission.
  ///
  /// Returns `false` when the device GPS service is off, or when
  /// permission is denied / denied-forever. On web the browser will prompt the
  /// user for location access.
  static Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  /// Returns `true` when the device GPS service is turned on.
  /// On web this checks whether the browser supports the Geolocation API.
  static Future<bool> isServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }
}
