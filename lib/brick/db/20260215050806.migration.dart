// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260215050806_up = [
  InsertTable('Trail'),
  InsertColumn('id', Column.integer, onTable: 'Trail'),
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
  InsertColumn('elevation_gain_m', Column.Double, onTable: 'Trail')
];

const List<MigrationCommand> _migration_20260215050806_down = [
  DropTable('Trail'),
  DropColumn('id', onTable: 'Trail'),
  DropColumn('name_en', onTable: 'Trail'),
  DropColumn('name_es', onTable: 'Trail'),
  DropColumn('description_en', onTable: 'Trail'),
  DropColumn('description_es', onTable: 'Trail'),
  DropColumn('island_id', onTable: 'Trail'),
  DropColumn('visit_site_id', onTable: 'Trail'),
  DropColumn('difficulty', onTable: 'Trail'),
  DropColumn('distance_km', onTable: 'Trail'),
  DropColumn('estimated_minutes', onTable: 'Trail'),
  DropColumn('coordinates', onTable: 'Trail'),
  DropColumn('elevation_gain_m', onTable: 'Trail')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260215050806',
  up: _migration_20260215050806_up,
  down: _migration_20260215050806_down,
)
class Migration20260215050806 extends Migration {
  const Migration20260215050806()
    : super(
        version: 20260215050806,
        up: _migration_20260215050806_up,
        down: _migration_20260215050806_down,
      );
}
