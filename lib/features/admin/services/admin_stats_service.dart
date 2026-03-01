import 'package:supabase_flutter/supabase_flutter.dart';

class AdminStatsService {
  final SupabaseClient _client;

  AdminStatsService(SupabaseClient client) : _client = client;

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
}
