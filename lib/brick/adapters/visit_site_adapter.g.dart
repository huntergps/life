// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<VisitSite> _$VisitSiteFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return VisitSite(
    id: data['id'] as int,
    islandId: data['island_id'] == null ? null : data['island_id'] as int?,
    nameEs: data['name_es'] as String,
    nameEn: data['name_en'] == null ? null : data['name_en'] as String?,
    latitude: data['latitude'] == null ? null : (data['latitude'] as num).toDouble(),
    longitude: data['longitude'] == null ? null : (data['longitude'] as num).toDouble(),
    descriptionEs: data['description_es'] == null
        ? null
        : data['description_es'] as String?,
    descriptionEn: data['description_en'] == null
        ? null
        : data['description_en'] as String?,
    monitoringType: data['monitoring_type'] == null
        ? null
        : data['monitoring_type'] as String?,
    difficulty: data['difficulty'] == null
        ? null
        : data['difficulty'] as String?,
    conservationZone: data['conservation_zone'] == null
        ? null
        : data['conservation_zone'] as String?,
    publicUseZone: data['public_use_zone'] == null
        ? null
        : data['public_use_zone'] as String?,
    capacity: data['capacity'] == null ? null : data['capacity'] as int?,
    status: data['status'] == null ? null : data['status'] as String?,
    attractionEs: data['attraction_es'] == null
        ? null
        : data['attraction_es'] as String?,
    abbreviation: data['abbreviation'] == null
        ? null
        : data['abbreviation'] as String?,
    parkId: data['park_id'] == null ? null : data['park_id'] as String?,
  );
}

Future<Map<String, dynamic>> _$VisitSiteToSupabase(
  VisitSite instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'island_id': instance.islandId,
    'name_es': instance.nameEs,
    'name_en': instance.nameEn,
    'latitude': instance.latitude,
    'longitude': instance.longitude,
    'description_es': instance.descriptionEs,
    'description_en': instance.descriptionEn,
    'monitoring_type': instance.monitoringType,
    'difficulty': instance.difficulty,
    'conservation_zone': instance.conservationZone,
    'public_use_zone': instance.publicUseZone,
    'capacity': instance.capacity,
    'status': instance.status,
    'attraction_es': instance.attractionEs,
    'abbreviation': instance.abbreviation,
    'park_id': instance.parkId,
  };
}

Future<VisitSite> _$VisitSiteFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return VisitSite(
    id: data['id'] as int,
    islandId: data['island_id'] == null ? null : data['island_id'] as int?,
    nameEs: data['name_es'] as String,
    nameEn: data['name_en'] == null ? null : data['name_en'] as String?,
    latitude: data['latitude'] == null ? null : (data['latitude'] as num).toDouble(),
    longitude: data['longitude'] == null ? null : (data['longitude'] as num).toDouble(),
    descriptionEs: data['description_es'] == null
        ? null
        : data['description_es'] as String?,
    descriptionEn: data['description_en'] == null
        ? null
        : data['description_en'] as String?,
    monitoringType: data['monitoring_type'] == null
        ? null
        : data['monitoring_type'] as String?,
    difficulty: data['difficulty'] == null
        ? null
        : data['difficulty'] as String?,
    conservationZone: data['conservation_zone'] == null
        ? null
        : data['conservation_zone'] as String?,
    publicUseZone: data['public_use_zone'] == null
        ? null
        : data['public_use_zone'] as String?,
    capacity: data['capacity'] == null ? null : data['capacity'] as int?,
    status: data['status'] == null ? null : data['status'] as String?,
    attractionEs: data['attraction_es'] == null
        ? null
        : data['attraction_es'] as String?,
    abbreviation: data['abbreviation'] == null
        ? null
        : data['abbreviation'] as String?,
    parkId: data['park_id'] == null ? null : data['park_id'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$VisitSiteToSqlite(
  VisitSite instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'island_id': instance.islandId,
    'name_es': instance.nameEs,
    'name_en': instance.nameEn,
    'latitude': instance.latitude,
    'longitude': instance.longitude,
    'description_es': instance.descriptionEs,
    'description_en': instance.descriptionEn,
    'monitoring_type': instance.monitoringType,
    'difficulty': instance.difficulty,
    'conservation_zone': instance.conservationZone,
    'public_use_zone': instance.publicUseZone,
    'capacity': instance.capacity,
    'status': instance.status,
    'attraction_es': instance.attractionEs,
    'abbreviation': instance.abbreviation,
    'park_id': instance.parkId,
  };
}

/// Construct a [VisitSite]
class VisitSiteAdapter extends OfflineFirstWithSupabaseAdapter<VisitSite> {
  VisitSiteAdapter();

  @override
  final supabaseTableName = 'visit_sites';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'islandId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'island_id',
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
    'descriptionEs': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'description_es',
    ),
    'descriptionEn': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'description_en',
    ),
    'monitoringType': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'monitoring_type',
    ),
    'difficulty': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'difficulty',
    ),
    'conservationZone': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'conservation_zone',
    ),
    'publicUseZone': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'public_use_zone',
    ),
    'capacity': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'capacity',
    ),
    'status': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'status',
    ),
    'attractionEs': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'attraction_es',
    ),
    'abbreviation': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'abbreviation',
    ),
    'parkId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'park_id',
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
    'islandId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'island_id',
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
    'monitoringType': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'monitoring_type',
      iterable: false,
      type: String,
    ),
    'difficulty': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'difficulty',
      iterable: false,
      type: String,
    ),
    'conservationZone': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'conservation_zone',
      iterable: false,
      type: String,
    ),
    'publicUseZone': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'public_use_zone',
      iterable: false,
      type: String,
    ),
    'capacity': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'capacity',
      iterable: false,
      type: int,
    ),
    'status': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'status',
      iterable: false,
      type: String,
    ),
    'attractionEs': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'attraction_es',
      iterable: false,
      type: String,
    ),
    'abbreviation': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'abbreviation',
      iterable: false,
      type: String,
    ),
    'parkId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'park_id',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    VisitSite instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'VisitSite';

  @override
  Future<VisitSite> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$VisitSiteFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    VisitSite input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$VisitSiteToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<VisitSite> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$VisitSiteFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    VisitSite input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$VisitSiteToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
