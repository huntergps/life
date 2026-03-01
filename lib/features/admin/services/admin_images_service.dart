import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminImagesService {
  final SupabaseClient _client;

  AdminImagesService(SupabaseClient client) : _client = client;

  Future<List<Map<String, dynamic>>> getSpeciesImages(int speciesId) async {
    final response = await _client
        .from('species_images')
        .select()
        .eq('species_id', speciesId)
        .order('sort_order')
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> upsertSpeciesImage(Map<String, dynamic> data) async {
    final response = await _client
        .from('species_images')
        .upsert(data)
        .select()
        .single();
    return response;
  }

  Future<void> deleteSpeciesImage(int id) async {
    await _client.from('species_images').delete().eq('id', id);
  }

  Future<void> updateSpeciesImage(int imageId, Map<String, dynamic> data) async {
    await _client.from('species_images').update(data).eq('id', imageId);
  }

  Future<void> updateImageSortOrders(List<Map<String, dynamic>> orders) async {
    for (final order in orders) {
      await _client
          .from('species_images')
          .update({'sort_order': order['sort_order']})
          .eq('id', order['id']);
    }
  }

  // ── Storage ──

  Future<String> uploadImage({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    await _client.storage.from(bucket).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: true),
    );
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteStorageFile(String bucket, String path) async {
    await _client.storage.from(bucket).remove([path]);
  }
}
