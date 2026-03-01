// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<UserSiteWishlist> _$UserSiteWishlistFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return UserSiteWishlist(
    id: data['id'] as int,
    userId: data['user_id'] as String,
    visitSiteId: data['visit_site_id'] as int,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] == null
        ? null
        : DateTime.tryParse(data['created_at'] as String),
  );
}

Future<Map<String, dynamic>> _$UserSiteWishlistToSupabase(
  UserSiteWishlist instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'user_id': instance.userId,
    'visit_site_id': instance.visitSiteId,
    'created_at': instance.createdAt?.toIso8601String(),
  };
}

Future<UserSiteWishlist> _$UserSiteWishlistFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return UserSiteWishlist(
    id: data['id'] as int,
    userId: data['user_id'] as String,
    visitSiteId: data['visit_site_id'] as int,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] == null
        ? null
        : DateTime.tryParse(data['created_at'] as String),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$UserSiteWishlistToSqlite(
  UserSiteWishlist instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'user_id': instance.userId,
    'visit_site_id': instance.visitSiteId,
    'created_at': instance.createdAt?.toIso8601String(),
  };
}

/// Construct a [UserSiteWishlist]
class UserSiteWishlistAdapter
    extends OfflineFirstWithSupabaseAdapter<UserSiteWishlist> {
  UserSiteWishlistAdapter();

  @override
  final supabaseTableName = 'user_site_wishlist';
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
    'visitSiteId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'visit_site_id',
    ),
    'createdAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'created_at',
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
    'visitSiteId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'visit_site_id',
      iterable: false,
      type: int,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: DateTime,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    UserSiteWishlist instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'UserSiteWishlist';

  @override
  Future<UserSiteWishlist> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserSiteWishlistFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    UserSiteWishlist input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserSiteWishlistToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<UserSiteWishlist> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserSiteWishlistFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    UserSiteWishlist input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserSiteWishlistToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
