/// Fixes the 10 spider species that lack images by using genus/family-level
/// representative photos from iNaturalist.
///
/// Mapping:
///   Hogna species (119,121,122,123) → Hogna galapagoensis photo (Galápagos wolf spider)
///   Metagonia species (129,130,131) → Metagonia genus photo
///   Galapa species (132,133,134)    → Oonopidae family photo (goblin spiders)
///
/// Each image is downloaded, cropped to 16:9 (hero 1280x720, thumb 400x225),
/// plus a 400x400 square card, then uploaded to Supabase Storage.
library;

import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

// ── Credentials ─────────────────────────────────────────────────
const _supabaseUrl = 'https://vojbznerffkemxqlwapf.supabase.co';
const _serviceRoleKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvamJ6bmVyZmZrZW14cWx3YXBmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTc2NTk0OSwiZXhwIjoyMDg3MzQxOTQ5fQ.Edz8JhsevSfJ3rj-U8q2lg6mYOjnXrbh68O_4XpB72s';
const _bucket = 'species-images';

// ── Image dimensions ─────────────────────────────────────────────
const _heroW = 1280, _heroH = 720;
const _thumbW = 400, _thumbH = 225;

// ── Genus/family representative photo URLs ──────────────────────
// Hogna galapagoensis — Galápagos wolf spider (best match for Hogna spp.)
const _hognaPhotoUrl =
    'https://static.inaturalist.org/photos/33044624/original.jpeg';
// Metagonia genus — cave spider representative
const _metagoniaPhotoUrl =
    'https://static.inaturalist.org/photos/235422735/original.jpg';
// Oonopidae family — goblin spider representative (for Galapa genus)
const _oonopidaePhotoUrl =
    'https://inaturalist-open-data.s3.amazonaws.com/photos/352358423/medium.jpg';

// ── Species → photo URL mapping ─────────────────────────────────
const _speciesPhotoMap = <int, String>{
  119: _hognaPhotoUrl,     // Dune wolf spider (Hogna snodgrassi)
  121: _hognaPhotoUrl,     // Transition zone wolf spider (Hogna junco)
  122: _hognaPhotoUrl,     // Española wolf spider (Hogna española)
  123: _hognaPhotoUrl,     // Humid pampa wolf spider (Hogna hendrickxi)
  129: _metagoniaPhotoUrl, // Bellavista cave spider (Metagonia bellavista)
  130: _metagoniaPhotoUrl, // Isabela cave spider (Metagonia reederi)
  131: _metagoniaPhotoUrl, // Blind cave spider (Metagonia zatoichi)
  132: _oonopidaePhotoUrl, // Baert's Galapa spider (Galapa baerti)
  133: _oonopidaePhotoUrl, // Beautiful Galapa spider (Galapa bella)
  134: _oonopidaePhotoUrl, // Floreana Galapa spider (Galapa floreana)
};

// ── Image processing ─────────────────────────────────────────────

Uint8List _crop16x9(Uint8List bytes, int w, int h) {
  final decoded = img.decodeImage(bytes)!;
  final srcRatio = decoded.width / decoded.height;
  const tgt = 16.0 / 9.0;
  int cW, cH, cX, cY;
  if (srcRatio > tgt) {
    cH = decoded.height;
    cW = (cH * tgt).round();
    cX = (decoded.width - cW) ~/ 2;
    cY = 0;
  } else {
    cW = decoded.width;
    cH = (cW / tgt).round();
    cX = 0;
    cY = (decoded.height - cH) ~/ 2;
  }
  final cropped = img.copyCrop(decoded, x: cX, y: cY, width: cW, height: cH);
  final resized = img.copyResize(cropped, width: w, height: h);
  return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
}

Uint8List _cropSquare(Uint8List bytes, int size) {
  final decoded = img.decodeImage(bytes)!;
  final side = decoded.height < decoded.width ? decoded.height : decoded.width;
  final x = (decoded.width - side) ~/ 2;
  final y = (decoded.height - side) ~/ 2;
  final cropped = img.copyCrop(decoded, x: x, y: y, width: side, height: side);
  final resized = img.copyResize(cropped, width: size, height: size);
  return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
}

// ── Download ─────────────────────────────────────────────────────

