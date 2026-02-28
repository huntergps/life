import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:galapagos_wildlife/brick/models/island.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';

/// The current search query entered by the user.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// All islands — fetched from Supabase remote with local fallback.
final allIslandsProvider = FutureProvider<List<Island>>((ref) async {
  return fetchDeduped<Island>(idSelector: (i) => i.id);
});

/// All visit sites — fetched from Supabase remote with local fallback.
final allVisitSitesProvider = FutureProvider<List<VisitSite>>((ref) async {
  return fetchDeduped<VisitSite>(idSelector: (vs) => vs.id);
});
