import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_category_provider.dart';

final adminSpeciesListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(adminSupabaseServiceProvider);
  return service.getSpecies();
});


final deletedSpeciesListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(adminSupabaseServiceProvider);
  return service.getDeletedSpecies();
});

final adminSpeciesProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, id) async {
  final service = ref.watch(adminSupabaseServiceProvider);
  return service.getSpeciesById(id);
});

final adminSpeciesSitesProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, speciesId) async {
  final service = ref.watch(adminSupabaseServiceProvider);
  return service.getSpeciesSites(speciesId: speciesId);
});
