import 'package:drift/drift.dart';

class SpeciesReferences extends Table {
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get speciesId => integer()();
  TextColumn get citation => text()();
  TextColumn get url => text().nullable()();
  TextColumn get doi => text().nullable()();
  TextColumn get referenceType => text().nullable()();
}
