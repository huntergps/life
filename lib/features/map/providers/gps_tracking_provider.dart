import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'field_edit_provider.dart';

/// Manages background GPS tracking independently of any widget lifecycle.
///
/// Automatically starts/stops the position stream based on [fieldEditProvider]
/// state, so GPS continues even when the app is backgrounded or the screen
/// is locked.
class GpsTrackingNotifier extends StateNotifier<bool> {
  GpsTrackingNotifier(this._ref) : super(false) {
    // React to field edit mode changes
    _ref.listen<FieldEditState>(fieldEditProvider, (prev, next) {
      final isGPSMode = next.mode == FieldEditMode.createTrailGPS ||
          next.mode == FieldEditMode.editTrailGPS;

      if (isGPSMode && next.isRecording && !state) {
        _startTracking();
      } else if ((!isGPSMode || !next.isRecording) && state) {
        _stopTracking();
      }
    });
  }

  final Ref _ref;
  StreamSubscription<Position>? _subscription;

  /// Maps [TrackingProfile] to the iOS CLLocationManager ActivityType hint.
  ActivityType _activityType(TrackingProfile profile) => switch (profile) {
    TrackingProfile.walking  => ActivityType.fitness,
    TrackingProfile.cycling  => ActivityType.fitness,
    TrackingProfile.boat     => ActivityType.otherNavigation,
    TrackingProfile.vehicle  => ActivityType.automotiveNavigation,
  };

  Future<void> _startTracking() async {
    if (kIsWeb) return; // GPS background tracking not supported on web

    // Verify permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final profile = _ref.read(fieldEditProvider).trackingProfile;
    final distFilter = profile.distanceFilterMeters;

    // iOS: enable background location updates so GPS continues when the
    // screen is locked or another app is in the foreground.
    // Each profile sets the appropriate activityType so iOS's motion
    // coprocessor can apply the right dead-reckoning corrections.
    final locationSettings = Platform.isIOS
        ? AppleSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: distFilter,
            pauseLocationUpdatesAutomatically: false,
            allowBackgroundLocationUpdates: true,
            activityType: _activityType(profile),
          )
        : AndroidSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: distFilter,
            intervalDuration: const Duration(seconds: 3),
          );

    _subscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) {
      final editState = _ref.read(fieldEditProvider);
      if (editState.isRecording) {
        _ref.read(fieldEditProvider.notifier).addRecordingPoint(
              LatLng(position.latitude, position.longitude),
            );
      }
    });

    state = true;
  }

  void _stopTracking() {
    _subscription?.cancel();
    _subscription = null;
    state = false;
  }

  @override
  void dispose() {
    _stopTracking();
    super.dispose();
  }
}

/// `true` while GPS background tracking is active, `false` otherwise.
final gpsTrackingProvider =
    StateNotifierProvider<GpsTrackingNotifier, bool>((ref) {
  return GpsTrackingNotifier(ref);
});
