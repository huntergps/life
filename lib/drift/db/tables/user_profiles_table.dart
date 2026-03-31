import 'package:drift/drift.dart';

class UserProfiles extends Table {
  @override
  String get tableName => 'profiles';

  @override
  Set<Column> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get bio => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get countryCode => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
