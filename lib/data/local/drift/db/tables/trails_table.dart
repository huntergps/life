import 'package:drift/drift.dart';

class Trails extends Table {
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  TextColumn get nameEn => text()();
  TextColumn get nameEs => text()();
  TextColumn get descriptionEn => text().nullable()();
  TextColumn get descriptionEs => text().nullable()();
  IntColumn get islandId => integer().nullable()();
  IntColumn get visitSiteId => integer().nullable()();
  TextColumn get difficulty => text().nullable()();
  RealColumn get distanceKm => real().nullable()();
  IntColumn get estimatedMinutes => integer().nullable()();
  TextColumn get coordinates =>
      text().withDefault(const Constant('[]'))();
  RealColumn get elevationGainM => real().nullable()();
  TextColumn get userId => text().nullable()();
}
