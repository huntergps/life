// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260216050308_up = [
  InsertTable('UserProfile'),
  InsertColumn('id', Column.varchar, onTable: 'UserProfile'),
  InsertColumn('display_name', Column.varchar, onTable: 'UserProfile'),
  InsertColumn('bio', Column.varchar, onTable: 'UserProfile'),
  InsertColumn('birth_date', Column.datetime, onTable: 'UserProfile'),
  InsertColumn('country', Column.varchar, onTable: 'UserProfile'),
  InsertColumn('country_code', Column.varchar, onTable: 'UserProfile'),
  InsertColumn('avatar_url', Column.varchar, onTable: 'UserProfile'),
  InsertColumn('created_at', Column.datetime, onTable: 'UserProfile'),
  InsertColumn('updated_at', Column.datetime, onTable: 'UserProfile'),
  InsertColumn('is_birthday_today', Column.boolean, onTable: 'UserProfile')
];

const List<MigrationCommand> _migration_20260216050308_down = [
  DropTable('UserProfile'),
  DropColumn('id', onTable: 'UserProfile'),
  DropColumn('display_name', onTable: 'UserProfile'),
  DropColumn('bio', onTable: 'UserProfile'),
  DropColumn('birth_date', onTable: 'UserProfile'),
  DropColumn('country', onTable: 'UserProfile'),
  DropColumn('country_code', onTable: 'UserProfile'),
  DropColumn('avatar_url', onTable: 'UserProfile'),
  DropColumn('created_at', onTable: 'UserProfile'),
  DropColumn('updated_at', onTable: 'UserProfile'),
  DropColumn('is_birthday_today', onTable: 'UserProfile')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260216050308',
  up: _migration_20260216050308_up,
  down: _migration_20260216050308_down,
)
class Migration20260216050308 extends Migration {
  const Migration20260216050308()
    : super(
        version: 20260216050308,
        up: _migration_20260216050308_up,
        down: _migration_20260216050308_down,
      );
}
