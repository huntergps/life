// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Category> _$CategoryFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Category(
    id: data['id'] as int,
    slug: data['slug'] as String,
    nameEs: data['name_es'] as String,
    nameEn: data['name_en'] as String,
    iconName: data['icon_name'] == null ? null : data['icon_name'] as String?,
    sortOrder: data['sort_order'] as int,
  );
}

Future<Map<String, dynamic>> _$CategoryToSupabase(
  Category instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'slug': instance.slug,
    'name_es': instance.nameEs,
    'name_en': instance.nameEn,
    'icon_name': instance.iconName,
    'sort_order': instance.sortOrder,
  };
}

Future<Category> _$CategoryFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Category(
    id: data['id'] as int,
    slug: data['slug'] as String,
    nameEs: data['name_es'] as String,
    nameEn: data['name_en'] as String,
    iconName: data['icon_name'] == null ? null : data['icon_name'] as String?,
    sortOrder: data['sort_order'] as int,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$CategoryToSqlite(
  Category instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'slug': instance.slug,
    'name_es': instance.nameEs,
    'name_en': instance.nameEn,
    'icon_name': instance.iconName,
    'sort_order': instance.sortOrder,
  };
}

/// Construct a [Category]
class CategoryAdapter extends OfflineFirstWithSupabaseAdapter<Category> {
  CategoryAdapter();

  @override
  final supabaseTableName = 'categories';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'slug': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'slug',
    ),
    'nameEs': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name_es',
    ),
    'nameEn': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name_en',
    ),
    'iconName': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'icon_name',
    ),
    'sortOrder': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'sort_order',
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
    'slug': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'slug',
      iterable: false,
      type: String,
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
    'iconName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'icon_name',
      iterable: false,
      type: String,
    ),
    'sortOrder': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sort_order',
      iterable: false,
      type: int,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    Category instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'Category';

  @override
  Future<Category> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$CategoryFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    Category input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$CategoryToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Category> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$CategoryFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    Category input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$CategoryToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
