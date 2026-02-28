// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SpeciesReference> _$SpeciesReferenceFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return SpeciesReference(
    id: data['id'] as int,
    speciesId: data['species_id'] as int,
    citation: data['citation'] as String,
    url: data['url'] == null ? null : data['url'] as String?,
    doi: data['doi'] == null ? null : data['doi'] as String?,
    referenceType: data['reference_type'] == null
        ? null
        : data['reference_type'] as String?,
  );
}

Future<Map<String, dynamic>> _$SpeciesReferenceToSupabase(
  SpeciesReference instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'species_id': instance.speciesId,
    'citation': instance.citation,
    'url': instance.url,
    'doi': instance.doi,
    'reference_type': instance.referenceType,
  };
}

Future<SpeciesReference> _$SpeciesReferenceFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return SpeciesReference(
    id: data['id'] as int,
    speciesId: data['species_id'] as int,
    citation: data['citation'] as String,
    url: data['url'] == null ? null : data['url'] as String?,
    doi: data['doi'] == null ? null : data['doi'] as String?,
    referenceType: data['reference_type'] == null
        ? null
        : data['reference_type'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SpeciesReferenceToSqlite(
  SpeciesReference instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'species_id': instance.speciesId,
    'citation': instance.citation,
    'url': instance.url,
    'doi': instance.doi,
    'reference_type': instance.referenceType,
  };
}

/// Construct a [SpeciesReference]
class SpeciesReferenceAdapter
    extends OfflineFirstWithSupabaseAdapter<SpeciesReference> {
  SpeciesReferenceAdapter();

  @override
  final supabaseTableName = 'species_references';
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
    'citation': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'citation',
    ),
    'url': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'url',
    ),
    'doi': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'doi',
    ),
    'referenceType': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'reference_type',
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
    'citation': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'citation',
      iterable: false,
      type: String,
    ),
    'url': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'url',
      iterable: false,
      type: String,
    ),
    'doi': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'doi',
      iterable: false,
      type: String,
    ),
    'referenceType': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'reference_type',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    SpeciesReference instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'SpeciesReference';

  @override
  Future<SpeciesReference> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesReferenceFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    SpeciesReference input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesReferenceToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<SpeciesReference> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesReferenceFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    SpeciesReference input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesReferenceToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
