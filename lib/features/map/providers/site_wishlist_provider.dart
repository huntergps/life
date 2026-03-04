import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';

/// Manages visit site wishlist IDs with optimistic updates.
class WishlistNotifier extends AsyncNotifier<Set<int>> {
  SupabaseClient get _db => Supabase.instance.client;

  @override
  Future<Set<int>> build() async {
    final user = _db.auth.currentUser;
    if (user == null) return {};
    try {
      final data = await _db
          .from('user_site_wishlist')
          .select('visit_site_id')
          .eq('user_id', user.id);
      return {for (final row in data as List) row['visit_site_id'] as int};
    } catch (_) {
      return {};
    }
  }

  Future<void> toggle(int siteId) async {
    final user = _db.auth.currentUser;
    if (user == null) return;

    final current = state.asData?.value ?? {};
    final isInList = current.contains(siteId);

    // Optimistic update — instant UI response
    final updated = Set<int>.from(current);
    if (isInList) {
      updated.remove(siteId);
    } else {
      updated.add(siteId);
    }
    state = AsyncData(updated);

    try {
      if (isInList) {
        await _db
            .from('user_site_wishlist')
            .delete()
            .eq('user_id', user.id)
            .eq('visit_site_id', siteId);
      } else {
        await _db.from('user_site_wishlist').upsert({
          'user_id': user.id,
          'visit_site_id': siteId,
        });
      }
    } catch (e) {
      // Revert on failure
      state = AsyncData(current);
      AppLogger.error('toggleSiteWishlist failed', e);
    }
  }
}

final siteWishlistProvider =
    AsyncNotifierProvider<WishlistNotifier, Set<int>>(WishlistNotifier.new);

/// Returns true if the given site is in the wishlist.
final isSiteInWishlistProvider = Provider.family<bool, int>((ref, siteId) {
  return ref.watch(siteWishlistProvider).asData?.value.contains(siteId) ?? false;
});

/// Convenience wrapper — call from any WidgetRef context.
Future<void> toggleSiteWishlist(WidgetRef ref, int siteId) async {
  await ref.read(siteWishlistProvider.notifier).toggle(siteId);
}
