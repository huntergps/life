import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';

/// Default 10 species every tourist can see.
const kDefaultSpeciesIds = <int>[
  12, // Galapagos Sea Lion
  1, // Marine Iguana
  41, // Sally Lightfoot Crab
  5, // Blue-footed Booby
  3, // Santa Cruz Giant Tortoise
  7, // Magnificent Frigatebird
  14, // Green Sea Turtle
  8, // Galapagos Penguin
  11, // Medium Ground Finch
  21, // American Flamingo
];

const _cacheKey = 'checklist_species_ids';

/// The user's custom checklist species IDs, ordered.
/// Persisted locally (SharedPreferences) + remotely (Supabase).
/// Returns defaults if user hasn't customized.
class ChecklistSpeciesNotifier extends AsyncNotifier<List<int>> {
  SupabaseClient get _db => Supabase.instance.client;

  /// Read from local cache first (instant, works offline).
  List<int> _readLocalCache() {
    final stored = Bootstrap.prefs.getString(_cacheKey);
    if (stored == null || stored.isEmpty) return List.from(kDefaultSpeciesIds);
    return stored.split(',').map((s) => int.tryParse(s)).whereType<int>().toList();
  }

  /// Save to local cache.
  Future<void> _saveLocalCache(List<int> ids) async {
    await Bootstrap.prefs.setString(_cacheKey, ids.join(','));
  }

  @override
  Future<List<int>> build() async {
    ref.watch(isAuthenticatedProvider);
    final user = _db.auth.currentUser;

    // Always start with local cache (instant, works offline)
    final localIds = _readLocalCache();

    if (user == null) return localIds;

    // Try to sync from server
    try {
      final data = await _db
          .from('user_checklist_species')
          .select('species_id, sort_order')
          .eq('user_id', user.id)
          .order('sort_order');

      if ((data as List).isEmpty) {
        // First time: seed server with local/defaults
        await _seedDefaults(user.id, localIds);
        return localIds;
      }

      final serverIds = data.map<int>((r) => r['species_id'] as int).toList();
      await _saveLocalCache(serverIds);
      return serverIds;
    } catch (_) {
      // Offline — use local cache
      return localIds;
    }
  }

  Future<void> _seedDefaults(String userId, List<int> ids) async {
    final rows = ids.asMap().entries.map((e) => {
      'user_id': userId,
      'species_id': e.value,
      'sort_order': e.key,
    }).toList();
    try {
      await _db.from('user_checklist_species').upsert(rows);
    } catch (_) {}
  }

  /// Add a species to the checklist at the end.
  Future<void> addSpecies(int speciesId) async {
    final current = state.asData?.value ?? [];
    if (current.contains(speciesId)) return;

    final updated = [...current, speciesId];
    state = AsyncData(updated);
    await _saveLocalCache(updated);

    final user = _db.auth.currentUser;
    if (user == null) return;
    try {
      await _db.from('user_checklist_species').upsert({
        'user_id': user.id,
        'species_id': speciesId,
        'sort_order': current.length,
      });
    } catch (e) {
      state = AsyncData(current);
      await _saveLocalCache(current);
    }
  }

  /// Remove a species from the checklist.
  Future<void> removeSpecies(int speciesId) async {
    final current = state.asData?.value ?? [];
    if (!current.contains(speciesId)) return;

    final updated = current.where((id) => id != speciesId).toList();
    state = AsyncData(updated);
    await _saveLocalCache(updated);

    final user = _db.auth.currentUser;
    if (user == null) return;
    try {
      await _db
          .from('user_checklist_species')
          .delete()
          .eq('user_id', user.id)
          .eq('species_id', speciesId);
    } catch (e) {
      state = AsyncData(current);
      await _saveLocalCache(current);
    }
  }

  /// Reorder the checklist. Called after drag-and-drop.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = List<int>.from(state.asData?.value ?? []);
    if (newIndex > oldIndex) newIndex--;
    final item = current.removeAt(oldIndex);
    current.insert(newIndex, item);

    state = AsyncData(current);
    await _saveLocalCache(current);

    final user = _db.auth.currentUser;
    if (user == null) return;
    try {
      final rows = current.asMap().entries.map((e) => {
        'user_id': user.id,
        'species_id': e.value,
        'sort_order': e.key,
      }).toList();
      await _db.from('user_checklist_species').upsert(rows);
    } catch (_) {}
  }

  /// Reset the checklist to the default 10 species.
  Future<void> resetToDefaults() async {
    final defaults = List<int>.from(kDefaultSpeciesIds);
    state = AsyncData(defaults);
    await _saveLocalCache(defaults);

    final user = _db.auth.currentUser;
    if (user == null) return;
    try {
      await _db
          .from('user_checklist_species')
          .delete()
          .eq('user_id', user.id);
      await _seedDefaults(user.id, defaults);
    } catch (_) {}
  }
}

final checklistSpeciesProvider =
    AsyncNotifierProvider<ChecklistSpeciesNotifier, List<int>>(
        ChecklistSpeciesNotifier.new);
