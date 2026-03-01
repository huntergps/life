import 'package:flutter_riverpod/legacy.dart';

/// View mode for the sightings list screen.
enum SightingsViewMode { list, calendar }

/// Tracks the selected sighting index for master-detail on tablet.
final selectedSightingIndexProvider = StateProvider<int?>((ref) => null);

/// Tracks whether the filter bar is visible.
final showFiltersProvider = StateProvider<bool>((ref) => false);

/// Tracks the current view mode: list or calendar (month-grouped).
final viewModeProvider =
    StateProvider<SightingsViewMode>((ref) => SightingsViewMode.list);
