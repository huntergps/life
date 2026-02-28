import 'package:flutter_test/flutter_test.dart';

/// Test the deduplication logic used in brick_helpers.dart.
/// We extract the pure algorithm to test without Brick/Repository dependencies.

/// Pure deduplication function — mirrors the logic in fetchDeduped().
List<T> deduplicateById<T>(List<T> raw, int Function(T) idSelector) {
  final deduped = <int, T>{};
  for (final item in raw) {
    deduped[idSelector(item)] = item;
  }
  return deduped.values.toList();
}

/// Pure lookup builder — mirrors the logic in fetchLookup().
Map<int, T> buildLookup<T>(List<T> raw, int Function(T) idSelector) {
  final map = <int, T>{};
  for (final item in raw) {
    map[idSelector(item)] = item;
  }
  return map;
}

class FakeItem {
  final int id;
  final String name;
  FakeItem(this.id, this.name);
}

void main() {
  group('deduplicateById', () {
    test('returns empty list for empty input', () {
      final result = deduplicateById<FakeItem>([], (item) => item.id);
      expect(result, isEmpty);
    });

    test('returns all items when no duplicates', () {
      final items = [FakeItem(1, 'a'), FakeItem(2, 'b'), FakeItem(3, 'c')];
      final result = deduplicateById(items, (item) => item.id);
      expect(result.length, 3);
    });

    test('keeps last occurrence for duplicate ids', () {
      final items = [
        FakeItem(1, 'old'),
        FakeItem(2, 'b'),
        FakeItem(1, 'new'), // duplicate id=1, should win
      ];
      final result = deduplicateById(items, (item) => item.id);
      expect(result.length, 2);
      final item1 = result.firstWhere((r) => r.id == 1);
      expect(item1.name, 'new'); // last occurrence wins
    });

    test('handles many duplicates', () {
      final items = [
        FakeItem(1, 'v1'),
        FakeItem(1, 'v2'),
        FakeItem(1, 'v3'),
        FakeItem(2, 'only'),
      ];
      final result = deduplicateById(items, (item) => item.id);
      expect(result.length, 2);
      expect(result.firstWhere((r) => r.id == 1).name, 'v3');
    });

    test('preserves order of unique ids', () {
      final items = [FakeItem(3, 'c'), FakeItem(1, 'a'), FakeItem(2, 'b')];
      final result = deduplicateById(items, (item) => item.id);
      expect(result.map((r) => r.id).toList(), [3, 1, 2]);
    });
  });

  group('buildLookup', () {
    test('returns empty map for empty input', () {
      final result = buildLookup<FakeItem>([], (item) => item.id);
      expect(result, isEmpty);
    });

    test('builds correct lookup map', () {
      final items = [FakeItem(1, 'a'), FakeItem(2, 'b'), FakeItem(3, 'c')];
      final result = buildLookup(items, (item) => item.id);
      expect(result.length, 3);
      expect(result[1]?.name, 'a');
      expect(result[2]?.name, 'b');
      expect(result[3]?.name, 'c');
    });

    test('last occurrence wins in lookup', () {
      final items = [FakeItem(1, 'old'), FakeItem(1, 'new')];
      final result = buildLookup(items, (item) => item.id);
      expect(result.length, 1);
      expect(result[1]?.name, 'new');
    });

    test('returns null for missing keys', () {
      final items = [FakeItem(1, 'a')];
      final result = buildLookup(items, (item) => item.id);
      expect(result[99], isNull);
    });
  });
}
