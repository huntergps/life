import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:galapagos_wildlife/brick/models/sighting.model.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sightings_provider.dart';

/// Filter: selected species ID (null = all species).
final sightingSpeciesFilterProvider = StateProvider<int?>((ref) => null);

/// Filter: date range start (null = no lower bound).
final sightingDateFromProvider = StateProvider<DateTime?>((ref) => null);

/// Filter: date range end (null = no upper bound).
final sightingDateToProvider = StateProvider<DateTime?>((ref) => null);

/// Whether any filter is currently active.
final hasActiveFiltersProvider = Provider<bool>((ref) {
  return ref.watch(sightingSpeciesFilterProvider) != null ||
      ref.watch(sightingDateFromProvider) != null ||
      ref.watch(sightingDateToProvider) != null;
});

/// Sightings filtered by the current filter state.
final filteredSightingsProvider = Provider<AsyncValue<List<Sighting>>>((ref) {
  final sightingsAsync = ref.watch(sightingsProvider);
  final speciesFilter = ref.watch(sightingSpeciesFilterProvider);
  final dateFrom = ref.watch(sightingDateFromProvider);
  final dateTo = ref.watch(sightingDateToProvider);

  return sightingsAsync.whenData((sightings) {
    var filtered = sightings;
    if (speciesFilter != null) {
      filtered = filtered.where((s) => s.speciesId == speciesFilter).toList();
    }
    if (dateFrom != null) {
      filtered = filtered
          .where(
              (s) => s.observedAt != null && !s.observedAt!.isBefore(dateFrom))
          .toList();
    }
    if (dateTo != null) {
      filtered = filtered
          .where((s) =>
              s.observedAt != null &&
              s.observedAt!.isBefore(dateTo.add(const Duration(days: 1))))
          .toList();
    }
    return filtered;
  });
});
