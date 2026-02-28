// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<UserProfile> _$UserProfileFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return UserProfile(
    id: data['id'] as String,
    displayName: data['display_name'] == null
        ? null
        : data['display_name'] as String?,
    bio: data['bio'] == null ? null : data['bio'] as String?,
    birthDate: data['birth_date'] == null
        ? null
        : data['birth_date'] == null
        ? null
        : DateTime.tryParse(data['birth_date'] as String),
    country: data['country'] == null ? null : data['country'] as String?,
    countryCode: data['country_code'] == null
        ? null
        : data['country_code'] as String?,
    avatarUrl: data['avatar_url'] == null
        ? null
        : data['avatar_url'] as String?,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] == null
        ? null
        : DateTime.tryParse(data['created_at'] as String),
    updatedAt: data['updated_at'] == null
        ? null
        : data['updated_at'] == null
        ? null
        : DateTime.tryParse(data['updated_at'] as String),
  );
}

Future<Map<String, dynamic>> _$UserProfileToSupabase(
  UserProfile instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'display_name': instance.displayName,
    'bio': instance.bio,
    'birth_date': instance.birthDate?.toIso8601String(),
    'country': instance.country,
    'country_code': instance.countryCode,
    'avatar_url': instance.avatarUrl,
    'created_at': instance.createdAt?.toIso8601String(),
    'updated_at': instance.updatedAt?.toIso8601String(),
  };
}

Future<UserProfile> _$UserProfileFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return UserProfile(
    id: data['id'] as String,
    displayName: data['display_name'] == null
        ? null
        : data['display_name'] as String?,
    bio: data['bio'] == null ? null : data['bio'] as String?,
    birthDate: data['birth_date'] == null
        ? null
        : data['birth_date'] == null
        ? null
        : DateTime.tryParse(data['birth_date'] as String),
    country: data['country'] == null ? null : data['country'] as String?,
    countryCode: data['country_code'] == null
        ? null
        : data['country_code'] as String?,
    avatarUrl: data['avatar_url'] == null
        ? null
        : data['avatar_url'] as String?,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] == null
        ? null
        : DateTime.tryParse(data['created_at'] as String),
    updatedAt: data['updated_at'] == null
        ? null
        : data['updated_at'] == null
        ? null
        : DateTime.tryParse(data['updated_at'] as String),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$UserProfileToSqlite(
  UserProfile instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'display_name': instance.displayName,
    'bio': instance.bio,
    'birth_date': instance.birthDate?.toIso8601String(),
    'country': instance.country,
    'country_code': instance.countryCode,
    'avatar_url': instance.avatarUrl,
    'created_at': instance.createdAt?.toIso8601String(),
    'updated_at': instance.updatedAt?.toIso8601String(),
  };
}

/// Construct a [UserProfile]
class UserProfileAdapter extends OfflineFirstWithSupabaseAdapter<UserProfile> {
  UserProfileAdapter();

  @override
  final supabaseTableName = 'profiles';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'displayName': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'display_name',
    ),
    'bio': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'bio',
    ),
    'birthDate': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'birth_date',
    ),
    'country': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'country',
    ),
    'countryCode': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'country_code',
    ),
    'avatarUrl': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'avatar_url',
    ),
    'createdAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'created_at',
    ),
    'updatedAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'updated_at',
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
      type: String,
    ),
    'displayName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'display_name',
      iterable: false,
      type: String,
    ),
    'bio': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'bio',
      iterable: false,
      type: String,
    ),
    'birthDate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'birth_date',
      iterable: false,
      type: DateTime,
    ),
    'country': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'country',
      iterable: false,
      type: String,
    ),
    'countryCode': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'country_code',
      iterable: false,
      type: String,
    ),
    'avatarUrl': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'avatar_url',
      iterable: false,
      type: String,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: DateTime,
    ),
    'updatedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'updated_at',
      iterable: false,
      type: DateTime,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    UserProfile instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'UserProfile';

  @override
  Future<UserProfile> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserProfileFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    UserProfile input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserProfileToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<UserProfile> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserProfileFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    UserProfile input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserProfileToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
