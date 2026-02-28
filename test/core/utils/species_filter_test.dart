import 'package:flutter_test/flutter_test.dart';

/// Test species filtering logic extracted from speciesListProvider.
/// Pure functions tested without Riverpod/Brick dependencies.

class FakeSpecies {
  final int id;
  final String commonNameEn;
  final String commonNameEs;
  final String scientificName;
  final int categoryId;
  final String? conservationStatus;
  final bool isEndemic;

  FakeSpecies({
    required this.id,
    required this.commonNameEn,
    required this.commonNameEs,
    required this.scientificName,
    required this.categoryId,
    this.conservationStatus,
    this.isEndemic = false,
  });
}

/// Mirrors the filter logic in speciesListProvider.
List<FakeSpecies> filterSpecies({
  required List<FakeSpecies> all,
  int? categoryId,
  String? conservationFilter,
  bool? endemicFilter,
  String searchQuery = '',
}) {
  var filtered = categoryId != null
      ? all.where((s) => s.categoryId == categoryId).toList()
      : List<FakeSpecies>.from(all);

  if (conservationFilter != null) {
    filtered = filtered.where((s) => s.conservationStatus == conservationFilter).toList();
  }

  if (endemicFilter == true) {
    filtered = filtered.where((s) => s.isEndemic).toList();
  }

  if (searchQuery.isEmpty) return filtered;

  final query = searchQuery.toLowerCase();
  return filtered
      .where((s) =>
          s.commonNameEn.toLowerCase().contains(query) ||
          s.commonNameEs.toLowerCase().contains(query) ||
          s.scientificName.toLowerCase().contains(query))
      .toList();
}

void main() {
  final species = [
    FakeSpecies(id: 1, commonNameEn: 'Blue-footed Booby', commonNameEs: 'Piquero patas azules', scientificName: 'Sula nebouxii', categoryId: 1, conservationStatus: 'LC', isEndemic: false),
    FakeSpecies(id: 2, commonNameEn: 'Marine Iguana', commonNameEs: 'Iguana marina', scientificName: 'Amblyrhynchus cristatus', categoryId: 2, conservationStatus: 'VU', isEndemic: true),
    FakeSpecies(id: 3, commonNameEn: 'Galápagos Penguin', commonNameEs: 'Pingüino de Galápagos', scientificName: 'Spheniscus mendiculus', categoryId: 1, conservationStatus: 'EN', isEndemic: true),
    FakeSpecies(id: 4, commonNameEn: 'Giant Tortoise', commonNameEs: 'Tortuga gigante', scientificName: 'Chelonoidis niger', categoryId: 2, conservationStatus: 'VU', isEndemic: true),
    FakeSpecies(id: 5, commonNameEn: 'Frigatebird', commonNameEs: 'Fragata', scientificName: 'Fregata magnificens', categoryId: 1, conservationStatus: 'LC', isEndemic: false),
  ];

  group('filterSpecies', () {
    test('returns all species with no filters', () {
      final result = filterSpecies(all: species);
      expect(result.length, 5);
    });

    test('filters by category', () {
      final result = filterSpecies(all: species, categoryId: 1);
      expect(result.length, 3);
      expect(result.every((s) => s.categoryId == 1), isTrue);
    });

    test('filters by conservation status', () {
      final result = filterSpecies(all: species, conservationFilter: 'VU');
      expect(result.length, 2);
      expect(result.every((s) => s.conservationStatus == 'VU'), isTrue);
    });

    test('filters by endemic', () {
      final result = filterSpecies(all: species, endemicFilter: true);
      expect(result.length, 3);
      expect(result.every((s) => s.isEndemic), isTrue);
    });

    test('combines category + conservation filters', () {
      final result = filterSpecies(all: species, categoryId: 2, conservationFilter: 'VU');
      expect(result.length, 2); // Marine Iguana + Giant Tortoise
    });

    test('combines category + endemic filters', () {
      final result = filterSpecies(all: species, categoryId: 1, endemicFilter: true);
      expect(result.length, 1); // Only Galápagos Penguin
      expect(result.first.commonNameEn, 'Galápagos Penguin');
    });

    test('combines all filters', () {
      final result = filterSpecies(
        all: species,
        categoryId: 2,
        conservationFilter: 'VU',
        endemicFilter: true,
      );
      expect(result.length, 2); // Marine Iguana + Giant Tortoise (both VU, endemic, cat 2)
    });

    test('search filters by English name', () {
      final result = filterSpecies(all: species, searchQuery: 'booby');
      expect(result.length, 1);
      expect(result.first.id, 1);
    });

    test('search filters by Spanish name', () {
      final result = filterSpecies(all: species, searchQuery: 'tortuga');
      expect(result.length, 1);
      expect(result.first.id, 4);
    });

    test('search filters by scientific name', () {
      final result = filterSpecies(all: species, searchQuery: 'amblyrhynchus');
      expect(result.length, 1);
      expect(result.first.id, 2);
    });

    test('search is case insensitive', () {
      final result = filterSpecies(all: species, searchQuery: 'PENGUIN');
      expect(result.length, 1);
      expect(result.first.id, 3);
    });

    test('search + category combined', () {
      final result = filterSpecies(all: species, categoryId: 1, searchQuery: 'piq');
      expect(result.length, 1);
      expect(result.first.id, 1);
    });

    test('returns empty when no match', () {
      final result = filterSpecies(all: species, conservationFilter: 'CR');
      expect(result, isEmpty);
    });

    test('endemic null does not filter', () {
      final result = filterSpecies(all: species, endemicFilter: null);
      expect(result.length, 5);
    });

    test('endemic false does not filter', () {
      final result = filterSpecies(all: species, endemicFilter: false);
      expect(result.length, 5);
    });
  });
}
