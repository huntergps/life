import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';

/// Manages "seen" species IDs with optimistic updates.
class ChecklistNotifier extends AsyncNotifier<Set<int>> {
  SupabaseClient get _db => Supabase.instance.client;

  @override
  Future<Set<int>> build() async {
    ref.watch(isAuthenticatedProvider);
    final user = _db.auth.currentUser;
    if (user == null) return {};
    try {
      final data = await _db
          .from('user_species_checklist')
          .select('species_id')
          .eq('user_id', user.id);
      return {for (final row in data as List) row['species_id'] as int};
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
    if (isSeen) {
      updated.remove(speciesId);
    } else {
      updated.add(speciesId);
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
        await _db.from('user_species_checklist').upsert({
          'user_id': user.id,
          'species_id': speciesId,
        });
      }
    } catch (e) {
      // Revert on failure
      state = AsyncData(current);
      AppLogger.error('toggleSpeciesSeen failed', e);
    }
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
