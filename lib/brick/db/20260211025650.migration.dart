// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// Single consolidated migration for development - all tables

const List<MigrationCommand> _migration_20260211025650_up = [
  InsertTable('Category'),
  InsertTable('Island'),
  InsertTable('Sighting'),
  InsertTable('Species'),
  InsertTable('SpeciesImage'),
  InsertTable('SpeciesSite'),
  InsertTable('UserFavorite'),
  InsertTable('VisitSite'),
  InsertColumn('id', Column.integer, onTable: 'Category'),
  InsertColumn('slug', Column.varchar, onTable: 'Category'),
  InsertColumn('name_es', Column.varchar, onTable: 'Category'),
  InsertColumn('name_en', Column.varchar, onTable: 'Category'),
  InsertColumn('icon_name', Column.varchar, onTable: 'Category'),
  InsertColumn('sort_order', Column.integer, onTable: 'Category'),
  InsertColumn('id', Column.integer, onTable: 'Island'),
  InsertColumn('name_es', Column.varchar, onTable: 'Island'),
  InsertColumn('name_en', Column.varchar, onTable: 'Island'),
  InsertColumn('latitude', Column.Double, onTable: 'Island'),
  InsertColumn('longitude', Column.Double, onTable: 'Island'),
  InsertColumn('area_km2', Column.Double, onTable: 'Island'),
  InsertColumn('description_es', Column.varchar, onTable: 'Island'),
  InsertColumn('description_en', Column.varchar, onTable: 'Island'),
  InsertColumn('id', Column.integer, onTable: 'Sighting'),
  InsertColumn('user_id', Column.varchar, onTable: 'Sighting'),
  InsertColumn('species_id', Column.integer, onTable: 'Sighting'),
  InsertColumn('visit_site_id', Column.integer, onTable: 'Sighting'),
  InsertColumn('observed_at', Column.datetime, onTable: 'Sighting'),
  InsertColumn('notes', Column.varchar, onTable: 'Sighting'),
  InsertColumn('latitude', Column.Double, onTable: 'Sighting'),
  InsertColumn('longitude', Column.Double, onTable: 'Sighting'),
  InsertColumn('photo_url', Column.varchar, onTable: 'Sighting'),
  InsertColumn('id', Column.integer, onTable: 'Species'),
  InsertColumn('category_id', Column.integer, onTable: 'Species'),
  InsertColumn('common_name_es', Column.varchar, onTable: 'Species'),
  InsertColumn('common_name_en', Column.varchar, onTable: 'Species'),
  InsertColumn('scientific_name', Column.varchar, onTable: 'Species'),
  InsertColumn('conservation_status', Column.varchar, onTable: 'Species'),
  InsertColumn('weight_kg', Column.Double, onTable: 'Species'),
  InsertColumn('size_cm', Column.Double, onTable: 'Species'),
  InsertColumn('population_estimate', Column.integer, onTable: 'Species'),
  InsertColumn('lifespan_years', Column.integer, onTable: 'Species'),
  InsertColumn('description_es', Column.varchar, onTable: 'Species'),
  InsertColumn('description_en', Column.varchar, onTable: 'Species'),
  InsertColumn('habitat_es', Column.varchar, onTable: 'Species'),
  InsertColumn('habitat_en', Column.varchar, onTable: 'Species'),
  InsertColumn('hero_image_url', Column.varchar, onTable: 'Species'),
  InsertColumn('thumbnail_url', Column.varchar, onTable: 'Species'),
  InsertColumn('is_endemic', Column.boolean, onTable: 'Species'),
  InsertColumn('taxonomy_kingdom', Column.varchar, onTable: 'Species'),
  InsertColumn('taxonomy_phylum', Column.varchar, onTable: 'Species'),
  InsertColumn('taxonomy_class', Column.varchar, onTable: 'Species'),
  InsertColumn('taxonomy_order', Column.varchar, onTable: 'Species'),
  InsertColumn('taxonomy_family', Column.varchar, onTable: 'Species'),
  InsertColumn('taxonomy_genus', Column.varchar, onTable: 'Species'),
  InsertColumn('id', Column.integer, onTable: 'SpeciesImage'),
  InsertColumn('species_id', Column.integer, onTable: 'SpeciesImage'),
  InsertColumn('image_url', Column.varchar, onTable: 'SpeciesImage'),
  InsertColumn('caption_es', Column.varchar, onTable: 'SpeciesImage'),
  InsertColumn('caption_en', Column.varchar, onTable: 'SpeciesImage'),
  InsertColumn('sort_order', Column.integer, onTable: 'SpeciesImage'),
  InsertColumn('id', Column.integer, onTable: 'SpeciesSite'),
  InsertColumn('species_id', Column.integer, onTable: 'SpeciesSite'),
  InsertColumn('visit_site_id', Column.integer, onTable: 'SpeciesSite'),
  InsertColumn('frequency', Column.varchar, onTable: 'SpeciesSite'),
  InsertColumn('id', Column.integer, onTable: 'UserFavorite'),
  InsertColumn('user_id', Column.varchar, onTable: 'UserFavorite'),
  InsertColumn('species_id', Column.integer, onTable: 'UserFavorite'),
  InsertColumn('id', Column.integer, onTable: 'VisitSite'),
  InsertColumn('island_id', Column.integer, onTable: 'VisitSite'),
  InsertColumn('name_es', Column.varchar, onTable: 'VisitSite'),
  InsertColumn('name_en', Column.varchar, onTable: 'VisitSite'),
  InsertColumn('latitude', Column.Double, onTable: 'VisitSite'),
  InsertColumn('longitude', Column.Double, onTable: 'VisitSite'),
  InsertColumn('description_es', Column.varchar, onTable: 'VisitSite'),
  InsertColumn('description_en', Column.varchar, onTable: 'VisitSite'),
  InsertColumn('site_type', Column.varchar, onTable: 'VisitSite'),
];

const List<MigrationCommand> _migration_20260211025650_down = [
  DropTable('Category'),
  DropTable('Island'),
  DropTable('Sighting'),
  DropTable('Species'),
  DropTable('SpeciesImage'),
  DropTable('SpeciesSite'),
  DropTable('UserFavorite'),
  DropTable('VisitSite'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260211025650',
  up: _migration_20260211025650_up,
  down: _migration_20260211025650_down,
)
class Migration20260211025650 extends Migration {
  const Migration20260211025650()
    : super(
        version: 20260211025650,
        up: _migration_20260211025650_up,
        down: _migration_20260211025650_down,
      );
}
