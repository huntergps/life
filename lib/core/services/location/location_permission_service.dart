import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

/// Centralises GPS permission checks across the app.
///
/// Use [ensurePermission] before starting any location stream or one-shot fix.
class LocationPermissionService {
  const LocationPermissionService._();

  /// Returns `true` when the GPS service is enabled and the app has (or just
  /// obtained) location permission.
  ///
  /// Returns `false` on web, when the device GPS service is off, or when
  /// permission is denied / denied-forever.
  static Future<bool> ensurePermission() async {
    if (kIsWeb) return false;
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  /// Returns `true` when the device GPS service is turned on.
  /// Always `false` on web.
  static Future<bool> isServiceEnabled() async {
    if (kIsWeb) return false;
    return Geolocator.isLocationServiceEnabled();
  }
}
