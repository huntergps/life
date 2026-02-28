// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260223201904_up = [
  InsertColumn('user_id', Column.varchar, onTable: 'Trail')
];

const List<MigrationCommand> _migration_20260223201904_down = [
  DropColumn('user_id', onTable: 'Trail')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260223201904',
  up: _migration_20260223201904_up,
  down: _migration_20260223201904_down,
)
class Migration20260223201904 extends Migration {
  const Migration20260223201904()
    : super(
        version: 20260223201904,
        up: _migration_20260223201904_up,
        down: _migration_20260223201904_down,
      );
}
