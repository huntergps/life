import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';
import 'package:galapagos_wildlife/features/ai_chat/services/ai_chat_service.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/gemma_species_service.dart';

class AiDailyFactService {
  static const _cacheKey = 'ai_daily_fact';
  static const _cacheDateKey = 'ai_daily_fact_date';

  /// Generate a fresh daily fact about Galapagos wildlife.
  /// Returns cached fact if already generated today.
  static Future<String?> getDailyFact({required bool isEs}) async {
    final status = await GemmaSpeciesService.checkStatus();
    if (status != GemmaModelStatus.ready) return null;

    // Check cache -- one fact per day
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final cachedDate = Bootstrap.prefs.getString(_cacheDateKey);
    if (cachedDate == today) {
      return Bootstrap.prefs.getString(_cacheKey);
    }

    final prompt = isEs
        ? 'Dime un dato curioso y sorprendente sobre la fauna de las Islas Galapagos. Maximo 2 oraciones. Se creativo y diferente cada vez.'
        : 'Tell me a surprising and curious fact about Galapagos Islands wildlife. Maximum 2 sentences. Be creative and different each time.';

    try {
      final fact = await AiChatService.sendMessage(prompt);
      await Bootstrap.prefs.setString(_cacheKey, fact);
      await Bootstrap.prefs.setString(_cacheDateKey, today);
      return fact;
    } catch (_) {
      return null;
    }
  }
}
