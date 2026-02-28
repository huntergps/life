// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Island> _$IslandFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Island(
    id: data['id'] as int,
    nameEs: data['name_es'] as String,
    nameEn: data['name_en'] as String,
    latitude: data['latitude'] == null ? null : (data['latitude'] as num).toDouble(),
    longitude: data['longitude'] == null ? null : (data['longitude'] as num).toDouble(),
    areaKm2: data['area_km2'] == null ? null : (data['area_km2'] as num).toDouble(),
    areaHa: data['area_ha'] == null ? null : (data['area_ha'] as num).toDouble(),
    descriptionEs: data['description_es'] == null
        ? null
        : data['description_es'] as String?,
    descriptionEn: data['description_en'] == null
        ? null
        : data['description_en'] as String?,
    parkId: data['park_id'] == null ? null : data['park_id'] as String?,
    islandType: data['island_type'] == null
        ? null
        : data['island_type'] as String?,
    classification: data['classification'] == null
        ? null
        : data['classification'] as String?,
    isPopulated: data['is_populated'] == null
        ? null
        : data['is_populated'] as bool?,
  );
}

Future<Map<String, dynamic>> _$IslandToSupabase(
  Island instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'name_es': instance.nameEs,
    'name_en': instance.nameEn,
    'latitude': instance.latitude,
    'longitude': instance.longitude,
    'area_km2': instance.areaKm2,
    'area_ha': instance.areaHa,
    'description_es': instance.descriptionEs,
    'description_en': instance.descriptionEn,
    'park_id': instance.parkId,
    'island_type': instance.islandType,
    'classification': instance.classification,
    'is_populated': instance.isPopulated,
  };
}

Future<Island> _$IslandFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Island(
    id: data['id'] as int,
    nameEs: data['name_es'] as String,
    nameEn: data['name_en'] as String,
    latitude: data['latitude'] == null ? null : (data['latitude'] as num).toDouble(),
    longitude: data['longitude'] == null ? null : (data['longitude'] as num).toDouble(),
    areaKm2: data['area_km2'] == null ? null : (data['area_km2'] as num).toDouble(),
    areaHa: data['area_ha'] == null ? null : (data['area_ha'] as num).toDouble(),
    descriptionEs: data['description_es'] == null
        ? null
        : data['description_es'] as String?,
    descriptionEn: data['description_en'] == null
        ? null
        : data['description_en'] as String?,
    parkId: data['park_id'] == null ? null : data['park_id'] as String?,
    islandType: data['island_type'] == null
        ? null
        : data['island_type'] as String?,
    classification: data['classification'] == null
        ? null
        : data['classification'] as String?,
    isPopulated: data['is_populated'] == null
        ? null
        : data['is_populated'] == 1,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$IslandToSqlite(
  Island instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'name_es': instance.nameEs,
    'name_en': instance.nameEn,
    'latitude': instance.latitude,
    'longitude': instance.longitude,
    'area_km2': instance.areaKm2,
    'area_ha': instance.areaHa,
    'description_es': instance.descriptionEs,
    'description_en': instance.descriptionEn,
    'park_id': instance.parkId,
    'island_type': instance.islandType,
    'classification': instance.classification,
    'is_populated': instance.isPopulated == null
        ? null
        : (instance.isPopulated! ? 1 : 0),
  };
}

/// Construct a [Island]
class IslandAdapter extends OfflineFirstWithSupabaseAdapter<Island> {
  IslandAdapter();

  @override
  final supabaseTableName = 'islands';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'nameEs': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name_es',
    ),
    'nameEn': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name_en',
    ),
    'latitude': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'latitude',
    ),
    'longitude': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'longitude',
    ),
    'areaKm2': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'area_km2',
    ),
    'areaHa': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'area_ha',
    ),
    'descriptionEs': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'description_es',
    ),
    'descriptionEn': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'description_en',
    ),
    'parkId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'park_id',
    ),
    'islandType': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'island_type',
    ),
    'classification': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'classification',
    ),
    'isPopulated': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'is_populated',
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
    'nameEs': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'name_es',
      iterable: false,
      type: String,
    ),
    'nameEn': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'name_en',
      iterable: false,
      type: String,
    ),
    'latitude': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'latitude',
      iterable: false,
      type: double,
    ),
    'longitude': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'longitude',
      iterable: false,
      type: double,
    ),
    'areaKm2': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'area_km2',
      iterable: false,
      type: double,
    ),
    'areaHa': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'area_ha',
      iterable: false,
      type: double,
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
    'parkId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'park_id',
      iterable: false,
      type: String,
    ),
    'islandType': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'island_type',
      iterable: false,
      type: String,
    ),
    'classification': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'classification',
      iterable: false,
      type: String,
    ),
    'isPopulated': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_populated',
      iterable: false,
      type: bool,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    Island instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'Island';

  @override
  Future<Island> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$IslandFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    Island input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$IslandToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Island> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$IslandFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    Island input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async =>
      await _$IslandToSqlite(input, provider: provider, repository: repository);
}
