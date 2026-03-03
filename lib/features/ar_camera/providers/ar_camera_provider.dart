import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/brick/models/species_site.model.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';
import 'package:galapagos_wildlife/features/species/providers/species_identification_provider.dart';

/// Live AR detection result — the species currently being detected in the camera frame.
class ArLiveResult {
  final SpeciesIdSuggestion suggestion;
  final DateTime detectedAt;

  const ArLiveResult({required this.suggestion, required this.detectedAt});
}

/// Holds the most recent live detection result (null = nothing detected).
final arLiveResultProvider = StateProvider<ArLiveResult?>((ref) => null);

/// Current user position for the AR camera
final arLocationProvider = FutureProvider<({double? lat, double? lng})>((ref) async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return (lat: null, lng: null);
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return (lat: null, lng: null);
    }
    if (permission == LocationPermission.deniedForever) return (lat: null, lng: null);
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 8),
      ),
    );
    return (lat: pos.latitude, lng: pos.longitude);
  } catch (_) {
    return (lat: null, lng: null);
  }
});

/// Species at the nearest visit site (within 2km), for AR overlay
final fieldCameraSpeciesProvider =
    FutureProvider<List<({Species species, String frequency})>>((ref) async {
  final location = await ref.watch(arLocationProvider.future);
  final lat = location.lat;
  final lng = location.lng;

  final allSpecies = await fetchDeduped<Species>(idSelector: (s) => s.id);
  if (allSpecies.isEmpty) return [];

  if (lat == null || lng == null) {
    // No GPS — return first 6 species as fallback
    return allSpecies.take(6).map((sp) => (species: sp, frequency: 'common')).toList();
  }

  // Find nearest visit site within 2km
  final sites = await fetchDeduped<VisitSite>(idSelector: (s) => s.id);
  const dist = Distance();
  final userPos = LatLng(lat, lng);

  VisitSite? nearest;
  double nearestDist = double.infinity;
  for (final site in sites) {
    if (site.latitude == null || site.longitude == null) continue;
    final d = dist.distance(userPos, LatLng(site.latitude!, site.longitude!));
    if (d < nearestDist && d < 2000) {
      nearestDist = d;
      nearest = site;
    }
  }

  if (nearest == null) {
    // Outside any site — show generic species
    return allSpecies.take(6).map((sp) => (species: sp, frequency: 'common')).toList();
  }

  // Get species at nearest site
  final speciesSites = await fetchDeduped<SpeciesSite>(
    idSelector: (ss) => ss.id,
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where('visitSiteId').isExactly(nearest.id)]),
  );

  final ids = speciesSites.map((ss) => ss.speciesId).toSet();
  final siteSpecies = allSpecies.where((sp) => ids.contains(sp.id)).toList();

  return siteSpecies.take(8).map((sp) {
    final freq = speciesSites
        .where((ss) => ss.speciesId == sp.id)
        .map((ss) => ss.frequency ?? 'common')
        .firstOrNull ?? 'common';
    return (species: sp, frequency: freq);
  }).toList();
});
