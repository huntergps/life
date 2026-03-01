// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20260301221322_up = [
  InsertTable('UserSiteWishlist'),
  InsertTable('UserSpeciesChecklist'),
  InsertColumn('id', Column.integer, onTable: 'UserSiteWishlist'),
  InsertColumn('user_id', Column.varchar, onTable: 'UserSiteWishlist'),
  InsertColumn('visit_site_id', Column.integer, onTable: 'UserSiteWishlist'),
  InsertColumn('created_at', Column.datetime, onTable: 'UserSiteWishlist'),
  InsertColumn('id', Column.integer, onTable: 'UserSpeciesChecklist'),
  InsertColumn('user_id', Column.varchar, onTable: 'UserSpeciesChecklist'),
  InsertColumn('species_id', Column.integer, onTable: 'UserSpeciesChecklist'),
  InsertColumn('seen_at', Column.datetime, onTable: 'UserSpeciesChecklist')
];

const List<MigrationCommand> _migration_20260301221322_down = [
  DropTable('UserSiteWishlist'),
  DropTable('UserSpeciesChecklist'),
  DropColumn('id', onTable: 'UserSiteWishlist'),
  DropColumn('user_id', onTable: 'UserSiteWishlist'),
  DropColumn('visit_site_id', onTable: 'UserSiteWishlist'),
  DropColumn('created_at', onTable: 'UserSiteWishlist'),
  DropColumn('id', onTable: 'UserSpeciesChecklist'),
  DropColumn('user_id', onTable: 'UserSpeciesChecklist'),
  DropColumn('species_id', onTable: 'UserSpeciesChecklist'),
  DropColumn('seen_at', onTable: 'UserSpeciesChecklist')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20260301221322',
  up: _migration_20260301221322_up,
  down: _migration_20260301221322_down,
)
class Migration20260301221322 extends Migration {
  const Migration20260301221322()
    : super(
        version: 20260301221322,
        up: _migration_20260301221322_up,
        down: _migration_20260301221322_down,
      );
}
