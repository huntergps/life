import 'package:drift/drift.dart';

class SpeciesSounds extends Table {
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get speciesId => integer()();
  TextColumn get soundUrl => text()();
  TextColumn get soundType => text().nullable()();
  TextColumn get descriptionEs => text().nullable()();
  TextColumn get descriptionEn => text().nullable()();
  TextColumn get recordedBy => text().nullable()();
  DateTimeColumn get recordedDate => dateTime().nullable()();
}
