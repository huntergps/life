// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Sighting> _$SightingFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Sighting(
    id: data['id'] as int,
    userId: data['user_id'] as String,
    speciesId: data['species_id'] as int,
    visitSiteId: data['visit_site_id'] == null
        ? null
        : data['visit_site_id'] as int?,
    observedAt: data['observed_at'] == null
        ? null
        : data['observed_at'] == null
        ? null
        : DateTime.tryParse(data['observed_at'] as String),
    notes: data['notes'] == null ? null : data['notes'] as String?,
    latitude: data['latitude'] == null ? null : (data['latitude'] as num).toDouble(),
    longitude: data['longitude'] == null ? null : (data['longitude'] as num).toDouble(),
    photoUrl: data['photo_url'] == null ? null : data['photo_url'] as String?,
  );
}

Future<Map<String, dynamic>> _$SightingToSupabase(
  Sighting instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'user_id': instance.userId,
    'species_id': instance.speciesId,
    'visit_site_id': instance.visitSiteId,
    'observed_at': instance.observedAt?.toIso8601String(),
    'notes': instance.notes,
    'latitude': instance.latitude,
    'longitude': instance.longitude,
    'photo_url': instance.photoUrl,
  };
}

Future<Sighting> _$SightingFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Sighting(
    id: data['id'] as int,
    userId: data['user_id'] as String,
    speciesId: data['species_id'] as int,
    visitSiteId: data['visit_site_id'] == null
        ? null
        : data['visit_site_id'] as int?,
    observedAt: data['observed_at'] == null
        ? null
        : data['observed_at'] == null
        ? null
        : DateTime.tryParse(data['observed_at'] as String),
    notes: data['notes'] == null ? null : data['notes'] as String?,
    latitude: data['latitude'] == null ? null : (data['latitude'] as num).toDouble(),
    longitude: data['longitude'] == null ? null : (data['longitude'] as num).toDouble(),
    photoUrl: data['photo_url'] == null ? null : data['photo_url'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SightingToSqlite(
  Sighting instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'user_id': instance.userId,
    'species_id': instance.speciesId,
    'visit_site_id': instance.visitSiteId,
    'observed_at': instance.observedAt?.toIso8601String(),
    'notes': instance.notes,
    'latitude': instance.latitude,
    'longitude': instance.longitude,
    'photo_url': instance.photoUrl,
  };
}

/// Construct a [Sighting]
class SightingAdapter extends OfflineFirstWithSupabaseAdapter<Sighting> {
  SightingAdapter();

  @override
  final supabaseTableName = 'sightings';
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
    'visitSiteId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'visit_site_id',
    ),
    'observedAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'observed_at',
    ),
    'notes': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'notes',
    ),
    'latitude': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'latitude',
    ),
    'longitude': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'longitude',
    ),
    'photoUrl': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'photo_url',
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
    'visitSiteId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'visit_site_id',
      iterable: false,
      type: int,
    ),
    'observedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'observed_at',
      iterable: false,
      type: DateTime,
    ),
    'notes': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'notes',
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
    'photoUrl': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'photo_url',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    Sighting instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'Sighting';

  @override
  Future<Sighting> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SightingFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    Sighting input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SightingToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Sighting> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SightingFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    Sighting input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SightingToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
