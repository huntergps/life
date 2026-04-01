import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';

/// Per-species checklist metadata (always captured, shown only to premium).
class ChecklistEntry {
  final DateTime? seenAt;
  final double? latitude;
  final double? longitude;
  ChecklistEntry({this.seenAt, this.latitude, this.longitude});
}

/// Manages "seen" species IDs with optimistic updates.
/// Always captures date+time+GPS. Premium users see the details.
class ChecklistNotifier extends AsyncNotifier<Set<int>> {
  SupabaseClient get _db => Supabase.instance.client;

  /// Cache of species_id → full entry (date, GPS).
  final Map<int, ChecklistEntry> _entries = {};

  /// Returns the entry for a given species, or null.
  ChecklistEntry? entryFor(int speciesId) => _entries[speciesId];

  /// Legacy convenience — returns seen_at timestamp.
  DateTime? seenAtFor(int speciesId) => _entries[speciesId]?.seenAt;

  @override
  Future<Set<int>> build() async {
    ref.watch(isAuthenticatedProvider);
    final user = _db.auth.currentUser;
    if (user == null) return {};
    try {
      final data = await _db
          .from('user_species_checklist')
          .select('species_id, seen_at, latitude, longitude')
          .eq('user_id', user.id);
      final ids = <int>{};
      _entries.clear();
      for (final row in data as List) {
        final id = row['species_id'] as int;
        ids.add(id);
        _entries[id] = ChecklistEntry(
          seenAt: row['seen_at'] != null ? DateTime.tryParse(row['seen_at'] as String) : null,
          latitude: (row['latitude'] as num?)?.toDouble(),
          longitude: (row['longitude'] as num?)?.toDouble(),
        );
      }
      return ids;
    } catch (_) {
      return {};
    }
  }

  Future<void> toggle(int speciesId) async {
    final user = _db.auth.currentUser;
    if (user == null) return;

    final current = state.asData?.value ?? {};
    final isSeen = current.contains(speciesId);

    // Optimistic update — instant UI response
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

    try {
      if (isSeen) {
        await _db
            .from('user_species_checklist')
            .delete()
            .eq('user_id', user.id)
            .eq('species_id', speciesId);
      } else {
        // Capture GPS silently (best-effort, don't block on failure)
        double? lat, lng;
        try {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 5),
            ),
          );
          lat = pos.latitude;
          lng = pos.longitude;
          _entries[speciesId] = ChecklistEntry(seenAt: now, latitude: lat, longitude: lng);
        } catch (_) {
          // GPS unavailable — save without coordinates
        }
        await _db.from('user_species_checklist').upsert({
          'user_id': user.id,
          'species_id': speciesId,
          'seen_at': now.toUtc().toIso8601String(),
          if (lat != null) 'latitude': lat,
          if (lng != null) 'longitude': lng,
        });
      }
    } catch (e) {
      // Revert on failure
      state = AsyncData(current);
      if (isSeen) {
        _entries[speciesId] = ChecklistEntry(); // was there, restore placeholder
      } else {
        _entries.remove(speciesId);
      }
      AppLogger.error('toggleSpeciesSeen failed', e);
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

/// Returns true if the given species has been marked as seen.
final isSpeciesSeenProvider = Provider.family<bool, int>((ref, speciesId) {
  return ref.watch(userChecklistProvider).asData?.value.contains(speciesId) ?? false;
});

/// Count of species the current user has marked as seen.
final speciesSeenCountProvider = Provider<int>((ref) {
  return ref.watch(userChecklistProvider).asData?.value.length ?? 0;
});

/// Convenience wrapper — call from any WidgetRef context.
Future<void> toggleSpeciesSeen(WidgetRef ref, int speciesId) async {
  await ref.read(userChecklistProvider.notifier).toggle(speciesId);
}
