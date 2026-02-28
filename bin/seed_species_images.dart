/// Seeds species_images table from local asset files.
///
/// Uploads each asset image + its auto-generated thumbnail to Supabase Storage,
/// then inserts a species_images row.  The first image per species (hero or
/// thumbnail fallback) is marked is_primary=true so the DB trigger syncs
/// hero_image_url / thumbnail_url on the species row.
///
/// Usage:  dart run bin/seed_species_images.dart
library;

import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:supabase/supabase.dart';

// ── Supabase credentials (from .env) ───────────────────────────
const _supabaseUrl = 'https://vojbznerffkemxqlwapf.supabase.co';
const _serviceRoleKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvamJ6bmVyZmZrZW14cWx3YXBmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTc2NTk0OSwiZXhwIjoyMDg3MzQxOTQ5fQ.Edz8JhsevSfJ3rj-U8q2lg6mYOjnXrbh68O_4XpB72s';
const _bucket = 'species-images';

// ── Thumbnail settings ─────────────────────────────────────────
const _thumbWidth = 400;
const _thumbHeight = 225;
const _cardThumbSize = 400;

// ── Asset base paths ───────────────────────────────────────────
const _base = 'assets/images/species';
const _hero = 'assets/images/hero';

// ── Image data per species ─────────────────────────────────────
// For each species we list ALL unique images in display order.
// The first entry is treated as "primary" (hero).
// Paths are relative to the project root.

