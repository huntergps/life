// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Trail> _$TrailFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Trail(
    id: data['id'] as int,
    nameEn: data['name_en'] as String,
    nameEs: data['name_es'] as String,
    descriptionEn: data['description_en'] == null
        ? null
        : data['description_en'] as String?,
    descriptionEs: data['description_es'] == null
        ? null
        : data['description_es'] as String?,
    islandId: data['island_id'] == null ? null : data['island_id'] as int?,
    visitSiteId: data['visit_site_id'] == null
        ? null
        : data['visit_site_id'] as int?,
    difficulty: data['difficulty'] == null
        ? null
        : data['difficulty'] as String?,
    distanceKm: data['distance_km'] == null
        ? null
        : data['distance_km'] as double?,
    estimatedMinutes: data['estimated_minutes'] == null
        ? null
        : data['estimated_minutes'] as int?,
    coordinates: data['coordinates'] as String,
    elevationGainM: data['elevation_gain_m'] == null
        ? null
        : data['elevation_gain_m'] as double?,
    userId: data['user_id'] == null ? null : data['user_id'] as String?,
  );
}

Future<Map<String, dynamic>> _$TrailToSupabase(
  Trail instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'name_en': instance.nameEn,
    'name_es': instance.nameEs,
    'description_en': instance.descriptionEn,
    'description_es': instance.descriptionEs,
    'island_id': instance.islandId,
    'visit_site_id': instance.visitSiteId,
    'difficulty': instance.difficulty,
    'distance_km': instance.distanceKm,
    'estimated_minutes': instance.estimatedMinutes,
    'coordinates': instance.coordinates,
    'elevation_gain_m': instance.elevationGainM,
    'user_id': instance.userId,
  };
}

Future<Trail> _$TrailFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Trail(
    id: data['id'] as int,
    nameEn: data['name_en'] as String,
    nameEs: data['name_es'] as String,
    descriptionEn: data['description_en'] == null
        ? null
        : data['description_en'] as String?,
    descriptionEs: data['description_es'] == null
        ? null
        : data['description_es'] as String?,
    islandId: data['island_id'] == null ? null : data['island_id'] as int?,
    visitSiteId: data['visit_site_id'] == null
        ? null
        : data['visit_site_id'] as int?,
    difficulty: data['difficulty'] == null
        ? null
        : data['difficulty'] as String?,
    distanceKm: data['distance_km'] == null
        ? null
        : data['distance_km'] as double?,
    estimatedMinutes: data['estimated_minutes'] == null
        ? null
        : data['estimated_minutes'] as int?,
    coordinates: data['coordinates'] as String,
    elevationGainM: data['elevation_gain_m'] == null
        ? null
        : data['elevation_gain_m'] as double?,
    userId: data['user_id'] == null ? null : data['user_id'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$TrailToSqlite(
  Trail instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'name_en': instance.nameEn,
    'name_es': instance.nameEs,
    'description_en': instance.descriptionEn,
    'description_es': instance.descriptionEs,
    'island_id': instance.islandId,
    'visit_site_id': instance.visitSiteId,
    'difficulty': instance.difficulty,
    'distance_km': instance.distanceKm,
    'estimated_minutes': instance.estimatedMinutes,
    'coordinates': instance.coordinates,
    'elevation_gain_m': instance.elevationGainM,
    'user_id': instance.userId,
  };
}

/// Construct a [Trail]
class TrailAdapter extends OfflineFirstWithSupabaseAdapter<Trail> {
  TrailAdapter();

  @override
  final supabaseTableName = 'trails';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'nameEn': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name_en',
    ),
    'nameEs': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name_es',
    ),
    'descriptionEn': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'description_en',
    ),
    'descriptionEs': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'description_es',
    ),
    'islandId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'island_id',
    ),
    'visitSiteId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'visit_site_id',
    ),
    'difficulty': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'difficulty',
    ),
    'distanceKm': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'distance_km',
    ),
    'estimatedMinutes': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'estimated_minutes',
    ),
    'coordinates': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'coordinates',
    ),
    'elevationGainM': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'elevation_gain_m',
    ),
    'userId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'user_id',
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
    'nameEn': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'name_en',
      iterable: false,
      type: String,
    ),
    'nameEs': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'name_es',
      iterable: false,
      type: String,
    ),
    'descriptionEn': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'description_en',
      iterable: false,
      type: String,
    ),
    'descriptionEs': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'description_es',
      iterable: false,
      type: String,
    ),
    'islandId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'island_id',
      iterable: false,
      type: int,
    ),
    'visitSiteId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'visit_site_id',
      iterable: false,
      type: int,
    ),
    'difficulty': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'difficulty',
      iterable: false,
      type: String,
    ),
    'distanceKm': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'distance_km',
      iterable: false,
      type: double,
    ),
    'estimatedMinutes': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'estimated_minutes',
      iterable: false,
      type: int,
    ),
    'coordinates': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'coordinates',
      iterable: false,
      type: String,
    ),
    'elevationGainM': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'elevation_gain_m',
      iterable: false,
      type: double,
    ),
    'userId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'user_id',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    Trail instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `Trail` WHERE id = ? LIMIT 1''',
      [instance.id],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'Trail';

  @override
  Future<Trail> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$TrailFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    Trail input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$TrailToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Trail> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$TrailFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    Trail input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async =>
      await _$TrailToSqlite(input, provider: provider, repository: repository);
}
