import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class UserSpeciesChecklist extends OfflineFirstWithSupabaseModel {
  final int id;

  final String userId;

  final int speciesId;

  final DateTime? seenAt;

  @override
  Object? get primaryKey => id;

  UserSpeciesChecklist({
    required this.id,
    required this.userId,
    required this.speciesId,
    this.seenAt,
  });
}
