import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/brick/models/species_site.model.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';

class SoundIdSuggestion {
  final Species species;
  final String reason;
  final String frequency;

  const SoundIdSuggestion({
    required this.species,
    required this.reason,
    required this.frequency,
  });
}

/// Provider that returns wildlife suggestions for a given location and time.
/// Completely offline — uses local SQLite via Brick.
final soundIdSuggestionsProvider = FutureProvider.family<
    List<SoundIdSuggestion>,
    ({double? lat, double? lng})>((ref, location) async {
  final lat = location.lat;
  final lng = location.lng;

  // Load all sites and species from local DB
  final sites = await fetchDeduped<VisitSite>(idSelector: (s) => s.id);
  final allSpecies = await fetchDeduped<Species>(idSelector: (s) => s.id);

  if (allSpecies.isEmpty) return [];

  // Find nearest visit site (within 5km)
  VisitSite? nearestSite;
  if (lat != null && lng != null && sites.isNotEmpty) {
    final dist = Distance();
    final userPos = LatLng(lat, lng);
    double nearestDist = double.infinity;

    for (final site in sites) {
      if (site.latitude == null || site.longitude == null) continue;
      final d = dist.distance(userPos, LatLng(site.latitude!, site.longitude!));
      if (d < nearestDist && d < 5000) {
        nearestDist = d;
        nearestSite = site;
      }
    }
  }

  List<Species> candidateSpecies;

  if (nearestSite != null) {
    // Get species associated with nearest site
    final speciesSites = await fetchDeduped<SpeciesSite>(
      idSelector: (ss) => ss.id,
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where('visitSiteId').isExactly(nearestSite.id)]),
    );
    final ids = speciesSites.map((ss) => ss.speciesId).toSet();
    candidateSpecies = allSpecies.where((sp) => ids.contains(sp.id)).toList();
  } else {
    // No nearby site — use all species, show most common
    candidateSpecies = allSpecies;
  }

  if (candidateSpecies.isEmpty) return [];

  // Filter by current time of day (activityPattern)
  final hour = DateTime.now().hour;
  final isDiurnal = hour >= 6 && hour < 19;
  final isCrepuscular = (hour >= 5 && hour < 7) || (hour >= 18 && hour < 20);

  final activeSpecies = candidateSpecies.where((sp) {
    final pattern = sp.activityPattern?.toLowerCase() ?? '';
    if (pattern.isEmpty) return true;
    if (pattern.contains('diurnal') && isDiurnal) return true;
    if (pattern.contains('nocturnal') && !isDiurnal) return true;
    if (pattern.contains('crepuscular') && isCrepuscular) return true;
    if (pattern.contains('diurnal') || pattern.isEmpty) return isDiurnal;
    return true;
  }).toList();

  // Build suggestions
  final suggestions = (activeSpecies.isNotEmpty ? activeSpecies : candidateSpecies)
      .take(8)
      .map((sp) {
    String reason;
    if (nearestSite != null) {
      final siteName = nearestSite.nameEn ?? nearestSite.nameEs;
      reason = 'Found at $siteName';
    } else {
      reason = 'Common in Galápagos';
    }

    // Add time-of-day context
    final pattern = sp.activityPattern?.toLowerCase() ?? '';
    if (pattern.contains('diurnal') && isDiurnal) {
      reason += ' · Active during the day';
    } else if (pattern.contains('nocturnal') && !isDiurnal) {
      reason += ' · Active at night';
    } else if (pattern.contains('crepuscular') && isCrepuscular) {
      reason += ' · Active at dawn/dusk';
    }

    return SoundIdSuggestion(
      species: sp,
      reason: reason,
      frequency: 'common',
    );
  }).toList();

  return suggestions;
});
