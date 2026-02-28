import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages user favorite species IDs with optimistic updates.
/// Uses Supabase directly — avoids Brick offline-queue RLS issues with id=0.
class FavoritesNotifier extends AsyncNotifier<Set<int>> {
  SupabaseClient get _db => Supabase.instance.client;

  @override
  Future<Set<int>> build() async {
    final user = _db.auth.currentUser;
    if (user == null) return {};

    final rows = await _db
        .from('user_favorites')
        .select('species_id')
        .eq('user_id', user.id);

    return (rows as List)
        .map((row) => row['species_id'] as int)
        .toSet();
  }

  Future<void> toggle(int speciesId) async {
    final user = _db.auth.currentUser;
    if (user == null) return;

    final current = state.asData?.value ?? {};
    final isFav = current.contains(speciesId);

    // Optimistic update — instant UI response, no loading blink
    final updated = Set<int>.from(current);
    if (isFav) {
      updated.remove(speciesId);
    } else {
      updated.add(speciesId);
    }
    state = AsyncData(updated);

    try {
      if (isFav) {
        await _db
            .from('user_favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('species_id', speciesId);
      } else {
        await _db.from('user_favorites').insert({
          'user_id': user.id,
          'species_id': speciesId,
        });
      }
    } catch (e) {
      // Revert optimistic update on failure
      state = AsyncData(current);
      AppLogger.error('toggleFavorite failed', e);
      rethrow;
    }
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, Set<int>>(FavoritesNotifier.new);

/// Returns true if species is in favorites (synchronous, no loading flash).
final isSpeciesFavoriteProvider = Provider.family<bool, int>((ref, speciesId) {
  final favs = ref.watch(favoritesProvider).asData?.value;
  return favs?.contains(speciesId) ?? false;
});

final favoriteSpeciesProvider = FutureProvider<List<Species>>((ref) async {
  final favoriteIds = ref.watch(favoritesProvider).asData?.value ?? {};
  if (favoriteIds.isEmpty) return [];
  final allSpecies = await fetchLookup<Species>(idSelector: (s) => s.id);
  return allSpecies.entries
      .where((e) => favoriteIds.contains(e.key))
      .map((e) => e.value)
      .toList();
});

/// Convenience wrapper — call from any WidgetRef context.
Future<void> toggleFavorite(WidgetRef ref, int speciesId) async {
  await ref.read(favoritesProvider.notifier).toggle(speciesId);
}
