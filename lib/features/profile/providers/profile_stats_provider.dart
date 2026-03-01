import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sightings_provider.dart';

class ProfileStats {
  final int uniqueSpecies;
  final int uniqueSites;
  final int photosCount;
  final int totalSightings;

  const ProfileStats({
    required this.uniqueSpecies,
    required this.uniqueSites,
    required this.photosCount,
    required this.totalSightings,
  });
}

/// Derived provider that computes profile statistics from the sightings list.
/// Only recomputes when the sightings list changes.
final profileStatsProvider = Provider<AsyncValue<ProfileStats>>((ref) {
  final sightingsAsync = ref.watch(sightingsProvider);
  return sightingsAsync.whenData((sightings) {
    final uniqueSpeciesIds = <int>{};
    final visitSiteIds = <int>{};
    int photosCount = 0;
    for (final s in sightings) {
      uniqueSpeciesIds.add(s.speciesId);
      if (s.visitSiteId != null) visitSiteIds.add(s.visitSiteId!);
      if (s.photoUrl != null) photosCount++;
    }
    return ProfileStats(
      uniqueSpecies: uniqueSpeciesIds.length,
      uniqueSites: visitSiteIds.length,
      photosCount: photosCount,
      totalSightings: sightings.length,
    );
  });
});
