import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'trails'),
)
class Trail extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  @Sqlite(unique: true)
  final int id;

  @Supabase(name: 'name_en')
  final String nameEn;

  @Supabase(name: 'name_es')
  final String nameEs;

  @Supabase(name: 'description_en')
  final String? descriptionEn;

  @Supabase(name: 'description_es')
  final String? descriptionEs;

  @Supabase(name: 'island_id')
  final int? islandId;

  @Supabase(name: 'visit_site_id')
  final int? visitSiteId;

  final String? difficulty;

  @Supabase(name: 'distance_km')
  final double? distanceKm;

  @Supabase(name: 'estimated_minutes')
  final int? estimatedMinutes;

  /// JSON-encoded array of [lat, lng] coordinate pairs.
  /// Example: '[[-0.75,-90.31],[-0.76,-90.32]]'
  final String coordinates;

  @Supabase(name: 'elevation_gain_m')
  final double? elevationGainM;

  /// Owner of this trail (null for official/admin-curated trails).
  @Supabase(name: 'user_id')
  final String? userId;

  Trail({
    required this.id,
    required this.nameEn,
    required this.nameEs,
    this.descriptionEn,
    this.descriptionEs,
    this.islandId,
    this.visitSiteId,
    this.difficulty,
    this.distanceKm,
    this.estimatedMinutes,
    this.coordinates = '[]',
    this.elevationGainM,
    this.userId,
  });
}
