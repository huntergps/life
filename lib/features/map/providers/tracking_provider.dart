import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import '../utils/route_utils.dart';

// ---------------------------------------------------------------------------
// State providers (legacy StateProvider for Riverpod 3.x compatibility)
// ---------------------------------------------------------------------------

/// Whether GPS tracking is currently active.
final isTrackingProvider = StateProvider<bool>((ref) => false);

/// The parsed trail coordinates the user is following, or `null` when free
/// walking (no trail selected).
final activeTrailCoordsProvider = StateProvider<List<LatLng>?>((ref) => null);

/// The recorded track points collected during the current session.
final trackPointsProvider =
    StateProvider<List<({LatLng point, DateTime time})>>((ref) => []);

/// Whether the user is currently off the active trail route.
final offRouteProvider = StateProvider<bool>((ref) => false);

/// Distance in meters from the user to the nearest point on the active trail.
final distanceFromTrailProvider = StateProvider<double>((ref) => 0);

// ---------------------------------------------------------------------------
// GPS position stream
// ---------------------------------------------------------------------------

/// Streams GPS [Position] updates while tracking is active.
///
/// Uses high accuracy and a 5-meter distance filter. The stream automatically
/// pauses when [isTrackingProvider] is `false`.
final gpsStreamProvider = StreamProvider<Position>((ref) {
  if (kIsWeb) return const Stream<Position>.empty();

  final isTracking = ref.watch(isTrackingProvider);

  if (!isTracking) {
    // Return an empty stream that never emits when tracking is off.
    return const Stream<Position>.empty();
  }

  const settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: AppConstants.gpsDistanceFilterMeters,
  );

  return Geolocator.getPositionStream(locationSettings: settings);
});

// ---------------------------------------------------------------------------
// Tracking service
// ---------------------------------------------------------------------------

/// Summary data returned when a tracking session ends.
class TrackingSummary {
  /// Total distance walked in meters, calculated from recorded track points.
  final double distanceMeters;

  /// Total duration of the tracking session.
  final Duration duration;

  /// Number of GPS fixes recorded.
  final int pointCount;

  /// The recorded track as a list of [LatLng] points (without timestamps).
  final List<LatLng> polyline;

  const TrackingSummary({
    required this.distanceMeters,
    required this.duration,
    required this.pointCount,
    required this.polyline,
  });
}

/// Manages GPS tracking lifecycle: start/stop, point recording, and
/// off-route detection.
///
/// Accepts a [WidgetRef] so it can be created from ConsumerState widgets.
class TrackingService {
  final WidgetRef _ref;
  StreamSubscription<Position>? _gpsSub;
  DateTime? _startTime;

  TrackingService(this._ref);

  /// Begins a tracking session.
  ///
  /// If [trailCoordinates] is provided the service will calculate off-route
  /// status and distance-from-trail for each GPS fix. Pass `null` for free
  /// walking mode.
  void startTracking([List<LatLng>? trailCoordinates]) {
    if (kIsWeb) return; // GPS tracking not supported on web

    // Reset state
    _ref.read(trackPointsProvider.notifier).state = [];
    _ref.read(offRouteProvider.notifier).state = false;
    _ref.read(distanceFromTrailProvider.notifier).state = 0;
    _ref.read(activeTrailCoordsProvider.notifier).state = trailCoordinates;

    _startTime = DateTime.now();

    // Activate tracking state
    _ref.read(isTrackingProvider.notifier).state = true;

    // Listen directly to Geolocator position stream (avoids Ref vs WidgetRef
    // issues with provider subscriptions).
    _gpsSub?.cancel();
    _gpsSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: AppConstants.gpsDistanceFilterMeters,
      ),
    ).listen(
      _onPosition,
      onError: (_) {},
    );
  }

  /// Processes a single GPS position fix.
  void _onPosition(Position position) {
    final latLng = LatLng(position.latitude, position.longitude);
    final now = DateTime.now();

    // Append to recorded track
    final current =
        List<({LatLng point, DateTime time})>.from(_ref.read(trackPointsProvider));
    current.add((point: latLng, time: now));
    _ref.read(trackPointsProvider.notifier).state = current;

    // Off-route detection when following a trail
    final trailCoords = _ref.read(activeTrailCoordsProvider);
    if (trailCoords != null && trailCoords.length >= 2) {
      final result = distanceToPolyline(latLng, trailCoords);
      _ref.read(distanceFromTrailProvider.notifier).state = result.distance;
      _ref.read(offRouteProvider.notifier).state = result.distance > AppConstants.offRouteThresholdMeters;
    }
  }

  /// Stops the current tracking session and returns a [TrackingSummary].
  TrackingSummary stopTracking() {
    _ref.read(isTrackingProvider.notifier).state = false;
    _gpsSub?.cancel();
    _gpsSub = null;

    final points = _ref.read(trackPointsProvider);
    final polyline = points.map((p) => p.point).toList();

    final duration = _startTime != null
        ? DateTime.now().difference(_startTime!)
        : Duration.zero;

    final distance = polylineLength(polyline);

    // Clear trail-following state
    _ref.read(activeTrailCoordsProvider.notifier).state = null;
    _ref.read(offRouteProvider.notifier).state = false;
    _ref.read(distanceFromTrailProvider.notifier).state = 0;

    return TrackingSummary(
      distanceMeters: distance,
      duration: duration,
      pointCount: points.length,
      polyline: polyline,
    );
  }
}
