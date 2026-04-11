import 'package:galapagos_wildlife/features/ai_chat/services/ai_chat_service.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/gemma_species_service.dart';
import 'package:galapagos_wildlife/models/sighting.model.dart';
import 'package:galapagos_wildlife/models/species.model.dart';

class AiTripReportService {
  static Future<String?> generateReport({
    required List<Sighting> sightings,
    required Map<int, Species> speciesMap,
    required bool isEs,
  }) async {
    final status = await GemmaSpeciesService.checkStatus();
    if (status != GemmaModelStatus.ready) return null;

    // Build a summary of sightings
    final summary = sightings.map((s) {
      final species = speciesMap[s.speciesId];
      final name = species?.commonNameEn ?? 'Unknown';
      final date = s.observedAt?.toIso8601String().substring(0, 10) ?? '';
      return '$name ($date)';
    }).join(', ');

    final prompt = isEs
        ? 'Escribe un breve resumen narrativo (3-4 parrafos) de este viaje de observacion de fauna en Galapagos. Especies vistas: $summary. Hazlo emocionante y personal.'
        : 'Write a brief narrative summary (3-4 paragraphs) of this Galapagos wildlife trip. Species seen: $summary. Make it exciting and personal.';

    try {
      return await AiChatService.sendMessage(prompt);
    } catch (_) {
      return null;
    }
  }
}
