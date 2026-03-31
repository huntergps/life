import 'package:drift/drift.dart';

class UserFavorites extends Table {
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  TextColumn get userId => text()();
  IntColumn get speciesId => integer()();
}
