/// Maps species IDs to local asset image paths.
/// Used as fallback when thumbnail_url / hero_image_url are not yet
/// populated in the database (e.g. images haven't been uploaded to
/// Supabase Storage).
class SpeciesAssets {
  SpeciesAssets._();

  static const _base = 'assets/images/species';
  static const _hero = 'assets/images/hero';

  /// Thumbnail fallback for the species grid cards.
  static String? thumbnail(int speciesId) => _thumbnails[speciesId];

  /// Hero image fallback for the species detail screen.
  static String? heroImage(int speciesId) => _heroes[speciesId];

  /// Local gallery images for the species detail screen (excludes thumbnail).
  static List<String> gallery(int speciesId) => _gallery[speciesId] ?? [];

  static const _thumbnails = <int, String>{
    // === Original species with curated photos ===
    1: '$_base/marine_iguana_closeup.jpeg',             // Marine Iguana
    2: '$_base/land_iguana_walking.jpg',                // Land Iguana
    3: '$_base/giant_tortoise_face_closeup.jpg',        // Giant Tortoise
    4: '$_base/lava_lizard.jpg',                        // Lava Lizard
    5: '$_base/blue_footed_booby_preening.jpg',         // Blue-footed Booby
    6: '$_base/nazca_booby_with_chick.jpg',             // Nazca Booby
    7: '$_base/frigatebird_red_pouch_nest.jpeg',        // Magnificent Frigatebird
    8: '$_base/penguin_pair_rocks.jpg',                 // Galapagos Penguin
    9: '$_base/waved_albatross_nesting.jpg',            // Waved Albatross
    11: '$_base/darwins_finch.jpg',                     // Darwin's Finch
    12: '$_base/sea_lion_pup_rocks.jpg',                // Galapagos Sea Lion
    18: '$_base/galapagos_racer_snake.jpg',             // Galapagos Racer Snake
    20: '$_base/red_footed_booby_nesting.jpeg',         // Red-footed Booby
    21: '$_base/flamingo_closeup.jpg',                  // American Flamingo
    22: '$_base/flightless_cormorant_swimming.jpeg',    // Flightless Cormorant
    23: '$_base/swallow_tailed_gull_standing.jpeg',     // Swallow-tailed Gull
    25: '$_base/galapagos_dove_perched.jpeg',           // Galapagos Dove
    28: '$_base/brown_pelican_fishing.jpeg',            // Brown Pelican
    29: '$_hero/great_blue_heron_coast.jpg',            // Great Blue Heron
    30: '$_base/lava_heron_on_branch.jpeg',             // Lava Heron
    36: '$_base/eagle_rays_group_underwater.jpeg',      // Spotted Eagle Ray

    // === Downloaded from Wikimedia Commons (16:9, 1280x720) ===
    // Reptiles - Tortoises
    10: '$_base/galapagos_hawk.jpg',                    // Galapagos Hawk
    17: '$_base/pink_land_iguana.jpg',                  // Pink Land Iguana
    43: '$_base/san_cristobal_tortoise.jpg',            // San Cristobal Giant Tortoise
    44: '$_base/espanola_tortoise.jpg',                 // Espanola Giant Tortoise
    45: '$_base/alcedo_tortoise.jpg',                   // Alcedo Giant Tortoise
    46: '$_base/wolf_volcano_tortoise.jpg',             // Wolf Volcano Giant Tortoise
    47: '$_base/santiago_tortoise.jpg',                 // Santiago Giant Tortoise
    48: '$_base/pinzon_tortoise.jpg',                   // Pinzon Giant Tortoise
    49: '$_base/sierra_negra_tortoise.jpg',             // Sierra Negra Giant Tortoise
    50: '$_base/eastern_santa_cruz_tortoise.jpg',       // Eastern Santa Cruz Tortoise
    51: '$_base/fernandina_tortoise.jpg',               // Fernandina Giant Tortoise
    52: '$_base/lonesome_george.jpg',                   // Lonesome George (Pinta)
    53: '$_base/darwin_volcano_tortoise.jpg',           // Darwin Volcano Giant Tortoise
    54: '$_base/cerro_azul_tortoise.jpg',               // Cerro Azul Giant Tortoise
    89: '$_base/floreana_tortoise.jpg',                 // Floreana Giant Tortoise (extinct)
    90: '$_base/santa_fe_tortoise.jpg',                 // Santa Fe Giant Tortoise (extinct)

    // Reptiles - Iguanas
    55: '$_base/santa_fe_land_iguana.jpg',              // Santa Fe Land Iguana

    // Reptiles - Snakes
    56: '$_base/central_galapagos_racer.jpg',           // Central Galapagos Racer
    57: '$_base/western_galapagos_racer.jpg',           // Western Galapagos Racer
    58: '$_base/espanola_racer.jpg',                    // Espanola Racer
    59: '$_base/striped_galapagos_snake.jpg',           // Painted Galapagos Racer
    60: '$_base/yellow_bellied_sea_snake.jpg',          // Yellow-bellied Sea Snake
    106: '$_base/pinzon_racer.jpg',                     // Pinzon Racer
    107: '$_base/santiago_racer.jpg',                   // Santiago Racer
    109: '$_base/tortuga_island_racer.jpg',             // Darwin Island Racer
    110: '$_base/thomas_racer.jpg',                     // Thomas Racer

    // Sea Turtles
    14: '$_base/green_sea_turtle.jpg',                  // Green Sea Turtle
    19: '$_base/hawksbill_sea_turtle.jpg',              // Hawksbill Sea Turtle
    61: '$_base/loggerhead_sea_turtle.jpg',             // Loggerhead Sea Turtle
    62: '$_base/olive_ridley_turtle.jpg',               // Olive Ridley Turtle
    63: '$_base/leatherback_turtle.jpg',                // Leatherback Turtle

    // Birds - Raptors & Owls
    24: '$_base/galapagos_short_eared_owl.jpg',         // Galapagos Short-eared Owl
    115: '$_base/galapagos_barn_owl.jpg',               // Galapagos Barn Owl

    // Birds - Seabirds
    31: '$_base/great_frigatebird.jpg',                 // Great Frigatebird
    79: '$_base/galapagos_petrel.jpg',                  // Galapagos Petrel
    114: '$_base/galapagos_shearwater.jpg',             // Galapagos Shearwater
    116: '$_base/wedge_rumped_storm_petrel.jpg',        // Wedge-rumped Storm Petrel

    // Birds - Songbirds & Passerines
    26: '$_base/galapagos_yellow_warbler.jpg',          // Galapagos Yellow Warbler
    27: '$_base/galapagos_mockingbird.jpg',             // Galapagos Mockingbird
    75: '$_base/espanola_mockingbird.jpg',              // Espanola Mockingbird
    76: '$_base/floreana_mockingbird.jpg',              // Floreana Mockingbird
    104: '$_base/san_cristobal_mockingbird.jpg',        // San Cristobal Mockingbird
    77: '$_base/galapagos_flycatcher.jpg',              // Galapagos Flycatcher
    78: '$_base/galapagos_vermilion_flycatcher.jpg',    // Galapagos Vermilion Flycatcher
    80: '$_base/galapagos_martin.jpg',                  // Galapagos Martin

    // Birds - Darwin's Finches
    64: '$_base/small_ground_finch.jpg',                // Small Ground Finch
    65: '$_base/large_ground_finch.jpg',                // Large Ground Finch
    66: '$_base/common_cactus_finch.jpg',               // Common Cactus Finch
    67: '$_base/large_cactus_finch.jpg',                // Espanola Cactus Finch
    68: '$_base/woodpecker_finch.jpg',                  // Woodpecker Finch
    69: '$_base/small_tree_finch.jpg',                  // Small Tree Finch
    70: '$_base/vegetarian_finch.jpg',                  // Vegetarian Finch
    71: '$_base/green_warbler_finch.jpg',               // Green Warbler Finch
    72: '$_base/mangrove_finch.jpg',                    // Mangrove Finch
    92: '$_base/sharp_beaked_ground_finch.jpg',         // Sharp-beaked Ground Finch
    93: '$_base/vampire_ground_finch.jpg',              // Vampire Ground Finch
    94: '$_base/genovesa_ground_finch.jpg',             // Genovesa Ground Finch
    95: '$_base/genovesa_cactus_finch.jpg',             // Genovesa Cactus Finch
    96: '$_base/medium_tree_finch.jpg',                 // Medium Tree Finch
    97: '$_base/large_tree_finch.jpg',                  // Large Tree Finch
    98: '$_base/grey_warbler_finch.jpg',                // Grey Warbler Finch
    99: '$_base/cocos_finch.jpg',                       // Cocos Finch

    // Birds - Other
    73: '$_base/galapagos_rail.jpg',                    // Galapagos Rail
    74: '$_base/lava_gull.jpg',                         // Lava Gull
    111: '$_base/white_cheeked_pintail.jpg',            // White-cheeked Pintail
    112: '$_base/yellow_crowned_night_heron.jpg',       // Yellow-crowned Night Heron
    113: '$_base/galapagos_oystercatcher.jpg',          // Galapagos Oystercatcher

    // Mammals
    13: '$_base/galapagos_fur_seal.jpg',                // Galapagos Fur Seal
    32: '$_base/galapagos_rice_rat.jpg',                // Galapagos Rice Rat
    33: '$_base/galapagos_red_bat.jpg',                 // Galapagos Red Bat
    34: '$_base/galapagos_hoary_bat.jpg',               // Galapagos Hoary Bat
    81: '$_base/bottlenose_dolphin.jpg',                // Bottlenose Dolphin
    82: '$_base/humpback_whale.jpg',                    // Humpback Whale
    83: '$_base/orca.jpg',                              // Orca
    108: '$_base/sperm_whale.jpg',                      // Sperm Whale

    // Marine Life - Sharks & Rays
    15: '$_base/galapagos_shark.jpg',                   // Galapagos Shark
    16: '$_base/scalloped_hammerhead.jpg',              // Scalloped Hammerhead
    35: '$_base/giant_manta_ray.jpg',                   // Giant Manta Ray
    37: '$_base/whale_shark.jpg',                       // Whale Shark
    40: '$_base/whitetip_reef_shark.jpg',               // Whitetip Reef Shark

    // Marine Life - Fish & Other
    38: '$_base/pacific_seahorse.jpg',                  // Pacific Seahorse
    39: '$_base/galapagos_reef_octopus.jpg',            // Galapagos Reef Octopus
    84: '$_base/ocean_sunfish.jpg',                     // Ocean Sunfish
    85: '$_base/porcupinefish.jpg',                     // Porcupinefish

    // Invertebrates
    41: '$_base/sally_lightfoot_crab.jpg',              // Sally Lightfoot Crab
    42: '$_base/galapagos_painted_locust.jpg',          // Galapagos Painted Locust
    86: '$_base/galapagos_spiny_lobster.jpg',           // Galapagos Spiny Lobster
    87: '$_base/black_sea_cucumber.jpg',                // Black Sea Cucumber
    88: '$_base/white_sea_urchin.jpg',                  // White Sea Urchin
  };

