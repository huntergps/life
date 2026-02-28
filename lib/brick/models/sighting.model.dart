import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'sightings'),
)
class Sighting extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  final int id;

  @Supabase(name: 'user_id')
  final String userId;

  @Supabase(name: 'species_id')
  final int speciesId;

  @Supabase(name: 'visit_site_id')
  final int? visitSiteId;

  @Supabase(name: 'observed_at')
  final DateTime? observedAt;

  final String? notes;

  final double? latitude;
  final double? longitude;

  @Supabase(name: 'photo_url')
  final String? photoUrl;

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
