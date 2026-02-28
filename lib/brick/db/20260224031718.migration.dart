// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260224031718_up = [
  DropColumn('id', onTable: 'Trail'),
  InsertColumn('id', Column.integer, onTable: 'Trail', unique: true)
];

const List<MigrationCommand> _migration_20260224031718_down = [
  DropColumn('id', onTable: 'Trail')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260224031718',
  up: _migration_20260224031718_up,
  down: _migration_20260224031718_down,
)
class Migration20260224031718 extends Migration {
  const Migration20260224031718()
    : super(
        version: 20260224031718,
        up: _migration_20260224031718_up,
        down: _migration_20260224031718_down,
      );
}
