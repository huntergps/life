import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class Island extends OfflineFirstWithSupabaseModel {
  final int id;

  final String nameEs;

  final String nameEn;

  final double? latitude;
  final double? longitude;

  final double? areaKm2;

  final double? areaHa;

  final String? descriptionEs;

  final String? descriptionEn;

  final String? parkId;

  final String? islandType;

  final String? classification;

  final bool? isPopulated;

  @override
  Object? get primaryKey => id;

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
