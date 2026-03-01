import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'user_species_checklist'),
)
class UserSpeciesChecklist extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  final int id;

  @Supabase(name: 'user_id')
  final String userId;

  @Supabase(name: 'species_id')
  final int speciesId;

  @Supabase(name: 'seen_at')
  final DateTime? seenAt;

  UserSpeciesChecklist({
    required this.id,
    required this.userId,
    required this.speciesId,
    this.seenAt,
  });
}
