import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:galapagos_wildlife/brick/models/sighting.model.dart';
import 'package:galapagos_wildlife/features/favorites/providers/favorites_provider.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sightings_provider.dart';

// ---------------------------------------------------------------------------
// SightingFilters value object
// ---------------------------------------------------------------------------

class SightingFilters {
  final int? speciesId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? visitSiteId;
  final bool photosOnly;
  final bool favoritesOnly;
  final String? searchQuery;

  const SightingFilters({
    this.speciesId,
    this.dateFrom,
    this.dateTo,
    this.visitSiteId,
    this.photosOnly = false,
    this.favoritesOnly = false,
    this.searchQuery,
  });

  bool get hasActiveFilters =>
      speciesId != null ||
      dateFrom != null ||
      dateTo != null ||
      visitSiteId != null ||
      photosOnly ||
      favoritesOnly ||
      (searchQuery?.isNotEmpty ?? false);

  SightingFilters copyWith({
    Object? speciesId = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
    Object? visitSiteId = _sentinel,
    bool? photosOnly,
    bool? favoritesOnly,
    Object? searchQuery = _sentinel,
  }) {
    return SightingFilters(
      speciesId: speciesId == _sentinel ? this.speciesId : speciesId as int?,
      dateFrom: dateFrom == _sentinel ? this.dateFrom : dateFrom as DateTime?,
      dateTo: dateTo == _sentinel ? this.dateTo : dateTo as DateTime?,
      visitSiteId:
          visitSiteId == _sentinel ? this.visitSiteId : visitSiteId as int?,
      photosOnly: photosOnly ?? this.photosOnly,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      searchQuery:
          searchQuery == _sentinel ? this.searchQuery : searchQuery as String?,
    );
  }
}

// Sentinel used by copyWith to distinguish "not provided" from null.
const _sentinel = Object();

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SightingFiltersNotifier extends StateNotifier<SightingFilters> {
  SightingFiltersNotifier() : super(const SightingFilters());

  void setSpecies(int? speciesId) =>
      state = state.copyWith(speciesId: speciesId);

  void setDateFrom(DateTime? date) =>
      state = state.copyWith(dateFrom: date);

  void setDateTo(DateTime? date) =>
      state = state.copyWith(dateTo: date);

  void setVisitSite(int? visitSiteId) =>
      state = state.copyWith(visitSiteId: visitSiteId);

  void setPhotosOnly(bool value) =>
      state = state.copyWith(photosOnly: value);

  void setFavoritesOnly(bool value) =>
      state = state.copyWith(favoritesOnly: value);

  void setSearchQuery(String? query) =>
      state = state.copyWith(searchQuery: query?.isEmpty == true ? null : query);

  void clearAll() => state = const SightingFilters();
}

final sightingFiltersProvider =
    StateNotifierProvider<SightingFiltersNotifier, SightingFilters>(
  (ref) => SightingFiltersNotifier(),
);

// ---------------------------------------------------------------------------
// Legacy individual providers — kept for backward-compat with filter bar
// (delegates read/write to sightingFiltersProvider)
// ---------------------------------------------------------------------------

/// Filter: selected species ID (null = all species).
final sightingSpeciesFilterProvider = Provider<int?>((ref) {
  return ref.watch(sightingFiltersProvider).speciesId;
});

/// Filter: date range start.
final sightingDateFromProvider = Provider<DateTime?>((ref) {
  return ref.watch(sightingFiltersProvider).dateFrom;
});

/// Filter: date range end.
final sightingDateToProvider = Provider<DateTime?>((ref) {
  return ref.watch(sightingFiltersProvider).dateTo;
});

/// Whether any filter is currently active.
final hasActiveFiltersProvider = Provider<bool>((ref) {
  return ref.watch(sightingFiltersProvider).hasActiveFilters;
});

// ---------------------------------------------------------------------------
// Filtered sightings provider
// ---------------------------------------------------------------------------

/// Sightings filtered by the current filter state.
final filteredSightingsProvider = Provider<AsyncValue<List<Sighting>>>((ref) {
  final sightingsAsync = ref.watch(sightingsProvider);
  final filters = ref.watch(sightingFiltersProvider);

  // Read favorite species IDs for the favoritesOnly filter.
  // Favorites are species-based in this app; sighting favorites are not yet
  // implemented. For now we skip the favoritesOnly filter with a TODO.
  // TODO(sighting-favorites): implement per-sighting favorites and wire here.
  final favoriteSpeciesIds =
      filters.favoritesOnly ? ref.watch(favoritesProvider).asData?.value : null;

  return sightingsAsync.whenData((sightings) {
    var filtered = sightings;

    // Species filter
    if (filters.speciesId != null) {
      filtered = filtered
          .where((s) => s.speciesId == filters.speciesId)
          .toList();
    }

    // Date from filter
    if (filters.dateFrom != null) {
      filtered = filtered
          .where((s) =>
              s.observedAt != null &&
              !s.observedAt!.isBefore(filters.dateFrom!))
          .toList();
    }

    // Date to filter
    if (filters.dateTo != null) {
      filtered = filtered
          .where((s) =>
              s.observedAt != null &&
              s.observedAt!
                  .isBefore(filters.dateTo!.add(const Duration(days: 1))))
          .toList();
    }

    // Visit site filter
    if (filters.visitSiteId != null) {
      filtered = filtered
          .where((s) => s.visitSiteId == filters.visitSiteId)
          .toList();
    }

    // Photos only filter
    if (filters.photosOnly) {
      filtered = filtered.where((s) => s.photoUrl != null).toList();
    }

    // Favorites only filter
    // Since user_favorites stores species IDs (not sighting IDs), we filter
    // sightings whose species is in the user's favorites list.
    if (filters.favoritesOnly && favoriteSpeciesIds != null) {
      filtered = filtered
          .where((s) => favoriteSpeciesIds.contains(s.speciesId))
          .toList();
    }

    // Text search filter (searches in notes)
    final query = filters.searchQuery;
    if (query != null && query.isNotEmpty) {
      final lower = query.toLowerCase();
      filtered = filtered
          .where((s) =>
              (s.notes?.toLowerCase().contains(lower) ?? false))
          .toList();
    }

    return filtered;
  });
});
