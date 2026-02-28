import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'species_sites'),
)
class SpeciesSite extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  final int id;

  @Supabase(name: 'species_id')
  final int speciesId;

  @Supabase(name: 'visit_site_id')
  final int visitSiteId;

  final String? frequency;

  SpeciesSite({
    required this.id,
    required this.speciesId,
    required this.visitSiteId,
    this.frequency,
  });
}
