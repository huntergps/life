// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<UserSpeciesChecklist> _$UserSpeciesChecklistFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return UserSpeciesChecklist(
    id: data['id'] as int,
    userId: data['user_id'] as String,
    speciesId: data['species_id'] as int,
    seenAt: data['seen_at'] == null
        ? null
        : data['seen_at'] == null
        ? null
        : DateTime.tryParse(data['seen_at'] as String),
  );
}

Future<Map<String, dynamic>> _$UserSpeciesChecklistToSupabase(
  UserSpeciesChecklist instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'user_id': instance.userId,
    'species_id': instance.speciesId,
    'seen_at': instance.seenAt?.toIso8601String(),
  };
}

Future<UserSpeciesChecklist> _$UserSpeciesChecklistFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return UserSpeciesChecklist(
    id: data['id'] as int,
    userId: data['user_id'] as String,
    speciesId: data['species_id'] as int,
    seenAt: data['seen_at'] == null
        ? null
        : data['seen_at'] == null
        ? null
        : DateTime.tryParse(data['seen_at'] as String),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$UserSpeciesChecklistToSqlite(
  UserSpeciesChecklist instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'user_id': instance.userId,
    'species_id': instance.speciesId,
    'seen_at': instance.seenAt?.toIso8601String(),
  };
}

/// Construct a [UserSpeciesChecklist]
class UserSpeciesChecklistAdapter
    extends OfflineFirstWithSupabaseAdapter<UserSpeciesChecklist> {
  UserSpeciesChecklistAdapter();

  @override
  final supabaseTableName = 'user_species_checklist';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'userId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'user_id',
    ),
    'speciesId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'species_id',
    ),
    'seenAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'seen_at',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'id'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'id': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'id',
      iterable: false,
      type: int,
    ),
    'userId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'user_id',
      iterable: false,
      type: String,
    ),
    'speciesId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'species_id',
      iterable: false,
      type: int,
    ),
    'seenAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'seen_at',
      iterable: false,
      type: DateTime,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    UserSpeciesChecklist instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'UserSpeciesChecklist';

  @override
  Future<UserSpeciesChecklist> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserSpeciesChecklistFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    UserSpeciesChecklist input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserSpeciesChecklistToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<UserSpeciesChecklist> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserSpeciesChecklistFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    UserSpeciesChecklist input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserSpeciesChecklistToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
