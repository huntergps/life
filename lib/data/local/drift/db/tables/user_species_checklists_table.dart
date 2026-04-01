import 'package:drift/drift.dart';

class UserSpeciesChecklists extends Table {
  @override
  String get tableName => 'user_species_checklist';

  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  TextColumn get userId => text()();
  IntColumn get speciesId => integer()();
  DateTimeColumn get seenAt => dateTime().nullable()();
}
