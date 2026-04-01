import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/models/species.model.dart';
import 'package:galapagos_wildlife/models/species_image.model.dart';
import 'package:galapagos_wildlife/models/species_site.model.dart';
import 'package:galapagos_wildlife/models/species_threat.model.dart';
import 'package:galapagos_wildlife/models/species_reference.model.dart';
import 'package:galapagos_wildlife/models/visit_site.model.dart';
import 'package:drift_offline_first/drift_offline_first.dart';
import 'package:galapagos_wildlife/data/local/drift/drift.dart';
import 'package:galapagos_wildlife/data/mappers/data_helpers.dart';

final speciesDetailProvider = FutureProvider.family<Species?, int>((ref, id) async {
  List<Species> results;
  try {
    results = await WildlifeRepository.instance.get<Species>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where('id').isExactly(id)]),
    );
  } catch (_) {
    results = [];
  }
  if (results.isNotEmpty) return results.last;
  // Fallback: fetch from Supabase when not found locally (e.g. stale cache or empty web DB)
  try {
    final remote = await WildlifeRepository.instance.get<Species>(
      policy: OfflineFirstGetPolicy.awaitRemote,
      query: Query(where: [Where('id').isExactly(id)]),
    );
    return remote.isNotEmpty ? remote.last : null;
  } catch (_) {
    return null;
  }
});

final speciesImagesProvider = FutureProvider.family<List<SpeciesImage>, int>((ref, speciesId) async {
  return fetchDeduped<SpeciesImage>(
    idSelector: (img) => img.id,
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where('speciesId').isExactly(speciesId)]),
  );
});

/// Returns visit sites where this species can be found, with frequency info.
final speciesVisitSitesProvider = FutureProvider.family<List<({VisitSite site, String? frequency})>, int>((ref, speciesId) async {
  final speciesSites = await fetchDeduped<SpeciesSite>(
    idSelector: (ss) => ss.id,
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where('speciesId').isExactly(speciesId)]),
  );

  if (speciesSites.isEmpty) return [];

  final siteMap = await fetchLookup<VisitSite>(idSelector: (s) => s.id);

  return speciesSites
      .where((ss) => siteMap.containsKey(ss.visitSiteId))
      .map((ss) => (site: siteMap[ss.visitSiteId]!, frequency: ss.frequency))
      .toList();
});

final speciesThreatsProvider = FutureProvider.family<List<SpeciesThreat>, int>((ref, speciesId) async {
  return fetchDeduped<SpeciesThreat>(
    idSelector: (t) => t.id,
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where('speciesId').isExactly(speciesId)]),
  );
});

final speciesReferencesProvider = FutureProvider.family<List<SpeciesReference>, int>((ref, speciesId) async {
  return fetchDeduped<SpeciesReference>(
    idSelector: (r) => r.id,
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where('speciesId').isExactly(speciesId)]),
  );
});
