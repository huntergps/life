import 'package:supabase_flutter/supabase_flutter.dart';

class AccountDeletionService {
  /// Deletes all user data and the auth account.
  ///
  /// Order: user-generated content first, then profile, then auth account.
  /// RLS policies ensure only the authenticated user's own rows are affected.
  /// The `delete_own_account` RPC is a SECURITY DEFINER function that calls
  /// `auth.users` DELETE on behalf of the user.
  static Future<void> deleteAccount() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Delete user data from all tables (RLS ensures only own data)
    await client.from('sightings').delete().eq('user_id', userId);
    await client.from('user_favorites').delete().eq('user_id', userId);
    await client.from('user_species_checklist').delete().eq('user_id', userId);
    await client.from('user_site_wishlist').delete().eq('user_id', userId);
    await client.from('user_profiles').delete().eq('id', userId);

    // Call server-side RPC to delete auth user
    // (users can't delete themselves directly -- need a SECURITY DEFINER function)
    await client.rpc('delete_own_account');

    // Sign out locally
    await client.auth.signOut();
  }
}