Future<Uint8List?> _download(String url) async {
  final client = http.Client();
  try {
    final resp = await client.get(
      Uri.parse(url),
      headers: {'User-Agent': 'GalapagosWildlifeApp/1.0 (educational project)'},
    );
    if (resp.statusCode == 200) return resp.bodyBytes;
    print('  ⚠ HTTP ${resp.statusCode} for $url');
    return null;
  } catch (e) {
    print('  ⚠ Download error: $e');
    return null;
  } finally {
    client.close();
  }
}

// ── Main ─────────────────────────────────────────────────────────

Future<void> main() async {
  final client = SupabaseClient(_supabaseUrl, _serviceRoleKey);

  // Fetch species info for the 10 missing species
  final ids = _speciesPhotoMap.keys.toList();
  final rows = await client
      .from('species')
      .select('id, common_name_en, scientific_name')
      .inFilter('id', ids)
      .order('id');
  final species = List<Map<String, dynamic>>.from(rows);
  print('Found ${species.length} species to fix\n');

  // Download and cache genus photos (avoid re-downloading the same image)
  final photoCache = <String, Uint8List>{};
  for (final url in _speciesPhotoMap.values.toSet()) {
    print('Downloading: ${url.substring(0, url.length.clamp(0, 80))}...');
    final bytes = await _download(url);
    if (bytes == null) {
      print('  FATAL: Could not download $url');
      client.dispose();
      return;
    }
    photoCache[url] = bytes;
    print('  OK (${bytes.length} bytes)\n');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  int ok = 0, failed = 0;

  for (final sp in species) {
    final id = sp['id'] as int;
    final name = sp['common_name_en'] as String;
    final sciName = sp['scientific_name'] as String;
    final photoUrl = _speciesPhotoMap[id]!;
    final bytes = photoCache[photoUrl]!;

    print('[#$id] $name ($sciName)');

    // Process images
    Uint8List hero, thumb, card;
    try {
      hero = _crop16x9(bytes, _heroW, _heroH);
      thumb = _crop16x9(bytes, _thumbW, _thumbH);
      card = _cropSquare(bytes, 400);
    } catch (e) {
      print('  ❌ Image processing failed: $e\n');
      failed++;
      continue;
    }

    // Upload to Supabase Storage
    final base = 'species/$id';
    try {
      await client.storage.from(_bucket).uploadBinary(
            '$base/hero.jpg',
            hero,
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
      await client.storage.from(_bucket).uploadBinary(
            '$base/thumb.jpg',
            thumb,
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
      await client.storage.from(_bucket).uploadBinary(
            '$base/card.jpg',
            card,
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
    } catch (e) {
      print('  ❌ Upload failed: $e\n');
      failed++;
      continue;
    }

    final heroUrl =
        '$_supabaseUrl/storage/v1/object/public/$_bucket/$base/hero.jpg';
    final thumbUrl =
        '$_supabaseUrl/storage/v1/object/public/$_bucket/$base/thumb.jpg';
    final cardUrl =
        '$_supabaseUrl/storage/v1/object/public/$_bucket/$base/card.jpg';

    // Insert species_images row
    try {
      await client
          .from('species_images')
          .delete()
          .eq('species_id', id)
          .eq('is_primary', true);
      await client.from('species_images').insert({
        'species_id': id,
        'image_url': heroUrl,
        'thumbnail_url': thumbUrl,
        'card_thumbnail_url': cardUrl,
        'is_primary': true,
        'sort_order': 0,
        'caption_en': '$name (genus representative)',
        'caption_es': '$name (representante del genero)',
      });
    } catch (e) {
      print('  ❌ DB insert failed: $e\n');
      failed++;
      continue;
    }

    // Update species.hero_image_url / thumbnail_url
    await client.from('species').update({
      'hero_image_url': heroUrl,
      'thumbnail_url': thumbUrl,
    }).eq('id', id);

    print('  ✅ Done\n');
    ok++;
  }

  print('═══════════════════════════════════════');
  print('✅ Success: $ok');
  print('❌ Failed:  $failed');
  print('📊 Total:   ${ok + failed}');
  print('═══════════════════════════════════════');

  client.dispose();
}
