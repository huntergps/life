import 'package:latlong2/latlong.dart';

/// Geospatial utilities for GPS track processing.
///
/// All methods are pure functions (no I/O, no state) — safe to call from
/// any context or isolate.
class GeoUtils {
  const GeoUtils._();

  /// Calculates the total length of [points] in **kilometres**.
  ///
  /// Uses the [latlong2] `Distance` class (vincenty formula).
  /// Returns 0 for fewer than 2 points.
  static double calculateDistanceKm(List<LatLng> points) {
    if (points.length < 2) return 0;

    final d = Distance();
    double totalMeters = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalMeters += d.distance(points[i], points[i + 1]);
    }
    return totalMeters / 1000.0;
  }

  /// Simplifies a GPS track using the Ramer-Douglas-Peucker algorithm.
  ///
  /// Removes points that deviate less than [toleranceMeters] from the
  /// straight line between their neighbours, typically achieving a 70–85 %
  /// point-count reduction while preserving visible shape.
  ///
  /// Recommended tolerances: 5 m (hiking), 8 m (default), 15 m (boat/bike),
  /// 20 m (vehicle).
  static List<LatLng> simplifyTrack(
    List<LatLng> points, {
    double toleranceMeters = 8,
  }) {
    if (points.length <= 2) return points;

    double maxDistance = 0;
    int maxIndex = 0;

    for (int i = 1; i < points.length - 1; i++) {
      final d = perpendicularDistance(points[i], points.first, points.last);
      if (d > maxDistance) {
        maxDistance = d;
        maxIndex = i;
      }
    }

    if (maxDistance > toleranceMeters) {
      final left = simplifyTrack(
        points.sublist(0, maxIndex + 1),
        toleranceMeters: toleranceMeters,
      );
      final right = simplifyTrack(
        points.sublist(maxIndex),
        toleranceMeters: toleranceMeters,
      );
      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [points.first, points.last];
    }
  }

  /// Perpendicular distance in **metres** from [point] to the line
  /// segment [start]→[end].
  ///
  /// Uses a flat-earth dot-product projection with the [latlong2] `Distance`
  /// class for the final measurement — accurate for the short GPS segments
  /// typical of Galápagos trails.
  static double perpendicularDistance(
    LatLng point,
    LatLng start,
    LatLng end,
  ) {
    final dist = Distance();
    final lineLength = dist.distance(start, end);
    if (lineLength == 0) return dist.distance(point, start);

    final dx = end.longitude - start.longitude;
    final dy = end.latitude - start.latitude;
    final t = ((point.longitude - start.longitude) * dx +
            (point.latitude - start.latitude) * dy) /
        (dx * dx + dy * dy);
    final tClamped = t.clamp(0.0, 1.0);

    final closest = LatLng(
      start.latitude + tClamped * dy,
      start.longitude + tClamped * dx,
    );
    return dist.distance(point, closest);
  }
}
