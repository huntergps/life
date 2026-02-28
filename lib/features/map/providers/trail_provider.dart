import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/brick/models/trail.model.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';

/// All trails — always fetches fresh from Supabase so user-recorded trails
/// (uploaded during the session) appear immediately. Falls back to local cache
/// when offline.
final trailsProvider = FutureProvider<List<Trail>>((ref) async {
  return fetchDeduped<Trail>(
    idSelector: (t) => t.id,
    awaitRemote: true,
  );
});

/// Trails filtered by a specific island ID.
final trailsByIslandProvider =
    FutureProvider.family<List<Trail>, int>((ref, islandId) async {
  return fetchDeduped<Trail>(
    idSelector: (t) => t.id,
    awaitRemote: true,
    query: Query(where: [Where('islandId').isExactly(islandId)]),
  );
});
