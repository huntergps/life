import 'package:galapagos_wildlife/features/ai_chat/services/ai_chat_service.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/gemma_species_service.dart';
import 'package:galapagos_wildlife/models/species.model.dart';
import 'package:share_plus/share_plus.dart';

class AiCaptionService {
  static Future<String?> generateCaption(
    Species species, {
    required bool isEs,
  }) async {
    final status = await GemmaSpeciesService.checkStatus();
    if (status != GemmaModelStatus.ready) return null;

    final name = isEs ? species.commonNameEs : species.commonNameEn;
    final scientific = species.scientificName;
    final conservation = species.conservationStatus ?? '';

    final prompt = isEs
        ? 'Genera un caption para Instagram sobre haber visto un $name ($scientific) en las Islas Galapagos. '
            '${conservation.isNotEmpty ? "Estado de conservacion: $conservation. " : ""}'
            'Incluye emojis, hashtags relevantes, y un dato curioso. Maximo 3 lineas. Tono: emocionado y educativo.'
        : 'Generate an Instagram caption about spotting a $name ($scientific) in the Galapagos Islands. '
            '${conservation.isNotEmpty ? "Conservation status: $conservation. " : ""}'
            'Include emojis, relevant hashtags, and a fun fact. Maximum 3 lines. Tone: excited and educational.';

    try {
      return await AiChatService.sendMessage(prompt);
    } catch (_) {
      return null;
    }
  }

  static Future<void> generateAndShare(
    Species species, {
    required bool isEs,
  }) async {
    final caption = await generateCaption(species, isEs: isEs);
    if (caption != null) {
      await SharePlus.instance.share(ShareParams(text: caption));
    }
  }
}
