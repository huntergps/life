import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/services/location/location_permission_service.dart';
import 'package:galapagos_wildlife/brick/models/island.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/species_site.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';

final islandsProvider = FutureProvider<List<Island>>((ref) async {
  return fetchDeduped<Island>(
    idSelector: (i) => i.id,
    policy: OfflineFirstGetPolicy.localOnly,
  );
});

final visitSitesProvider = FutureProvider<List<VisitSite>>((ref) async {
  return fetchDeduped<VisitSite>(
    idSelector: (s) => s.id,
    awaitRemote: true,
  );
});

/// Returns species found at a specific visit site.
final siteSpeciesProvider = FutureProvider.family<List<({Species species, String? frequency})>, int>((ref, siteId) async {
  if (kIsWeb) {
    final ssData = await Supabase.instance.client
        .from('species_sites')
        .select()
        .eq('visit_site_id', siteId);
    final speciesSites = (ssData as List).map((r) => speciesSiteFromRow(r as Map<String, dynamic>)).toList();
    if (speciesSites.isEmpty) return [];
    final speciesIds = speciesSites.map((ss) => ss.speciesId).toList();
    final spData = await Supabase.instance.client
        .from('species')
        .select()
        .inFilter('id', speciesIds);
    final speciesMap = {for (final r in spData as List) (r['id'] as int): speciesFromRow(r as Map<String, dynamic>)};
    return speciesSites
        .where((ss) => speciesMap.containsKey(ss.speciesId))
        .map((ss) => (species: speciesMap[ss.speciesId]!, frequency: ss.frequency))
        .toList();
  }
  final speciesSites = await fetchDeduped<SpeciesSite>(
    idSelector: (ss) => ss.id,
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where('visitSiteId').isExactly(siteId)]),
  );

  if (speciesSites.isEmpty) return [];

  final speciesMap = await fetchLookup<Species>(idSelector: (s) => s.id);

  return speciesSites
      .where((ss) => speciesMap.containsKey(ss.speciesId))
      .map((ss) => (species: speciesMap[ss.speciesId]!, frequency: ss.frequency))
      .toList();
});

/// Returns types, modalities and activities assigned to a visit site.
/// Fetches directly from Supabase (junction tables not in Brick cache).
/// Returns empty lists when offline.
final siteClassificationsProvider = FutureProvider.family<Map<String, List<String>>, int>(
  (ref, siteId) async {
    try {
      final client = Supabase.instance.client;
      final results = await Future.wait([
        client
            .from('visit_site_types')
            .select('site_type_catalog(name)')
            .eq('visit_site_id', siteId),
        client
            .from('visit_site_modalities')
            .select('site_modality_catalog(name)')
            .eq('visit_site_id', siteId),
        client
            .from('visit_site_activities')
            .select('site_activity_catalog(name)')
            .eq('visit_site_id', siteId),
      ]);
      List<String> names(List<dynamic> rows, String key) => rows
          .map((r) => r[key]?['name'] as String?)
          .whereType<String>()
          .toList();
      return {
        'types': names(results[0] as List, 'site_type_catalog'),
        'modalities': names(results[1] as List, 'site_modality_catalog'),
        'activities': names(results[2] as List, 'site_activity_catalog'),
      };
    } catch (e) {
      AppLogger.warning('siteClassificationsProvider: offline or error', e);
      return {'types': [], 'modalities': [], 'activities': []};
    }
  },
);

/// User's current GPS position, or null if unavailable/denied.
/// Returns null on web — GPS not supported in web deployment.
final userLocationProvider = FutureProvider<Position?>((ref) async {
  if (kIsWeb) return null;

  if (!await LocationPermissionService.ensurePermission()) return null;

  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 10),
    ),
  );
});

/// Returns a map of visitSiteId → total sighting count across all users.
/// Uses Supabase directly since we need aggregate counts across users.
/// Returns empty map when offline or on error.
final siteSightingCountsProvider = FutureProvider<Map<int, int>>((ref) async {
  try {
    final data = await Supabase.instance.client
        .from('sightings')
        .select('visit_site_id')
        .not('visit_site_id', 'is', null);
    final counts = <int, int>{};
    for (final row in data as List) {
      final siteId = row['visit_site_id'] as int?;
      if (siteId != null) {
        counts[siteId] = (counts[siteId] ?? 0) + 1;
      }
    }
    return counts;
  } catch (_) {
    return {};
  }
});

/// Returns sites with sightings in the last 48 hours, with the list of recent sightings.
/// Requires auth. Returns empty map when not authenticated or on error.
final recentSightingsBySiteProvider = FutureProvider<Map<int, List<Map<String, dynamic>>>>((ref) async {
  final isLoggedIn = ref.watch(isAuthenticatedProvider);
  if (!isLoggedIn) return {};
  try {
    final cutoff = DateTime.now().subtract(const Duration(hours: 48));
    final data = await Supabase.instance.client
        .from('sightings')
        .select('id, species_id, visit_site_id, observed_at, notes, photo_url')
        .not('visit_site_id', 'is', null)
        .gte('observed_at', cutoff.toIso8601String())
        .order('observed_at', ascending: false);

    final result = <int, List<Map<String, dynamic>>>{};
    for (final row in data as List) {
      final siteId = row['visit_site_id'] as int?;
      if (siteId == null) continue;
      result.putIfAbsent(siteId, () => []).add(row as Map<String, dynamic>);
    }
    return result;
  } catch (_) {
    return {};
  }
});

/// Nearest visit site within 2km of the user, or null if none / no GPS.
final nearbyMapSiteProvider = FutureProvider<({VisitSite site, double distanceM})?>(
  (ref) async {
    if (kIsWeb) return null;
    final pos = await ref.watch(userLocationProvider.future);
    if (pos == null) return null;
    final sites = await ref.watch(visitSitesProvider.future);
    const distCalc = Distance();
    final userPos = LatLng(pos.latitude, pos.longitude);

    VisitSite? nearest;
    double nearestDist = double.infinity;
    for (final site in sites) {
      if (site.latitude == null || site.longitude == null) continue;
      final d = distCalc.distance(userPos, LatLng(site.latitude!, site.longitude!));
      if (d < nearestDist && d < 2000) {
        nearestDist = d;
        nearest = site;
      }
    }
    if (nearest == null) return null;
    return (site: nearest, distanceM: nearestDist);
  },
);

/// Whether the given position is within the Galápagos bounding box.
bool isInGalapagos(Position pos) {
  return pos.latitude >= AppConstants.galapagosMinLat &&
      pos.latitude <= AppConstants.galapagosMaxLat &&
      pos.longitude >= AppConstants.galapagosMinLng &&
      pos.longitude <= AppConstants.galapagosMaxLng;
}
