// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SpeciesSound> _$SpeciesSoundFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return SpeciesSound(
    id: data['id'] as int,
    speciesId: data['species_id'] as int,
    soundUrl: data['sound_url'] as String,
    soundType: data['sound_type'] == null
        ? null
        : data['sound_type'] as String?,
    descriptionEs: data['description_es'] == null
        ? null
        : data['description_es'] as String?,
    descriptionEn: data['description_en'] == null
        ? null
        : data['description_en'] as String?,
    recordedBy: data['recorded_by'] == null
        ? null
        : data['recorded_by'] as String?,
    recordedDate: data['recorded_date'] == null
        ? null
        : data['recorded_date'] == null
        ? null
        : DateTime.tryParse(data['recorded_date'] as String),
  );
}

Future<Map<String, dynamic>> _$SpeciesSoundToSupabase(
  SpeciesSound instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'species_id': instance.speciesId,
    'sound_url': instance.soundUrl,
    'sound_type': instance.soundType,
    'description_es': instance.descriptionEs,
    'description_en': instance.descriptionEn,
    'recorded_by': instance.recordedBy,
    'recorded_date': instance.recordedDate?.toIso8601String(),
  };
}

Future<SpeciesSound> _$SpeciesSoundFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return SpeciesSound(
    id: data['id'] as int,
    speciesId: data['species_id'] as int,
    soundUrl: data['sound_url'] as String,
    soundType: data['sound_type'] == null
        ? null
        : data['sound_type'] as String?,
    descriptionEs: data['description_es'] == null
        ? null
        : data['description_es'] as String?,
    descriptionEn: data['description_en'] == null
        ? null
        : data['description_en'] as String?,
    recordedBy: data['recorded_by'] == null
        ? null
        : data['recorded_by'] as String?,
    recordedDate: data['recorded_date'] == null
        ? null
        : data['recorded_date'] == null
        ? null
        : DateTime.tryParse(data['recorded_date'] as String),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SpeciesSoundToSqlite(
  SpeciesSound instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'species_id': instance.speciesId,
    'sound_url': instance.soundUrl,
    'sound_type': instance.soundType,
    'description_es': instance.descriptionEs,
    'description_en': instance.descriptionEn,
    'recorded_by': instance.recordedBy,
    'recorded_date': instance.recordedDate?.toIso8601String(),
  };
}

/// Construct a [SpeciesSound]
class SpeciesSoundAdapter
    extends OfflineFirstWithSupabaseAdapter<SpeciesSound> {
  SpeciesSoundAdapter();

  @override
  final supabaseTableName = 'species_sounds';
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
    'soundUrl': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'sound_url',
    ),
    'soundType': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'sound_type',
    ),
    'descriptionEs': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'description_es',
    ),
    'descriptionEn': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'description_en',
    ),
    'recordedBy': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'recorded_by',
    ),
    'recordedDate': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'recorded_date',
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
    'soundUrl': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sound_url',
      iterable: false,
      type: String,
    ),
    'soundType': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sound_type',
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
    'recordedBy': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'recorded_by',
      iterable: false,
      type: String,
    ),
    'recordedDate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'recorded_date',
      iterable: false,
      type: DateTime,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    SpeciesSound instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'SpeciesSound';

  @override
  Future<SpeciesSound> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesSoundFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    SpeciesSound input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesSoundToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<SpeciesSound> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesSoundFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    SpeciesSound input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesSoundToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
