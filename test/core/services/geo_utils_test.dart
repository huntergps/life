import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:galapagos_wildlife/core/services/location/geo_utils.dart';

// Realistic Galápagos coordinates
const _puertoAyora = LatLng(-0.7454, -90.3132);
const _tortugaBay = LatLng(-0.7631, -90.3343);
const _charlesDarwin = LatLng(-0.7413, -90.3035);
const _lasGrietas = LatLng(-0.7530, -90.3200);

void main() {
  // =========================================================================
  // calculateDistanceKm
  // =========================================================================
  group('GeoUtils.calculateDistanceKm', () {
    test('returns 0 for empty list', () {
      expect(GeoUtils.calculateDistanceKm([]), 0.0);
    });

    test('returns 0 for single point', () {
      expect(GeoUtils.calculateDistanceKm([const LatLng(0, 0)]), 0.0);
    });

    test('returns positive value for two different points', () {
      final points = [_puertoAyora, _tortugaBay];
      expect(GeoUtils.calculateDistanceKm(points), greaterThan(0));
    });

    test('known distance Puerto Ayora to Tortuga Bay is roughly 2-4 km', () {
      final km = GeoUtils.calculateDistanceKm([_puertoAyora, _tortugaBay]);
      expect(km, greaterThan(2.0));
      expect(km, lessThan(4.0));
    });

    test('is symmetric: dist(a,b) == dist(b,a)', () {
      final forward =
          GeoUtils.calculateDistanceKm([_puertoAyora, _tortugaBay]);
      final backward =
          GeoUtils.calculateDistanceKm([_tortugaBay, _puertoAyora]);
      expect(forward, closeTo(backward, 1e-9));
    });

    test('multi-segment distance is sum of individual segments', () {
      final points = [_charlesDarwin, _puertoAyora, _lasGrietas, _tortugaBay];
      final total = GeoUtils.calculateDistanceKm(points);

      final seg0 =
          GeoUtils.calculateDistanceKm([_charlesDarwin, _puertoAyora]);
      final seg1 = GeoUtils.calculateDistanceKm([_puertoAyora, _lasGrietas]);
      final seg2 = GeoUtils.calculateDistanceKm([_lasGrietas, _tortugaBay]);

      expect(total, closeTo(seg0 + seg1 + seg2, 1e-9));
    });

    test('same point twice returns 0', () {
      expect(
        GeoUtils.calculateDistanceKm([_puertoAyora, _puertoAyora]),
        closeTo(0.0, 1e-6),
      );
    });

    test('returns value in kilometres (not metres)', () {
      // Puerto Ayora to Tortuga Bay is about 2-4 km, definitely not 2000-4000
      final km = GeoUtils.calculateDistanceKm([_puertoAyora, _tortugaBay]);
      expect(km, lessThan(10.0));
    });
  });

  // =========================================================================
  // simplifyTrack
  // =========================================================================
  group('GeoUtils.simplifyTrack', () {
    test('returns original list for 0 points', () {
      final empty = <LatLng>[];
      expect(GeoUtils.simplifyTrack(empty), empty);
    });

    test('returns original list for single point', () {
      final single = [_puertoAyora];
      expect(GeoUtils.simplifyTrack(single), single);
    });

    test('returns original list for exactly 2 points', () {
      final twoPoints = [_puertoAyora, _tortugaBay];
      final result = GeoUtils.simplifyTrack(twoPoints);
      expect(result, twoPoints);
    });

    test('result always starts and ends with original first/last points', () {
      final points = [
        _charlesDarwin,
        _puertoAyora,
        _lasGrietas,
        _tortugaBay,
      ];
      final result = GeoUtils.simplifyTrack(points);
      expect(result.first.latitude, closeTo(_charlesDarwin.latitude, 1e-9));
      expect(result.first.longitude, closeTo(_charlesDarwin.longitude, 1e-9));
      expect(result.last.latitude, closeTo(_tortugaBay.latitude, 1e-9));
      expect(result.last.longitude, closeTo(_tortugaBay.longitude, 1e-9));
    });

    test('result has fewer or equal points than the input', () {
      final points = [
        _charlesDarwin,
        _puertoAyora,
        _lasGrietas,
        _tortugaBay,
      ];
      final result = GeoUtils.simplifyTrack(points);
      expect(result.length, lessThanOrEqualTo(points.length));
    });

    test('collinear points are reduced to 2 with high tolerance', () {
      // Three collinear-ish points at equator: all on same latitude.
      // The middle point deviates 0 m perpendicularly so it will be removed.
      const a = LatLng(0.0, -90.0);
      const mid = LatLng(0.0, -90.1);
      const b = LatLng(0.0, -90.2);

      final result = GeoUtils.simplifyTrack([a, mid, b],
          toleranceMeters: 1); // 1 m tolerance; deviation is 0
      expect(result.length, 2);
      expect(result.first.latitude, closeTo(a.latitude, 1e-9));
      expect(result.last.latitude, closeTo(b.latitude, 1e-9));
    });

    test('point far off the line is preserved even with large tolerance', () {
      // The middle point is significantly off the straight line
      const start = LatLng(-0.7, -90.3);
      const deviated = LatLng(-0.8, -90.35); // large deviation
      const end = LatLng(-0.7, -90.4);

      // With a tight tolerance (1 m) the off-line point must be kept
      final result = GeoUtils.simplifyTrack([start, deviated, end],
          toleranceMeters: 1);
      expect(result.length, 3);
    });
  });

  // =========================================================================
  // perpendicularDistance
  // =========================================================================
  group('GeoUtils.perpendicularDistance', () {
    test('point on segment returns near-zero distance', () {
      // A point exactly between start and end (same latitude line)
      const start = LatLng(-0.74, -90.31);
      const end = LatLng(-0.74, -90.32);
      const mid = LatLng(-0.74, -90.315);

      final d = GeoUtils.perpendicularDistance(mid, start, end);
      expect(d, lessThan(1.0)); // less than 1 metre
    });

    test('degenerate segment (start == end) returns distance to start', () {
      const p = LatLng(-0.7, -90.3);
      const q = LatLng(-0.71, -90.31);
      final d = GeoUtils.perpendicularDistance(p, q, q);
      final dist = Distance();
      expect(d, closeTo(dist.distance(p, q), 1.0));
    });

    test('perpendicular distance is non-negative', () {
      final d = GeoUtils.perpendicularDistance(
          _lasGrietas, _puertoAyora, _tortugaBay);
      expect(d, greaterThanOrEqualTo(0.0));
    });
  });
}
