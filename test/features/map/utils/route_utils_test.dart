import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:galapagos_wildlife/features/map/utils/route_utils.dart';
import 'package:latlong2/latlong.dart';

// ---------------------------------------------------------------------------
// Realistic Galapagos coordinates used throughout the tests
// ---------------------------------------------------------------------------

/// Puerto Ayora dock area (Santa Cruz)
final _puertoAyora = LatLng(-0.7454, -90.3132);

/// Tortuga Bay beach (Santa Cruz) -- roughly 2.5 km south-west of Puerto Ayora
final _tortugaBay = LatLng(-0.7631, -90.3343);

/// Charles Darwin Research Station
final _charlesDarwin = LatLng(-0.7413, -90.3035);

/// Las Grietas viewpoint
final _lasGrietas = LatLng(-0.7530, -90.3200);

/// A simple two-point trail from Puerto Ayora toward Tortuga Bay
final _simpleTwoPointTrail = [_puertoAyora, _tortugaBay];

/// A multi-segment trail: Darwin Station -> Puerto Ayora -> Las Grietas -> Tortuga Bay
final _multiSegmentTrail = [
  _charlesDarwin,
  _puertoAyora,
  _lasGrietas,
  _tortugaBay,
];

void main() {
  // =========================================================================
  // parseTrailCoordinates
  // =========================================================================
  group('parseTrailCoordinates', () {
    test('valid JSON string returns correct LatLng list', () {
      final json = jsonEncode([
        [-0.7454, -90.3132],
        [-0.7631, -90.3343],
      ]);

      final result = parseTrailCoordinates(json);

      expect(result, hasLength(2));
      expect(result[0].latitude, closeTo(-0.7454, 1e-6));
      expect(result[0].longitude, closeTo(-90.3132, 1e-6));
      expect(result[1].latitude, closeTo(-0.7631, 1e-6));
      expect(result[1].longitude, closeTo(-90.3343, 1e-6));
    });

    test('empty array returns empty list', () {
      final result = parseTrailCoordinates('[]');
      expect(result, isEmpty);
    });

    test('empty string returns empty list', () {
      final result = parseTrailCoordinates('');
      expect(result, isEmpty);
    });

    test('malformed JSON returns empty list', () {
      final result = parseTrailCoordinates('not valid json [[[');
      expect(result, isEmpty);
    });

    test('JSON object instead of array returns empty list', () {
      final result = parseTrailCoordinates('{"lat": -0.7}');
      expect(result, isEmpty);
    });

    test('single coordinate point', () {
      final json = jsonEncode([
        [-0.7454, -90.3132],
      ]);

      final result = parseTrailCoordinates(json);

      expect(result, hasLength(1));
      expect(result[0].latitude, closeTo(-0.7454, 1e-6));
      expect(result[0].longitude, closeTo(-90.3132, 1e-6));
    });

    test('multiple coordinate points with correct lat/lng mapping', () {
      // Verify lat is coords[0] and lng is coords[1]
      final json = jsonEncode([
        [-0.7413, -90.3035], // Darwin Station
        [-0.7454, -90.3132], // Puerto Ayora
        [-0.7530, -90.3200], // Las Grietas
        [-0.7631, -90.3343], // Tortuga Bay
      ]);

      final result = parseTrailCoordinates(json);

      expect(result, hasLength(4));
      // Verify first element is latitude, second is longitude
      expect(result[0].latitude, closeTo(-0.7413, 1e-6));
      expect(result[0].longitude, closeTo(-90.3035, 1e-6));
      expect(result[3].latitude, closeTo(-0.7631, 1e-6));
      expect(result[3].longitude, closeTo(-90.3343, 1e-6));
    });

    test('integer coordinates are accepted', () {
      final json = jsonEncode([
        [0, -90],
      ]);

      final result = parseTrailCoordinates(json);

      expect(result, hasLength(1));
      expect(result[0].latitude, closeTo(0.0, 1e-6));
      expect(result[0].longitude, closeTo(-90.0, 1e-6));
    });
  });

  // =========================================================================
  // haversineDistance
  // =========================================================================
  group('haversineDistance', () {
    test('same point returns 0', () {
      final d = haversineDistance(_puertoAyora, _puertoAyora);
      expect(d, closeTo(0.0, 1e-6));
    });

    test('known distance Puerto Ayora to Tortuga Bay ~2.5 km', () {
      final d = haversineDistance(_puertoAyora, _tortugaBay);
      // Approximate real-world distance is ~3 km; accept a range of 2.5-3.5 km
      expect(d, greaterThan(2500));
      expect(d, lessThan(3500));
    });

    test('short distance in meters', () {
      // Two points about 100 m apart (small latitude shift at equator)
      final a = LatLng(-0.7454, -90.3132);
      final b = LatLng(-0.7463, -90.3132); // ~0.0009 deg lat ~ 100 m
      final d = haversineDistance(a, b);
      expect(d, greaterThan(50));
      expect(d, lessThan(200));
    });

    test('symmetrical: distance(a, b) == distance(b, a)', () {
      final dAB = haversineDistance(_puertoAyora, _tortugaBay);
      final dBA = haversineDistance(_tortugaBay, _puertoAyora);
      expect(dAB, closeTo(dBA, 1e-6));
    });

    test('large distance across the island', () {
      // Puerto Ayora to Charles Darwin Station is a short distance
      final d = haversineDistance(_puertoAyora, _charlesDarwin);
      expect(d, greaterThan(500));
      expect(d, lessThan(2000));
    });
  });

  // =========================================================================
  // projectPointOnSegment
  // =========================================================================
  group('projectPointOnSegment', () {
    test('point projects onto middle of segment', () {
      // A point offset perpendicularly from the midpoint of the segment
      final start = LatLng(-0.7400, -90.3100);
      final end = LatLng(-0.7400, -90.3200);
      // Point is north of the segment midpoint
      final point = LatLng(-0.7380, -90.3150);

      final projected = projectPointOnSegment(point, start, end);

      // The projected point should have approximately the same longitude as the
      // input point and the latitude of the segment (which is constant at -0.74)
      expect(projected.latitude, closeTo(-0.7400, 1e-3));
      expect(projected.longitude, closeTo(-90.3150, 1e-3));
    });

    test('point beyond start clamps to start', () {
      final start = LatLng(-0.7400, -90.3100);
      final end = LatLng(-0.7400, -90.3200);
      // Point is far east, past the start
      final point = LatLng(-0.7400, -90.3000);

      final projected = projectPointOnSegment(point, start, end);

      expect(projected.latitude, closeTo(start.latitude, 1e-6));
      expect(projected.longitude, closeTo(start.longitude, 1e-6));
    });

    test('point beyond end clamps to end', () {
      final start = LatLng(-0.7400, -90.3100);
      final end = LatLng(-0.7400, -90.3200);
      // Point is far west, past the end
      final point = LatLng(-0.7400, -90.3300);

      final projected = projectPointOnSegment(point, start, end);

      expect(projected.latitude, closeTo(end.latitude, 1e-6));
      expect(projected.longitude, closeTo(end.longitude, 1e-6));
    });

    test('point exactly on segment returns itself', () {
      final start = LatLng(-0.7400, -90.3100);
      final end = LatLng(-0.7400, -90.3200);
      // Midpoint of the segment
      final point = LatLng(-0.7400, -90.3150);

      final projected = projectPointOnSegment(point, start, end);

      expect(projected.latitude, closeTo(point.latitude, 1e-6));
      expect(projected.longitude, closeTo(point.longitude, 1e-6));
    });

    test('degenerate segment (start == end) returns start', () {
      final start = LatLng(-0.7400, -90.3100);
      final end = LatLng(-0.7400, -90.3100);
      final point = LatLng(-0.7380, -90.3150);

      final projected = projectPointOnSegment(point, start, end);

      expect(projected.latitude, closeTo(start.latitude, 1e-6));
      expect(projected.longitude, closeTo(start.longitude, 1e-6));
    });
  });

  // =========================================================================
  // distanceToPolyline
  // =========================================================================
  group('distanceToPolyline', () {
    test('empty polyline returns infinity distance and segment index -1', () {
      final result = distanceToPolyline(_puertoAyora, []);
      expect(result.distance, double.infinity);
      expect(result.segmentIndex, -1);
    });

    test('single point polyline returns distance to that point', () {
      final result = distanceToPolyline(_puertoAyora, [_tortugaBay]);
      final expected = haversineDistance(_puertoAyora, _tortugaBay);
      expect(result.distance, closeTo(expected, 1e-6));
      expect(result.segmentIndex, 0);
    });

    test('single segment polyline', () {
      final result = distanceToPolyline(_lasGrietas, _simpleTwoPointTrail);

      // Las Grietas is between Puerto Ayora and Tortuga Bay, roughly on the
      // line; the distance should be relatively small (under 500 m)
      expect(result.distance, lessThan(500));
      expect(result.segmentIndex, 0);
    });

    test('multi-segment polyline picks closest segment', () {
      // Point near the Darwin Station -> Puerto Ayora segment
      final nearDarwin = LatLng(-0.7430, -90.3080);
      final result = distanceToPolyline(nearDarwin, _multiSegmentTrail);

      // Should be closest to segment 0 (Darwin -> PuertoAyora)
      expect(result.segmentIndex, 0);
      expect(result.distance, lessThan(500));
    });

    test('point on the polyline returns ~0 distance', () {
      // Use an exact vertex of the polyline
      final result = distanceToPolyline(_puertoAyora, _multiSegmentTrail);
      expect(result.distance, closeTo(0, 1.0));
    });

    test('point far from polyline returns large distance', () {
      // Isla Isabela -- far from Santa Cruz trail
      final farPoint = LatLng(-0.8300, -91.1000);
      final result = distanceToPolyline(farPoint, _simpleTwoPointTrail);

      // Should be many km away (>50 km)
      expect(result.distance, greaterThan(50000));
    });

    test('returns correct nearest point', () {
      final result = distanceToPolyline(_puertoAyora, _simpleTwoPointTrail);
      // The nearest point should be very close to _puertoAyora itself
      final distToNearest =
          haversineDistance(_puertoAyora, result.nearest);
      expect(distToNearest, closeTo(0, 1.0));
    });
  });

  // =========================================================================
  // polylineLength
  // =========================================================================
  group('polylineLength', () {
    test('empty list returns 0', () {
      expect(polylineLength([]), 0);
    });

    test('single point returns 0', () {
      expect(polylineLength([_puertoAyora]), 0);
    });

    test('two points returns haversine distance between them', () {
      final length = polylineLength(_simpleTwoPointTrail);
      final expected =
          haversineDistance(_simpleTwoPointTrail[0], _simpleTwoPointTrail[1]);
      expect(length, closeTo(expected, 1e-6));
    });

    test('multiple points sums all segments', () {
      final length = polylineLength(_multiSegmentTrail);

      final seg0 =
          haversineDistance(_multiSegmentTrail[0], _multiSegmentTrail[1]);
      final seg1 =
          haversineDistance(_multiSegmentTrail[1], _multiSegmentTrail[2]);
      final seg2 =
          haversineDistance(_multiSegmentTrail[2], _multiSegmentTrail[3]);

      expect(length, closeTo(seg0 + seg1 + seg2, 1e-6));
    });

    test('total length is greater than direct distance', () {
      // The polyline through intermediate points should be longer than a
      // straight line from first to last point
      final total = polylineLength(_multiSegmentTrail);
      final direct = haversineDistance(
          _multiSegmentTrail.first, _multiSegmentTrail.last);
      expect(total, greaterThan(direct));
    });
  });

  // =========================================================================
  // isOffRoute
  // =========================================================================
  group('isOffRoute', () {
    test('empty trail always returns false', () {
      expect(isOffRoute(_puertoAyora, []), isFalse);
    });

    test('user on trail returns false', () {
      // User at an exact vertex of the trail
      final result = isOffRoute(_puertoAyora, _simpleTwoPointTrail);
      expect(result, isFalse);
    });

    test('user very close to trail returns false', () {
      // Shift user ~10 m north of Puerto Ayora (well within 50 m default)
      final nearUser = LatLng(-0.7453, -90.3132);
      final result = isOffRoute(nearUser, _simpleTwoPointTrail);
      expect(result, isFalse);
    });

    test('user 100m away returns true with default 50m threshold', () {
      // Shift user ~100 m east of Puerto Ayora
      // At the equator, ~0.001 deg longitude ~ 111 m
      final farUser = LatLng(-0.7454, -90.3122);
      final distFromTrail =
          distanceToPolyline(farUser, _simpleTwoPointTrail).distance;

      // First confirm the point is actually > 50 m away
      expect(distFromTrail, greaterThan(50));

      final result = isOffRoute(farUser, _simpleTwoPointTrail);
      expect(result, isTrue);
    });

    test('user exactly at threshold is not off-route (> not >=)', () {
      // Construct a point that is exactly at a known distance, then set
      // threshold to that distance. Since isOffRoute uses `>`, it should
      // return false when distance == threshold.
      final testPoint = LatLng(-0.7454, -90.3122);
      final distFromTrail =
          distanceToPolyline(testPoint, _simpleTwoPointTrail).distance;

      // Using the exact distance as threshold: distance > threshold is false
      final result = isOffRoute(
        testPoint,
        _simpleTwoPointTrail,
        thresholdMeters: distFromTrail,
      );
      expect(result, isFalse);
    });

    test('custom threshold: 200m keeps user on route', () {
      // User is ~100 m away but with a 200 m threshold they are still on route
      final farUser = LatLng(-0.7454, -90.3122);
      final result = isOffRoute(
        farUser,
        _simpleTwoPointTrail,
        thresholdMeters: 200,
      );
      expect(result, isFalse);
    });

    test('custom threshold: 10m detects slight deviation', () {
      // User just 20 m from trail should be off-route with 10 m threshold
      // ~0.0002 deg lat ~ 22 m
      final slightlyOff = LatLng(-0.7456, -90.3132);
      final distFromTrail =
          distanceToPolyline(slightlyOff, _simpleTwoPointTrail).distance;

      // Only flag if the point is actually > 10 m away
      if (distFromTrail > 10) {
        final result = isOffRoute(
          slightlyOff,
          _simpleTwoPointTrail,
          thresholdMeters: 10,
        );
        expect(result, isTrue);
      }
    });

    test('user far from trail on different island returns true', () {
      final isabelaPoint = LatLng(-0.8300, -91.1000);
      final result = isOffRoute(isabelaPoint, _simpleTwoPointTrail);
      expect(result, isTrue);
    });
  });
}
