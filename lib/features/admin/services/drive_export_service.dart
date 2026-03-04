import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Google Drive folder that receives training exports.
/// https://drive.google.com/drive/folders/15YRj9vFy-HEmnyqljR7SMFAMO6qVu6M4
const _kTargetFolderId = '15YRj9vFy-HEmnyqljR7SMFAMO6qVu6M4';

class DriveExportService {
  static final DriveExportService _instance = DriveExportService._();
  factory DriveExportService() => _instance;
  DriveExportService._();

  final _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  bool get isSignedIn => _googleSignIn.currentUser != null;
  String? get userEmail => _googleSignIn.currentUser?.email;

  /// Attempts silent sign-in on startup; non-blocking.
  Future<void> tryRestoreSession() async {
    try {
      await _googleSignIn.signInSilently();
    } catch (_) {}
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
  }

  // ── Private Drive API helpers ───────────────────────────────────────────────

  Future<Map<String, String>> _headers() async {
    final h = await _googleSignIn.currentUser!.authHeaders;
    return Map<String, String>.from(h);
  }

  Future<String> _createFolder(
    Map<String, String> headers,
    String name,
    String parentId,
  ) async {
    final resp = await http.post(
      Uri.parse('https://www.googleapis.com/drive/v3/files'),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'mimeType': 'application/vnd.google-apps.folder',
        'parents': [parentId],
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error creando carpeta Drive: ${resp.statusCode} ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['id'] as String;
  }

  Future<void> _uploadFile(
    Map<String, String> headers,
    String filename,
    Uint8List bytes,
    String mimeType,
    String parentId,
  ) async {
    const boundary = 'galwildlife_export_boundary';
    final metaJson = jsonEncode({'name': filename, 'parents': [parentId]});

    final bodyBytes = Uint8List.fromList([
      ...utf8.encode('--$boundary\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n'),
      ...utf8.encode(metaJson),
      ...utf8.encode('\r\n--$boundary\r\nContent-Type: $mimeType\r\n\r\n'),
      ...bytes,
      ...utf8.encode('\r\n--$boundary--'),
    ]);

    final resp = await http.post(
      Uri.parse(
          'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart'),
      headers: {
        ...headers,
        'Content-Type': 'multipart/related; boundary=$boundary',
        'Content-Length': '${bodyBytes.length}',
      },
      body: bodyBytes,
    );
    if (resp.statusCode != 200) {
      throw Exception(
          'Error subiendo $filename: ${resp.statusCode} ${resp.body}');
    }
  }

  // ── Public export ───────────────────────────────────────────────────────────

  /// Streams progress messages. Last message is 'DONE' or starts with 'ERROR:'.
  Stream<String> exportTrainingData() async* {
    try {
      final headers = await _headers();

      // Create timestamped export folder
      final now = DateTime.now();
      final folderName =
          'galapagos_training_${now.year}${_p2(now.month)}${_p2(now.day)}'
          '_${_p2(now.hour)}${_p2(now.minute)}';

      yield 'Creando carpeta "$folderName"…';
      final exportFolderId =
          await _createFolder(headers, folderName, _kTargetFolderId);
      yield '📁 Carpeta creada';

      // Fetch feedback records with species names
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
      yield '${records.length} registros (${records.where((r) => !((r['is_correction'] as bool?) ?? false)).length} confirmados, '
          '${records.where((r) => (r['is_correction'] as bool?) ?? false).length} correcciones, '
          '$withPhoto con foto)';

      // Upload metadata.json
      yield 'Subiendo metadata.json…';
      final metaList = records.map((r) {
        final predicted = r['predicted'] as Map? ?? {};
        final correct = r['correct'] as Map? ?? {};
        return {
          'id': r['id'],
          'created_at': r['created_at'],
          'predicted_species_es': predicted['common_name_es'],
          'predicted_scientific': predicted['scientific_name'],
          'correct_species_es': correct['common_name_es'],
          'correct_scientific': correct['scientific_name'],
          'confidence': r['predicted_confidence'],
          'is_correction': r['is_correction'],
          'user_selected_rank': r['user_selected_rank'],
          'lat': r['lat'],
          'lng': r['lng'],
          'photo_url': r['photo_url'],
          'is_curator_validated': r['is_curator_validated'],
        };
      }).toList();

      await _uploadFile(
        headers,
        'metadata.json',
        Uint8List.fromList(
            utf8.encode(const JsonEncoder.withIndent('  ').convert(metaList))),
        'application/json',
        exportFolderId,
      );
      yield '✓ metadata.json';

      // Upload images
      int uploaded = 0;
      int skipped = 0;
      int failed = 0;
      final client = http.Client();

      try {
        for (final r in records) {
          final photoUrl = r['photo_url'] as String?;
          if (photoUrl == null) {
            skipped++;
            continue;
          }

          final id = r['id'];
          final isCorr = (r['is_correction'] as bool?) ?? false;
          final correct =
              (r['correct'] as Map?)?['common_name_es'] as String? ?? 'unknown';
          final conf =
              ((r['predicted_confidence'] as double?) ?? 0.0) * 100;
          final tag = isCorr ? 'corr' : 'ok';
          final slug = correct
              .toLowerCase()
              .replaceAll(' ', '_')
              .replaceAll(RegExp(r'[^a-z0-9_]'), '');
          final filename =
              '${id}_${tag}_${slug}_${conf.toStringAsFixed(0)}pct.jpg';

          try {
            final imgResp = await client.get(Uri.parse(photoUrl));
            if (imgResp.statusCode == 200) {
              await _uploadFile(
                  headers, filename, imgResp.bodyBytes, 'image/jpeg',
                  exportFolderId);
              uploaded++;
              yield '✓ $filename';
            } else {
              failed++;
              yield '⚠️ #$id HTTP ${imgResp.statusCode}';
            }
          } catch (e) {
            failed++;
            yield '⚠️ #$id error: $e';
          }
        }
      } finally {
        client.close();
      }

      yield '─────────────────────────────';
      yield '✅ Exportación completa\n'
          '   $uploaded imágenes subidas\n'
          '   $skipped sin foto\n'
          '   $failed errores\n'
          '   Carpeta: $folderName';
      yield 'DONE';
    } catch (e, st) {
      debugPrint('DriveExportService error: $e\n$st');
      yield 'ERROR: $e';
    }
  }

  static String _p2(int n) => n.toString().padLeft(2, '0');
}
