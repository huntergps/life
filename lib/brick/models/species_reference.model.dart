import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'species_references'),
)
class SpeciesReference extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  final int id;

  @Supabase(name: 'species_id')
  final int speciesId;

  @Supabase(name: 'citation')
  final String citation;

  @Supabase(name: 'url')
  final String? url;

  @Supabase(name: 'doi')
  final String? doi;

  @Supabase(name: 'reference_type')
  final String? referenceType;

  SpeciesReference({
    required this.id,
    required this.speciesId,
    required this.citation,
    this.url,
    this.doi,
    this.referenceType,
  });
}
