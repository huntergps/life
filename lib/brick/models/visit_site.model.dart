import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'visit_sites'),
)
class VisitSite extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  final int id;

  @Supabase(name: 'island_id')
  final int? islandId;

  @Supabase(name: 'name_es')
  final String nameEs;

  @Supabase(name: 'name_en')
  final String? nameEn;

  final double? latitude;
  final double? longitude;

  @Supabase(name: 'description_es')
  final String? descriptionEs;

  @Supabase(name: 'description_en')
  final String? descriptionEn;

  @Supabase(name: 'monitoring_type')
  final String? monitoringType;

  final String? difficulty;

  @Supabase(name: 'conservation_zone')
  final String? conservationZone;

  @Supabase(name: 'public_use_zone')
  final String? publicUseZone;

  final int? capacity;
  final String? status;

  @Supabase(name: 'attraction_es')
  final String? attractionEs;

  final String? abbreviation;

  @Supabase(name: 'park_id')
  final String? parkId;

  VisitSite({
    required this.id,
    this.islandId,
    required this.nameEs,
    this.nameEn,
    this.latitude,
    this.longitude,
    this.descriptionEs,
    this.descriptionEn,
    this.monitoringType,
    this.difficulty,
    this.conservationZone,
    this.publicUseZone,
    this.capacity,
    this.status,
    this.attractionEs,
    this.abbreviation,
    this.parkId,
  });
}
