import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/features/species/providers/species_list_provider.dart';
import 'package:galapagos_wildlife/features/home/providers/home_provider.dart';
import 'package:galapagos_wildlife/features/favorites/providers/favorites_provider.dart';
import 'package:galapagos_wildlife/features/map/services/field_edit_service.dart';
import 'package:galapagos_wildlife/features/map/providers/trail_provider.dart';

/// Streams `true` when the device has any network connection, `false` otherwise.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => results.any((r) => r != ConnectivityResult.none),
  );
});

/// Watches connectivity and invalidates main data providers when the device
/// transitions from offline → online, triggering a background re-sync.
/// Also flushes any locally-queued (offline-recorded) trails to Supabase.
final connectivityRefreshProvider = Provider<void>((ref) {
  bool wasOffline = false;
  ref.listen(connectivityProvider, (prev, next) {
    final isOnline = next.asData?.value ?? false;
    if (wasOffline && isOnline) {
      ref.invalidate(allSpeciesProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(featuredSpeciesProvider);
      ref.invalidate(favoritesProvider);
      ref.invalidate(trailsProvider);

      // Upload any trails that were recorded while offline.
      if (FieldEditService.pendingTrailCount() > 0) {
        FieldEditService.syncPendingTrails();
      }
    }
    wasOffline = !isOnline;
  });
});
