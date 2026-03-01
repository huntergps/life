import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCategoriesService {
  final SupabaseClient _client;

  AdminCategoriesService(SupabaseClient client) : _client = client;

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .isFilter('deleted_at', null)
        .order('sort_order')
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> upsertCategory(Map<String, dynamic> data) async {
    final response = await _client
        .from('categories')
        .upsert(data)
        .select()
        .single();
    return response;
  }

  Future<void> deleteCategory(int id) async {
    await _client.from('categories').update({
      'deleted_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getDeletedCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .not('deleted_at', 'is', null)
        .order('deleted_at', ascending: false)
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> restoreCategory(int id) async {
    await _client.from('categories').update({
      'deleted_at': null,
    }).eq('id', id);
  }

  Future<void> permanentlyDeleteCategory(int id) async {
    await _client.from('categories').delete().eq('id', id);
  }
}
