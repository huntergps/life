import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/species_image.model.dart';
import 'package:galapagos_wildlife/brick/models/species_site.model.dart';
import 'package:galapagos_wildlife/brick/models/species_threat.model.dart';
import 'package:galapagos_wildlife/brick/models/species_reference.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/brick/repository.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';

final speciesDetailProvider = FutureProvider.family<Species?, int>((ref, id) async {
  if (kIsWeb) {
    final data = await Supabase.instance.client
        .from('species')
        .select()
        .eq('id', id)
        .maybeSingle();
    return data != null ? speciesFromRow(data) : null;
  }
  final results = await Repository().get<Species>(
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where('id').isExactly(id)]),
  );
  if (results.isNotEmpty) return results.last;
  // Fallback: fetch from Supabase when not found locally (e.g. stale cache)
  try {
    final remote = await Repository().get<Species>(
      policy: OfflineFirstGetPolicy.awaitRemote,
      query: Query(where: [Where('id').isExactly(id)]),
    );
    return remote.isNotEmpty ? remote.last : null;
  } catch (_) {
    return null;
  }
});

final speciesImagesProvider = FutureProvider.family<List<SpeciesImage>, int>((ref, speciesId) async {
  if (kIsWeb) {
    final data = await Supabase.instance.client
        .from('species_images')
        .select()
        .eq('species_id', speciesId)
        .order('sort_order');
    return (data as List).map((r) => speciesImageFromRow(r as Map<String, dynamic>)).toList();
  }
  return fetchDeduped<SpeciesImage>(
    idSelector: (img) => img.id,
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where('speciesId').isExactly(speciesId)]),
  );
});

/// Returns visit sites where this species can be found, with frequency info.
final speciesVisitSitesProvider = FutureProvider.family<List<({VisitSite site, String? frequency})>, int>((ref, speciesId) async {
  if (kIsWeb) {
    final ssData = await Supabase.instance.client
        .from('species_sites')
        .select()
        .eq('species_id', speciesId);
    final speciesSites = (ssData as List).map((r) => speciesSiteFromRow(r as Map<String, dynamic>)).toList();
    if (speciesSites.isEmpty) return [];
    final siteIds = speciesSites.map((ss) => ss.visitSiteId).toList();
    final sitesData = await Supabase.instance.client
        .from('visit_sites')
        .select()
        .inFilter('id', siteIds);
    final siteMap = {for (final r in sitesData as List) (r['id'] as int): visitSiteFromRow(r as Map<String, dynamic>)};
    return speciesSites
        .where((ss) => siteMap.containsKey(ss.visitSiteId))
        .map((ss) => (site: siteMap[ss.visitSiteId]!, frequency: ss.frequency))
        .toList();
  }
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
  if (kIsWeb) {
    final data = await Supabase.instance.client
        .from('species_threats')
        .select()
        .eq('species_id', speciesId);
    return (data as List).map((r) => SpeciesThreat(
      id: r['id'] as int,
      speciesId: r['species_id'] as int,
      threatType: r['threat_type'] as String,
      severity: r['severity'] as String,
      descriptionEs: r['description_es'] as String?,
      descriptionEn: r['description_en'] as String?,
    )).toList();
  }
  return fetchDeduped<SpeciesThreat>(
    idSelector: (t) => t.id,
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where('speciesId').isExactly(speciesId)]),
  );
});

final speciesReferencesProvider = FutureProvider.family<List<SpeciesReference>, int>((ref, speciesId) async {
  if (kIsWeb) {
    final data = await Supabase.instance.client
        .from('species_references')
        .select()
        .eq('species_id', speciesId)
        .order('id');
    return (data as List).map((r) => SpeciesReference(
      id: r['id'] as int,
      speciesId: r['species_id'] as int,
      citation: r['citation'] as String,
      url: r['url'] as String?,
      doi: r['doi'] as String?,
      referenceType: r['reference_type'] as String?,
    )).toList();
  }
  return fetchDeduped<SpeciesReference>(
    idSelector: (r) => r.id,
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where('speciesId').isExactly(speciesId)]),
  );
});
