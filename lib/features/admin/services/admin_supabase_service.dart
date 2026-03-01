import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_categories_service.dart';
import 'admin_images_service.dart';
import 'admin_islands_service.dart';
import 'admin_species_service.dart';
import 'admin_stats_service.dart';
import 'admin_visit_sites_service.dart';

/// Facade that delegates every call to a focused per-entity sub-service.
/// All existing callers continue to work without changes.
class AdminSupabaseService {
  final AdminCategoriesService categories;
  final AdminIslandsService islands;
  final AdminVisitSitesService visitSites;
  final AdminSpeciesService species;
  final AdminImagesService images;
  final AdminStatsService stats;

  AdminSupabaseService({SupabaseClient? client})
      : categories = AdminCategoriesService(client ?? Supabase.instance.client),
        islands = AdminIslandsService(client ?? Supabase.instance.client),
        visitSites = AdminVisitSitesService(client ?? Supabase.instance.client),
        species = AdminSpeciesService(client ?? Supabase.instance.client),
        images = AdminImagesService(client ?? Supabase.instance.client),
        stats = AdminStatsService(client ?? Supabase.instance.client);

  // ── Categories ──

  Future<List<Map<String, dynamic>>> getCategories() => categories.getCategories();
  Future<Map<String, dynamic>> upsertCategory(Map<String, dynamic> data) => categories.upsertCategory(data);
  Future<void> deleteCategory(int id) => categories.deleteCategory(id);
  Future<List<Map<String, dynamic>>> getDeletedCategories() => categories.getDeletedCategories();
  Future<void> restoreCategory(int id) => categories.restoreCategory(id);
  Future<void> permanentlyDeleteCategory(int id) => categories.permanentlyDeleteCategory(id);

  // ── Islands ──

  Future<List<Map<String, dynamic>>> getIslands() => islands.getIslands();
  Future<Map<String, dynamic>> upsertIsland(Map<String, dynamic> data) => islands.upsertIsland(data);
  Future<void> deleteIsland(int id) => islands.deleteIsland(id);
  Future<List<Map<String, dynamic>>> getDeletedIslands() => islands.getDeletedIslands();
  Future<void> restoreIsland(int id) => islands.restoreIsland(id);
  Future<void> permanentlyDeleteIsland(int id) => islands.permanentlyDeleteIsland(id);

  // ── Visit Sites ──

  Future<List<Map<String, dynamic>>> getVisitSitesByIsland(int islandId) => visitSites.getVisitSitesByIsland(islandId);
  Future<List<Map<String, dynamic>>> getVisitSites() => visitSites.getVisitSites();
  Future<Map<String, dynamic>> upsertVisitSite(Map<String, dynamic> data) => visitSites.upsertVisitSite(data);
  Future<void> deleteVisitSite(int id) => visitSites.deleteVisitSite(id);
  Future<List<Map<String, dynamic>>> getDeletedVisitSites() => visitSites.getDeletedVisitSites();
  Future<void> restoreVisitSite(int id) => visitSites.restoreVisitSite(id);
  Future<void> permanentlyDeleteVisitSite(int id) => visitSites.permanentlyDeleteVisitSite(id);

  // ── Species ──

  Future<List<Map<String, dynamic>>> getSpecies() => species.getSpecies();
  Future<Map<String, dynamic>> upsertSpecies(Map<String, dynamic> data) => species.upsertSpecies(data);
  Future<void> updateSpecies(int id, Map<String, dynamic> data) => species.updateSpecies(id, data);
  Future<void> deleteSpecies(int id) => species.deleteSpecies(id);
  Future<List<Map<String, dynamic>>> getDeletedSpecies() => species.getDeletedSpecies();
  Future<void> restoreSpecies(int id) => species.restoreSpecies(id);
  Future<void> permanentlyDeleteSpecies(int id) => species.permanentlyDeleteSpecies(id);

  // ── Species Images ──

