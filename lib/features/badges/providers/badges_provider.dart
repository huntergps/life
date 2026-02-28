import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/brick/models/sighting.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/features/badges/models/badge_definition.dart';
import 'package:galapagos_wildlife/features/favorites/providers/favorites_provider.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sightings_provider.dart';

/// All badge definitions. Uses i18n `t` for localized names/descriptions.
List<BadgeDefinition> allBadges() => [
      BadgeDefinition(
        id: 'first_sighting',
        name: (t) => t.badges.firstSighting,
        description: (t) => t.badges.firstSightingDesc,
        icon: Icons.camera_alt,
        color: Colors.amber,
        category: BadgeCategory.sightings,
        target: 1,
      ),
      BadgeDefinition(
        id: 'explorer',
        name: (t) => t.badges.explorer,
        description: (t) => t.badges.explorerDesc,
        icon: Icons.explore,
        color: Colors.blue,
        category: BadgeCategory.sightings,
        target: 10,
      ),
      BadgeDefinition(
        id: 'field_researcher',
        name: (t) => t.badges.fieldResearcher,
        description: (t) => t.badges.fieldResearcherDesc,
        icon: Icons.science,
        color: Colors.purple,
        category: BadgeCategory.sightings,
        target: 50,
      ),
      BadgeDefinition(
        id: 'naturalist',
        name: (t) => t.badges.naturalist,
        description: (t) => t.badges.naturalistDesc,
        icon: Icons.pets,
        color: Colors.green,
        category: BadgeCategory.species,
        target: 5,
      ),
      BadgeDefinition(
        id: 'biologist',
        name: (t) => t.badges.biologist,
        description: (t) => t.badges.biologistDesc,
        icon: Icons.biotech,
        color: Colors.teal,
        category: BadgeCategory.species,
        target: 20,
      ),
      BadgeDefinition(
        id: 'endemic_explorer',
        name: (t) => t.badges.endemicExplorer,
        description: (t) => t.badges.endemicExplorerDesc,
        icon: Icons.eco,
        color: Colors.lightGreen,
        category: BadgeCategory.species,
        target: 5,
      ),
      BadgeDefinition(
        id: 'island_hopper',
        name: (t) => t.badges.islandHopper,
        description: (t) => t.badges.islandHopperDesc,
        icon: Icons.sailing,
        color: Colors.cyan,
        category: BadgeCategory.exploration,
        target: 3,
      ),
      BadgeDefinition(
        id: 'photographer',
        name: (t) => t.badges.photographer,
        description: (t) => t.badges.photographerDesc,
        icon: Icons.photo_camera,
        color: Colors.orange,
        category: BadgeCategory.sightings,
        target: 10,
      ),
      BadgeDefinition(
        id: 'curator',
        name: (t) => t.badges.curator,
        description: (t) => t.badges.curatorDesc,
        icon: Icons.favorite,
        color: Colors.red,
        category: BadgeCategory.social,
        target: 10,
      ),
      BadgeDefinition(
        id: 'conservationist',
        name: (t) => t.badges.conservationist,
        description: (t) => t.badges.conservationistDesc,
        icon: Icons.shield,
        color: Colors.deepOrange,
        category: BadgeCategory.conservation,
        target: 3,
      ),
    ];

/// Computes badge progress from existing sightings, species, and favorites data.
final badgeProgressProvider = FutureProvider<List<BadgeProgress>>((ref) async {
  final sightings = await ref.watch(sightingsProvider.future);
  final speciesMap = await ref.watch(speciesLookupProvider.future);
  final favorites = await ref.watch(favoritesProvider.future);

  final badges = allBadges();
  final stats = _computeStats(sightings, speciesMap);

  return badges.map((badge) {
    final current = _currentForBadge(badge.id, stats, favorites.length);
    return BadgeProgress(badge: badge, current: current);
  }).toList();
});

/// Count of unlocked badges (for display in settings/nav).
final unlockedBadgeCountProvider = FutureProvider<int>((ref) async {
  final progress = await ref.watch(badgeProgressProvider.future);
  return progress.where((p) => p.isUnlocked).length;
});

class _Stats {
  final int totalSightings;
  final int uniqueSpecies;
  final int endemicSpecies;
  final int uniqueIslands;
  final int photosCount;
  final int threatenedSpecies;

  const _Stats({
    required this.totalSightings,
    required this.uniqueSpecies,
    required this.endemicSpecies,
    required this.uniqueIslands,
    required this.photosCount,
    required this.threatenedSpecies,
  });
}

_Stats _computeStats(List<Sighting> sightings, Map<int, Species> speciesMap) {
  final uniqueSpeciesIds = <int>{};
  final endemicIds = <int>{};
  final islandSiteIds = <int>{};
  final threatenedIds = <int>{};
  int photos = 0;

  for (final s in sightings) {
    uniqueSpeciesIds.add(s.speciesId);

    if (s.photoUrl != null) photos++;
    if (s.visitSiteId != null) islandSiteIds.add(s.visitSiteId!);

    final species = speciesMap[s.speciesId];
    if (species != null) {
      if (species.isEndemic) endemicIds.add(s.speciesId);
      final status = species.conservationStatus;
      if (status == 'CR' || status == 'EN' || status == 'VU') {
        threatenedIds.add(s.speciesId);
      }
    }
  }

  return _Stats(
    totalSightings: sightings.length,
    uniqueSpecies: uniqueSpeciesIds.length,
    endemicSpecies: endemicIds.length,
    uniqueIslands: islandSiteIds.length, // approximation via visit sites
    photosCount: photos,
    threatenedSpecies: threatenedIds.length,
  );
}

int _currentForBadge(String badgeId, _Stats stats, int favoritesCount) {
  return switch (badgeId) {
    'first_sighting' => stats.totalSightings,
    'explorer' => stats.totalSightings,
    'field_researcher' => stats.totalSightings,
    'naturalist' => stats.uniqueSpecies,
    'biologist' => stats.uniqueSpecies,
    'endemic_explorer' => stats.endemicSpecies,
    'island_hopper' => stats.uniqueIslands,
    'photographer' => stats.photosCount,
    'curator' => favoritesCount,
    'conservationist' => stats.threatenedSpecies,
    _ => 0,
  };
}
