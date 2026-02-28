import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient? get _supabaseClient {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}

final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = _supabaseClient;
  if (client == null) return const Stream.empty();
  return client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  // Watch auth state changes so this provider rebuilds on login/logout
  ref.watch(authStateProvider);
  return _supabaseClient?.auth.currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null && user.isAnonymous == false;
});