final _speciesImages = <int, List<String>>{
  // 1 - Marine Iguana
  1: [
    '$_base/marine_iguana_closeup.jpeg', // thumbnail → primary
    '$_base/marine_iguana_group.jpeg', // gallery
  ],
  // 2 - Land Iguana
  2: [
    '$_base/land_iguana_walking.jpg',
    '$_base/land_iguana_face_closeup.jpg',
  ],
  // 3 - Giant Tortoise
  3: [
    '$_hero/giant_tortoise_pair.jpg', // hero → primary
    '$_base/giant_tortoise_face_closeup.jpg', // thumbnail
  ],
  // 4 - Lava Lizard
  4: [
    '$_base/lava_lizard.jpg',
    '$_base/lava_lizard_red_closeup.jpg',
  ],
  // 5 - Blue-footed Booby
  5: [
    '$_base/blue_footed_booby_standing.jpg', // hero → primary
    '$_base/blue_footed_booby_preening.jpg', // thumbnail
    '$_base/blue_footed_booby_with_egg.JPG', // gallery
  ],
  // 6 - Nazca Booby
  6: [
    '$_base/nazca_booby_pair.jpg', // hero → primary
    '$_base/nazca_booby_with_chick.jpg', // thumbnail
    '$_base/nazca_booby_pair_closeup.jpg',
    '$_base/nazca_booby_adult_juvenile.jpg',
  ],
  // 7 - Magnificent Frigatebird
  7: [
    '$_base/frigatebird_males_display.jpeg', // hero → primary
    '$_base/frigatebird_red_pouch_nest.jpeg', // thumbnail
    '$_base/frigatebird_female_perched.jpeg',
  ],
  // 8 - Galapagos Penguin
  8: [
    '$_base/penguin_swimming.jpg', // hero → primary
    '$_base/penguin_pair_rocks.jpg', // thumbnail
    '$_base/penguin_swimming_side.jpg',
  ],
  // 9 - Waved Albatross
  9: [
    '$_base/waved_albatross_face_closeup.jpg', // hero → primary
    '$_base/waved_albatross_nesting.jpg', // thumbnail
  ],
  // 11 - Darwin's Finch
  11: [
    '$_base/darwins_finch.jpg',
  ],
  // 12 - Galapagos Sea Lion
  12: [
    '$_hero/sea_lion_beach.jpg', // hero → primary
    '$_base/sea_lion_pup_rocks.jpg', // thumbnail
  ],
  // 18 - Galapagos Racer Snake
  18: [
    '$_base/galapagos_racer_snake.jpg',
  ],
  // 20 - Red-footed Booby
  20: [
    '$_base/red_footed_booby_nesting.jpeg',
  ],
  // 21 - American Flamingo
  21: [
    '$_hero/flamingo_lagoon.jpg', // hero → primary
    '$_base/flamingo_closeup.jpg', // thumbnail
    '$_base/flamingo_closeup_2.jpg',
    '$_base/flamingo_in_water.jpg',
    '$_base/flamingo_in_water_2.jpeg',
  ],
  // 22 - Flightless Cormorant
  22: [
    '$_base/flightless_cormorant_swimming.jpeg', // thumbnail → primary
    '$_base/flightless_cormorant_cliff.jpeg',
    '$_base/flightless_cormorant_resting.jpeg',
  ],
  // 23 - Swallow-tailed Gull
  23: [
    '$_base/swallow_tailed_gull_standing.jpeg',
    '$_base/swallow_tailed_gull_nesting.jpeg',
  ],
  // 25 - Galapagos Dove
  25: [
    '$_base/galapagos_dove_perched.jpeg',
    '$_base/galapagos_dove_feeding.jpeg',
    '$_base/galapagos_dove_walking.jpeg',
  ],
  // 28 - Brown Pelican
  28: [
    '$_base/brown_pelican_fishing.jpeg',
    '$_base/brown_pelican_red_sand.jpeg',
  ],
  // 29 - Great Blue Heron
  29: [
    '$_hero/great_blue_heron_coast.jpg',
  ],
  // 30 - Lava Heron
  30: [
    '$_base/lava_heron_on_rocks.JPG', // hero → primary
    '$_base/lava_heron_on_branch.jpeg', // thumbnail
    '$_base/lava_heron_juvenile.JPG',
    '$_base/lava_heron_with_prey.jpeg',
  ],
  // 36 - Spotted Eagle Ray
  36: [
    '$_base/eagle_rays_group_underwater.jpeg',
    '$_base/golden_rays_school.jpeg',
  ],

  // === Downloaded from Wikimedia Commons (16:9, 1280x720) ===

  // Reptiles - Tortoises
  10: ['$_base/galapagos_hawk.jpg'],
  17: ['$_base/pink_land_iguana.jpg'],
  43: ['$_base/san_cristobal_tortoise.jpg'],
  44: ['$_base/espanola_tortoise.jpg'],
  45: ['$_base/alcedo_tortoise.jpg'],
  46: ['$_base/wolf_volcano_tortoise.jpg'],
  47: ['$_base/santiago_tortoise.jpg'],
  48: ['$_base/pinzon_tortoise.jpg'],
  49: ['$_base/sierra_negra_tortoise.jpg'],
  50: ['$_base/eastern_santa_cruz_tortoise.jpg'],
  51: ['$_base/fernandina_tortoise.jpg'],
  52: ['$_base/lonesome_george.jpg'],
  53: ['$_base/darwin_volcano_tortoise.jpg'],
  54: ['$_base/cerro_azul_tortoise.jpg'],
  89: ['$_base/floreana_tortoise.jpg'],
  90: ['$_base/santa_fe_tortoise.jpg'],

  // Reptiles - Iguanas
  55: ['$_base/santa_fe_land_iguana.jpg'],

  // Reptiles - Snakes
  56: ['$_base/central_galapagos_racer.jpg'],
  57: ['$_base/western_galapagos_racer.jpg'],
  58: ['$_base/espanola_racer.jpg'],
  59: ['$_base/striped_galapagos_snake.jpg'],
  60: ['$_base/yellow_bellied_sea_snake.jpg'],
  106: ['$_base/pinzon_racer.jpg'],
  107: ['$_base/santiago_racer.jpg'],
  109: ['$_base/tortuga_island_racer.jpg'],
  110: ['$_base/thomas_racer.jpg'],

  // Sea Turtles
  14: ['$_base/green_sea_turtle.jpg'],
  19: ['$_base/hawksbill_sea_turtle.jpg'],
  61: ['$_base/loggerhead_sea_turtle.jpg'],
  62: ['$_base/olive_ridley_turtle.jpg'],
  63: ['$_base/leatherback_turtle.jpg'],

  // Birds - Raptors & Owls
  24: ['$_base/galapagos_short_eared_owl.jpg'],
  115: ['$_base/galapagos_barn_owl.jpg'],

  // Birds - Seabirds
  31: ['$_base/great_frigatebird.jpg'],
  79: ['$_base/galapagos_petrel.jpg'],
  114: ['$_base/galapagos_shearwater.jpg'],
  116: ['$_base/wedge_rumped_storm_petrel.jpg'],

  // Birds - Songbirds & Passerines
  26: ['$_base/galapagos_yellow_warbler.jpg'],
  27: ['$_base/galapagos_mockingbird.jpg'],
  75: ['$_base/espanola_mockingbird.jpg'],
  76: ['$_base/floreana_mockingbird.jpg'],
  104: ['$_base/san_cristobal_mockingbird.jpg'],
  77: ['$_base/galapagos_flycatcher.jpg'],
  78: ['$_base/galapagos_vermilion_flycatcher.jpg'],
  80: ['$_base/galapagos_martin.jpg'],

  // Birds - Darwin's Finches
  64: ['$_base/small_ground_finch.jpg'],
  65: ['$_base/large_ground_finch.jpg'],
  66: ['$_base/common_cactus_finch.jpg'],
  67: ['$_base/large_cactus_finch.jpg'],
  68: ['$_base/woodpecker_finch.jpg'],
  69: ['$_base/small_tree_finch.jpg'],
  70: ['$_base/vegetarian_finch.jpg'],
  71: ['$_base/green_warbler_finch.jpg'],
  72: ['$_base/mangrove_finch.jpg'],
  92: ['$_base/sharp_beaked_ground_finch.jpg'],
  93: ['$_base/vampire_ground_finch.jpg'],
  94: ['$_base/genovesa_ground_finch.jpg'],
  95: ['$_base/genovesa_cactus_finch.jpg'],
  96: ['$_base/medium_tree_finch.jpg'],
  97: ['$_base/large_tree_finch.jpg'],
  98: ['$_base/grey_warbler_finch.jpg'],
  99: ['$_base/cocos_finch.jpg'],

  // Birds - Other
  73: ['$_base/galapagos_rail.jpg'],
  74: ['$_base/lava_gull.jpg'],
  111: ['$_base/white_cheeked_pintail.jpg'],
  112: ['$_base/yellow_crowned_night_heron.jpg'],
  113: ['$_base/galapagos_oystercatcher.jpg'],

  // Mammals
  13: ['$_base/galapagos_fur_seal.jpg'],
  32: ['$_base/galapagos_rice_rat.jpg'],
  33: ['$_base/galapagos_red_bat.jpg'],
  34: ['$_base/galapagos_hoary_bat.jpg'],
  81: ['$_base/bottlenose_dolphin.jpg'],
  82: ['$_base/humpback_whale.jpg'],
  83: ['$_base/orca.jpg'],
  108: ['$_base/sperm_whale.jpg'],

  // Marine Life
  15: ['$_base/galapagos_shark.jpg'],
  16: ['$_base/scalloped_hammerhead.jpg'],
  35: ['$_base/giant_manta_ray.jpg'],
  37: ['$_base/whale_shark.jpg'],
  38: ['$_base/pacific_seahorse.jpg'],
  39: ['$_base/galapagos_reef_octopus.jpg'],
  40: ['$_base/whitetip_reef_shark.jpg'],
  84: ['$_base/ocean_sunfish.jpg'],
  85: ['$_base/porcupinefish.jpg'],

  // Invertebrates
  41: ['$_base/sally_lightfoot_crab.jpg'],
  42: ['$_base/galapagos_painted_locust.jpg'],
  86: ['$_base/galapagos_spiny_lobster.jpg'],
  87: ['$_base/black_sea_cucumber.jpg'],
  88: ['$_base/white_sea_urchin.jpg'],
};

