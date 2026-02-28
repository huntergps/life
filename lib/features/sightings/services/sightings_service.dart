import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/constants/supabase_constants.dart';

class SightingsService {
  final SupabaseClient _client;

  SightingsService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<Map<String, dynamic>> createSighting({
    required int speciesId,
    required DateTime observedAt,
    String? notes,
    double? latitude,
    double? longitude,
    int? visitSiteId,
    String? photoUrl,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client.from('sightings').insert({
      'user_id': userId,
      'species_id': speciesId,
      'observed_at': observedAt.toUtc().toIso8601String(),
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'visit_site_id': visitSiteId,
      'photo_url': photoUrl,
    }).select().single();

    return response;
  }

  Future<void> deleteSighting(int id) async {
    await _client.from('sightings').delete().eq('id', id);
  }

  Future<String> uploadPhoto({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('Not authenticated');

    final path = '$userId/$fileName';
    await _client.storage
        .from(SupabaseConstants.sightingPhotosBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
    return _client.storage
        .from(SupabaseConstants.sightingPhotosBucket)
        .getPublicUrl(path);
  }

  Future<void> deletePhoto(String photoUrl) async {
    final uri = Uri.parse(photoUrl);
    final segments = uri.pathSegments;
    final bucketIdx = segments.indexOf(SupabaseConstants.sightingPhotosBucket);
    if (bucketIdx < 0) return;
    final path = segments.sublist(bucketIdx + 1).join('/');
    await _client.storage
        .from(SupabaseConstants.sightingPhotosBucket)
        .remove([path]);
  }
}
