import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';

/// Per-species checklist metadata (always captured, shown only to premium).
class ChecklistEntry {
  final DateTime? seenAt;
  final double? latitude;
  final double? longitude;
  ChecklistEntry({this.seenAt, this.latitude, this.longitude});

  Map<String, dynamic> toJson() => {
    'seenAt': seenAt?.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
  };

  factory ChecklistEntry.fromJson(Map<String, dynamic> json) => ChecklistEntry(
    seenAt: json['seenAt'] != null ? DateTime.tryParse(json['seenAt'] as String) : null,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );
}

const _localSeenKey = 'checklist_seen_ids';
const _localEntriesKey = 'checklist_entries';

/// Manages "seen" species IDs.
/// Works without login (local-only). Syncs to Supabase when logged in.
class ChecklistNotifier extends AsyncNotifier<Set<int>> {
  SupabaseClient get _db => Supabase.instance.client;

  final Map<int, ChecklistEntry> _entries = {};

  ChecklistEntry? entryFor(int speciesId) => _entries[speciesId];
  DateTime? seenAtFor(int speciesId) => _entries[speciesId]?.seenAt;

  // ── Local persistence ──

  Set<int> _readLocalIds() {
    final stored = Bootstrap.prefs.getString(_localSeenKey);
    if (stored == null || stored.isEmpty) return {};
    return stored.split(',').map((s) => int.tryParse(s)).whereType<int>().toSet();
  }

  void _readLocalEntries() {
    final stored = Bootstrap.prefs.getString(_localEntriesKey);
    if (stored == null || stored.isEmpty) return;
    try {
      final map = jsonDecode(stored) as Map<String, dynamic>;
      for (final e in map.entries) {
        final id = int.tryParse(e.key);
        if (id != null && e.value is Map<String, dynamic>) {
          _entries[id] = ChecklistEntry.fromJson(e.value as Map<String, dynamic>);
        }
      }
    } catch (_) {}
  }

  Future<void> _saveLocal(Set<int> ids) async {
    await Bootstrap.prefs.setString(_localSeenKey, ids.join(','));
    final entriesJson = <String, dynamic>{};
    for (final id in ids) {
      final entry = _entries[id];
      if (entry != null) entriesJson[id.toString()] = entry.toJson();
    }
    await Bootstrap.prefs.setString(_localEntriesKey, jsonEncode(entriesJson));
  }

  // ── Build ──

  @override
  Future<Set<int>> build() async {
    ref.watch(isAuthenticatedProvider);

    // Always start with local data (instant, works offline, works without login)
    final localIds = _readLocalIds();
    _readLocalEntries();

    final user = _db.auth.currentUser;
    if (user == null) return localIds;

    // Logged in — try to sync from server
    try {
      final data = await _db
          .from('user_species_checklist')
          .select('species_id, seen_at, latitude, longitude')
          .eq('user_id', user.id);
      final serverIds = <int>{};
      for (final row in data as List) {
        final id = row['species_id'] as int;
        serverIds.add(id);
        _entries[id] = ChecklistEntry(
          seenAt: row['seen_at'] != null ? DateTime.tryParse(row['seen_at'] as String) : null,
          latitude: (row['latitude'] as num?)?.toDouble(),
          longitude: (row['longitude'] as num?)?.toDouble(),
        );
      }

      // Merge: local items not on server → push to server
      final localOnly = localIds.difference(serverIds);
      for (final id in localOnly) {
        serverIds.add(id);
        final entry = _entries[id] ?? ChecklistEntry(seenAt: DateTime.now());
        _entries[id] = entry;
        try {
          await _db.from('user_species_checklist').upsert({
            'user_id': user.id,
            'species_id': id,
            'seen_at': (entry.seenAt ?? DateTime.now()).toUtc().toIso8601String(),
            if (entry.latitude != null) 'latitude': entry.latitude,
            if (entry.longitude != null) 'longitude': entry.longitude,
          });
        } catch (_) {}
      }

      await _saveLocal(serverIds);
      return serverIds;
    } catch (_) {
      return localIds;
    }
  }

  // ── Toggle ──

  Future<void> toggle(int speciesId) async {
    final current = state.asData?.value ?? {};
    final isSeen = current.contains(speciesId);

    final updated = Set<int>.from(current);
    final now = DateTime.now();
    if (isSeen) {
      updated.remove(speciesId);
      _entries.remove(speciesId);
    } else {
      updated.add(speciesId);
      _entries[speciesId] = ChecklistEntry(seenAt: now);
    }
    state = AsyncData(updated);
    await _saveLocal(updated);

    // Capture GPS silently (best-effort)
    if (!isSeen) {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
        _entries[speciesId] = ChecklistEntry(
          seenAt: now, latitude: pos.latitude, longitude: pos.longitude,
        );
        await _saveLocal(updated);
      } catch (_) {}
    }

    // Sync to Supabase if logged in
    final user = _db.auth.currentUser;
    if (user == null) return;

    try {
      if (isSeen) {
        await _db
            .from('user_species_checklist')
            .delete()
            .eq('user_id', user.id)
            .eq('species_id', speciesId);
      } else {
        final entry = _entries[speciesId]!;
        await _db.from('user_species_checklist').upsert({
          'user_id': user.id,
          'species_id': speciesId,
          'seen_at': (entry.seenAt ?? now).toUtc().toIso8601String(),
          if (entry.latitude != null) 'latitude': entry.latitude,
          if (entry.longitude != null) 'longitude': entry.longitude,
        });
      }
    } catch (e) {
      // Supabase sync failed — data is still saved locally
      AppLogger.warning('Checklist sync failed (offline?)', e);
    }
  }

  /// Marks a species as seen without toggling. No-op if already seen.
  Future<void> markAsSeen(int speciesId) async {
    final current = state.asData?.value ?? {};
    if (current.contains(speciesId)) return;
    await toggle(speciesId);
  }
}

final userChecklistProvider =
    AsyncNotifierProvider<ChecklistNotifier, Set<int>>(ChecklistNotifier.new);

final isSpeciesSeenProvider = Provider.family<bool, int>((ref, speciesId) {
  return ref.watch(userChecklistProvider).asData?.value.contains(speciesId) ?? false;
});

final speciesSeenCountProvider = Provider<int>((ref) {
  return ref.watch(userChecklistProvider).asData?.value.length ?? 0;
});

Future<void> toggleSpeciesSeen(WidgetRef ref, int speciesId) async {
  await ref.read(userChecklistProvider.notifier).toggle(speciesId);
}
