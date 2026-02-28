import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _client = Supabase.instance.client;

// ── Taxonomy Classes ──

final taxonomyClassesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await _client
      .from('taxonomy_classes')
      .select()
      .order('name');
  return List<Map<String, dynamic>>.from(response);
});

// ── Taxonomy Orders (filtered by class_id) ──

final taxonomyOrdersProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int?>((ref, classId) async {
  if (classId == null) return [];
  final response = await _client
      .from('taxonomy_orders')
      .select()
      .eq('class_id', classId)
      .order('name');
  return List<Map<String, dynamic>>.from(response);
});

// ── Taxonomy Families (filtered by order_id) ──

final taxonomyFamiliesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int?>((ref, orderId) async {
  if (orderId == null) return [];
  final response = await _client
      .from('taxonomy_families')
      .select()
      .eq('order_id', orderId)
      .order('name');
  return List<Map<String, dynamic>>.from(response);
});

// ── Taxonomy Genera (filtered by family_id) ──

final taxonomyGeneraProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int?>((ref, familyId) async {
  if (familyId == null) return [];
  final response = await _client
      .from('taxonomy_genera')
      .select()
      .eq('family_id', familyId)
      .order('name');
  return List<Map<String, dynamic>>.from(response);
});

// ── CRUD helpers ──

Future<Map<String, dynamic>> createTaxonomyClass(String name, {String phylum = 'Chordata', String kingdom = 'Animalia'}) async {
  final response = await _client
      .from('taxonomy_classes')
      .insert({'name': name, 'phylum': phylum, 'kingdom': kingdom})
      .select()
      .single();
  return response;
}

Future<Map<String, dynamic>> createTaxonomyOrder(String name, int classId) async {
  final response = await _client
      .from('taxonomy_orders')
      .insert({'name': name, 'class_id': classId})
      .select()
      .single();
  return response;
}

Future<Map<String, dynamic>> createTaxonomyFamily(String name, int orderId) async {
  final response = await _client
      .from('taxonomy_families')
      .insert({'name': name, 'order_id': orderId})
      .select()
      .single();
  return response;
}

Future<Map<String, dynamic>> createTaxonomyGenus(String name, int familyId) async {
  final response = await _client
      .from('taxonomy_genera')
      .insert({'name': name, 'family_id': familyId})
      .select()
      .single();
  return response;
}

// ── Update helpers ──

Future<void> updateTaxonomyClass(int id, String name) async {
  await _client.from('taxonomy_classes').update({'name': name}).eq('id', id);
}

Future<void> updateTaxonomyOrder(int id, String name) async {
  await _client.from('taxonomy_orders').update({'name': name}).eq('id', id);
}

Future<void> updateTaxonomyFamily(int id, String name) async {
  await _client.from('taxonomy_families').update({'name': name}).eq('id', id);
}

Future<void> updateTaxonomyGenus(int id, String name) async {
  await _client.from('taxonomy_genera').update({'name': name}).eq('id', id);
}

// ── Delete helpers ──

Future<void> deleteTaxonomyClass(int id) async {
  await _client.from('taxonomy_classes').delete().eq('id', id);
}

Future<void> deleteTaxonomyOrder(int id) async {
  await _client.from('taxonomy_orders').delete().eq('id', id);
}

Future<void> deleteTaxonomyFamily(int id) async {
  await _client.from('taxonomy_families').delete().eq('id', id);
}

Future<void> deleteTaxonomyGenus(int id) async {
  await _client.from('taxonomy_genera').delete().eq('id', id);
}

// ── Count providers (for taxonomy summary) ──

final taxonomyClassCountProvider = FutureProvider<int>((ref) async {
  final response = await _client.from('taxonomy_classes').select().count(CountOption.exact);
  return response.count;
});

final taxonomyOrderCountProvider = FutureProvider<int>((ref) async {
  final response = await _client.from('taxonomy_orders').select().count(CountOption.exact);
  return response.count;
});

final taxonomyFamilyCountProvider = FutureProvider<int>((ref) async {
  final response = await _client.from('taxonomy_families').select().count(CountOption.exact);
  return response.count;
});

final taxonomyGenusCountProvider = FutureProvider<int>((ref) async {
  final response = await _client.from('taxonomy_genera').select().count(CountOption.exact);
  return response.count;
});

/// Resolves genus_id → full taxonomy text fields for backward compatibility.
Future<Map<String, String?>> resolveTaxonomyFromGenusId(int genusId) async {
  final genus = await _client.from('taxonomy_genera').select().eq('id', genusId).single();
  final family = await _client.from('taxonomy_families').select().eq('id', genus['family_id']).single();
  final order = await _client.from('taxonomy_orders').select().eq('id', family['order_id']).single();
  final taxClass = await _client.from('taxonomy_classes').select().eq('id', order['class_id']).single();

  return {
    'taxonomy_kingdom': taxClass['kingdom'] as String?,
    'taxonomy_phylum': taxClass['phylum'] as String?,
    'taxonomy_class': taxClass['name'] as String?,
    'taxonomy_order': order['name'] as String?,
    'taxonomy_family': family['name'] as String?,
    'taxonomy_genus': genus['name'] as String?,
  };
}
