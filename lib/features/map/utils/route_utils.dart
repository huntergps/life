import 'dart:convert';
import 'dart:math';

import 'package:latlong2/latlong.dart';

/// Earth's mean radius in meters (WGS-84).
const double _earthRadiusM = 6371000.0;

/// Parses the JSON coordinates string into a list of [LatLng] points.
///
/// Expects a JSON array of `[latitude, longitude]` pairs, e.g.
/// `'[[-0.75,-90.31],[-0.76,-90.32]]'`.
/// Returns an empty list for empty or malformed input.
List<LatLng> parseTrailCoordinates(String coordinatesJson) {
  if (coordinatesJson.isEmpty) return [];

  try {
    final decoded = jsonDecode(coordinatesJson) as List<dynamic>;
    return decoded.map<LatLng>((pair) {
      final coords = pair as List<dynamic>;
      final lat = (coords[0] as num).toDouble();
      final lng = (coords[1] as num).toDouble();
      return LatLng(lat, lng);
    }).toList();
  } catch (_) {
    return [];
  }
}

/// Calculates the distance in meters between two [LatLng] points using the
/// Haversine formula.
double haversineDistance(LatLng a, LatLng b) {
  final dLat = _toRadians(b.latitude - a.latitude);
  final dLng = _toRadians(b.longitude - a.longitude);

  final sinDLat = sin(dLat / 2);
  final sinDLng = sin(dLng / 2);

  final h = sinDLat * sinDLat +
      cos(_toRadians(a.latitude)) *
          cos(_toRadians(b.latitude)) *
          sinDLng *
          sinDLng;

  return 2 * _earthRadiusM * asin(sqrt(h));
}

/// Projects [point] onto the line segment from [start] to [end], clamped to
/// the segment endpoints.
///
/// Uses a planar approximation with latitude-corrected longitude scaling,
/// which is accurate enough for the short segments typical of trail
/// coordinates in the Galapagos.
LatLng projectPointOnSegment(LatLng point, LatLng start, LatLng end) {
  // Scale longitude differences by cos(latitude) to approximate equal-area
  final midLat = _toRadians((start.latitude + end.latitude) / 2);
  final cosLat = cos(midLat);

  final dx = (end.latitude - start.latitude);
  final dy = (end.longitude - start.longitude) * cosLat;

  final px = (point.latitude - start.latitude);
  final py = (point.longitude - start.longitude) * cosLat;

  final segLenSq = dx * dx + dy * dy;

  // Degenerate segment (start == end)
  if (segLenSq < 1e-18) return start;

  // Parameter t along the segment, clamped to [0, 1]
  final t = ((px * dx + py * dy) / segLenSq).clamp(0.0, 1.0);

  return LatLng(
    start.latitude + t * (end.latitude - start.latitude),
    start.longitude + t * (end.longitude - start.longitude),
  );
}

/// Calculates the distance in meters from [point] to the nearest point on
/// [polyline].
///
/// Returns a record with:
/// - `distance`: perpendicular distance in meters to the nearest segment
/// - `nearest`: the closest [LatLng] on the polyline
/// - `segmentIndex`: index of the segment (0-based) where the nearest point
///   lies (segment i connects `polyline[i]` to `polyline[i+1]`)
///
/// If [polyline] has fewer than 2 points, returns distance to the single
/// point (or infinity for an empty polyline).
({double distance, LatLng nearest, int segmentIndex}) distanceToPolyline(
  LatLng point,
  List<LatLng> polyline,
) {
  if (polyline.isEmpty) {
    return (
      distance: double.infinity,
      nearest: LatLng(0, 0),
      segmentIndex: -1,
    );
  }

  if (polyline.length == 1) {
    return (
      distance: haversineDistance(point, polyline.first),
      nearest: polyline.first,
      segmentIndex: 0,
    );
  }

  var bestDistance = double.infinity;
  var bestNearest = polyline.first;
  var bestSegment = 0;

  for (var i = 0; i < polyline.length - 1; i++) {
    final projected = projectPointOnSegment(point, polyline[i], polyline[i + 1]);
    final dist = haversineDistance(point, projected);

    if (dist < bestDistance) {
      bestDistance = dist;
      bestNearest = projected;
      bestSegment = i;
    }
  }

  return (
    distance: bestDistance,
    nearest: bestNearest,
    segmentIndex: bestSegment,
  );
}

/// Calculates the total length of [points] in meters by summing
/// consecutive Haversine distances.
double polylineLength(List<LatLng> points) {
  if (points.length < 2) return 0;

  var total = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    total += haversineDistance(points[i], points[i + 1]);
  }
  return total;
}

/// Returns `true` if [userPosition] is more than [thresholdMeters] away from
/// the nearest point on [trailCoordinates].
///
/// Defaults to a 50-meter threshold.
bool isOffRoute(
  LatLng userPosition,
  List<LatLng> trailCoordinates, {
  double thresholdMeters = 50,
}) {
  if (trailCoordinates.isEmpty) return false;

  final result = distanceToPolyline(userPosition, trailCoordinates);
  return result.distance > thresholdMeters;
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

double _toRadians(double degrees) => degrees * pi / 180;
