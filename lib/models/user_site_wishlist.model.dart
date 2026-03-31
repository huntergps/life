import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class UserSiteWishlist extends OfflineFirstWithSupabaseModel {
  final int id;

  final String userId;

  final int visitSiteId;

  final DateTime? createdAt;

  @override
  Object? get primaryKey => id;

  UserSiteWishlist({
    required this.id,
    required this.userId,
    required this.visitSiteId,
    this.createdAt,
  });
}
