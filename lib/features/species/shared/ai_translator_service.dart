import 'package:galapagos_wildlife/features/ai_chat/services/ai_chat_service.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/gemma_species_service.dart';

class AiTranslatorService {
  static const supportedLanguages = {
    'fr': 'French',
    'de': 'German',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'pt': 'Portuguese',
    'it': 'Italian',
    'ko': 'Korean',
  };

  static Future<String?> translate(String text, String targetLang) async {
    final status = await GemmaSpeciesService.checkStatus();
    if (status != GemmaModelStatus.ready) return null;

    final langName = supportedLanguages[targetLang] ?? targetLang;
    try {
      return await AiChatService.sendMessage(
        'Translate the following to $langName. Only output the translation, nothing else:\n\n$text',
      );
    } catch (_) {
      return null;
    }
  }
}
