import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/species_image.model.dart';
import 'package:galapagos_wildlife/brick/models/species_site.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/brick/repository.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';

final speciesDetailProvider = FutureProvider.family<Species?, int>((ref, id) async {
  final results = await Repository().get<Species>(
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where('id').isExactly(id)]),
  );
  return results.isNotEmpty ? results.last : null;
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
