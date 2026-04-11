import 'package:galapagos_wildlife/features/ai_chat/services/ai_chat_service.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/gemma_species_service.dart';
import 'package:galapagos_wildlife/models/sighting.model.dart';
import 'package:galapagos_wildlife/models/species.model.dart';
import 'package:intl/intl.dart';

class AiDiaryService {
  /// Generate a diary entry for a specific day's sightings.
  static Future<String?> generateDiaryEntry({
    required DateTime date,
    required List<Sighting> sightings,
    required Map<int, Species> speciesMap,
    required bool isEs,
  }) async {
    final status = await GemmaSpeciesService.checkStatus();
    if (status != GemmaModelStatus.ready) return null;

    if (sightings.isEmpty) return null;

    final dateStr = DateFormat.yMMMMd(isEs ? 'es' : 'en').format(date);

    // Build sighting summary with times
    final entries = sightings.map((s) {
      final species = speciesMap[s.speciesId];
      final name = isEs
          ? (species?.commonNameEs ?? '?')
          : (species?.commonNameEn ?? '?');
      final time = s.observedAt != null ? DateFormat.Hm().format(s.observedAt!) : '';
      final hasPhoto = s.photoUrl != null ? '(photo)' : '';
      final notes = s.notes ?? '';
      return '$time - $name $hasPhoto ${notes.isNotEmpty ? ": $notes" : ""}'
          .trim();
    }).join('\n');

    final prompt = isEs
        ? 'Escribe una entrada de diario de viaje para $dateStr en las Islas Galapagos. '
            'Avistamientos del dia:\n$entries\n\n'
            'Escribe en primera persona, 2-3 parrafos, tono personal y emotivo. '
            'Incluye detalles sobre el clima, las emociones y los momentos especiales.'
        : 'Write a travel diary entry for $dateStr in the Galapagos Islands. '
            "Today's sightings:\n$entries\n\n"
            'Write in first person, 2-3 paragraphs, personal and emotional tone. '
            'Include details about the weather, emotions, and special moments.';

    try {
      return await AiChatService.sendMessage(prompt);
    } catch (_) {
      return null;
    }
  }
}
