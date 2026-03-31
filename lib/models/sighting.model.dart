import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class Sighting extends OfflineFirstWithSupabaseModel {
  final int id;

  final String userId;

  final int speciesId;

  final int? visitSiteId;

  final DateTime? observedAt;

  final String? notes;

  final double? latitude;
  final double? longitude;

  final String? photoUrl;

  @override
  Object? get primaryKey => id;

  Sighting({
    required this.id,
    required this.userId,
    required this.speciesId,
    this.visitSiteId,
    this.observedAt,
    this.notes,
    this.latitude,
    this.longitude,
    this.photoUrl,
  });
}
