import 'package:flutter_riverpod/flutter_riverpod.dart';

/// IDs of the 25 most iconic Galapagos species.
/// These are suggested as the starter checklist for new users.
///
/// Source: queried from the species table by common name.
const kSuggestedSpeciesIds = <int>[
  1, // Marine Iguana
  2, // Galapagos Land Iguana
  3, // Santa Cruz Giant Tortoise
  4, // Galapagos Lava Lizard
  5, // Blue-footed Booby
  6, // Nazca Booby
  7, // Magnificent Frigatebird
  8, // Galapagos Penguin
  9, // Waved Albatross
  10, // Galapagos Hawk
  11, // Medium Ground Finch
  12, // Galapagos Sea Lion
  13, // Galapagos Fur Seal
  14, // Green Sea Turtle
  16, // Scalloped Hammerhead Shark
  20, // Red-footed Booby
  21, // American Flamingo
  22, // Galapagos Flightless Cormorant
  25, // Galapagos Dove
  27, // Galapagos Mockingbird
  31, // Great Frigatebird
  40, // White-tip Reef Shark
  41, // Sally Lightfoot Crab
  17, // Galapagos Pink Land Iguana
  55, // Santa Fe Land Iguana
];

final suggestedSpeciesIdsProvider =
    Provider<List<int>>((ref) => kSuggestedSpeciesIds);
