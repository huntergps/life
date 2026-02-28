import 'dart:async';
import 'dart:developer' as dev;
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/brick/models/category.model.dart';
import 'package:galapagos_wildlife/brick/models/island.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/species_image.model.dart';
import 'package:galapagos_wildlife/brick/models/species_site.model.dart';
import 'package:galapagos_wildlife/brick/models/trail.model.dart';
import 'package:galapagos_wildlife/brick/repository.dart';
import 'package:galapagos_wildlife/features/admin/providers/admin_category_provider.dart';
import 'package:galapagos_wildlife/features/admin/providers/admin_island_provider.dart';
import 'package:galapagos_wildlife/features/admin/providers/admin_visit_site_provider.dart';
import 'package:galapagos_wildlife/features/admin/providers/admin_species_provider.dart';
import 'package:galapagos_wildlife/features/admin/providers/admin_image_provider.dart';
import 'package:galapagos_wildlife/features/home/providers/home_provider.dart';
import 'package:galapagos_wildlife/features/species/providers/species_list_provider.dart';
import 'package:galapagos_wildlife/features/species/providers/species_detail_provider.dart';
import 'package:galapagos_wildlife/features/map/providers/map_provider.dart';
import 'package:galapagos_wildlife/features/map/providers/trail_provider.dart';
import 'package:galapagos_wildlife/features/favorites/providers/favorites_provider.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sightings_provider.dart';

class RealtimeService {
  final Ref _ref;
  RealtimeChannel? _generalChannel;
  RealtimeChannel? _userChannel;
  StreamSubscription<AuthState>? _authSub;

  RealtimeService(this._ref);

  void init() {
    _subscribeGeneral();
    _listenAuth();
  }

  // ── General data channel (all users) ──

  void _subscribeGeneral() {
    final client = Supabase.instance.client;
    _generalChannel = client
        .channel('general-changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'categories',
          callback: (_) => _onCategoriesChange(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'islands',
          callback: (_) => _onIslandsChange(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'visit_sites',
          callback: (_) => _onVisitSitesChange(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'species',
          callback: (_) => _onSpeciesChange(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'species_images',
          callback: (payload) => _onSpeciesImagesChange(payload),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'species_sites',
          callback: (_) => _onSpeciesSitesChange(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'trails',
          callback: (_) => _onTrailsChange(),
        )
        .subscribe();
  }

  // ── User-specific channel (favorites & sightings) ──

  void _listenAuth() {
    // Subscribe for current user if already logged in
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) _subscribeUser(user.id);

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null) {
        _subscribeUser(user.id);
      } else {
        _unsubscribeUser();
      }
    });
  }

  void _subscribeUser(String userId) {
    _unsubscribeUser();
    final client = Supabase.instance.client;
    _userChannel = client
        .channel('user-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_favorites',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => _onUserFavoritesChange(userId),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'sightings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => _ref.invalidate(sightingsProvider),
        )
        .subscribe();
  }

  void _unsubscribeUser() {
    if (_userChannel != null) {
      Supabase.instance.client.removeChannel(_userChannel!);
      _userChannel = null;
    }
  }

  // ── Change handlers ──
  // Pattern: sync Brick cache from server, then invalidate providers.
  // try-catch ensures providers are ALWAYS invalidated even if sync fails.

  Future<void> _onCategoriesChange() async {
    try {
      await Repository().get<Category>(policy: OfflineFirstGetPolicy.awaitRemote);
    } catch (e) {
      dev.log('Realtime: categories sync error: $e');
    }
    _ref.invalidate(categoriesProvider);
    _ref.invalidate(adminCategoriesProvider);
  }

  Future<void> _onIslandsChange() async {
    try {
      await Repository().get<Island>(policy: OfflineFirstGetPolicy.awaitRemote);
    } catch (e) {
      dev.log('Realtime: islands sync error: $e');
    }
    _ref.invalidate(islandsProvider);
    _ref.invalidate(adminIslandsProvider);
  }

  Future<void> _onVisitSitesChange() async {
    try {
      await Repository().get<VisitSite>(policy: OfflineFirstGetPolicy.awaitRemote);
    } catch (e) {
      dev.log('Realtime: visit_sites sync error: $e');
    }
    _ref.invalidate(visitSitesProvider);
    _ref.invalidate(adminVisitSitesProvider);
  }

  Future<void> _onSpeciesChange() async {
    try {
      await Repository().get<Species>(policy: OfflineFirstGetPolicy.awaitRemote);
    } catch (e) {
      dev.log('Realtime: species sync error: $e');
    }
    _ref.invalidate(speciesListProvider);
    _ref.invalidate(featuredSpeciesProvider);
    _ref.invalidate(adminSpeciesListProvider);
  }

  Future<void> _onSpeciesImagesChange(PostgresChangePayload payload) async {
    try {
      await Repository().get<SpeciesImage>(policy: OfflineFirstGetPolicy.awaitRemote);
    } catch (e) {
      dev.log('Realtime: species_images sync error: $e');
    }
    // Invalidate family providers if we can extract species_id
    final speciesId =
        payload.newRecord['species_id'] ?? payload.oldRecord['species_id'];
    if (speciesId is int) {
      _ref.invalidate(adminSpeciesImagesProvider(speciesId));
      _ref.invalidate(speciesImagesProvider(speciesId));
    }
    // Species thumbnail may have changed via trigger
    _ref.invalidate(adminSpeciesListProvider);
    _ref.invalidate(speciesListProvider);
  }

  Future<void> _onUserFavoritesChange(String userId) async {
    // Favorites now use direct Supabase (no Brick cache to sync).
    _ref.invalidate(favoritesProvider);
  }

  Future<void> _onTrailsChange() async {
    try {
      await Repository().get<Trail>(policy: OfflineFirstGetPolicy.awaitRemote);
    } catch (e) {
      dev.log('Realtime: trails sync error: $e');
    }
    _ref.invalidate(trailsProvider);
    _ref.invalidate(trailsByIslandProvider);
  }

  Future<void> _onSpeciesSitesChange() async {
    try {
      await Repository().get<SpeciesSite>(policy: OfflineFirstGetPolicy.awaitRemote);
    } catch (e) {
      dev.log('Realtime: species_sites sync error: $e');
    }
    _ref.invalidate(adminSpeciesListProvider);
    _ref.invalidate(speciesListProvider);
  }

  // ── Cleanup ──

  void dispose() {
    _authSub?.cancel();
    final client = Supabase.instance.client;
    if (_generalChannel != null) client.removeChannel(_generalChannel!);
    _unsubscribeUser();
  }
}

/// Riverpod provider — watch this in the main app to activate realtime.
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final service = RealtimeService(ref);
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});
