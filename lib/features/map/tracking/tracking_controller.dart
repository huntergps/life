import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';

import '../providers/tracking_provider.dart';
import '../utils/route_utils.dart';

/// Encapsulates trail-tracking lifecycle (start / stop) and the
/// zoom-to-trail-extent helper.
class TrackingController {
  TrackingController({
    required this.ref,
    required this.mapController,
  });

  final WidgetRef ref;
  final MapController mapController;

  TrackingService? _trackingService;

  /// Begin tracking the given trail.
  void startTrackingTrail(String coordinatesJson) {
    final coords = parseTrailCoordinates(coordinatesJson);
    if (coords.isEmpty) return;
    _trackingService = TrackingService(ref);
    _trackingService!.startTracking(coords);
    zoomToTrailExtent(coords);
  }

  /// Stop the active tracking session and show a summary snackbar.
  void stopTracking(BuildContext context) {
    if (_trackingService == null) {
      ref.read(isTrackingProvider.notifier).state = false;
      ref.read(offRouteProvider.notifier).state = false;
      ref.read(activeTrailCoordsProvider.notifier).state = null;
      ref.read(trackPointsProvider.notifier).state = [];
      ref.read(distanceFromTrailProvider.notifier).state = 0;
      return;
    }

    final summary = _trackingService!.stopTracking();
    _trackingService = null;

    final distanceKm = (summary.distanceMeters / 1000).toStringAsFixed(2);
    final message = StringBuffer(context.t.map.trackRecorded);
    message.write(' - ');
    message.write(context.t.map.trackDistance(km: distanceKm));

    if (summary.duration.inMinutes > 0) {
      final hours = summary.duration.inHours;
      final minutes = summary.duration.inMinutes.remainder(60);
      final durationStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
      message.write(' - ');
      message.write(context.t.map.trackDuration(duration: durationStr));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toString()),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Fit the camera to show the full extent of the given coordinates.
  void zoomToTrailExtent(List<LatLng> coords) {
    if (coords.isEmpty) return;
    if (coords.length == 1) {
      mapController.move(coords.first, 14);
      return;
    }

    var minLat = coords.first.latitude;
    var maxLat = coords.first.latitude;
    var minLng = coords.first.longitude;
    var maxLng = coords.first.longitude;

    for (final coord in coords) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }

    const padding = 0.005;
    final bounds = LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    );
    mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
  }
}