// ── Helpers ────────────────────────────────────────────────────

Uint8List _generateThumbnail(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Failed to decode image');
  final thumb = img.copyResize(decoded,
      width: _thumbWidth, height: _thumbHeight, maintainAspect: true);
  return Uint8List.fromList(img.encodeJpg(thumb, quality: 80));
}

/// Center-crop to 1:1, then resize to 400x400 for card thumbnails.
Uint8List _generateCardThumbnail(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Failed to decode image');
  final side = decoded.height < decoded.width ? decoded.height : decoded.width;
  final x = (decoded.width - side) ~/ 2;
  final y = (decoded.height - side) ~/ 2;
  final cropped = img.copyCrop(decoded, x: x, y: y, width: side, height: side);
  final thumb = img.copyResize(cropped, width: _cardThumbSize, height: _cardThumbSize);
  return Uint8List.fromList(img.encodeJpg(thumb, quality: 80));
}

String _fileName(String path) => path.split('/').last.toLowerCase().replaceAll(' ', '_');

// ── Main ───────────────────────────────────────────────────────

Future<void> main() async {
  final client = SupabaseClient(_supabaseUrl, _serviceRoleKey);

  // First, clear existing species_images to avoid duplicates
  print('Clearing existing species_images rows...');
  for (final speciesId in _speciesImages.keys) {
    await client.from('species_images').delete().eq('species_id', speciesId);
  }
  print('Done.\n');

  var totalUploaded = 0;

  for (final entry in _speciesImages.entries) {
    final speciesId = entry.key;
    final imagePaths = entry.value;

    print('Species $speciesId: ${imagePaths.length} image(s)');

    for (var i = 0; i < imagePaths.length; i++) {
      final assetPath = imagePaths[i];
      final file = File(assetPath);

      if (!file.existsSync()) {
        print('  ⚠ SKIP: $assetPath (file not found)');
        continue;
      }

      final bytes = file.readAsBytesSync();
      final name = _fileName(assetPath);
      final storagePath = '$speciesId/gallery_${i}_$name';
      final thumbPath = '$speciesId/thumb_${i}_$name';

      // Upload full image
      print('  ↑ $storagePath (${(bytes.length / 1024).toStringAsFixed(0)} KB)');
      await client.storage.from(_bucket).uploadBinary(
            storagePath,
            bytes,
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
      final imageUrl = client.storage.from(_bucket).getPublicUrl(storagePath);

      // Generate & upload gallery thumbnail (16:9)
      final thumbBytes = _generateThumbnail(bytes);
      print('  ↑ $thumbPath (${(thumbBytes.length / 1024).toStringAsFixed(0)} KB)');
      await client.storage.from(_bucket).uploadBinary(
            thumbPath,
            thumbBytes,
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
      final thumbnailUrl = client.storage.from(_bucket).getPublicUrl(thumbPath);

      // For primary images, also generate a 1:1 card thumbnail (center crop)
      String? cardThumbnailUrl;
      if (i == 0) {
        final cardThumbBytes = _generateCardThumbnail(bytes);
        final cardThumbPath = '$speciesId/card_thumb_0_$name';
        print('  ↑ $cardThumbPath (${(cardThumbBytes.length / 1024).toStringAsFixed(0)} KB) [card 1:1]');
        await client.storage.from(_bucket).uploadBinary(
              cardThumbPath,
              cardThumbBytes,
              fileOptions:
                  const FileOptions(contentType: 'image/jpeg', upsert: true),
            );
        cardThumbnailUrl = client.storage.from(_bucket).getPublicUrl(cardThumbPath);
      }

      // Insert record
      await client.from('species_images').insert({
        'species_id': speciesId,
        'image_url': imageUrl,
        'thumbnail_url': thumbnailUrl,
        if (cardThumbnailUrl != null) 'card_thumbnail_url': cardThumbnailUrl,
        'sort_order': i,
        'is_primary': i == 0, // first image is primary
      });

      totalUploaded++;
    }
    print('');
  }

  print('✓ Seeded $totalUploaded images for ${_speciesImages.length} species.');
  print('  The DB trigger has auto-synced hero_image_url & thumbnail_url on each species.');
  client.dispose();
}
