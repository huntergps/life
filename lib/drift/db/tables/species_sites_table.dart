import 'package:drift/drift.dart';

class SpeciesSites extends Table {
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get speciesId => integer()();
  IntColumn get visitSiteId => integer()();
  TextColumn get frequency => text().nullable()();
}
