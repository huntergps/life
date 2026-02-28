/// Fetches images from Wikimedia Commons for species missing images,
/// crops to 16:9, uploads to Supabase Storage, and inserts species_images rows.
///
/// Usage: dart run bin/fetch_wiki_images.dart [category_id]
///   category_id: 1=Reptiles, 2=Birds, 3=Mammals, 4=Marine, 5=Invertebrates
///   If omitted, processes ALL categories.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

// ── Supabase credentials ────────────────────────────────────────
const _supabaseUrl = 'https://pxkopudkwqysfdeprmke.supabase.co';
const _serviceRoleKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4a29wdWRrd3F5c2ZkZXBybWtlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MDc4ODI3MCwiZXhwIjoyMDg2MzY0MjcwfQ.HxzvQOADCEzon8Vg-AZfN1vEtyMxcQ-6jW__cq67x8I';
const _bucket = 'species-images';

// ── Image settings ──────────────────────────────────────────────
const _heroWidth = 1280;
const _heroHeight = 720;
const _thumbWidth = 400;
const _thumbHeight = 225;
const _cardThumbSize = 400;

// ── Wikimedia Commons API ───────────────────────────────────────

/// Search Wikimedia Commons for an image of the given species.
/// Returns the URL of the first suitable image, or null.
Future<String?> _findWikiImage(String scientificName) async {
  final client = http.Client();
  try {
    // Strategy 1: Search by scientific name in Wikimedia Commons
    final searchUrl = Uri.parse(
      'https://commons.wikimedia.org/w/api.php'
      '?action=query&list=search&srnamespace=6'
      '&srsearch=${Uri.encodeQueryComponent(scientificName)}'
      '&srqiprofile=natural&srlimit=5&format=json',
    );
    final searchResp = await client.get(searchUrl);
    if (searchResp.statusCode != 200) return null;

    final searchData = jsonDecode(searchResp.body) as Map<String, dynamic>;
    final results = (searchData['query']?['search'] as List?) ?? [];

    for (final result in results) {
      final title = result['title'] as String?;
      if (title == null) continue;
      // Skip SVG, PDF, OGG, WEBM
      if (title.toLowerCase().endsWith('.svg') ||
          title.toLowerCase().endsWith('.pdf') ||
          title.toLowerCase().endsWith('.ogg') ||
          title.toLowerCase().endsWith('.webm')) continue;

      // Get the actual image URL
      final infoUrl = Uri.parse(
        'https://commons.wikimedia.org/w/api.php'
        '?action=query&titles=${Uri.encodeQueryComponent(title)}'
        '&prop=imageinfo&iiprop=url|size|mime'
        '&iiurlwidth=1280&format=json',
      );
      final infoResp = await client.get(infoUrl);
      if (infoResp.statusCode != 200) continue;

      final infoData = jsonDecode(infoResp.body) as Map<String, dynamic>;
      final pages = infoData['query']?['pages'] as Map<String, dynamic>?;
      if (pages == null) continue;

      for (final page in pages.values) {
        final imageInfo = (page['imageinfo'] as List?)?.first;
        if (imageInfo == null) continue;
        final mime = imageInfo['mime'] as String? ?? '';
        if (!mime.startsWith('image/') || mime.contains('svg')) continue;
        final width = imageInfo['width'] as int? ?? 0;
        final height = imageInfo['height'] as int? ?? 0;
        if (width < 400 || height < 300) continue; // skip tiny images

        // Use thumburl if available (pre-scaled), else url
        final url = (imageInfo['thumburl'] as String?) ??
            (imageInfo['url'] as String?);
        if (url != null) return url;
      }
    }
    return null;
  } catch (e) {
    print('  ⚠ Wiki search error for "$scientificName": $e');
    return null;
  } finally {
    client.close();
  }
}

/// Download image bytes from URL.
Future<Uint8List?> _downloadImage(String url) async {
  final client = http.Client();
  try {
    final resp = await client.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'GalapagosWildlifeApp/1.0 (educational project)',
      },
    );
    if (resp.statusCode == 200) return resp.bodyBytes;
    print('  ⚠ Download failed: HTTP ${resp.statusCode}');
    return null;
  } catch (e) {
    print('  ⚠ Download error: $e');
    return null;
  } finally {
    client.close();
  }
}

// ── Image processing ────────────────────────────────────────────

/// Center-crop to 16:9 and resize to target dimensions.
Uint8List _cropTo16x9(Uint8List bytes, int targetW, int targetH) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Failed to decode image');

  final srcRatio = decoded.width / decoded.height;
  const targetRatio = 16.0 / 9.0;

  int cropW, cropH, cropX, cropY;
  if (srcRatio > targetRatio) {
    // Image is wider than 16:9 → crop sides
    cropH = decoded.height;
    cropW = (cropH * targetRatio).round();
    cropX = (decoded.width - cropW) ~/ 2;
    cropY = 0;
  } else {
    // Image is taller than 16:9 → crop top/bottom
    cropW = decoded.width;
    cropH = (cropW / targetRatio).round();
    cropX = 0;
    cropY = (decoded.height - cropH) ~/ 2;
  }

  final cropped =
      img.copyCrop(decoded, x: cropX, y: cropY, width: cropW, height: cropH);
  final resized = img.copyResize(cropped, width: targetW, height: targetH);
  return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
}

