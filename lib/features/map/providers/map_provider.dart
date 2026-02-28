import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/brick/models/island.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/species_site.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';

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
    } catch (_) {
      return {'types': [], 'modalities': [], 'activities': []};
    }
  },
);

/// User's current GPS position, or null if unavailable/denied.
final userLocationProvider = FutureProvider<Position?>((ref) async {
  if (!await Geolocator.isLocationServiceEnabled()) return null;

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
  }
  if (permission == LocationPermission.deniedForever) return null;

  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 10),
    ),
  );
});

/// Whether the given position is within the Galápagos bounding box.
bool isInGalapagos(Position pos) {
  return pos.latitude >= AppConstants.galapagosMinLat &&
      pos.latitude <= AppConstants.galapagosMaxLat &&
      pos.longitude >= AppConstants.galapagosMinLng &&
      pos.longitude <= AppConstants.galapagosMaxLng;
}
