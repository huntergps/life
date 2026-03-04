import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrainingExportService {
  static final TrainingExportService _instance = TrainingExportService._();
  factory TrainingExportService() => _instance;
  TrainingExportService._();

  /// Returns count of validated records newer than [since] (null = all).
  Future<int> countPendingExport(DateTime? since) async {
    var q = Supabase.instance.client
        .from('species_recognition_feedback')
        .select('id')
        .eq('is_curator_validated', true);
    if (since != null) q = q.gt('curator_validated_at', since.toIso8601String());
    final rows = await q;
    return (rows as List).length;
  }

  /// Streams progress. Last message is 'DONE' or starts with 'ERROR:'.
  /// [since] = only export records validated after this date (null = all validated).
  Stream<String> exportAsZip({DateTime? since}) async* {
    try {
      yield since != null
          ? 'Descargando registros validados desde ${_fmtDate(since)}…'
          : 'Descargando todos los registros validados por curador…';

      final db = Supabase.instance.client;
      var q = db
          .from('species_recognition_feedback')
          .select(
              'id, created_at, curator_validated_at, photo_url, '
              'predicted_confidence, is_correction, user_selected_rank, '
              'lat, lng, curator_notes, '
              'predicted:species!predicted_species_id(common_name_es, scientific_name), '
              'correct:species!correct_species_id(common_name_es, scientific_name)')
          .eq('is_curator_validated', true);

      if (since != null) {
        q = q.gt('curator_validated_at', since.toIso8601String());
      }

      final raw = await q.order('curator_validated_at');
      final records = List<Map<String, dynamic>>.from(raw);

      if (records.isEmpty) {
        yield 'ERROR: No hay registros validados${since != null ? ' desde ${_fmtDate(since)}' : ''}.\nValida registros como curador primero.';
        return;
      }

      final withPhoto = records.where((r) => r['photo_url'] != null).length;
      yield '${records.length} registros validados '
          '(${records.where((r) => !((r['is_correction'] as bool?) ?? false)).length} ✓ confirmados, '
          '${records.where((r) => (r['is_correction'] as bool?) ?? false).length} correcciones, '
          '$withPhoto con foto)';

      // Build ZIP
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
          'curator_validated_at': r['curator_validated_at'],
          'curator_notes': r['curator_notes'],
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
        };
      }).toList();

      final jsonBytes =
          utf8.encode(const JsonEncoder.withIndent('  ').convert(metaList));
      archive.addFile(ArchiveFile('metadata.json', jsonBytes.length, jsonBytes));

      // metadata.csv
      final csvHeader = 'id,created_at,curator_validated_at,'
          'correct_species_es,correct_scientific,predicted_species_es,'
          'confidence,is_correction,user_selected_rank,lat,lng,photo_filename';
      final csvLines = [csvHeader];
      for (final r in records) {
        final pred = r['predicted'] as Map? ?? {};
        final corr = r['correct'] as Map? ?? {};
        csvLines.add([
          r['id'],
          r['created_at'],
          r['curator_validated_at'] ?? '',
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

      // Download images
      yield 'Descargando $withPhoto imágenes…';
      int downloaded = 0, failed = 0;
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

      // Write ZIP
      yield 'Comprimiendo ZIP…';
      final now = DateTime.now();
      final suffix = since != null
          ? 'desde_${since.year}${_p2(since.month)}${_p2(since.day)}'
          : 'completo';
      final zipName =
          'galapagos_training_${suffix}_${now.year}${_p2(now.month)}${_p2(now.day)}'
          '_${_p2(now.hour)}${_p2(now.minute)}.zip';

      final tmpDir = await getTemporaryDirectory();
      final zipPath = '${tmpDir.path}/$zipName';
      final zipBytes = encoder.encode(archive);
      await File(zipPath).writeAsBytes(zipBytes);

      final sizeMb = (zipBytes.length / 1024 / 1024).toStringAsFixed(1);
      yield '─────────────────────────────';
      yield '📦 $zipName ($sizeMb MB)\n'
          '   $downloaded imágenes + metadata.json/csv'
          '${failed > 0 ? '\n   ⚠️ $failed fallos' : ''}';

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
    final corr =
        (r['correct'] as Map?)?['common_name_es'] as String? ?? 'unknown';
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
    if (s.contains(',') || s.contains('"')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${_p2(d.month)}-${_p2(d.day)}';
  static String _p2(int n) => n.toString().padLeft(2, '0');
}
