import 'dart:typed_data';
import 'package:galapagos_wildlife/features/ai_chat/services/ai_chat_service.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/gemma_species_service.dart';

class AiDescriptionService {
  static Future<String?> generateDescription(Uint8List imageBytes,
      {required bool isEs}) async {
    final status = await GemmaSpeciesService.checkStatus();
    if (status != GemmaModelStatus.ready) return null;

    final prompt = isEs
        ? 'Describe esta observacion de fauna de Galapagos en 1-2 oraciones. Incluye especie, comportamiento y tamano aproximado si es visible.'
        : 'Describe this Galapagos wildlife observation in 1-2 sentences. Include species, behavior, and approximate size if visible.';

    try {
      return await AiChatService.sendMessage(prompt, image: imageBytes);
    } catch (_) {
      return null;
    }
  }
}
