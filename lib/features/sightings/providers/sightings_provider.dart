import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/brick/models/sighting.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';
import 'package:galapagos_wildlife/features/species/providers/species_list_provider.dart' show allSpeciesProvider;
import 'package:galapagos_wildlife/features/map/providers/map_provider.dart' show visitSitesProvider;

/// All sightings for the current user (deduplicated).
final sightingsProvider = FutureProvider<List<Sighting>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

  if (kIsWeb) {
    final data = await Supabase.instance.client
        .from('sightings')
        .select()
        .eq('user_id', user.id)
        .order('observed_at', ascending: false);
    return (data as List).map((r) => sightingFromRow(r as Map<String, dynamic>)).toList();
  }

  final list = await fetchDeduped<Sighting>(
    idSelector: (s) => s.id,
    query: Query(where: [Where('userId').isExactly(user.id)]),
  );

  list.sort((a, b) {
    final aDate = a.observedAt ?? DateTime(2000);
    final bDate = b.observedAt ?? DateTime(2000);
    return bDate.compareTo(aDate);
  });
  return list;
});

/// Lookup map: speciesId → Species. Derived from allSpeciesProvider to avoid
/// a duplicate fetch when both are used on the same screen.
final speciesLookupProvider = FutureProvider<Map<int, Species>>((ref) async {
  final list = await ref.watch(allSpeciesProvider.future);
  return {for (final s in list) s.id: s};
});

/// Lookup map: visitSiteId → VisitSite. Derived from visitSitesProvider to
/// avoid a duplicate fetch when both are used on the same screen.
final visitSiteLookupProvider = FutureProvider<Map<int, VisitSite>>((ref) async {
  final list = await ref.watch(visitSitesProvider.future);
  return {for (final s in list) s.id: s};
});
