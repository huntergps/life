import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/bootstrap.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import '../../../features/auth/providers/auth_provider.dart';

/// Cached admin status — re-checks automatically on login/logout.
final _adminCheckProvider = FutureProvider<bool>((ref) async {
  // Watch auth state so this re-runs on login/logout
  ref.watch(authStateProvider);
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return false;

  try {
    final response = await Supabase.instance.client
        .from('admin_users')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();
    return response != null;
  } catch (e) {
    AppLogger.warning('Admin check failed (offline?)', e);
    return false;
  }
});

/// Keeps the last known value so UI never flickers.
/// Initialized from SharedPreferences for offline persistence.
/// Cache expires after 30 minutes to force a re-check with the server.
final _adminCacheProvider = StateProvider<bool?>((ref) {
  final prefs = Bootstrap.prefs;
  final cachedAt = prefs.getInt('admin_status_timestamp');
  if (cachedAt != null) {
    final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
    if (age > 30 * 60 * 1000) {
      // Cache expired — remove stale data so we re-fetch from server.
      prefs.remove('is_admin');
      prefs.remove('admin_status_timestamp');
      return null;
    }
  }
  return prefs.getBool('is_admin');
});

final isAdminProvider = Provider<AsyncValue<bool>>((ref) {
  final asyncResult = ref.watch(_adminCheckProvider);
  final cache = ref.watch(_adminCacheProvider);

  return asyncResult.when(
    data: (value) {
      // Update cache in memory + SharedPreferences (with timestamp).
      Future.microtask(() {
        ref.read(_adminCacheProvider.notifier).state = value;
        Bootstrap.prefs.setBool('is_admin', value);
        Bootstrap.prefs.setInt(
          'admin_status_timestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
      });
      return AsyncValue.data(value);
    },
    loading: () {
      // Return cached value instantly if available
      if (cache != null) return AsyncValue.data(cache);
      return const AsyncValue.loading();
    },
    error: (e, st) {
      if (cache != null) return AsyncValue.data(cache);
      return AsyncValue.error(e, st);
    },
  );
});
