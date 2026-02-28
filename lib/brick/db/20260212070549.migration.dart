// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260212070549_up = [
  InsertColumn('is_primary', Column.boolean, onTable: 'SpeciesImage'),
  InsertColumn('thumbnail_url', Column.varchar, onTable: 'SpeciesImage')
];

const List<MigrationCommand> _migration_20260212070549_down = [
  DropColumn('is_primary', onTable: 'SpeciesImage'),
  DropColumn('thumbnail_url', onTable: 'SpeciesImage')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260212070549',
  up: _migration_20260212070549_up,
  down: _migration_20260212070549_down,
)
class Migration20260212070549 extends Migration {
  const Migration20260212070549()
    : super(
        version: 20260212070549,
        up: _migration_20260212070549_up,
        down: _migration_20260212070549_down,
      );
}
