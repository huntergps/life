// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260303163824_up = [
  InsertColumn('size_mm_female_min', Column.Double, onTable: 'Species'),
  InsertColumn('size_mm_female_max', Column.Double, onTable: 'Species'),
  InsertColumn('size_mm_male_min', Column.Double, onTable: 'Species'),
  InsertColumn('size_mm_male_max', Column.Double, onTable: 'Species'),
  InsertColumn('builds_web', Column.boolean, onTable: 'Species'),
  InsertColumn('web_type', Column.varchar, onTable: 'Species'),
  InsertColumn('venomous_to_humans', Column.boolean, onTable: 'Species'),
  InsertColumn('inaturalist_taxon_id', Column.integer, onTable: 'Species'),
  InsertColumn('datazone_id', Column.integer, onTable: 'Species')
];

const List<MigrationCommand> _migration_20260303163824_down = [
  DropColumn('size_mm_female_min', onTable: 'Species'),
  DropColumn('size_mm_female_max', onTable: 'Species'),
  DropColumn('size_mm_male_min', onTable: 'Species'),
  DropColumn('size_mm_male_max', onTable: 'Species'),
  DropColumn('builds_web', onTable: 'Species'),
  DropColumn('web_type', onTable: 'Species'),
  DropColumn('venomous_to_humans', onTable: 'Species'),
  DropColumn('inaturalist_taxon_id', onTable: 'Species'),
  DropColumn('datazone_id', onTable: 'Species')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260303163824',
  up: _migration_20260303163824_up,
  down: _migration_20260303163824_down,
)
class Migration20260303163824 extends Migration {
  const Migration20260303163824()
    : super(
        version: 20260303163824,
        up: _migration_20260303163824_up,
        down: _migration_20260303163824_down,
      );
}
