import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/brick/models/sighting.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// All sightings for the current user (deduplicated).
final sightingsProvider = FutureProvider<List<Sighting>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

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
  return fetchLookup<Species>(idSelector: (s) => s.id);
});
