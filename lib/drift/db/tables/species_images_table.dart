import 'package:drift/drift.dart';

class SpeciesImages extends Table {
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get speciesId => integer()();
  TextColumn get imageUrl => text()();
  TextColumn get captionEs => text().nullable()();
  TextColumn get captionEn => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isPrimary =>
      boolean().withDefault(const Constant(false))();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get cardThumbnailUrl => text().nullable()();
}
