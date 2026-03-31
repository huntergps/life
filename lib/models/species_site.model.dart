import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class SpeciesSite extends OfflineFirstWithSupabaseModel {
  final int id;

  final int speciesId;

  final int visitSiteId;

  final String? frequency;

  @override
  Object? get primaryKey => id;

  SpeciesSite({
    required this.id,
    required this.speciesId,
    required this.visitSiteId,
    this.frequency,
  });
}
