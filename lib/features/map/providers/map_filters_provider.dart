import 'package:flutter_riverpod/legacy.dart';

class MapFilters {
  final bool showSites;
  final bool showSightings;
  final bool showTrails;
  final String searchQuery;
  final int? selectedIslandId;
  final String? selectedMonitoringType;

  const MapFilters({
    this.showSites = true,
    this.showSightings = true,
    this.showTrails = true,
    this.searchQuery = '',
    this.selectedIslandId,
    this.selectedMonitoringType,
  });

  MapFilters copyWith({
    bool? showSites,
    bool? showSightings,
    bool? showTrails,
    String? searchQuery,
    int? selectedIslandId,
    bool clearIsland = false,
    String? selectedMonitoringType,
    bool clearMonitoringType = false,
  }) {
    return MapFilters(
      showSites: showSites ?? this.showSites,
      showSightings: showSightings ?? this.showSightings,
      showTrails: showTrails ?? this.showTrails,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedIslandId: clearIsland ? null : (selectedIslandId ?? this.selectedIslandId),
      selectedMonitoringType: clearMonitoringType ? null : (selectedMonitoringType ?? this.selectedMonitoringType),
    );
  }
}

class MapFiltersNotifier extends StateNotifier<MapFilters> {
  MapFiltersNotifier() : super(const MapFilters());

  void toggleSites() => state = state.copyWith(showSites: !state.showSites);
  void toggleSightings() => state = state.copyWith(showSightings: !state.showSightings);
  void toggleTrails() => state = state.copyWith(showTrails: !state.showTrails);
  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void setSelectedIsland(int? id) {
    if (id == null) {
      state = state.copyWith(clearIsland: true);
    } else {
      state = state.copyWith(selectedIslandId: id);
    }
  }
  void setMonitoringType(String? type) {
    if (type == null) {
      state = state.copyWith(clearMonitoringType: true);
    } else {
      state = state.copyWith(selectedMonitoringType: type);
    }
  }
  void reset() => state = const MapFilters();
}

final mapFiltersProvider =
    StateNotifierProvider<MapFiltersNotifier, MapFilters>((ref) {
  return MapFiltersNotifier();
});
