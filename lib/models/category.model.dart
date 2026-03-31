import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class Category extends OfflineFirstWithSupabaseModel {
  final int id;

  final String slug;

  final String nameEs;

  final String nameEn;

  final String? iconName;

  final int sortOrder;

  @override
  Object? get primaryKey => id;

  Category({
    required this.id,
    required this.slug,
    required this.nameEs,
    required this.nameEn,
    this.iconName,
    this.sortOrder = 0,
  });
}
