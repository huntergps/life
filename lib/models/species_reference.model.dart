import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class SpeciesReference extends OfflineFirstWithSupabaseModel {
  final int id;

  final int speciesId;

  final String citation;

  final String? url;

  final String? doi;

  final String? referenceType;

  @override
  Object? get primaryKey => id;

  SpeciesReference({
    required this.id,
    required this.speciesId,
    required this.citation,
    this.url,
    this.doi,
    this.referenceType,
  });
}
