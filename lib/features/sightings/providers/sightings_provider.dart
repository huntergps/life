import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/brick/models/sighting.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';

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

/// Lookup map: speciesId → Species (for displaying names in sighting lists).
final speciesLookupProvider = FutureProvider<Map<int, Species>>((ref) async {
  if (kIsWeb) {
    final data = await Supabase.instance.client.from('species').select();
    return {for (final r in data as List) (r['id'] as int): speciesFromRow(r as Map<String, dynamic>)};
  }
  return fetchLookup<Species>(idSelector: (s) => s.id);
});

/// Lookup map: visitSiteId → VisitSite (used by the sightings visit-site filter chip).
final visitSiteLookupProvider = FutureProvider<Map<int, VisitSite>>((ref) async {
  if (kIsWeb) {
    final data = await Supabase.instance.client.from('visit_sites').select();
    return {
      for (final r in data as List)
        (r['id'] as int): visitSiteFromRow(r as Map<String, dynamic>)
    };
  }
  return fetchLookup<VisitSite>(idSelector: (s) => s.id);
});
