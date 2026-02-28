import 'package:flutter_test/flutter_test.dart';

/// Test sighting filtering logic extracted from filteredSightingsProvider.
/// Pure functions tested without Riverpod/Brick dependencies.

class MockSighting {
  final int speciesId;
  final DateTime? observedAt;
  final String? photoUrl;

  MockSighting({required this.speciesId, this.observedAt, this.photoUrl});
}

/// Mirrors the filter logic in filteredSightingsProvider (sighting_filters_provider.dart).
List<MockSighting> filterSightings(
  List<MockSighting> sightings, {
  int? speciesId,
  DateTime? dateFrom,
  DateTime? dateTo,
}) {
  var filtered = sightings;
  if (speciesId != null) {
    filtered = filtered.where((s) => s.speciesId == speciesId).toList();
  }
  if (dateFrom != null) {
    filtered = filtered
        .where((s) => s.observedAt != null && !s.observedAt!.isBefore(dateFrom))
        .toList();
  }
  if (dateTo != null) {
    filtered = filtered
        .where((s) =>
            s.observedAt != null &&
            s.observedAt!.isBefore(dateTo.add(const Duration(days: 1))))
        .toList();
  }
  return filtered;
}

void main() {
  final sightings = [
    MockSighting(
      speciesId: 1,
      observedAt: DateTime(2026, 1, 10),
      photoUrl: 'photo1.jpg',
    ),
    MockSighting(
      speciesId: 2,
      observedAt: DateTime(2026, 1, 15),
    ),
    MockSighting(
      speciesId: 1,
      observedAt: DateTime(2026, 2, 1),
      photoUrl: 'photo2.jpg',
    ),
    MockSighting(
      speciesId: 3,
      observedAt: DateTime(2026, 2, 10),
    ),
    MockSighting(
      speciesId: 2,
      observedAt: null, // no date
    ),
  ];

  group('filterSightings', () {
    test('returns all sightings when no filters applied', () {
      final result = filterSightings(sightings);
      expect(result.length, 5);
    });

    test('filters by species ID correctly', () {
      final result = filterSightings(sightings, speciesId: 1);
      expect(result.length, 2);
      expect(result.every((s) => s.speciesId == 1), isTrue);
    });

    test('filters by species ID with single match', () {
      final result = filterSightings(sightings, speciesId: 3);
      expect(result.length, 1);
      expect(result.first.speciesId, 3);
    });

    test('filters by date from (inclusive)', () {
      final result = filterSightings(
        sightings,
        dateFrom: DateTime(2026, 1, 15),
      );
      // Jan 15 (inclusive), Feb 1, Feb 10 = 3 results
      // The null-date sighting is excluded
      expect(result.length, 3);
      expect(
        result.every((s) =>
            s.observedAt != null &&
            !s.observedAt!.isBefore(DateTime(2026, 1, 15))),
        isTrue,
      );
    });

    test('filters by date from on exact date (inclusive)', () {
      final result = filterSightings(
        sightings,
        dateFrom: DateTime(2026, 1, 10),
      );
      // Jan 10 (inclusive), Jan 15, Feb 1, Feb 10 = 4 results
      expect(result.length, 4);
    });

    test('filters by date to (inclusive - end of day)', () {
      final result = filterSightings(
        sightings,
        dateTo: DateTime(2026, 1, 15),
      );
      // Jan 10 and Jan 15 (inclusive via add 1 day) = 2 results
      // The null-date sighting is excluded
      expect(result.length, 2);
      expect(
        result.every((s) =>
            s.observedAt != null &&
            s.observedAt!.isBefore(DateTime(2026, 1, 16))),
        isTrue,
      );
    });

    test('filters by date to on exact date (inclusive)', () {
      final result = filterSightings(
        sightings,
        dateTo: DateTime(2026, 1, 10),
      );
      // Only Jan 10 = 1 result
      expect(result.length, 1);
      expect(result.first.observedAt, DateTime(2026, 1, 10));
    });

    test('combines species + date filters', () {
      final result = filterSightings(
        sightings,
        speciesId: 1,
        dateFrom: DateTime(2026, 1, 15),
      );
      // Species 1 has Jan 10 and Feb 1. Only Feb 1 >= Jan 15
      expect(result.length, 1);
      expect(result.first.speciesId, 1);
      expect(result.first.observedAt, DateTime(2026, 2, 1));
    });

    test('combines species + date range filters', () {
      final result = filterSightings(
        sightings,
        speciesId: 2,
        dateFrom: DateTime(2026, 1, 1),
        dateTo: DateTime(2026, 1, 31),
      );
      // Species 2 has Jan 15 (in range) and null-date (excluded)
      expect(result.length, 1);
      expect(result.first.observedAt, DateTime(2026, 1, 15));
    });

    test('returns empty when no match on species', () {
      final result = filterSightings(sightings, speciesId: 999);
      expect(result, isEmpty);
    });

    test('returns empty when no match on date range', () {
      final result = filterSightings(
        sightings,
        dateFrom: DateTime(2030, 1, 1),
      );
      expect(result, isEmpty);
    });

    test('handles null observedAt gracefully - excluded from date filters', () {
      final nullDateSightings = [
        MockSighting(speciesId: 1, observedAt: null),
        MockSighting(speciesId: 2, observedAt: null),
        MockSighting(speciesId: 3, observedAt: DateTime(2026, 3, 1)),
      ];
      final result = filterSightings(
        nullDateSightings,
        dateFrom: DateTime(2026, 1, 1),
      );
      // Only the one with a date passes
      expect(result.length, 1);
      expect(result.first.speciesId, 3);
    });

    test('null observedAt included when no date filters', () {
      final nullDateSightings = [
        MockSighting(speciesId: 1, observedAt: null),
        MockSighting(speciesId: 2, observedAt: DateTime(2026, 3, 1)),
      ];
      final result = filterSightings(nullDateSightings);
      expect(result.length, 2);
    });

    test('handles empty list', () {
      final result = filterSightings(
        [],
        speciesId: 1,
        dateFrom: DateTime(2026, 1, 1),
        dateTo: DateTime(2026, 12, 31),
      );
      expect(result, isEmpty);
    });

    test('date from and date to same day returns that day', () {
      final result = filterSightings(
        sightings,
        dateFrom: DateTime(2026, 1, 15),
        dateTo: DateTime(2026, 1, 15),
      );
      // Only Jan 15 sighting
      expect(result.length, 1);
      expect(result.first.observedAt, DateTime(2026, 1, 15));
    });
  });
}
