import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/brick/models/species_sound.model.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';

final speciesSoundsProvider = FutureProvider.family<List<SpeciesSound>, int>((ref, speciesId) async {
  if (kIsWeb) {
    final data = await Supabase.instance.client
        .from('species_sounds')
        .select()
        .eq('species_id', speciesId)
        .order('id');
    return (data as List).map((r) {
      final m = r as Map<String, dynamic>;
      return SpeciesSound(
        id: m['id'] as int,
        speciesId: m['species_id'] as int,
        soundUrl: m['sound_url'] as String,
        soundType: m['sound_type'] as String?,
        descriptionEs: m['description_es'] as String?,
        descriptionEn: m['description_en'] as String?,
        recordedBy: m['recorded_by'] as String?,
        recordedDate: m['recorded_date'] != null
            ? DateTime.tryParse(m['recorded_date'] as String)
            : null,
      );
    }).toList();
  }
  return fetchDeduped<SpeciesSound>(
    idSelector: (s) => s.id,
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where('speciesId').isExactly(speciesId)]),
  );
});
