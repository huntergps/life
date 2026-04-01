import 'package:drift/drift.dart';

class Categories extends Table {
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  TextColumn get slug => text()();
  TextColumn get nameEs => text()();
  TextColumn get nameEn => text()();
  TextColumn get iconName => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
