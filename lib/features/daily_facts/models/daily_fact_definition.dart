import 'package:flutter/material.dart';

/// Categories for organizing facts
enum FactCategory {
  behavior,
  anatomy,
  conservation,
  habitat,
  diet,
  reproduction,
  evolution,
}

/// Definition of a daily fact that can be unlocked
class FactDefinition {
  /// Unique identifier for this fact
  final String id;

  /// Localized title function
  final String Function(dynamic t) title;

  /// Localized description (the fact itself)
  final String Function(dynamic t) description;

  /// Optional fun fact or easter egg
  final String Function(dynamic t)? funFact;

  /// Icon to display
  final IconData icon;

  /// Primary color for this fact
  final Color color;

  /// Category for filtering/grouping
  final FactCategory category;

  /// Species IDs related to this fact
  final List<int> relatedSpeciesIds;

  /// Number of sightings required to unlock
  final int unlocksAfterSightings;

  const FactDefinition({
    required this.id,
    required this.title,
    required this.description,
    this.funFact,
    required this.icon,
    required this.color,
    required this.category,
    required this.relatedSpeciesIds,
    required this.unlocksAfterSightings,
  });
}

/// Progress tracking for a fact
class FactProgress {
  final FactDefinition fact;
  final int currentSightings;

  const FactProgress({
    required this.fact,
    required this.currentSightings,
  });

  /// Whether this fact has been unlocked
  bool get isUnlocked => currentSightings >= fact.unlocksAfterSightings;

  /// Progress towards unlocking (0.0 - 1.0)
  double get progress =>
      (currentSightings / fact.unlocksAfterSightings).clamp(0.0, 1.0);

  /// Sightings remaining to unlock
  int get sightingsRemaining =>
      (fact.unlocksAfterSightings - currentSightings).clamp(0, 999);
}

