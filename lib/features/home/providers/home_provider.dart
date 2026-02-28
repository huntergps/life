import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/brick/models/category.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  if (kIsWeb) {
    final data = await Supabase.instance.client
        .from('categories')
        .select()
        .order('sort_order');
    return (data as List).map((r) => categoryFromRow(r as Map<String, dynamic>)).toList();
  }
  final list = await fetchDeduped<Category>(idSelector: (c) => c.id);
  list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return list;
});

final featuredSpeciesProvider = FutureProvider<List<Species>>((ref) async {
  if (kIsWeb) {
    final data = await Supabase.instance.client
        .from('species')
        .select()
        .eq('is_endemic', true)
        .limit(6);
    return (data as List).map((r) => speciesFromRow(r as Map<String, dynamic>)).toList();
  }
  final list = await fetchDeduped<Species>(
    idSelector: (s) => s.id,
    query: Query(where: [Where('isEndemic').isExactly(true)]),
  );
  return list.take(6).toList();
});
