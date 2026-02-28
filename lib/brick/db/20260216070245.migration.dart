// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260216070245_up = [
  InsertTable('SpeciesReference'),
  InsertTable('SpeciesSound'),
  InsertTable('SpeciesThreat'),
  InsertColumn('is_native', Column.boolean, onTable: 'Species'),
  InsertColumn('is_introduced', Column.boolean, onTable: 'Species'),
  InsertColumn('endemism_level', Column.varchar, onTable: 'Species'),
  InsertColumn('population_trend', Column.varchar, onTable: 'Species'),
  InsertColumn('breeding_season', Column.varchar, onTable: 'Species'),
  InsertColumn('clutch_size', Column.integer, onTable: 'Species'),
  InsertColumn('reproductive_frequency', Column.varchar, onTable: 'Species'),
  InsertColumn('social_structure', Column.varchar, onTable: 'Species'),
  InsertColumn('activity_pattern', Column.varchar, onTable: 'Species'),
  InsertColumn('diet_type', Column.varchar, onTable: 'Species'),
  InsertColumn('primary_food_sources', Column.varchar, onTable: 'Species'),
  InsertColumn('altitude_min_m', Column.integer, onTable: 'Species'),
  InsertColumn('altitude_max_m', Column.integer, onTable: 'Species'),
  InsertColumn('depth_min_m', Column.integer, onTable: 'Species'),
  InsertColumn('depth_max_m', Column.integer, onTable: 'Species'),
  InsertColumn('scientific_name_authorship', Column.varchar, onTable: 'Species'),
  InsertColumn('distinguishing_features_es', Column.varchar, onTable: 'Species'),
  InsertColumn('distinguishing_features_en', Column.varchar, onTable: 'Species'),
  InsertColumn('sexual_dimorphism', Column.boolean, onTable: 'Species'),
  InsertColumn('gbif_taxon_id', Column.varchar, onTable: 'Species'),
  InsertColumn('eol_page_id', Column.varchar, onTable: 'Species'),
  InsertColumn('iucn_assessment_url', Column.varchar, onTable: 'Species'),
  InsertColumn('sound_recording_url', Column.varchar, onTable: 'Species'),
  InsertColumn('video_url', Column.varchar, onTable: 'Species'),
  InsertColumn('id', Column.integer, onTable: 'SpeciesReference'),
  InsertColumn('species_id', Column.integer, onTable: 'SpeciesReference'),
  InsertColumn('citation', Column.varchar, onTable: 'SpeciesReference'),
  InsertColumn('url', Column.varchar, onTable: 'SpeciesReference'),
  InsertColumn('doi', Column.varchar, onTable: 'SpeciesReference'),
  InsertColumn('reference_type', Column.varchar, onTable: 'SpeciesReference'),
  InsertColumn('id', Column.integer, onTable: 'SpeciesSound'),
  InsertColumn('species_id', Column.integer, onTable: 'SpeciesSound'),
  InsertColumn('sound_url', Column.varchar, onTable: 'SpeciesSound'),
  InsertColumn('sound_type', Column.varchar, onTable: 'SpeciesSound'),
  InsertColumn('description_es', Column.varchar, onTable: 'SpeciesSound'),
  InsertColumn('description_en', Column.varchar, onTable: 'SpeciesSound'),
  InsertColumn('recorded_by', Column.varchar, onTable: 'SpeciesSound'),
  InsertColumn('recorded_date', Column.datetime, onTable: 'SpeciesSound'),
  InsertColumn('id', Column.integer, onTable: 'SpeciesThreat'),
  InsertColumn('species_id', Column.integer, onTable: 'SpeciesThreat'),
  InsertColumn('threat_type', Column.varchar, onTable: 'SpeciesThreat'),
  InsertColumn('severity', Column.varchar, onTable: 'SpeciesThreat'),
  InsertColumn('description_es', Column.varchar, onTable: 'SpeciesThreat'),
  InsertColumn('description_en', Column.varchar, onTable: 'SpeciesThreat')
];

const List<MigrationCommand> _migration_20260216070245_down = [
  DropTable('SpeciesReference'),
  DropTable('SpeciesSound'),
  DropTable('SpeciesThreat'),
  DropColumn('is_native', onTable: 'Species'),
  DropColumn('is_introduced', onTable: 'Species'),
  DropColumn('endemism_level', onTable: 'Species'),
  DropColumn('population_trend', onTable: 'Species'),
  DropColumn('breeding_season', onTable: 'Species'),
  DropColumn('clutch_size', onTable: 'Species'),
  DropColumn('reproductive_frequency', onTable: 'Species'),
  DropColumn('social_structure', onTable: 'Species'),
  DropColumn('activity_pattern', onTable: 'Species'),
  DropColumn('diet_type', onTable: 'Species'),
  DropColumn('primary_food_sources', onTable: 'Species'),
  DropColumn('altitude_min_m', onTable: 'Species'),
  DropColumn('altitude_max_m', onTable: 'Species'),
  DropColumn('depth_min_m', onTable: 'Species'),
  DropColumn('depth_max_m', onTable: 'Species'),
  DropColumn('scientific_name_authorship', onTable: 'Species'),
  DropColumn('distinguishing_features_es', onTable: 'Species'),
  DropColumn('distinguishing_features_en', onTable: 'Species'),
  DropColumn('sexual_dimorphism', onTable: 'Species'),
  DropColumn('gbif_taxon_id', onTable: 'Species'),
  DropColumn('eol_page_id', onTable: 'Species'),
  DropColumn('iucn_assessment_url', onTable: 'Species'),
  DropColumn('sound_recording_url', onTable: 'Species'),
  DropColumn('video_url', onTable: 'Species'),
  DropColumn('id', onTable: 'SpeciesReference'),
  DropColumn('species_id', onTable: 'SpeciesReference'),
  DropColumn('citation', onTable: 'SpeciesReference'),
  DropColumn('url', onTable: 'SpeciesReference'),
  DropColumn('doi', onTable: 'SpeciesReference'),
  DropColumn('reference_type', onTable: 'SpeciesReference'),
  DropColumn('id', onTable: 'SpeciesSound'),
  DropColumn('species_id', onTable: 'SpeciesSound'),
  DropColumn('sound_url', onTable: 'SpeciesSound'),
  DropColumn('sound_type', onTable: 'SpeciesSound'),
  DropColumn('description_es', onTable: 'SpeciesSound'),
  DropColumn('description_en', onTable: 'SpeciesSound'),
  DropColumn('recorded_by', onTable: 'SpeciesSound'),
  DropColumn('recorded_date', onTable: 'SpeciesSound'),
  DropColumn('id', onTable: 'SpeciesThreat'),
  DropColumn('species_id', onTable: 'SpeciesThreat'),
  DropColumn('threat_type', onTable: 'SpeciesThreat'),
  DropColumn('severity', onTable: 'SpeciesThreat'),
  DropColumn('description_es', onTable: 'SpeciesThreat'),
  DropColumn('description_en', onTable: 'SpeciesThreat')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260216070245',
  up: _migration_20260216070245_up,
  down: _migration_20260216070245_down,
)
class Migration20260216070245 extends Migration {
  const Migration20260216070245()
    : super(
        version: 20260216070245,
        up: _migration_20260216070245_up,
        down: _migration_20260216070245_down,
      );
}
