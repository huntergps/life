import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:galapagos_wildlife/models/species.model.dart';
import 'package:galapagos_wildlife/models/species_site.model.dart';
import 'package:galapagos_wildlife/models/visit_site.model.dart';
import 'package:galapagos_wildlife/data/mappers/data_helpers.dart';
import 'package:galapagos_wildlife/core/services/location/location_permission_service.dart';

/// Species likely found near the user's current GPS location.
///
/// Logic:
/// 1. Get user GPS position
/// 2. Find nearest visit site (within 50 km)
/// 3. Get species associated with that site via species_sites
/// 4. Return the species list (max 10)
final nearbySpeciesProvider = FutureProvider<List<Species>>((ref) async {
  try {
    if (!await LocationPermissionService.ensurePermission()) return [];

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );

    // Get all visit sites and find nearest
    final sites = await fetchDeduped<VisitSite>(idSelector: (s) => s.id);
    if (sites.isEmpty) return [];

    VisitSite? nearest;
    double minDist = double.infinity;
    for (final site in sites) {
      if (site.latitude == null || site.longitude == null) continue;
      final dist = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        site.latitude!,
        site.longitude!,
      );
      if (dist < minDist) {
        minDist = dist;
        nearest = site;
      }
    }

    // If no site within 50 km, user is probably not in Galapagos
    if (nearest == null || minDist > 50000) return [];

    // Get species linked to this site
    final speciesSites = await fetchDeduped<SpeciesSite>(idSelector: (s) => s.id);
    final siteSpeciesIds = speciesSites
        .where((ss) => ss.visitSiteId == nearest!.id)
        .map((ss) => ss.speciesId)
        .toSet();

    if (siteSpeciesIds.isEmpty) return [];

    final allSpecies = await fetchDeduped<Species>(idSelector: (s) => s.id);
    return allSpecies.where((s) => siteSpeciesIds.contains(s.id)).toList();
  } catch (_) {
    return [];
  }
});
