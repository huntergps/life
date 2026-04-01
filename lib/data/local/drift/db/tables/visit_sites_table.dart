import 'package:drift/drift.dart';

class VisitSites extends Table {
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get islandId => integer().nullable()();
  TextColumn get nameEs => text()();
  TextColumn get nameEn => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get descriptionEs => text().nullable()();
  TextColumn get descriptionEn => text().nullable()();
  TextColumn get monitoringType => text().nullable()();
  TextColumn get difficulty => text().nullable()();
  TextColumn get conservationZone => text().nullable()();
  TextColumn get publicUseZone => text().nullable()();
  IntColumn get capacity => integer().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get attractionEs => text().nullable()();
  TextColumn get abbreviation => text().nullable()();
  TextColumn get parkId => text().nullable()();
}