  static const _heroes = <int, String>{
    3: '$_hero/giant_tortoise_pair.jpg',                // Giant Tortoises
    5: '$_base/blue_footed_booby_standing.jpg',         // Blue-footed Booby
    6: '$_base/nazca_booby_pair.jpg',                   // Nazca Booby
    7: '$_base/frigatebird_males_display.jpeg',         // Magnificent Frigatebird
    8: '$_base/penguin_swimming.jpg',                   // Galapagos Penguin
    9: '$_base/waved_albatross_face_closeup.jpg',       // Waved Albatross
    12: '$_hero/sea_lion_beach.jpg',                    // Sea Lions on beach
    21: '$_hero/flamingo_lagoon.jpg',                   // Flamingos in lagoon
    29: '$_hero/great_blue_heron_coast.jpg',            // Great Blue Heron
    30: '$_base/lava_heron_on_rocks.JPG',               // Lava Heron
  };

  static const _gallery = <int, List<String>>{
    1: ['$_base/marine_iguana_group.jpeg'],
    2: ['$_base/land_iguana_face_closeup.jpg'],
    4: ['$_base/lava_lizard_red_closeup.jpg'],
    5: [
      '$_base/blue_footed_booby_standing.jpg',
      '$_base/blue_footed_booby_with_egg.JPG',
    ],
    6: [
      '$_base/nazca_booby_pair.jpg',
      '$_base/nazca_booby_pair_closeup.jpg',
      '$_base/nazca_booby_adult_juvenile.jpg',
    ],
    7: [
      '$_base/frigatebird_female_perched.jpeg',
      '$_base/frigatebird_males_display.jpeg',
    ],
    8: [
      '$_base/penguin_swimming.jpg',
      '$_base/penguin_swimming_side.jpg',
    ],
    9: ['$_base/waved_albatross_face_closeup.jpg'],
    21: [
      '$_base/flamingo_closeup_2.jpg',
      '$_base/flamingo_in_water.jpg',
      '$_base/flamingo_in_water_2.jpeg',
    ],
    22: [
      '$_base/flightless_cormorant_cliff.jpeg',
      '$_base/flightless_cormorant_resting.jpeg',
    ],
    23: ['$_base/swallow_tailed_gull_nesting.jpeg'],
    25: [
      '$_base/galapagos_dove_feeding.jpeg',
      '$_base/galapagos_dove_walking.jpeg',
    ],
    28: ['$_base/brown_pelican_red_sand.jpeg'],
    30: [
      '$_base/lava_heron_juvenile.JPG',
      '$_base/lava_heron_on_rocks.JPG',
      '$_base/lava_heron_with_prey.jpeg',
    ],
    36: ['$_base/golden_rays_school.jpeg'],
  };
}
