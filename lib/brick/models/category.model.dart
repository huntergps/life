import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'categories'),
)
class Category extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  final int id;

  final String slug;

  @Supabase(name: 'name_es')
  final String nameEs;

  @Supabase(name: 'name_en')
  final String nameEn;

  @Supabase(name: 'icon_name')
  final String? iconName;

  @Supabase(name: 'sort_order')
  final int sortOrder;

  Category({
    required this.id,
    required this.slug,
    required this.nameEs,
    required this.nameEn,
    this.iconName,
    this.sortOrder = 0,
  });
}
