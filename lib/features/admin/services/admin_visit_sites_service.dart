import 'package:supabase_flutter/supabase_flutter.dart';

class AdminVisitSitesService {
  final SupabaseClient _client;

  AdminVisitSitesService(SupabaseClient client) : _client = client;

  Future<List<Map<String, dynamic>>> getVisitSitesByIsland(int islandId) async {
    final response = await _client
        .from('visit_sites')
        .select()
        .eq('island_id', islandId)
        .isFilter('deleted_at', null)
        .order('name_es')
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getVisitSites() async {
    final response = await _client
        .from('visit_sites')
        .select()
        .isFilter('deleted_at', null)
        .order('name_es')
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> upsertVisitSite(Map<String, dynamic> data) async {
    final response = await _client
        .from('visit_sites')
        .upsert(data)
        .select()
        .single();
    return response;
  }

  Future<void> deleteVisitSite(int id) async {
    await _client.from('visit_sites').update({
      'deleted_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getDeletedVisitSites() async {
    final response = await _client
        .from('visit_sites')
        .select()
        .not('deleted_at', 'is', null)
        .order('deleted_at', ascending: false)
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> restoreVisitSite(int id) async {
    await _client.from('visit_sites').update({
      'deleted_at': null,
    }).eq('id', id);
  }

  Future<void> permanentlyDeleteVisitSite(int id) async {
    await _client.from('visit_sites').delete().eq('id', id);
  }

  // ── Site Catalogs ──

  Future<List<Map<String, dynamic>>> getSiteTypeCatalog() async {
    final response = await _client
        .from('site_type_catalog')
        .select()
        .order('name')
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getSiteModalityCatalog() async {
    final response = await _client
        .from('site_modality_catalog')
        .select()
        .order('name')
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getSiteActivityCatalog() async {
    final response = await _client
        .from('site_activity_catalog')
        .select()
        .order('name')
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  // ── Site Catalog CRUD ──

  Future<void> createSiteCatalogEntry(String table, String name) async {
    await _client.from(table).insert({'name': name});
  }

  Future<void> updateSiteCatalogEntry(String table, String id, String name) async {
    await _client.from(table).update({'name': name}).eq('id', id);
  }

  Future<void> deleteSiteCatalogEntry(String table, String id) async {
    await _client.from(table).delete().eq('id', id);
  }

  // ── Site Junction Tables ──

  Future<List<Map<String, dynamic>>> getVisitSiteTypes(int siteId) async {
    final response = await _client
        .from('visit_site_types')
        .select('type_id, site_type_catalog(id, name)')
        .eq('visit_site_id', siteId)
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getVisitSiteModalities(int siteId) async {
    final response = await _client
        .from('visit_site_modalities')
        .select('modality_id, site_modality_catalog(id, name)')
        .eq('visit_site_id', siteId)
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getVisitSiteActivities(int siteId) async {
    final response = await _client
        .from('visit_site_activities')
        .select('activity_id, capacity, site_activity_catalog(id, name, abbreviation)')
        .eq('visit_site_id', siteId)
        .limit(500);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> setVisitSiteTypes(int siteId, List<String> typeIds) async {
    await _client.from('visit_site_types').delete().eq('visit_site_id', siteId);
    if (typeIds.isEmpty) return;
    await _client.from('visit_site_types').insert(
      typeIds.map((id) => {'visit_site_id': siteId, 'type_id': id}).toList(),
    );
  }

  Future<void> setVisitSiteModalities(int siteId, List<String> modalityIds) async {
    await _client.from('visit_site_modalities').delete().eq('visit_site_id', siteId);
    if (modalityIds.isEmpty) return;
    await _client.from('visit_site_modalities').insert(
      modalityIds.map((id) => {'visit_site_id': siteId, 'modality_id': id}).toList(),
    );
  }

  Future<void> setVisitSiteActivities(int siteId, List<String> activityIds) async {
    await _client.from('visit_site_activities').delete().eq('visit_site_id', siteId);
    if (activityIds.isEmpty) return;
    await _client.from('visit_site_activities').insert(
      activityIds.map((id) => {'visit_site_id': siteId, 'activity_id': id}).toList(),
    );
  }
}
