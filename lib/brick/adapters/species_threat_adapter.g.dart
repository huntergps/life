// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SpeciesThreat> _$SpeciesThreatFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return SpeciesThreat(
    id: data['id'] as int,
    speciesId: data['species_id'] as int,
    threatType: data['threat_type'] as String,
    severity: data['severity'] as String,
    descriptionEs: data['description_es'] == null
        ? null
        : data['description_es'] as String?,
    descriptionEn: data['description_en'] == null
        ? null
        : data['description_en'] as String?,
  );
}

Future<Map<String, dynamic>> _$SpeciesThreatToSupabase(
  SpeciesThreat instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'species_id': instance.speciesId,
    'threat_type': instance.threatType,
    'severity': instance.severity,
    'description_es': instance.descriptionEs,
    'description_en': instance.descriptionEn,
  };
}

Future<SpeciesThreat> _$SpeciesThreatFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return SpeciesThreat(
    id: data['id'] as int,
    speciesId: data['species_id'] as int,
    threatType: data['threat_type'] as String,
    severity: data['severity'] as String,
    descriptionEs: data['description_es'] == null
        ? null
        : data['description_es'] as String?,
    descriptionEn: data['description_en'] == null
        ? null
        : data['description_en'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SpeciesThreatToSqlite(
  SpeciesThreat instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'species_id': instance.speciesId,
    'threat_type': instance.threatType,
    'severity': instance.severity,
    'description_es': instance.descriptionEs,
    'description_en': instance.descriptionEn,
  };
}

/// Construct a [SpeciesThreat]
class SpeciesThreatAdapter
    extends OfflineFirstWithSupabaseAdapter<SpeciesThreat> {
  SpeciesThreatAdapter();

  @override
  final supabaseTableName = 'species_threats';
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
    'threatType': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'threat_type',
    ),
    'severity': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'severity',
    ),
    'descriptionEs': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'description_es',
    ),
    'descriptionEn': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'description_en',
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
    'threatType': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'threat_type',
      iterable: false,
      type: String,
    ),
    'severity': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'severity',
      iterable: false,
      type: String,
    ),
    'descriptionEs': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'description_es',
      iterable: false,
      type: String,
    ),
    'descriptionEn': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'description_en',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    SpeciesThreat instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'SpeciesThreat';

  @override
  Future<SpeciesThreat> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesThreatFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    SpeciesThreat input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesThreatToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<SpeciesThreat> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesThreatFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    SpeciesThreat input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesThreatToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
