import 'package:flutter_test/flutter_test.dart';

/// Test badge stats computation logic extracted from badges_provider.dart.
/// Pure functions tested without Riverpod/Brick dependencies.

class MockBadgeSighting {
  final int speciesId;
  final int? visitSiteId;
  final String? photoUrl;

  MockBadgeSighting({
    required this.speciesId,
    this.visitSiteId,
    this.photoUrl,
  });
}

class MockSpeciesInfo {
  final bool isEndemic;
  final String? conservationStatus;

  MockSpeciesInfo({this.isEndemic = false, this.conservationStatus});
}

/// Mirrors the _computeStats logic in badges_provider.dart.
/// Takes sightings and a species lookup map (speciesId -> species info).
Map<String, int> computeStats(
  List<MockBadgeSighting> sightings,
  Map<int, MockSpeciesInfo> speciesMap,
) {
  final uniqueSpeciesIds = <int>{};
  final endemicIds = <int>{};
  final islandSiteIds = <int>{};
  final threatenedIds = <int>{};
  int photos = 0;

  for (final s in sightings) {
    uniqueSpeciesIds.add(s.speciesId);

    if (s.photoUrl != null) photos++;
    if (s.visitSiteId != null) islandSiteIds.add(s.visitSiteId!);

    final species = speciesMap[s.speciesId];
    if (species != null) {
      if (species.isEndemic) endemicIds.add(s.speciesId);
      final status = species.conservationStatus;
      if (status == 'CR' || status == 'EN' || status == 'VU') {
        threatenedIds.add(s.speciesId);
      }
    }
  }

  return {
    'totalSightings': sightings.length,
    'uniqueSpecies': uniqueSpeciesIds.length,
    'endemicSpecies': endemicIds.length,
    'uniqueIslands': islandSiteIds.length,
    'photosCount': photos,
    'threatenedSpecies': threatenedIds.length,
  };
}

