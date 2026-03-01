import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';

/// Returns set of species IDs the current user has marked as seen.
final userChecklistProvider = FutureProvider<Set<int>>((ref) async {
  ref.watch(isAuthenticatedProvider);
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return {};
  try {
    final data = await Supabase.instance.client
        .from('user_species_checklist')
        .select('species_id')
        .eq('user_id', user.id);
    return {for (final row in data as List) row['species_id'] as int};
  } catch (_) {
    return {};
  }
});

/// Returns true if the given species has been marked as seen.
final isSpeciesSeenProvider = Provider.family<bool, int>((ref, speciesId) {
  final checklist = ref.watch(userChecklistProvider).asData?.value ?? {};
  return checklist.contains(speciesId);
});

/// Count of species the current user has marked as seen.
final speciesSeenCountProvider = Provider<int>((ref) {
  return ref.watch(userChecklistProvider).asData?.value.length ?? 0;
});

/// Toggles the "seen" state for a species.
Future<void> toggleSpeciesSeen(WidgetRef ref, int speciesId) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return;
  final isSeen = ref.read(isSpeciesSeenProvider(speciesId));
  try {
    if (isSeen) {
      await Supabase.instance.client
          .from('user_species_checklist')
          .delete()
          .eq('user_id', user.id)
          .eq('species_id', speciesId);
    } else {
      await Supabase.instance.client
          .from('user_species_checklist')
          .upsert({'user_id': user.id, 'species_id': speciesId});
    }
    ref.invalidate(userChecklistProvider);
  } catch (_) {
    // Silently fail
  }
}
