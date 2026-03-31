import 'package:drift/drift.dart';

class Islands extends Table {
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  TextColumn get nameEs => text()();
  TextColumn get nameEn => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get areaKm2 => real().nullable()();
  RealColumn get areaHa => real().nullable()();
  TextColumn get descriptionEs => text().nullable()();
  TextColumn get descriptionEn => text().nullable()();
  TextColumn get parkId => text().nullable()();
  TextColumn get islandType => text().nullable()();
  TextColumn get classification => text().nullable()();
  BoolColumn get isPopulated => boolean().nullable()();
}
