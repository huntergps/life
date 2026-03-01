import 'package:supabase_flutter/supabase_flutter.dart';

class AdminIslandsService {
  final SupabaseClient _client;

  AdminIslandsService(SupabaseClient client) : _client = client;

  Future<List<Map<String, dynamic>>> getIslands() async {
    final response = await _client
        .from('islands')
        .select()
        .isFilter('deleted_at', null)
        .order('name_en')
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> upsertIsland(Map<String, dynamic> data) async {
    final response = await _client
        .from('islands')
        .upsert(data)
        .select()
        .single();
    return response;
  }

  Future<void> deleteIsland(int id) async {
    await _client.from('islands').update({
      'deleted_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getDeletedIslands() async {
    final response = await _client
        .from('islands')
        .select()
        .not('deleted_at', 'is', null)
        .order('deleted_at', ascending: false)
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> restoreIsland(int id) async {
    await _client.from('islands').update({
      'deleted_at': null,
    }).eq('id', id);
  }

  Future<void> permanentlyDeleteIsland(int id) async {
    await _client.from('islands').delete().eq('id', id);
  }
}
