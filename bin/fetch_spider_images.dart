/// Fetches images for spider species (category_id=6) from iNaturalist API,
/// crops to 16:9, uploads to Supabase Storage, inserts species_images rows.
///
/// Strategy:
///   1. iNaturalist API by taxon_id (for species with inaturalist_taxon_id)
///   2. iNaturalist taxa search by exact scientific_name
///   3. iNaturalist research-grade observations by scientific_name
///   If none found → skip (no image inserted, species left blank)
library;

import 'dart:convert';
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

// ── iNaturalist ──────────────────────────────────────────────────

Future<String?> _inatPhotoByTaxonId(int taxonId) async {
  final client = http.Client();
  try {
    final url = Uri.parse(
      'https://api.inaturalist.org/v1/taxa/$taxonId'
      '?photo_license=cc-by,cc-by-sa,cc-by-nc,cc-by-nc-sa,cc0,pd',
    );
    final resp = await client.get(url, headers: {'Accept': 'application/json'});
    if (resp.statusCode != 200) return null;
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final results = data['results'] as List?;
    if (results == null || results.isEmpty) return null;
    final taxon = results.first as Map<String, dynamic>;
    // taxon_photos first
    final taxonPhotos = taxon['taxon_photos'] as List?;
    if (taxonPhotos != null && taxonPhotos.isNotEmpty) {
      final photo = (taxonPhotos.first as Map)['photo'] as Map?;
      if (photo != null) {
        final url = (photo['original_url'] as String?) ??
            (photo['large_url'] as String?) ??
            (photo['medium_url'] as String?);
        if (url != null) return url;
      }
    }
    // default_photo fallback
    final defaultPhoto = taxon['default_photo'] as Map<String, dynamic>?;
    return (defaultPhoto?['original_url'] as String?) ??
        (defaultPhoto?['large_url'] as String?);
  } catch (e) {
    print('  ⚠ iNat taxon $taxonId error: $e');
    return null;
  } finally {
    client.close();
  }
}

Future<String?> _inatPhotoByName(String scientificName) async {
  final client = http.Client();
  try {
    final url = Uri.parse(
      'https://api.inaturalist.org/v1/taxa'
      '?q=${Uri.encodeQueryComponent(scientificName)}'
      '&rank=species,subspecies'
      '&per_page=5'
      '&photo_license=cc-by,cc-by-sa,cc-by-nc,cc-by-nc-sa,cc0,pd',
    );
    final resp = await client.get(url, headers: {'Accept': 'application/json'});
    if (resp.statusCode != 200) return null;
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final results = data['results'] as List?;
    if (results == null || results.isEmpty) return null;
    // Verify the taxon name actually matches — genus must match at minimum
    final genus = scientificName.split(' ').first.toLowerCase();
    for (final result in results) {
      final taxon = result as Map<String, dynamic>;
      final taxonName = (taxon['name'] as String? ?? '').toLowerCase();
      if (!taxonName.startsWith(genus)) continue;
      final defaultPhoto = taxon['default_photo'] as Map<String, dynamic>?;
      final photoUrl = (defaultPhoto?['original_url'] as String?) ??
          (defaultPhoto?['large_url'] as String?) ??
          (defaultPhoto?['medium_url'] as String?);
      if (photoUrl != null) return photoUrl;
    }
    return null;
  } catch (e) {
    print('  ⚠ iNat name search "$scientificName" error: $e');
    return null;
  } finally {
    client.close();
  }
}

/// Search iNaturalist observations for a species — gets real field photos.
Future<String?> _inatObservationPhoto(String scientificName) async {
  final client = http.Client();
  try {
    final url = Uri.parse(
      'https://api.inaturalist.org/v1/observations'
      '?taxon_name=${Uri.encodeQueryComponent(scientificName)}'
      '&has[]=photos&quality_grade=research&per_page=5'
      '&photo_license=cc-by,cc-by-sa,cc-by-nc,cc-by-nc-sa,cc0,pd'
      '&order_by=votes',
    );
    final resp = await client.get(url, headers: {'Accept': 'application/json'});
    if (resp.statusCode != 200) return null;
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final results = data['results'] as List?;
    if (results == null || results.isEmpty) return null;
    // Verify taxon matches — genus must match at minimum
    final genus = scientificName.split(' ').first.toLowerCase();
    for (final obs in results) {
      final obsMap = obs as Map<String, dynamic>;
      final taxonName = ((obsMap['taxon'] as Map?)?['name'] as String? ?? '').toLowerCase();
      if (!taxonName.startsWith(genus)) continue;
      final photos = obsMap['photos'] as List?;
      if (photos == null || photos.isEmpty) continue;
      final photo = photos.first as Map<String, dynamic>;
      final urlStr = photo['url'] as String?;
      if (urlStr == null) continue;
      // iNat URLs: replace 'square' with 'original'
      return urlStr
          .replaceAll('/square.', '/original.')
          .replaceAll('/small.', '/original.')
          .replaceAll('/medium.', '/original.')
          .replaceAll('/large.', '/original.');
    }
    return null;
  } catch (e) {
    print('  ⚠ iNat obs "$scientificName" error: $e');
    return null;
  } finally {
    client.close();
  }
}

