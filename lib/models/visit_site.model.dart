import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class VisitSite extends OfflineFirstWithSupabaseModel {
  final int id;

  final int? islandId;

  final String nameEs;

  final String? nameEn;

  final double? latitude;
  final double? longitude;

  final String? descriptionEs;

  final String? descriptionEn;

  final String? monitoringType;

  final String? difficulty;

  final String? conservationZone;

  final String? publicUseZone;

  final int? capacity;
  final String? status;

  final String? attractionEs;

  final String? abbreviation;

  final String? parkId;

  @override
  Object? get primaryKey => id;

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
