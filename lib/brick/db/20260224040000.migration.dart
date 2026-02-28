// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// Migration: fix Trail table after migration 20260224031718 dropped the id column
// and left all existing rows with id = NULL, causing a null cast error in the adapter.
// Solution: drop and recreate the Trail table so Brick fetches fresh data from Supabase.

const List<MigrationCommand> _migration_20260224040000_up = [
  DropTable('Trail'),
  InsertTable('Trail'),
  InsertColumn('id', Column.integer, onTable: 'Trail', unique: true),
  InsertColumn('name_en', Column.varchar, onTable: 'Trail'),
  InsertColumn('name_es', Column.varchar, onTable: 'Trail'),
  InsertColumn('description_en', Column.varchar, onTable: 'Trail'),
  InsertColumn('description_es', Column.varchar, onTable: 'Trail'),
  InsertColumn('island_id', Column.integer, onTable: 'Trail'),
  InsertColumn('visit_site_id', Column.integer, onTable: 'Trail'),
  InsertColumn('difficulty', Column.varchar, onTable: 'Trail'),
  InsertColumn('distance_km', Column.Double, onTable: 'Trail'),
  InsertColumn('estimated_minutes', Column.integer, onTable: 'Trail'),
  InsertColumn('coordinates', Column.varchar, onTable: 'Trail'),
  InsertColumn('elevation_gain_m', Column.Double, onTable: 'Trail'),
  InsertColumn('user_id', Column.varchar, onTable: 'Trail'),
];

const List<MigrationCommand> _migration_20260224040000_down = [
  DropTable('Trail'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260224040000',
  up: _migration_20260224040000_up,
  down: _migration_20260224040000_down,
)
class Migration20260224040000 extends Migration {
  const Migration20260224040000()
    : super(
        version: 20260224040000,
        up: _migration_20260224040000_up,
        down: _migration_20260224040000_down,
      );
}
