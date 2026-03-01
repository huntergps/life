import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Returns set of visitSiteIds in the current user's wishlist.
final siteWishlistProvider = FutureProvider<Set<int>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return {};
  try {
    final data = await Supabase.instance.client
        .from('user_site_wishlist')
        .select('visit_site_id')
        .eq('user_id', user.id);
    return {for (final row in data as List) row['visit_site_id'] as int};
  } catch (_) {
    return {};
  }
});

/// Returns true if the given site is in the wishlist.
final isSiteInWishlistProvider = Provider.family<bool, int>((ref, siteId) {
  final wishlist = ref.watch(siteWishlistProvider).asData?.value ?? {};
  return wishlist.contains(siteId);
});

/// Toggles a site in/out of the wishlist.
Future<void> toggleSiteWishlist(WidgetRef ref, int siteId) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return;
  final isInList = ref.read(isSiteInWishlistProvider(siteId));
  try {
    if (isInList) {
      await Supabase.instance.client
          .from('user_site_wishlist')
          .delete()
          .eq('user_id', user.id)
          .eq('visit_site_id', siteId);
    } else {
      await Supabase.instance.client
          .from('user_site_wishlist')
          .upsert({'user_id': user.id, 'visit_site_id': siteId});
    }
    ref.invalidate(siteWishlistProvider);
  } catch (_) {
    // Silently fail
  }
}
