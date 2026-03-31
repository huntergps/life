import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class UserFavorite extends OfflineFirstWithSupabaseModel {
  final int id;

  final String userId;

  final int speciesId;

  @override
  Object? get primaryKey => id;

  UserFavorite({
    required this.id,
    required this.userId,
    required this.speciesId,
  });
}