// ── Image processing ─────────────────────────────────────────────

Uint8List _crop16x9(Uint8List bytes, int w, int h) {
  final decoded = img.decodeImage(bytes)!;
  final srcRatio = decoded.width / decoded.height;
  const tgt = 16.0 / 9.0;
  int cW, cH, cX, cY;
  if (srcRatio > tgt) {
    cH = decoded.height; cW = (cH * tgt).round();
    cX = (decoded.width - cW) ~/ 2; cY = 0;
  } else {
    cW = decoded.width; cH = (cW / tgt).round();
    cX = 0; cY = (decoded.height - cH) ~/ 2;
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

Future<void> main(List<String> args) async {
  final client = SupabaseClient(_supabaseUrl, _serviceRoleKey);

  // Usage: dart run bin/fetch_spider_images.dart [id1 id2 ...]
  // If IDs provided → fetch only those species.
  // If no args → fetch ALL species with no thumbnail_url.
  late List<Map<String, dynamic>> species;
  if (args.isNotEmpty) {
    final ids = args.map(int.parse).toList();
    final rows = await client
        .from('species')
        .select('id, common_name_en, scientific_name, inaturalist_taxon_id')
        .inFilter('id', ids)
        .order('id');
    species = List<Map<String, dynamic>>.from(rows);
  } else {
    final rows = await client
        .from('species')
        .select('id, common_name_en, scientific_name, inaturalist_taxon_id')
        .isFilter('thumbnail_url', null)
        .order('id');
    species = List<Map<String, dynamic>>.from(rows);
  }
  print('Found ${species.length} species to process\n');

  int ok = 0, failed = 0;

  for (final sp in species) {
    final id = sp['id'] as int;
    final name = sp['common_name_en'] as String;
    final sciName = sp['scientific_name'] as String;
    final inatId = sp['inaturalist_taxon_id'] as int?;

    print('[#$id] $name ($sciName)');

    String? imageUrl;

    // 1. iNaturalist by taxon ID (most reliable)
    if (inatId != null) {
      print('  → iNaturalist taxon $inatId...');
      imageUrl = await _inatPhotoByTaxonId(inatId);
    }

    // 2. iNaturalist taxa search by exact scientific name
    if (imageUrl == null) {
      print('  → iNaturalist taxa search "$sciName"...');
      imageUrl = await _inatPhotoByName(sciName);
    }

    // 3. iNaturalist research-grade observations
    if (imageUrl == null) {
      print('  → iNaturalist observations "$sciName"...');
      imageUrl = await _inatObservationPhoto(sciName);
    }

    if (imageUrl == null) {
      print('  ❌ No image found\n');
      failed++;
      continue;
    }

    print('  ✓ Found: ${imageUrl.substring(0, imageUrl.length.clamp(0, 80))}');
    print('  ⬇ Downloading...');

    final bytes = await _download(imageUrl);
    if (bytes == null) {
      print('  ❌ Download failed\n');
      failed++;
      continue;
    }

    // Process images
    Uint8List hero, thumb, card;
    try {
      hero  = _crop16x9(bytes, _heroW, _heroH);
      thumb = _crop16x9(bytes, _thumbW, _thumbH);
      card  = _cropSquare(bytes, 400);
    } catch (e) {
      print('  ❌ Image processing failed: $e\n');
      failed++;
      continue;
    }

    // Upload to Supabase Storage
    final base = 'species/$id';
    try {
      await client.storage.from(_bucket).uploadBinary(
        '$base/hero.jpg', hero,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );
      await client.storage.from(_bucket).uploadBinary(
        '$base/thumb.jpg', thumb,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );
      await client.storage.from(_bucket).uploadBinary(
        '$base/card.jpg', card,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );
    } catch (e) {
      print('  ❌ Upload failed: $e\n');
      failed++;
      continue;
    }

    final heroUrl  = '$_supabaseUrl/storage/v1/object/public/$_bucket/$base/hero.jpg';
    final thumbUrl = '$_supabaseUrl/storage/v1/object/public/$_bucket/$base/thumb.jpg';
    final cardUrl  = '$_supabaseUrl/storage/v1/object/public/$_bucket/$base/card.jpg';

    // Insert species_images row (primary) — delete existing first to be idempotent
    try {
      await client.from('species_images')
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
        'caption_en': name,
        'caption_es': sp['common_name_en'] as String,
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

    await Future.delayed(const Duration(milliseconds: 300)); // be nice to APIs
  }

  print('═══════════════════════════════════════');
  print('✅ Success: $ok');
  print('❌ Failed:  $failed');
  print('📊 Total:   ${ok + failed}');
  print('═══════════════════════════════════════');

  client.dispose();
}
