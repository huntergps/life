import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_category_provider.dart';

final adminVisitSitesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(adminSupabaseServiceProvider);
  return service.getVisitSites();
});

final deletedVisitSitesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(adminSupabaseServiceProvider);
  return service.getDeletedVisitSites();
});

final visitSitesByIslandProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, islandId) async {
  final service = ref.watch(adminSupabaseServiceProvider);
  return service.getVisitSitesByIsland(islandId);
});

final adminVisitSiteProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, id) async {
  final sites = await ref.watch(adminVisitSitesProvider.future);
  final matches = sites.where((s) => s['id'] == id);
  return matches.isNotEmpty ? matches.first : null;
});

final speciesSitesByVisitSiteProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, visitSiteId) async {
  final service = ref.read(adminSupabaseServiceProvider);
  return service.getSpeciesSitesByVisitSite(visitSiteId);
});

final siteTypeCatalogProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(adminSupabaseServiceProvider);
  return service.getSiteTypeCatalog();
});

final siteModalityCatalogProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(adminSupabaseServiceProvider);
  return service.getSiteModalityCatalog();
});

final siteActivityCatalogProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(adminSupabaseServiceProvider);
  return service.getSiteActivityCatalog();
});

final visitSiteTypesProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, siteId) async {
  final service = ref.read(adminSupabaseServiceProvider);
  return service.getVisitSiteTypes(siteId);
});

final visitSiteModalitiesProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, siteId) async {
  final service = ref.read(adminSupabaseServiceProvider);
  return service.getVisitSiteModalities(siteId);
});

final visitSiteActivitiesProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, siteId) async {
  final service = ref.read(adminSupabaseServiceProvider);
  return service.getVisitSiteActivities(siteId);
});
