import 'package:drift/drift.dart';

class SpeciesThreats extends Table {
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get speciesId => integer()();
  TextColumn get threatType => text()();
  TextColumn get severity => text()();
  TextColumn get descriptionEs => text().nullable()();
  TextColumn get descriptionEn => text().nullable()();
}