  Future<List<Map<String, dynamic>>> getSpeciesImages(int speciesId) => images.getSpeciesImages(speciesId);
  Future<Map<String, dynamic>> upsertSpeciesImage(Map<String, dynamic> data) => images.upsertSpeciesImage(data);
  Future<void> deleteSpeciesImage(int id) => images.deleteSpeciesImage(id);
  Future<void> updateSpeciesImage(int imageId, Map<String, dynamic> data) => images.updateSpeciesImage(imageId, data);
  Future<void> updateImageSortOrders(List<Map<String, dynamic>> orders) => images.updateImageSortOrders(orders);

  // ── Species Sites ──

  Future<List<Map<String, dynamic>>> getSpeciesSitesByVisitSite(int visitSiteId) => species.getSpeciesSitesByVisitSite(visitSiteId);
  Future<List<Map<String, dynamic>>> getSpeciesSites({int? speciesId}) => species.getSpeciesSites(speciesId: speciesId);
  Future<Map<String, dynamic>> upsertSpeciesSite(Map<String, dynamic> data) => species.upsertSpeciesSite(data);
  Future<void> deleteSpeciesSite(int speciesId, int visitSiteId) => species.deleteSpeciesSite(speciesId, visitSiteId);

  // ── Storage ──

  Future<String> uploadImage({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) => images.uploadImage(bucket: bucket, path: path, bytes: bytes, contentType: contentType);

  Future<void> deleteStorageFile(String bucket, String path) => images.deleteStorageFile(bucket, path);

  // ── Entity Counts (for dashboard) ──

  Future<int> getCount(String table) => stats.getCount(table);
  Future<int> getActiveCount(String table) => stats.getActiveCount(table);

  // ── Dashboard Statistics ──

  Future<int> getTaxonomyCount() => stats.getTaxonomyCount();
  Future<List<Map<String, dynamic>>> getSpeciesCountByCategory() => stats.getSpeciesCountByCategory();
  Future<int> getOrphanVisitSitesCount() => stats.getOrphanVisitSitesCount();
  Future<int> getSpeciesWithoutImagesCount() => stats.getSpeciesWithoutImagesCount();

  // ── Site Catalogs ──

  Future<List<Map<String, dynamic>>> getSiteTypeCatalog() => visitSites.getSiteTypeCatalog();
  Future<List<Map<String, dynamic>>> getSiteModalityCatalog() => visitSites.getSiteModalityCatalog();
  Future<List<Map<String, dynamic>>> getSiteActivityCatalog() => visitSites.getSiteActivityCatalog();

  // ── Site Catalog CRUD ──

  Future<void> createSiteCatalogEntry(String table, String name) => visitSites.createSiteCatalogEntry(table, name);
  Future<void> updateSiteCatalogEntry(String table, String id, String name) => visitSites.updateSiteCatalogEntry(table, id, name);
  Future<void> deleteSiteCatalogEntry(String table, String id) => visitSites.deleteSiteCatalogEntry(table, id);

  // ── Site Junction Tables ──

  Future<List<Map<String, dynamic>>> getVisitSiteTypes(int siteId) => visitSites.getVisitSiteTypes(siteId);
  Future<List<Map<String, dynamic>>> getVisitSiteModalities(int siteId) => visitSites.getVisitSiteModalities(siteId);
  Future<List<Map<String, dynamic>>> getVisitSiteActivities(int siteId) => visitSites.getVisitSiteActivities(siteId);
  Future<void> setVisitSiteTypes(int siteId, List<String> typeIds) => visitSites.setVisitSiteTypes(siteId, typeIds);
  Future<void> setVisitSiteModalities(int siteId, List<String> modalityIds) => visitSites.setVisitSiteModalities(siteId, modalityIds);
  Future<void> setVisitSiteActivities(int siteId, List<String> activityIds) => visitSites.setVisitSiteActivities(siteId, activityIds);
}
