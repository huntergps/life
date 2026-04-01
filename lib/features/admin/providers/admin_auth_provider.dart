import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import '../../../features/auth/providers/auth_provider.dart';

// ── Internal: fetch all roles from server ────────────────────────────────────

final _rolesCheckProvider = FutureProvider<Set<String>>((ref) async {
  ref.watch(authStateProvider);
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return const {};
  try {
    // Uses get_user_active_roles which filters out expired roles
    final data = await Supabase.instance.client.rpc('get_user_active_roles');
    return (data as List<dynamic>).map((e) => e as String).toSet();
  } catch (e) {
    AppLogger.warning('Roles check failed (offline?)', e);
    return const {};
  }
});

// ── Internal: read cached roles from SharedPreferences ───────────────────────

Set<String> _cachedRoles() {
  final prefs = Bootstrap.prefs;
  final stored = prefs.getString('user_roles') ?? '';
  return stored.isEmpty ? {} : stored.split(',').toSet();
}

final _rolesCacheProvider = StateProvider<Set<String>?>((ref) => _cachedRoles());

// ── Public: current user's role set ──────────────────────────────────────────
//
// Returns AsyncValue<Set<String>> — e.g. {'admin', 'editor'}.
// Stays at loading until the first server fetch completes; uses cached value
// in the meantime so the UI never flickers.

final userRolesProvider = Provider<AsyncValue<Set<String>>>((ref) {
  final asyncResult = ref.watch(_rolesCheckProvider);
  final cache = ref.watch(_rolesCacheProvider);

  return asyncResult.when(
    data: (roles) {
      Future.microtask(() {
        ref.read(_rolesCacheProvider.notifier).state = roles;
        Bootstrap.prefs.setString('user_roles', roles.join(','));
        Bootstrap.prefs.setInt(
          'roles_cache_ts',
          DateTime.now().millisecondsSinceEpoch,
        );
        // Legacy key used by the router guard (synchronous check on cold start)
        Bootstrap.prefs.setBool('is_admin', roles.contains('admin'));
        Bootstrap.prefs.setBool('is_curator', roles.contains('curator') || roles.contains('admin'));
        Bootstrap.prefs.setBool('is_editor', roles.contains('editor') || roles.contains('admin'));
        Bootstrap.prefs.setBool('is_staff', roles.isNotEmpty);
        // Beta tester: experimental features not yet released (admin inherits)
        Bootstrap.prefs.setBool('is_beta_tester', roles.contains('beta_tester') || roles.contains('admin'));
        // Premium access via role (without paying): admin, sponsored, editor, curator
        final hasPremiumRole = roles.contains('admin') ||
            roles.contains('sponsored') ||
            roles.contains('editor') ||
            roles.contains('curator');
        Bootstrap.prefs.setBool('has_premium_role', hasPremiumRole);
      });
      return AsyncValue.data(roles);
    },
    loading: () {
      if (cache != null) return AsyncValue.data(cache);
      return const AsyncValue.loading();
    },
    error: (e, st) {
      if (cache != null) return AsyncValue.data(cache);
      return AsyncValue.error(e, st);
    },
  );
});

// ── Convenience role checks ───────────────────────────────────────────────────
//
// Admin inherits all lower-tier permissions (editor + curator).

final isAdminProvider = Provider<AsyncValue<bool>>((ref) =>
    ref.watch(userRolesProvider).whenData((r) => r.contains('admin')));

final isEditorProvider = Provider<AsyncValue<bool>>((ref) =>
    ref.watch(userRolesProvider).whenData(
        (r) => r.contains('editor') || r.contains('admin')));

final isCuratorProvider = Provider<AsyncValue<bool>>((ref) =>
    ref.watch(userRolesProvider).whenData(
        (r) => r.contains('curator') || r.contains('admin')));

final isStaffProvider = Provider<AsyncValue<bool>>((ref) =>
    ref.watch(userRolesProvider).whenData((r) => r.isNotEmpty));

final isBetaTesterProvider = Provider<AsyncValue<bool>>((ref) =>
    ref.watch(userRolesProvider).whenData(
        (r) => r.contains('beta_tester') || r.contains('admin')));

final isSponsoredProvider = Provider<AsyncValue<bool>>((ref) =>
    ref.watch(userRolesProvider).whenData(
        (r) => r.contains('sponsored') || r.contains('admin')));

/// True if user has ANY role that grants premium access (map, photo ID, etc.)
/// without purchasing. Includes: admin, beta_tester, sponsored, editor, curator.
final hasPremiumRoleProvider = Provider<AsyncValue<bool>>((ref) =>
    ref.watch(userRolesProvider).whenData((r) =>
        r.contains('admin') ||
        r.contains('beta_tester') ||
        r.contains('sponsored') ||
        r.contains('editor') ||
        r.contains('curator')));

// ── Role invalidation helper ──────────────────────────────────────────────────
//
// Call after granting/revoking a role so providers re-fetch from server.

void invalidateRoles(Ref ref) {
  Bootstrap.prefs.remove('user_roles');
  Bootstrap.prefs.remove('roles_cache_ts');
  ref.invalidate(_rolesCheckProvider);
}
