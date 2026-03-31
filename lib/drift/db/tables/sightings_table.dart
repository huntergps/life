import 'package:drift/drift.dart';

class Sightings extends Table {
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  TextColumn get userId => text()();
  IntColumn get speciesId => integer()();
  IntColumn get visitSiteId => integer().nullable()();
  DateTimeColumn get observedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get photoUrl => text().nullable()();
}
