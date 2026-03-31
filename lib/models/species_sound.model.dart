import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class SpeciesSound extends OfflineFirstWithSupabaseModel {
  final int id;

  final int speciesId;

  final String soundUrl;

  final String? soundType;

  final String? descriptionEs;

  final String? descriptionEn;

  final String? recordedBy;

  final DateTime? recordedDate;

  @override
  Object? get primaryKey => id;

  SpeciesSound({
    required this.id,
    required this.speciesId,
    required this.soundUrl,
    this.soundType,
    this.descriptionEs,
    this.descriptionEn,
    this.recordedBy,
    this.recordedDate,
  });
}