/// Center-crop to 1:1, then resize to square for card thumbnails.
Uint8List _cropToSquare(Uint8List bytes, int size) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Failed to decode image');
  final side =
      decoded.height < decoded.width ? decoded.height : decoded.width;
  final x = (decoded.width - side) ~/ 2;
  final y = (decoded.height - side) ~/ 2;
  final cropped =
      img.copyCrop(decoded, x: x, y: y, width: side, height: side);
  final thumb = img.copyResize(cropped, width: size, height: size);
  return Uint8List.fromList(img.encodeJpg(thumb, quality: 80));
}

// ── Main ────────────────────────────────────────────────────────

Future<void> main(List<String> args) async {
  final filterCategory = args.isNotEmpty ? int.tryParse(args.first) : null;
  final client = SupabaseClient(_supabaseUrl, _serviceRoleKey);

  // Fetch species missing images
  var query = client
      .from('species')
      .select('id, common_name_en, scientific_name, category_id')
      .isFilter('thumbnail_url', null)
      .order('category_id')
      .order('id');
  if (filterCategory != null) {
    query = client
        .from('species')
        .select('id, common_name_en, scientific_name, category_id')
        .isFilter('thumbnail_url', null)
        .eq('category_id', filterCategory)
        .order('id');
  }
  final rows = await query;
  final species = List<Map<String, dynamic>>.from(rows);

  final cats = {1: 'Reptiles', 2: 'Birds', 3: 'Mammals', 4: 'Marine', 5: 'Invertebrates'};
  print('Found ${species.length} species missing images'
      '${filterCategory != null ? " (category: ${cats[filterCategory]})" : ""}');
  print('');

  var processed = 0;
  var failed = 0;

  for (final s in species) {
    final id = s['id'] as int;
    final name = s['common_name_en'] as String;
    final sciName = s['scientific_name'] as String;
    final catId = s['category_id'] as int;

    print('[$id] $name ($sciName) [${cats[catId]}]');

    // 1. Find image on Wikimedia Commons
    print('  🔍 Searching Wikimedia Commons...');
    final imageUrl = await _findWikiImage(sciName);
    if (imageUrl == null) {
      print('  ❌ No image found');
      failed++;
      continue;
    }
    print('  ✓ Found: ${imageUrl.length > 80 ? '${imageUrl.substring(0, 80)}...' : imageUrl}');

    // 2. Download
    print('  ⬇ Downloading...');
    final rawBytes = await _downloadImage(imageUrl);
    if (rawBytes == null) {
      failed++;
      continue;
    }
    print('  ✓ Downloaded ${(rawBytes.length / 1024).toStringAsFixed(0)} KB');

    // 3. Process images
    print('  🔧 Processing (crop 16:9)...');
    Uint8List heroBytes;
    Uint8List thumbBytes;
    Uint8List cardThumbBytes;
    try {
      heroBytes = _cropTo16x9(rawBytes, _heroWidth, _heroHeight);
      thumbBytes = _cropTo16x9(rawBytes, _thumbWidth, _thumbHeight);
      cardThumbBytes = _cropToSquare(rawBytes, _cardThumbSize);
    } catch (e) {
      print('  ❌ Image processing failed: $e');
      failed++;
      continue;
    }

    // 4. Upload to Supabase Storage
    final baseName = sciName.toLowerCase().replaceAll(' ', '_').replaceAll('.', '');
    print('  ⬆ Uploading to storage...');
    try {
      // Hero (full 16:9)
      final heroPath = '$id/gallery_0_$baseName.jpg';
      await client.storage.from(_bucket).uploadBinary(
            heroPath,
            heroBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
      final heroUrl = client.storage.from(_bucket).getPublicUrl(heroPath);

      // Thumbnail (16:9 small)
      final thumbPath = '$id/thumb_0_$baseName.jpg';
      await client.storage.from(_bucket).uploadBinary(
            thumbPath,
            thumbBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
      final thumbUrl = client.storage.from(_bucket).getPublicUrl(thumbPath);

      // Card thumbnail (1:1)
      final cardPath = '$id/card_thumb_0_$baseName.jpg';
      await client.storage.from(_bucket).uploadBinary(
            cardPath,
            cardThumbBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
      final cardUrl = client.storage.from(_bucket).getPublicUrl(cardPath);

      // 5. Delete existing species_images for this species
      await client.from('species_images').delete().eq('species_id', id);

      // 6. Insert species_images row (triggers hero/thumb sync on species)
      await client.from('species_images').insert({
        'species_id': id,
        'image_url': heroUrl,
        'thumbnail_url': thumbUrl,
        'card_thumbnail_url': cardUrl,
        'sort_order': 0,
        'is_primary': true,
      });

      print('  ✅ Done! hero=${(heroBytes.length / 1024).toStringAsFixed(0)}KB, '
          'thumb=${(thumbBytes.length / 1024).toStringAsFixed(0)}KB');
      processed++;
    } catch (e) {
      print('  ❌ Upload/insert failed: $e');
      failed++;
    }

    // Small delay to avoid rate limiting
    await Future.delayed(const Duration(milliseconds: 500));
  }

  print('');
  print('═══════════════════════════════════════');
  print('✅ Processed: $processed');
  print('❌ Failed: $failed');
  print('📊 Total: ${species.length}');
  print('═══════════════════════════════════════');

  client.dispose();
}
