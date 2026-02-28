import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';

final speciesCategoryFilterProvider = StateProvider<int?>((ref) => null);
final speciesSearchQueryProvider = StateProvider<String>((ref) => '');
final speciesConservationFilterProvider = StateProvider<String?>((ref) => null);
final speciesEndemicFilterProvider = StateProvider<bool?>((ref) => null);

/// All species — fetches from Supabase remote (with local fallback on error).
/// On web, queries Supabase directly (no local SQLite).
final allSpeciesProvider = FutureProvider<List<Species>>((ref) async {
  if (kIsWeb) {
    final data = await Supabase.instance.client.from('species').select();
    return (data as List).map((r) => speciesFromRow(r as Map<String, dynamic>)).toList();
  }
  return fetchDeduped<Species>(idSelector: (s) => s.id);
});

/// Count of species per category id. Key null = total.
final speciesCountByCategoryProvider = FutureProvider<Map<int?, int>>((ref) async {
  final all = await ref.watch(allSpeciesProvider.future);
  final counts = <int?, int>{null: all.length};
  for (final s in all) {
    counts[s.categoryId] = (counts[s.categoryId] ?? 0) + 1;
  }
  return counts;
});

final speciesListProvider = FutureProvider<List<Species>>((ref) async {
  final categoryId = ref.watch(speciesCategoryFilterProvider);
  final searchQuery = ref.watch(speciesSearchQueryProvider);
  final conservationFilter = ref.watch(speciesConservationFilterProvider);
  final endemicFilter = ref.watch(speciesEndemicFilterProvider);

  final all = await ref.watch(allSpeciesProvider.future);

  var filtered = categoryId != null
      ? all.where((s) => s.categoryId == categoryId).toList()
      : List<Species>.from(all);

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
});

/// Whether any filter beyond category is active.
final hasActiveFiltersProvider = Provider<bool>((ref) {
  return ref.watch(speciesConservationFilterProvider) != null ||
      ref.watch(speciesEndemicFilterProvider) == true ||
      ref.watch(speciesSearchQueryProvider).isNotEmpty;
});
