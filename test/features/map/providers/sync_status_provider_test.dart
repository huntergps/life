import 'package:flutter_test/flutter_test.dart';
import 'package:galapagos_wildlife/features/map/providers/sync_status_provider.dart';

void main() {
  // =========================================================================
  // SyncStatus model — pure value-object logic, no I/O
  // =========================================================================
  group('SyncStatus', () {
    test('default constructor has no pending changes', () {
      const status = SyncStatus();
      expect(status.pendingChanges, isEmpty);
      expect(status.pendingCount, 0);
      expect(status.hasPendingChanges, isFalse);
      expect(status.isSyncing, isFalse);
      expect(status.lastSyncTime, isNull);
      expect(status.lastError, isNull);
    });

    test('hasPendingChanges is true when list is non-empty', () {
      final change = PendingChange(
        id: 'abc',
        type: 'site',
        action: 'update',
        name: 'Test Site',
        timestamp: DateTime(2026, 1, 1),
      );
      final status = SyncStatus(pendingChanges: [change]);
      expect(status.hasPendingChanges, isTrue);
      expect(status.pendingCount, 1);
    });

    test('pendingCount reflects list length', () {
      final changes = List.generate(
        3,
        (i) => PendingChange(
          id: 'id_$i',
          type: 'trail',
          action: 'create',
          name: 'Trail $i',
          timestamp: DateTime(2026, 1, i + 1),
        ),
      );
      final status = SyncStatus(pendingChanges: changes);
      expect(status.pendingCount, 3);
    });

    test('copyWith pendingChanges replaces the list', () {
      const original = SyncStatus();
      final change = PendingChange(
        id: '1',
        type: 'site',
        action: 'delete',
        name: 'Old Site',
        timestamp: DateTime(2026, 2, 1),
      );
      final updated = original.copyWith(pendingChanges: [change]);
      expect(updated.pendingCount, 1);
      expect(original.pendingCount, 0); // original unchanged
    });

    test('copyWith isSyncing updates syncing flag', () {
      const status = SyncStatus();
      final syncing = status.copyWith(isSyncing: true);
      expect(syncing.isSyncing, isTrue);
      expect(status.isSyncing, isFalse); // original unchanged
    });

    test('copyWith preserves unmodified fields', () {
      final time = DateTime(2026, 3, 1);
      final status = SyncStatus(lastSyncTime: time, lastError: 'oops');
      final updated = status.copyWith(isSyncing: true);
      expect(updated.lastSyncTime, time);
      expect(updated.lastError, 'oops');
      expect(updated.isSyncing, isTrue);
    });

    test('copyWith lastError updates error field', () {
      const status = SyncStatus();
      final withError = status.copyWith(lastError: 'network failure');
      expect(withError.lastError, 'network failure');
    });
  });

  // =========================================================================
  // PendingChange model — serialization round-trip
  // =========================================================================
  group('PendingChange', () {
    test('toJson and fromJson round-trip preserves all fields', () {
      final original = PendingChange(
        id: 'site-42',
        type: 'site',
        action: 'update',
        name: 'Darwin Bay',
        timestamp: DateTime(2026, 2, 15, 10, 30),
      );

      final json = original.toJson();
      final restored = PendingChange.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.action, original.action);
      expect(restored.name, original.name);
      expect(restored.timestamp.toIso8601String(),
          original.timestamp.toIso8601String());
    });

    test('toJson contains expected keys', () {
      final change = PendingChange(
        id: 'trail-7',
        type: 'trail',
        action: 'create',
        name: 'Tortuga Bay Trail',
        timestamp: DateTime(2026, 1, 10),
      );
      final json = change.toJson();

      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('type'), isTrue);
      expect(json.containsKey('action'), isTrue);
      expect(json.containsKey('name'), isTrue);
      expect(json.containsKey('timestamp'), isTrue);
    });

    test('fromJson parses timestamp from ISO8601 string', () {
      final map = {
        'id': 'x',
        'type': 'trail',
        'action': 'delete',
        'name': 'Short Trail',
        'timestamp': '2026-03-01T08:00:00.000',
      };
      final change = PendingChange.fromJson(map);
      expect(change.timestamp.year, 2026);
      expect(change.timestamp.month, 3);
      expect(change.timestamp.day, 1);
    });
  });

  // =========================================================================
  // SyncStatus — simulating notifier state transitions in pure logic
  // =========================================================================
  group('SyncStatus state transitions (pure logic)', () {
    test('adding a change via copyWith increases pendingCount', () {
      SyncStatus state = const SyncStatus();

      final change = PendingChange(
        id: 'new-1',
        type: 'site',
        action: 'create',
        name: 'New Site',
        timestamp: DateTime.now(),
      );

      state = state.copyWith(pendingChanges: [...state.pendingChanges, change]);
      expect(state.pendingCount, 1);
      expect(state.hasPendingChanges, isTrue);
    });

    test('removing a change by id reduces pendingCount', () {
      final changes = [
        PendingChange(
          id: 'a',
          type: 'trail',
          action: 'update',
          name: 'Alpha Trail',
          timestamp: DateTime.now(),
        ),
        PendingChange(
          id: 'b',
          type: 'site',
          action: 'update',
          name: 'Beta Site',
          timestamp: DateTime.now(),
        ),
      ];
      SyncStatus state = SyncStatus(pendingChanges: changes);
      expect(state.pendingCount, 2);

      final filtered = state.pendingChanges.where((c) => c.id != 'a').toList();
      state = state.copyWith(pendingChanges: filtered);
      expect(state.pendingCount, 1);
      expect(state.pendingChanges.first.id, 'b');
    });

    test('clearing all changes results in empty list', () {
      final changes = [
        PendingChange(
          id: 'c1',
          type: 'site',
          action: 'delete',
          name: 'Site C',
          timestamp: DateTime.now(),
        ),
      ];
      SyncStatus state = SyncStatus(pendingChanges: changes);
      state = state.copyWith(pendingChanges: []);
      expect(state.pendingCount, 0);
      expect(state.hasPendingChanges, isFalse);
    });

    test('startSyncing sets isSyncing to true', () {
      SyncStatus state = const SyncStatus();
      // Mirror what SyncStatusNotifier.startSyncing() does
      state = state.copyWith(isSyncing: true);
      expect(state.isSyncing, isTrue);
    });

    test('copyWith with null lastError keeps existing error (copyWith ?? behaviour)', () {
      // NOTE: copyWith uses `lastError ?? this.lastError`, so passing null
      // cannot clear an existing error. This is the actual behaviour.
      SyncStatus state = const SyncStatus(lastError: 'previous error');
      final updated = state.copyWith(isSyncing: true, lastError: null);
      // lastError is unchanged because null ?? 'previous error' = 'previous error'
      expect(updated.lastError, 'previous error');
      expect(updated.isSyncing, isTrue);
    });

    test('completeSyncError sets isSyncing false and records error', () {
      SyncStatus state = const SyncStatus(isSyncing: true);
      state = state.copyWith(isSyncing: false, lastError: 'timeout');
      expect(state.isSyncing, isFalse);
      expect(state.lastError, 'timeout');
    });
  });
}
