import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents an app user as seen by the admin.
class AdminUserRecord {
  final String id;
  final String email;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final String? displayName;
  final String? avatarUrl;
  final String? country;
  final String? countryCode;
  final bool isAdmin;
  final int sightingsCount;
  final List<String> roles;

  const AdminUserRecord({
    required this.id,
    required this.email,
    this.createdAt,
    this.lastSignInAt,
    this.displayName,
    this.avatarUrl,
    this.country,
    this.countryCode,
    required this.isAdmin,
    required this.sightingsCount,
    this.roles = const [],
  });

  bool get isEditor => roles.contains('editor');
  bool get isCurator => roles.contains('curator');

  String get nameOrEmail => displayName?.isNotEmpty == true ? displayName! : email;

  factory AdminUserRecord.fromMap(Map<String, dynamic> m) => AdminUserRecord(
        id: m['id'] as String,
        email: (m['email'] as String?) ?? '',
        createdAt: m['created_at'] != null
            ? DateTime.tryParse(m['created_at'] as String)
            : null,
        lastSignInAt: m['last_sign_in_at'] != null
            ? DateTime.tryParse(m['last_sign_in_at'] as String)
            : null,
        displayName: m['display_name'] as String?,
        avatarUrl: m['avatar_url'] as String?,
        country: m['country'] as String?,
        countryCode: m['country_code'] as String?,
        isAdmin: (m['is_admin'] as bool?) ?? false,
        sightingsCount: (m['sightings_count'] as int?) ?? 0,
        roles: m['roles'] == null
            ? const []
            : List<String>.from(m['roles'] as List),
      );
}

/// Fetches all users via the `get_all_users()` RPC (admin-only).
final adminUsersProvider = FutureProvider.autoDispose<List<AdminUserRecord>>((ref) async {
  final data = await Supabase.instance.client.rpc('get_all_users');
  return (data as List)
      .map((r) => AdminUserRecord.fromMap(r as Map<String, dynamic>))
      .toList();
});

/// Grants admin access to [userId].
Future<void> adminGrantAdmin(String userId) async {
  await Supabase.instance.client
      .rpc('grant_admin', params: {'target_user_id': userId});
}

/// Revokes admin access from [userId].
Future<void> adminRevokeAdmin(String userId) async {
  await Supabase.instance.client
      .rpc('revoke_admin', params: {'target_user_id': userId});
}

/// Grants any role ('admin', 'editor', 'curator') to [userId].
Future<void> adminGrantRole(String userId, String role) async {
  await Supabase.instance.client
      .rpc('grant_role', params: {'target_user_id': userId, 'target_role': role});
}

/// Revokes any role from [userId].
Future<void> adminRevokeRole(String userId, String role) async {
  await Supabase.instance.client
      .rpc('revoke_role', params: {'target_user_id': userId, 'target_role': role});
}

/// Sends an email invitation via the `invite-user` Edge Function.
Future<void> adminInviteUser(String email) async {
  final response = await Supabase.instance.client.functions.invoke(
    'invite-user',
    body: {'email': email},
  );
  if (response.status != 200) {
    final msg = response.data?['error'] ?? 'Error sending invitation';
    throw Exception(msg);
  }
}