void main() {
  group('computeStats', () {
    test('empty sightings returns all zeros', () {
      final stats = computeStats([], {});
      expect(stats['totalSightings'], 0);
      expect(stats['uniqueSpecies'], 0);
      expect(stats['endemicSpecies'], 0);
      expect(stats['uniqueIslands'], 0);
      expect(stats['photosCount'], 0);
      expect(stats['threatenedSpecies'], 0);
    });

    test('counts total sightings correctly', () {
      final sightings = [
        MockBadgeSighting(speciesId: 1),
        MockBadgeSighting(speciesId: 1),
        MockBadgeSighting(speciesId: 2),
      ];
      final stats = computeStats(sightings, {});
      expect(stats['totalSightings'], 3);
    });

    test('counts unique species (deduplicates)', () {
      final sightings = [
        MockBadgeSighting(speciesId: 1),
        MockBadgeSighting(speciesId: 1),
        MockBadgeSighting(speciesId: 1),
        MockBadgeSighting(speciesId: 2),
        MockBadgeSighting(speciesId: 3),
      ];
      final stats = computeStats(sightings, {});
      expect(stats['totalSightings'], 5);
      expect(stats['uniqueSpecies'], 3);
    });

    test('counts endemic species (deduplicates)', () {
      final speciesMap = {
        1: MockSpeciesInfo(isEndemic: true),
        2: MockSpeciesInfo(isEndemic: false),
        3: MockSpeciesInfo(isEndemic: true),
      };
      final sightings = [
        MockBadgeSighting(speciesId: 1),
        MockBadgeSighting(speciesId: 1), // duplicate endemic
        MockBadgeSighting(speciesId: 2),
        MockBadgeSighting(speciesId: 3),
      ];
      final stats = computeStats(sightings, speciesMap);
      expect(stats['endemicSpecies'], 2); // species 1 and 3
    });

    test('counts unique islands (via visit site IDs)', () {
      final sightings = [
        MockBadgeSighting(speciesId: 1, visitSiteId: 10),
        MockBadgeSighting(speciesId: 2, visitSiteId: 10), // same site
        MockBadgeSighting(speciesId: 3, visitSiteId: 20),
        MockBadgeSighting(speciesId: 4, visitSiteId: 30),
        MockBadgeSighting(speciesId: 5), // null visit site
      ];
      final stats = computeStats(sightings, {});
      expect(stats['uniqueIslands'], 3); // sites 10, 20, 30
    });

    test('counts photos', () {
      final sightings = [
        MockBadgeSighting(speciesId: 1, photoUrl: 'photo1.jpg'),
        MockBadgeSighting(speciesId: 2), // no photo
        MockBadgeSighting(speciesId: 3, photoUrl: 'photo3.jpg'),
        MockBadgeSighting(speciesId: 1, photoUrl: 'photo4.jpg'),
      ];
      final stats = computeStats(sightings, {});
      expect(stats['photosCount'], 3);
    });

    test('photos count is not deduplicated by species', () {
      final sightings = [
        MockBadgeSighting(speciesId: 1, photoUrl: 'a.jpg'),
        MockBadgeSighting(speciesId: 1, photoUrl: 'b.jpg'),
        MockBadgeSighting(speciesId: 1, photoUrl: 'c.jpg'),
      ];
      final stats = computeStats(sightings, {});
      expect(stats['photosCount'], 3);
      expect(stats['uniqueSpecies'], 1);
    });

    test('counts threatened species - CR only', () {
      final speciesMap = {
        1: MockSpeciesInfo(conservationStatus: 'CR'),
        2: MockSpeciesInfo(conservationStatus: 'LC'),
      };
      final sightings = [
        MockBadgeSighting(speciesId: 1),
        MockBadgeSighting(speciesId: 2),
      ];
      final stats = computeStats(sightings, speciesMap);
      expect(stats['threatenedSpecies'], 1);
    });

    test('counts threatened species - EN only', () {
      final speciesMap = {
        1: MockSpeciesInfo(conservationStatus: 'EN'),
      };
      final sightings = [MockBadgeSighting(speciesId: 1)];
      final stats = computeStats(sightings, speciesMap);
      expect(stats['threatenedSpecies'], 1);
    });

    test('counts threatened species - VU only', () {
      final speciesMap = {
        1: MockSpeciesInfo(conservationStatus: 'VU'),
      };
      final sightings = [MockBadgeSighting(speciesId: 1)];
      final stats = computeStats(sightings, speciesMap);
      expect(stats['threatenedSpecies'], 1);
    });

    test('does not count non-threatened statuses', () {
      final speciesMap = {
        1: MockSpeciesInfo(conservationStatus: 'LC'),
        2: MockSpeciesInfo(conservationStatus: 'NT'),
        3: MockSpeciesInfo(conservationStatus: 'DD'),
        4: MockSpeciesInfo(conservationStatus: null),
      };
      final sightings = [
        MockBadgeSighting(speciesId: 1),
        MockBadgeSighting(speciesId: 2),
        MockBadgeSighting(speciesId: 3),
        MockBadgeSighting(speciesId: 4),
      ];
      final stats = computeStats(sightings, speciesMap);
      expect(stats['threatenedSpecies'], 0);
    });

    test('threatened species are deduplicated', () {
      final speciesMap = {
        1: MockSpeciesInfo(conservationStatus: 'CR'),
      };
      final sightings = [
        MockBadgeSighting(speciesId: 1),
        MockBadgeSighting(speciesId: 1),
        MockBadgeSighting(speciesId: 1),
      ];
      final stats = computeStats(sightings, speciesMap);
      expect(stats['threatenedSpecies'], 1);
    });

    test('species not in map are ignored for endemic/threatened', () {
      final speciesMap = <int, MockSpeciesInfo>{}; // empty map
      final sightings = [
        MockBadgeSighting(speciesId: 1),
        MockBadgeSighting(speciesId: 2),
      ];
      final stats = computeStats(sightings, speciesMap);
      expect(stats['totalSightings'], 2);
      expect(stats['uniqueSpecies'], 2);
      expect(stats['endemicSpecies'], 0);
      expect(stats['threatenedSpecies'], 0);
    });

    test('mixed data scenario with all metrics', () {
      final speciesMap = {
        1: MockSpeciesInfo(isEndemic: true, conservationStatus: 'EN'),
        2: MockSpeciesInfo(isEndemic: false, conservationStatus: 'LC'),
        3: MockSpeciesInfo(isEndemic: true, conservationStatus: 'VU'),
        4: MockSpeciesInfo(isEndemic: false, conservationStatus: 'CR'),
        5: MockSpeciesInfo(isEndemic: true, conservationStatus: 'LC'),
      };
      final sightings = [
        // Species 1: endemic + EN (threatened)
        MockBadgeSighting(
            speciesId: 1, visitSiteId: 100, photoUrl: 'photo1.jpg'),
        MockBadgeSighting(speciesId: 1, visitSiteId: 100), // dup species+site
        // Species 2: not endemic, LC
        MockBadgeSighting(
            speciesId: 2, visitSiteId: 200, photoUrl: 'photo2.jpg'),
        // Species 3: endemic + VU (threatened)
        MockBadgeSighting(speciesId: 3, visitSiteId: 300),
        // Species 4: not endemic + CR (threatened)
        MockBadgeSighting(
            speciesId: 4, visitSiteId: 200, photoUrl: 'photo4.jpg'),
        // Species 5: endemic, LC
        MockBadgeSighting(speciesId: 5), // no site, no photo
      ];

      final stats = computeStats(sightings, speciesMap);

      expect(stats['totalSightings'], 6);
      expect(stats['uniqueSpecies'], 5); // 1, 2, 3, 4, 5
      expect(stats['endemicSpecies'], 3); // 1, 3, 5
      expect(stats['uniqueIslands'], 3); // 100, 200, 300
      expect(stats['photosCount'], 3); // photo1, photo2, photo4
      expect(stats['threatenedSpecies'], 3); // 1(EN), 3(VU), 4(CR)
    });

    test('single sighting with all attributes', () {
      final speciesMap = {
        42: MockSpeciesInfo(isEndemic: true, conservationStatus: 'CR'),
      };
      final sightings = [
        MockBadgeSighting(
            speciesId: 42, visitSiteId: 7, photoUrl: 'rare.jpg'),
      ];
      final stats = computeStats(sightings, speciesMap);

      expect(stats['totalSightings'], 1);
      expect(stats['uniqueSpecies'], 1);
      expect(stats['endemicSpecies'], 1);
      expect(stats['uniqueIslands'], 1);
      expect(stats['photosCount'], 1);
      expect(stats['threatenedSpecies'], 1);
    });
  });
}
