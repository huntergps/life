import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSupabaseService {
  final SupabaseClient _client;

  AdminSupabaseService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // ── Categories ──

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .isFilter('deleted_at', null)
        .order('sort_order');
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
        .order('deleted_at', ascending: false);
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

  // ── Islands ──

  Future<List<Map<String, dynamic>>> getIslands() async {
    final response = await _client
        .from('islands')
        .select()
        .isFilter('deleted_at', null)
        .order('name_en');
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
        .order('deleted_at', ascending: false);
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

  // ── Visit Sites ──

  Future<List<Map<String, dynamic>>> getVisitSitesByIsland(int islandId) async {
    final response = await _client
        .from('visit_sites')
        .select()
        .eq('island_id', islandId)
        .isFilter('deleted_at', null)
        .order('name_es');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getVisitSites() async {
    final response = await _client
        .from('visit_sites')
        .select()
        .isFilter('deleted_at', null)
        .order('name_es');
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
        .order('deleted_at', ascending: false);
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

  // ── Species ──

  Future<List<Map<String, dynamic>>> getSpecies() async {
    final response = await _client
        .from('species')
        .select('*, categories(name_en)')
        .isFilter('deleted_at', null)
        .order('common_name_en');
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
        .order('deleted_at', ascending: false);
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

  // ── Species Images ──

  Future<List<Map<String, dynamic>>> getSpeciesImages(int speciesId) async {
    final response = await _client
        .from('species_images')
        .select()
        .eq('species_id', speciesId)
        .order('sort_order');
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

  // ── Species Sites ──

  Future<List<Map<String, dynamic>>> getSpeciesSitesByVisitSite(int visitSiteId) async {
    final response = await _client
        .from('species_sites')
        .select('*, species(id, common_name_es, common_name_en, scientific_name, thumbnail_url)')
        .eq('visit_site_id', visitSiteId)
        .order('species_id');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getSpeciesSites({int? speciesId}) async {
    var query = _client
        .from('species_sites')
        .select('*, species(common_name_en), visit_sites(name_en)');
    if (speciesId != null) {
      query = query.eq('species_id', speciesId);
    }
    final response = await query.order('species_id');
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

  // ── Entity Counts (for dashboard) ──

  Future<int> getCount(String table) async {
    final response = await _client.from(table).select().count(CountOption.exact);
    return response.count;
  }

  /// Count only active (non-deleted) records for tables with soft delete.
  Future<int> getActiveCount(String table) async {
    final response = await _client
        .from(table)
        .select()
        .isFilter('deleted_at', null)
        .count(CountOption.exact);
    return response.count;
  }

  // ── Dashboard Statistics ──

  /// Get taxonomy genera count.
  Future<int> getTaxonomyCount() async {
    return getCount('taxonomy_genera');
  }

  /// Get species count grouped by category (SQL GROUP BY via RPC).
  /// Returns list of maps with keys: category_id, name_es, name_en, count.
  Future<List<Map<String, dynamic>>> getSpeciesCountByCategory() async {
    final response = await _client.rpc('get_species_count_by_category');
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Get count of visit sites with no species relationships (SQL subquery via RPC).
  Future<int> getOrphanVisitSitesCount() async {
    final response = await _client.rpc('get_orphan_visit_sites_count');
    return response as int;
  }

  /// Get count of species with no images (SQL subquery via RPC).
  Future<int> getSpeciesWithoutImagesCount() async {
    final response = await _client.rpc('get_species_without_images_count');
    return response as int;
  }

  // ── Site Catalogs ──

  Future<List<Map<String, dynamic>>> getSiteTypeCatalog() async {
    final response = await _client
        .from('site_type_catalog')
        .select()
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getSiteModalityCatalog() async {
    final response = await _client
        .from('site_modality_catalog')
        .select()
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getSiteActivityCatalog() async {
    final response = await _client
        .from('site_activity_catalog')
        .select()
        .order('name');
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
        .eq('visit_site_id', siteId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getVisitSiteModalities(int siteId) async {
    final response = await _client
        .from('visit_site_modalities')
        .select('modality_id, site_modality_catalog(id, name)')
        .eq('visit_site_id', siteId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getVisitSiteActivities(int siteId) async {
    final response = await _client
        .from('visit_site_activities')
        .select('activity_id, capacity, site_activity_catalog(id, name, abbreviation)')
        .eq('visit_site_id', siteId);
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
