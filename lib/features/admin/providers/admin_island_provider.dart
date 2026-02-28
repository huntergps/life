import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_category_provider.dart';

final adminIslandsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(adminSupabaseServiceProvider);
  return service.getIslands();
});

final deletedIslandsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(adminSupabaseServiceProvider);
  return service.getDeletedIslands();
});

final adminIslandProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, id) async {
  final islands = await ref.watch(adminIslandsProvider.future);
  final matches = islands.where((i) => i['id'] == id);
  return matches.isNotEmpty ? matches.first : null;
});
