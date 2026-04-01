import 'package:latlong2/latlong.dart';
import 'package:galapagos_wildlife/models/species.model.dart';
import 'package:galapagos_wildlife/models/species_site.model.dart';
import 'package:galapagos_wildlife/models/visit_site.model.dart';
import 'package:drift_offline_first/drift_offline_first.dart';
import 'package:galapagos_wildlife/data/mappers/data_helpers.dart';

/// Provides GPS-based species suggestions when ML confidence is low
/// or the TFLite model is unavailable.
class LocationFallbackService {
  const LocationFallbackService._();

  /// Maximum distance (meters) from user to a visit site for it to be considered "nearby".
  static const _maxDistanceMeters = 3000.0;

  /// Find species associated with the nearest visit site to [lat], [lng].
  /// Only sites within [_maxDistanceMeters] are considered.
  /// Returns a filtered subset of [allSpecies] that are linked to the nearest site.
  static Future<List<Species>> getNearbySpecies(
    double lat,
    double lng,
    List<Species> allSpecies,
  ) async {
    try {
      final sites = await fetchDeduped<VisitSite>(idSelector: (s) => s.id);
      if (sites.isEmpty) return [];

      const dist = Distance();
      final userPos = LatLng(lat, lng);
      VisitSite? nearest;
      double nearestDist = double.infinity;

      for (final site in sites) {
        if (site.latitude == null || site.longitude == null) continue;
        final d = dist.distance(userPos, LatLng(site.latitude!, site.longitude!));
        if (d < nearestDist && d < _maxDistanceMeters) {
          nearestDist = d;
          nearest = site;
        }
      }
      if (nearest == null) return [];

      final speciesSites = await fetchDeduped<SpeciesSite>(
        idSelector: (ss) => ss.id,
        policy: OfflineFirstGetPolicy.localOnly,
        query: Query(where: [Where('visitSiteId').isExactly(nearest.id)]),
      );

      final ids = speciesSites.map((ss) => ss.speciesId).toSet();
      return allSpecies.where((sp) => ids.contains(sp.id)).toList();
    } catch (_) {
      return [];
    }
  }
}
