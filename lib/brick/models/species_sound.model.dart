import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'species_sounds'),
)
class SpeciesSound extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  final int id;

  @Supabase(name: 'species_id')
  final int speciesId;

  @Supabase(name: 'sound_url')
  final String soundUrl;

  @Supabase(name: 'sound_type')
  final String? soundType;

  @Supabase(name: 'description_es')
  final String? descriptionEs;

  @Supabase(name: 'description_en')
  final String? descriptionEn;

  @Supabase(name: 'recorded_by')
  final String? recordedBy;

  @Supabase(name: 'recorded_date')
  final DateTime? recordedDate;

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
