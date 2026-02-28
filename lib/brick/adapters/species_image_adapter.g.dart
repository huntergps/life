// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SpeciesImage> _$SpeciesImageFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return SpeciesImage(
    id: data['id'] as int,
    speciesId: data['species_id'] as int,
    imageUrl: data['image_url'] as String,
    captionEs: data['caption_es'] == null
        ? null
        : data['caption_es'] as String?,
    captionEn: data['caption_en'] == null
        ? null
        : data['caption_en'] as String?,
    sortOrder: data['sort_order'] as int,
    isPrimary: data['is_primary'] as bool,
    thumbnailUrl: data['thumbnail_url'] == null
        ? null
        : data['thumbnail_url'] as String?,
    cardThumbnailUrl: data['card_thumbnail_url'] == null
        ? null
        : data['card_thumbnail_url'] as String?,
  );
}

Future<Map<String, dynamic>> _$SpeciesImageToSupabase(
  SpeciesImage instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'species_id': instance.speciesId,
    'image_url': instance.imageUrl,
    'caption_es': instance.captionEs,
    'caption_en': instance.captionEn,
    'sort_order': instance.sortOrder,
    'is_primary': instance.isPrimary,
    'thumbnail_url': instance.thumbnailUrl,
    'card_thumbnail_url': instance.cardThumbnailUrl,
  };
}

Future<SpeciesImage> _$SpeciesImageFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return SpeciesImage(
    id: data['id'] as int,
    speciesId: data['species_id'] as int,
    imageUrl: data['image_url'] as String,
    captionEs: data['caption_es'] == null
        ? null
        : data['caption_es'] as String?,
    captionEn: data['caption_en'] == null
        ? null
        : data['caption_en'] as String?,
    sortOrder: data['sort_order'] as int,
    isPrimary: data['is_primary'] == 1,
    thumbnailUrl: data['thumbnail_url'] == null
        ? null
        : data['thumbnail_url'] as String?,
    cardThumbnailUrl: data['card_thumbnail_url'] == null
        ? null
        : data['card_thumbnail_url'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SpeciesImageToSqlite(
  SpeciesImage instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'species_id': instance.speciesId,
    'image_url': instance.imageUrl,
    'caption_es': instance.captionEs,
    'caption_en': instance.captionEn,
    'sort_order': instance.sortOrder,
    'is_primary': instance.isPrimary ? 1 : 0,
    'thumbnail_url': instance.thumbnailUrl,
    'card_thumbnail_url': instance.cardThumbnailUrl,
  };
}

/// Construct a [SpeciesImage]
class SpeciesImageAdapter
    extends OfflineFirstWithSupabaseAdapter<SpeciesImage> {
  SpeciesImageAdapter();

  @override
  final supabaseTableName = 'species_images';
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
    'imageUrl': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'image_url',
    ),
    'captionEs': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'caption_es',
    ),
    'captionEn': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'caption_en',
    ),
    'sortOrder': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'sort_order',
    ),
    'isPrimary': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'is_primary',
    ),
    'thumbnailUrl': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'thumbnail_url',
    ),
    'cardThumbnailUrl': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'card_thumbnail_url',
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
    'imageUrl': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'image_url',
      iterable: false,
      type: String,
    ),
    'captionEs': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'caption_es',
      iterable: false,
      type: String,
    ),
    'captionEn': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'caption_en',
      iterable: false,
      type: String,
    ),
    'sortOrder': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sort_order',
      iterable: false,
      type: int,
    ),
    'isPrimary': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_primary',
      iterable: false,
      type: bool,
    ),
    'thumbnailUrl': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'thumbnail_url',
      iterable: false,
      type: String,
    ),
    'cardThumbnailUrl': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'card_thumbnail_url',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    SpeciesImage instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'SpeciesImage';

  @override
  Future<SpeciesImage> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesImageFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    SpeciesImage input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesImageToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<SpeciesImage> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesImageFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    SpeciesImage input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesImageToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
