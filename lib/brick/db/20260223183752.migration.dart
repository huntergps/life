// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260223183752_up = [
  DropColumn('site_type', onTable: 'VisitSite'),
  InsertColumn('area_ha', Column.Double, onTable: 'Island'),
  InsertColumn('park_id', Column.varchar, onTable: 'Island'),
  InsertColumn('island_type', Column.varchar, onTable: 'Island'),
  InsertColumn('classification', Column.varchar, onTable: 'Island'),
  InsertColumn('is_populated', Column.boolean, onTable: 'Island'),
  InsertColumn('monitoring_type', Column.varchar, onTable: 'VisitSite'),
  InsertColumn('difficulty', Column.varchar, onTable: 'VisitSite'),
  InsertColumn('conservation_zone', Column.varchar, onTable: 'VisitSite'),
  InsertColumn('public_use_zone', Column.varchar, onTable: 'VisitSite'),
  InsertColumn('capacity', Column.integer, onTable: 'VisitSite'),
  InsertColumn('status', Column.varchar, onTable: 'VisitSite'),
  InsertColumn('attraction_es', Column.varchar, onTable: 'VisitSite'),
  InsertColumn('abbreviation', Column.varchar, onTable: 'VisitSite'),
  InsertColumn('park_id', Column.varchar, onTable: 'VisitSite')
];

const List<MigrationCommand> _migration_20260223183752_down = [
  DropColumn('area_ha', onTable: 'Island'),
  DropColumn('park_id', onTable: 'Island'),
  DropColumn('island_type', onTable: 'Island'),
  DropColumn('classification', onTable: 'Island'),
  DropColumn('is_populated', onTable: 'Island'),
  DropColumn('monitoring_type', onTable: 'VisitSite'),
  DropColumn('difficulty', onTable: 'VisitSite'),
  DropColumn('conservation_zone', onTable: 'VisitSite'),
  DropColumn('public_use_zone', onTable: 'VisitSite'),
  DropColumn('capacity', onTable: 'VisitSite'),
  DropColumn('status', onTable: 'VisitSite'),
  DropColumn('attraction_es', onTable: 'VisitSite'),
  DropColumn('abbreviation', onTable: 'VisitSite'),
  DropColumn('park_id', onTable: 'VisitSite')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260223183752',
  up: _migration_20260223183752_up,
  down: _migration_20260223183752_down,
)
class Migration20260223183752 extends Migration {
  const Migration20260223183752()
    : super(
        version: 20260223183752,
        up: _migration_20260223183752_up,
        down: _migration_20260223183752_down,
      );
}
