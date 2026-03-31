import 'package:drift/drift.dart';

class UserSiteWishlists extends Table {
  @override
  String get tableName => 'user_site_wishlist';

  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  TextColumn get userId => text()();
  IntColumn get visitSiteId => integer()();
  DateTimeColumn get createdAt => dateTime().nullable()();
}
