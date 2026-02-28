// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SpeciesSite> _$SpeciesSiteFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return SpeciesSite(
    id: data['id'] as int,
    speciesId: data['species_id'] as int,
    visitSiteId: data['visit_site_id'] as int,
    frequency: data['frequency'] == null ? null : data['frequency'] as String?,
  );
}

Future<Map<String, dynamic>> _$SpeciesSiteToSupabase(
  SpeciesSite instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'species_id': instance.speciesId,
    'visit_site_id': instance.visitSiteId,
    'frequency': instance.frequency,
  };
}

Future<SpeciesSite> _$SpeciesSiteFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return SpeciesSite(
    id: data['id'] as int,
    speciesId: data['species_id'] as int,
    visitSiteId: data['visit_site_id'] as int,
    frequency: data['frequency'] == null ? null : data['frequency'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SpeciesSiteToSqlite(
  SpeciesSite instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'species_id': instance.speciesId,
    'visit_site_id': instance.visitSiteId,
    'frequency': instance.frequency,
  };
}

/// Construct a [SpeciesSite]
class SpeciesSiteAdapter extends OfflineFirstWithSupabaseAdapter<SpeciesSite> {
  SpeciesSiteAdapter();

  @override
  final supabaseTableName = 'species_sites';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'speciesId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'species_id',
    ),
    'visitSiteId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'visit_site_id',
    ),
    'frequency': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'frequency',
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
    'speciesId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'species_id',
      iterable: false,
      type: int,
    ),
    'visitSiteId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'visit_site_id',
      iterable: false,
      type: int,
    ),
    'frequency': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'frequency',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    SpeciesSite instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'SpeciesSite';

  @override
  Future<SpeciesSite> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesSiteFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    SpeciesSite input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesSiteToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<SpeciesSite> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesSiteFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    SpeciesSite input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesSiteToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