/// Hardcoded list of all available facts
/// Pattern copied from: lib/features/badges/models/badge_definition.dart
List<FactDefinition> allFacts() => [
      // Beginner facts (unlock after 1 sighting)
      FactDefinition(
        id: 'marine_iguana_dive',
        title: (t) => t.facts.marineIguanaDive,
        description: (t) => t.facts.marineIguanaDiveDesc,
        funFact: (t) => t.facts.marineIguanaDiveFun,
        icon: Icons.scuba_diving,
        color: Colors.blue,
        category: FactCategory.behavior,
        relatedSpeciesIds: [1], // Marine Iguana
        unlocksAfterSightings: 1,
      ),
      FactDefinition(
        id: 'blue_footed_booby_feet',
        title: (t) => t.facts.blueFootedBoobyFeet,
        description: (t) => t.facts.blueFootedBoobyFeetDesc,
        funFact: (t) => t.facts.blueFootedBoobyFeetFun,
        icon: Icons.pets,
        color: Colors.lightBlue,
        category: FactCategory.anatomy,
        relatedSpeciesIds: [6], // Blue-footed Booby
        unlocksAfterSightings: 1,
      ),
      FactDefinition(
        id: 'giant_tortoise_age',
        title: (t) => t.facts.giantTortoiseAge,
        description: (t) => t.facts.giantTortoiseAgeDesc,
        funFact: (t) => t.facts.giantTortoiseAgeFun,
        icon: Icons.cake,
        color: Colors.brown,
        category: FactCategory.anatomy,
        relatedSpeciesIds: [2], // Galápagos Giant Tortoise
        unlocksAfterSightings: 1,
      ),

      // Intermediate facts (unlock after 3 sightings)
      FactDefinition(
        id: 'frigatebird_throat',
        title: (t) => t.facts.frigatebirdThroat,
        description: (t) => t.facts.frigatebirdThroatDesc,
        icon: Icons.favorite,
        color: Colors.red,
        category: FactCategory.reproduction,
        relatedSpeciesIds: [7], // Magnificent Frigatebird
        unlocksAfterSightings: 3,
      ),
      FactDefinition(
        id: 'darwin_finches_beaks',
        title: (t) => t.facts.darwinFinchesBeaks,
        description: (t) => t.facts.darwinFinchesBeaksDesc,
        funFact: (t) => t.facts.darwinFinchesBeaksFun,
        icon: Icons.science,
        color: Colors.amber,
        category: FactCategory.evolution,
        relatedSpeciesIds: [29, 30, 31], // Darwin's Finches
        unlocksAfterSightings: 3,
      ),
      FactDefinition(
        id: 'sea_lion_sleep',
        title: (t) => t.facts.seaLionSleep,
        description: (t) => t.facts.seaLionSleepDesc,
        icon: Icons.hotel,
        color: Colors.teal,
        category: FactCategory.behavior,
        relatedSpeciesIds: [13], // Galápagos Sea Lion
        unlocksAfterSightings: 3,
      ),

      // Advanced facts (unlock after 5 sightings)
      FactDefinition(
        id: 'penguin_equator',
        title: (t) => t.facts.penguinEquator,
        description: (t) => t.facts.penguinEquatorDesc,
        icon: Icons.thermostat,
        color: Colors.cyan,
        category: FactCategory.habitat,
        relatedSpeciesIds: [12], // Galápagos Penguin
        unlocksAfterSightings: 5,
      ),
      FactDefinition(
        id: 'flightless_cormorant',
        title: (t) => t.facts.flightlessCormorant,
        description: (t) => t.facts.flightlessCormorantDesc,
        funFact: (t) => t.facts.flightlessCormorantFun,
        icon: Icons.airlines,
        color: Colors.blueGrey,
        category: FactCategory.evolution,
        relatedSpeciesIds: [8], // Flightless Cormorant
        unlocksAfterSightings: 5,
      ),
      FactDefinition(
        id: 'albatross_wingspan',
        title: (t) => t.facts.albatrossWingspan,
        description: (t) => t.facts.albatrossWingspanDesc,
        icon: Icons.zoom_out_map,
        color: Colors.indigo,
        category: FactCategory.anatomy,
        relatedSpeciesIds: [5], // Waved Albatross
        unlocksAfterSightings: 5,
      ),

      // Expert facts (unlock after 10 sightings)
      FactDefinition(
        id: 'marine_ecosystem',
        title: (t) => t.facts.marineEcosystem,
        description: (t) => t.facts.marineEcosystemDesc,
        icon: Icons.water,
        color: Colors.deepPurple,
        category: FactCategory.conservation,
        relatedSpeciesIds: [1, 13, 14, 15], // Marine species
        unlocksAfterSightings: 10,
      ),
      FactDefinition(
        id: 'land_iguana_cactus',
        title: (t) => t.facts.landIguanaCactus,
        description: (t) => t.facts.landIguanaCactusDesc,
        icon: Icons.yard,
        color: Colors.yellow,
        category: FactCategory.diet,
        relatedSpeciesIds: [3], // Land Iguana
        unlocksAfterSightings: 10,
      ),
      FactDefinition(
        id: 'hawk_territory',
        title: (t) => t.facts.hawkTerritory,
        description: (t) => t.facts.hawkTerritoryDesc,
        icon: Icons.map,
        color: Colors.orange,
        category: FactCategory.behavior,
        relatedSpeciesIds: [10], // Galápagos Hawk
        unlocksAfterSightings: 10,
      ),

      // Master facts (unlock after 15 sightings)
      FactDefinition(
        id: 'endemic_species',
        title: (t) => t.facts.endemicSpecies,
        description: (t) => t.facts.endemicSpeciesDesc,
        funFact: (t) => t.facts.endemicSpeciesFun,
        icon: Icons.star,
        color: Colors.purple,
        category: FactCategory.conservation,
        relatedSpeciesIds: [], // All endemic species
        unlocksAfterSightings: 15,
      ),
      FactDefinition(
        id: 'volcanic_formation',
        title: (t) => t.facts.volcanicFormation,
        description: (t) => t.facts.volcanicFormationDesc,
        icon: Icons.terrain,
        color: Colors.deepOrange,
        category: FactCategory.habitat,
        relatedSpeciesIds: [], // General
        unlocksAfterSightings: 15,
      ),
      FactDefinition(
        id: 'darwin_evolution',
        title: (t) => t.facts.darwinEvolution,
        description: (t) => t.facts.darwinEvolutionDesc,
        funFact: (t) => t.facts.darwinEvolutionFun,
        icon: Icons.auto_stories,
        color: Colors.green,
        category: FactCategory.evolution,
        relatedSpeciesIds: [], // General
        unlocksAfterSightings: 15,
      ),

      // Legend facts (unlock after 20 sightings)
      FactDefinition(
        id: 'conservation_efforts',
        title: (t) => t.facts.conservationEfforts,
        description: (t) => t.facts.conservationEffortsDesc,
        icon: Icons.eco,
        color: Colors.lightGreen,
        category: FactCategory.conservation,
        relatedSpeciesIds: [], // General
        unlocksAfterSightings: 20,
      ),
      FactDefinition(
        id: 'unesco_heritage',
        title: (t) => t.facts.unescoHeritage,
        description: (t) => t.facts.unescoHeritageDesc,
        icon: Icons.emoji_events,
        color: Colors.amber,
        category: FactCategory.conservation,
        relatedSpeciesIds: [], // General
        unlocksAfterSightings: 20,
      ),
    ];
