import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'islands'),
)
class Island extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  final int id;

  @Supabase(name: 'name_es')
  final String nameEs;

  @Supabase(name: 'name_en')
  final String nameEn;

  final double? latitude;
  final double? longitude;

  @Supabase(name: 'area_km2')
  final double? areaKm2;

  @Supabase(name: 'area_ha')
  final double? areaHa;

  @Supabase(name: 'description_es')
  final String? descriptionEs;

  @Supabase(name: 'description_en')
  final String? descriptionEn;

  @Supabase(name: 'park_id')
  final String? parkId;

  @Supabase(name: 'island_type')
  final String? islandType;

  final String? classification;

  @Supabase(name: 'is_populated')
  final bool? isPopulated;

  Island({
    required this.id,
    required this.nameEs,
    required this.nameEn,
    this.latitude,
    this.longitude,
    this.areaKm2,
    this.areaHa,
    this.descriptionEs,
    this.descriptionEn,
    this.parkId,
    this.islandType,
    this.classification,
    this.isPopulated,
  });
}
