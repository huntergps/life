import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class SpeciesThreat extends OfflineFirstWithSupabaseModel {
  final int id;

  final int speciesId;

  final String threatType;

  final String? severity;

  final String? descriptionEs;

  final String? descriptionEn;

  @override
  Object? get primaryKey => id;

  SpeciesThreat({
    required this.id,
    required this.speciesId,
    required this.threatType,
    this.severity,
    this.descriptionEs,
    this.descriptionEn,
  });
}
