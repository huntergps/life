import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class TrainingExportService {
  static final TrainingExportService _instance = TrainingExportService._();
  factory TrainingExportService() => _instance;
  TrainingExportService._();

  /// Streams progress messages; last message is 'DONE' or starts with 'ERROR:'.
  Stream<String> exportAsZip() async* {
    try {
      // 1. Fetch feedback records with species names
      yield 'Descargando registros de Supabase…';
      final db = Supabase.instance.client;
      final raw = await db
          .from('species_recognition_feedback')
          .select(
              'id, created_at, photo_url, predicted_confidence, is_correction, '
              'user_selected_rank, lat, lng, is_curator_validated, '
              'predicted:species!predicted_species_id(common_name_es, scientific_name), '
              'correct:species!correct_species_id(common_name_es, scientific_name)')
          .order('created_at');

      final records = List<Map<String, dynamic>>.from(raw);
      final withPhoto = records.where((r) => r['photo_url'] != null).length;
      yield '${records.length} registros (${records.where((r) => !((r['is_correction'] as bool?) ?? false)).length} ✓ '
          '+ ${records.where((r) => (r['is_correction'] as bool?) ?? false).length} correcciones, '
          '$withPhoto con foto)';

      // 2. Build ZIP in memory
      final encoder = ZipEncoder();
      final archive = Archive();

      // metadata.json
      yield 'Generando metadata.json…';
      final metaList = records.map((r) {
        final pred = r['predicted'] as Map? ?? {};
        final corr = r['correct'] as Map? ?? {};
        return {
          'id': r['id'],
          'created_at': r['created_at'],
          'predicted_species_es': pred['common_name_es'],
          'predicted_scientific': pred['scientific_name'],
          'correct_species_es': corr['common_name_es'],
          'correct_scientific': corr['scientific_name'],
          'confidence': r['predicted_confidence'],
          'is_correction': r['is_correction'],
          'user_selected_rank': r['user_selected_rank'],
          'lat': r['lat'],
          'lng': r['lng'],
          'photo_filename': _filename(r),
          'is_curator_validated': r['is_curator_validated'],
        };
      }).toList();

      final jsonBytes =
          utf8.encode(const JsonEncoder.withIndent('  ').convert(metaList));
      archive.addFile(ArchiveFile('metadata.json', jsonBytes.length, jsonBytes));

      // metadata.csv
      final csvLines = <String>[
        'id,created_at,correct_species_es,correct_scientific,predicted_species_es,'
            'confidence,is_correction,user_selected_rank,lat,lng,photo_filename',
      ];
      for (final r in records) {
        final pred = r['predicted'] as Map? ?? {};
        final corr = r['correct'] as Map? ?? {};
        csvLines.add([
          r['id'],
          r['created_at'],
          _csvEsc(corr['common_name_es']),
          _csvEsc(corr['scientific_name']),
          _csvEsc(pred['common_name_es']),
          r['predicted_confidence'],
          r['is_correction'],
          r['user_selected_rank'],
          r['lat'] ?? '',
          r['lng'] ?? '',
          _filename(r),
        ].join(','));
      }
      final csvBytes = utf8.encode(csvLines.join('\n'));
      archive.addFile(ArchiveFile('metadata.csv', csvBytes.length, csvBytes));

      // Download and add images
      yield 'Descargando imágenes…';
      int downloaded = 0;
      int failed = 0;
      final client = http.Client();
      try {
        for (final r in records) {
          final photoUrl = r['photo_url'] as String?;
          if (photoUrl == null) continue;
          try {
            final resp = await client.get(Uri.parse(photoUrl));
            if (resp.statusCode == 200) {
              final fname = 'images/${_filename(r)}';
              archive.addFile(
                  ArchiveFile(fname, resp.bodyBytes.length, resp.bodyBytes));
              downloaded++;
              yield '✓ ${_filename(r)}';
            } else {
              failed++;
              yield '⚠️ #${r['id']} HTTP ${resp.statusCode}';
            }
          } catch (e) {
            failed++;
            yield '⚠️ #${r['id']}: $e';
          }
        }
      } finally {
        client.close();
      }

      // 3. Write ZIP to temp file
      yield 'Comprimiendo ZIP…';
      final now = DateTime.now();
      final zipName =
          'galapagos_training_${now.year}${_p2(now.month)}${_p2(now.day)}'
          '_${_p2(now.hour)}${_p2(now.minute)}.zip';

      final tmpDir = await getTemporaryDirectory();
      final zipPath = '${tmpDir.path}/$zipName';
      final zipBytes = encoder.encode(archive);
      await File(zipPath).writeAsBytes(zipBytes);

      final sizeMb = (zipBytes.length / 1024 / 1024).toStringAsFixed(1);
      yield '─────────────────────────────';
      yield '📦 ZIP: $zipName (${sizeMb} MB)\n'
          '   $downloaded imágenes + metadata.json + metadata.csv'
          '${failed > 0 ? '\n   ⚠️ $failed fallos' : ''}';

      // 4. Share
      yield 'Abriendo menú compartir…';
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(zipPath)],
          subject: zipName,
          text: 'Galapagos Wildlife — training data export',
        ),
      );

      yield 'DONE';
    } catch (e, st) {
      debugPrint('TrainingExportService error: $e\n$st');
      yield 'ERROR: $e';
    }
  }

  static String _filename(Map<String, dynamic> r) {
    final id = r['id'];
    final isCorr = (r['is_correction'] as bool?) ?? false;
    final corr = (r['correct'] as Map?)?['common_name_es'] as String? ?? 'unknown';
    final conf = ((r['predicted_confidence'] as double?) ?? 0.0) * 100;
    final tag = isCorr ? 'corr' : 'ok';
    final slug = corr
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    return '${id}_${tag}_${slug}_${conf.toStringAsFixed(0)}pct.jpg';
  }

  static String _csvEsc(dynamic v) {
    if (v == null) return '';
    final s = v.toString();
    if (s.contains(',') || s.contains('"')) return '"${s.replaceAll('"', '""')}"';
    return s;
  }

  static String _p2(int n) => n.toString().padLeft(2, '0');
}
