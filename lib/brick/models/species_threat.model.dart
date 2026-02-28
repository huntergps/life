import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'species_threats'),
)
class SpeciesThreat extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  final int id;

  @Supabase(name: 'species_id')
  final int speciesId;

  @Supabase(name: 'threat_type')
  final String threatType;

  @Supabase(name: 'severity')
  final String severity;

  @Supabase(name: 'description_es')
  final String? descriptionEs;

  @Supabase(name: 'description_en')
  final String? descriptionEn;

  SpeciesThreat({
    required this.id,
    required this.speciesId,
    required this.threatType,
    required this.severity,
    this.descriptionEs,
    this.descriptionEn,
  });
}
