import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_supabase_service.dart';

final adminSupabaseServiceProvider = Provider<AdminSupabaseService>((ref) {
  return AdminSupabaseService();
});

final adminCategoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(adminSupabaseServiceProvider);
  return service.getCategories();
});

final deletedCategoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(adminSupabaseServiceProvider);
  return service.getDeletedCategories();
});

final adminCategoryProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, id) async {
  final categories = await ref.watch(adminCategoriesProvider.future);
  final matches = categories.where((c) => c['id'] == id);
  return matches.isNotEmpty ? matches.first : null;
});
