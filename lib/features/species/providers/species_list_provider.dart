import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';

final speciesCategoryFilterProvider = StateProvider<int?>((ref) => null);
final speciesSearchQueryProvider = StateProvider<String>((ref) => '');
final speciesConservationFilterProvider = StateProvider<String?>((ref) => null);
final speciesEndemicFilterProvider = StateProvider<bool?>((ref) => null);
final speciesDietFilterProvider = StateProvider<String?>((ref) => null);
final speciesActivityFilterProvider = StateProvider<String?>((ref) => null);

enum SpeciesSort { nameAsc, nameDesc, rarityFirst, endemicFirst }

final speciesSortProvider = StateProvider<SpeciesSort>((ref) => SpeciesSort.nameAsc);

/// All species — fetches from Supabase remote (with local fallback on error).
/// On web/desktop (Brick not initialized), fetchDeduped falls back to Supabase directly.
final allSpeciesProvider = FutureProvider<List<Species>>((ref) async {
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

/// Conservation status sort order — CR highest, DD lowest.
int _rarityOrder(String? status) {
  return switch (status) {
    'CR' => 0,
    'EN' => 1,
    'VU' => 2,
    'NT' => 3,
    'LC' => 4,
    'DD' => 5,
    _ => 6,
  };
}

final speciesListProvider = FutureProvider<List<Species>>((ref) async {
  final categoryId = ref.watch(speciesCategoryFilterProvider);
  final searchQuery = ref.watch(speciesSearchQueryProvider);
  final conservationFilter = ref.watch(speciesConservationFilterProvider);
  final endemicFilter = ref.watch(speciesEndemicFilterProvider);
  final dietFilter = ref.watch(speciesDietFilterProvider);
  final activityFilter = ref.watch(speciesActivityFilterProvider);
  final sort = ref.watch(speciesSortProvider);

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

  if (dietFilter != null) {
    filtered = filtered.where((s) => s.dietType == dietFilter).toList();
  }

  if (activityFilter != null) {
    filtered = filtered.where((s) => s.activityPattern == activityFilter).toList();
  }

  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    final extended = query.length > 3;
    filtered = filtered.where((s) {
      if (s.commonNameEn.toLowerCase().contains(query)) return true;
      if (s.commonNameEs.toLowerCase().contains(query)) return true;
      if (s.scientificName.toLowerCase().contains(query)) return true;
      if (extended) {
        if ((s.habitatEn ?? '').toLowerCase().contains(query)) return true;
        if ((s.habitatEs ?? '').toLowerCase().contains(query)) return true;
        if ((s.descriptionEn ?? '').toLowerCase().contains(query)) return true;
        if ((s.descriptionEs ?? '').toLowerCase().contains(query)) return true;
      }
      return false;
    }).toList();
  }

  // Apply sort
  switch (sort) {
    case SpeciesSort.nameAsc:
      filtered.sort((a, b) => a.commonNameEn.compareTo(b.commonNameEn));
    case SpeciesSort.nameDesc:
      filtered.sort((a, b) => b.commonNameEn.compareTo(a.commonNameEn));
    case SpeciesSort.rarityFirst:
      filtered.sort((a, b) =>
          _rarityOrder(a.conservationStatus).compareTo(_rarityOrder(b.conservationStatus)));
    case SpeciesSort.endemicFirst:
      filtered.sort((a, b) {
        if (a.isEndemic == b.isEndemic) return a.commonNameEn.compareTo(b.commonNameEn);
        return a.isEndemic ? -1 : 1;
      });
  }

  return filtered;
});

/// Whether any filter beyond category is active.
final hasActiveFiltersProvider = Provider<bool>((ref) {
  return ref.watch(speciesConservationFilterProvider) != null ||
      ref.watch(speciesEndemicFilterProvider) == true ||
      ref.watch(speciesDietFilterProvider) != null ||
      ref.watch(speciesActivityFilterProvider) != null ||
      ref.watch(speciesSearchQueryProvider).isNotEmpty;
});
