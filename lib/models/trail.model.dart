import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class Trail extends OfflineFirstWithSupabaseModel {
  final int id;

  final String nameEn;

  final String nameEs;

  final String? descriptionEn;

  final String? descriptionEs;

  final int? islandId;

  final int? visitSiteId;

  final String? difficulty;

  final double? distanceKm;

  final int? estimatedMinutes;

  /// JSON-encoded array of [lat, lng] coordinate pairs.
  /// Example: '[[-0.75,-90.31],[-0.76,-90.32]]'
  final String coordinates;

  final double? elevationGainM;

  /// Owner of this trail (null for official/admin-curated trails).
  final String? userId;

  @override
  Object? get primaryKey => id;

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
