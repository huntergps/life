import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'user_site_wishlist'),
)
class UserSiteWishlist extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  final int id;

  @Supabase(name: 'user_id')
  final String userId;

  @Supabase(name: 'visit_site_id')
  final int visitSiteId;

  @Supabase(name: 'created_at')
  final DateTime? createdAt;

  UserSiteWishlist({
    required this.id,
    required this.userId,
    required this.visitSiteId,
    this.createdAt,
  });
}
