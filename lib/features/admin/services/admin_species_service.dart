import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSpeciesService {
  final SupabaseClient _client;

  AdminSpeciesService(SupabaseClient client) : _client = client;

  Future<List<Map<String, dynamic>>> getSpecies() async {
    final response = await _client
        .from('species')
        .select('*, categories(name_en)')
        .isFilter('deleted_at', null)
        .order('common_name_en')
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> upsertSpecies(Map<String, dynamic> data) async {
    final response = await _client
        .from('species')
        .upsert(data)
        .select()
        .single();
    return response;
  }

  Future<void> updateSpecies(int id, Map<String, dynamic> data) async {
    await _client.from('species').update(data).eq('id', id);
  }

  Future<void> deleteSpecies(int id) async {
    await _client.from('species').update({
      'deleted_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getDeletedSpecies() async {
    final response = await _client
        .from('species')
        .select('*, categories(name_en)')
        .not('deleted_at', 'is', null)
        .order('deleted_at', ascending: false)
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> restoreSpecies(int id) async {
    await _client.from('species').update({
      'deleted_at': null,
    }).eq('id', id);
  }

  Future<void> permanentlyDeleteSpecies(int id) async {
    await _client.from('species').delete().eq('id', id);
  }

  // ── Species Sites ──

  Future<List<Map<String, dynamic>>> getSpeciesSitesByVisitSite(int visitSiteId) async {
    final response = await _client
        .from('species_sites')
        .select('*, species(id, common_name_es, common_name_en, scientific_name, thumbnail_url)')
        .eq('visit_site_id', visitSiteId)
        .order('species_id')
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getSpeciesSites({int? speciesId}) async {
    var query = _client
        .from('species_sites')
        .select('*, species(common_name_en), visit_sites(name_en)');
    if (speciesId != null) {
      query = query.eq('species_id', speciesId);
    }
    final response = await query.order('species_id').limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> upsertSpeciesSite(Map<String, dynamic> data) async {
    final response = await _client
        .from('species_sites')
        .upsert(data)
        .select()
        .single();
    return response;
  }

  Future<void> deleteSpeciesSite(int speciesId, int visitSiteId) async {
    await _client
        .from('species_sites')
        .delete()
        .eq('species_id', speciesId)
        .eq('visit_site_id', visitSiteId);
  }
}
