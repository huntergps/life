import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/constants/supabase_constants.dart';

/// Saves user corrections / confirmations of AI species recognition.
///
/// Every record in [species_recognition_feedback] becomes a potential
/// training example for retraining the TFLite classifier:
///
///   is_correction = false  →  confirmed positive (AI was right)
///   is_correction = true   →  hard negative for predicted_species_id
///                              + hard positive for correct_species_id
///
/// Photos are uploaded to [feedback-photos] bucket using SHA-256 hash as
/// filename, so the same photo uploaded multiple times only costs one upload.
class RecognitionFeedbackService {
  static final _db = Supabase.instance.client;

  // ── Photo upload ──────────────────────────────────────────────────────────

  /// Uploads [bytes] to the feedback-photos bucket and returns its public URL.
  ///
  /// Uses SHA-256 content hash as the filename → duplicate photos (same bytes)
  /// map to the same path and are silently overwritten (no extra storage cost).
  ///
  /// Returns null if:
  ///  - user is not authenticated (RLS requires {userId}/ prefix)
  ///  - upload fails for any reason (non-blocking)
  static Future<String?> uploadFeedbackPhoto(Uint8List bytes) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return null; // RLS needs an authenticated user

    try {
      final hash     = sha256.convert(bytes).toString();
      final path     = '$userId/$hash.jpg';
      final bucket   = _db.storage.from(SupabaseConstants.feedbackPhotosBucket);

      // upsert:true → same content = same hash = no-op overwrite; no error on duplicate
      await bucket.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );

      return bucket.getPublicUrl(path);
    } catch (_) {
      return null; // never block the feedback save
    }
  }

  // ── Feedback record ───────────────────────────────────────────────────────

  /// Called when the user taps "Register" on any suggestion tile.
  ///
  /// [predictedSpeciesId]  — top-1 species the AI returned (may be null if model unavailable)
  /// [predictedConfidence] — confidence score of the top-1 prediction
  /// [correctSpeciesId]    — species the user confirmed / selected
  /// [userSelectedRank]    — 1 = user confirmed top match, 2-5 = picked alternative, 0 = manual search
  /// [photoUrl]            — URL of the uploaded feedback / sighting photo (may be null)
  static Future<void> save({
    required int? predictedSpeciesId,
    required double predictedConfidence,
    required int correctSpeciesId,
    required int userSelectedRank,
    String? photoUrl,
    double? lat,
    double? lng,
  }) async {
    try {
      final userId = _db.auth.currentUser?.id;
      final isCorrection = predictedSpeciesId != null &&
          predictedSpeciesId != correctSpeciesId;

      await _db.from('species_recognition_feedback').insert({
        'user_id':              userId,
        'photo_url':            photoUrl,
        'predicted_species_id': predictedSpeciesId,
        'predicted_confidence': predictedConfidence,
        'correct_species_id':   correctSpeciesId,
        'is_correction':        isCorrection,
        'user_selected_rank':   userSelectedRank,
        'lat':                  lat,
        'lng':                  lng,
      });
    } catch (_) {
      // Non-critical — never block sighting registration
    }
  }
}
