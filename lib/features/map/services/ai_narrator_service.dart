import 'package:galapagos_wildlife/features/ai_chat/services/ai_chat_service.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/gemma_species_service.dart';
import 'package:galapagos_wildlife/models/visit_site.model.dart';
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';

class AiNarratorService {
  /// Generate a narration for a visit site, like a tour guide would.
  /// Cached per site to avoid regenerating.
  static Future<String?> narrateSite(VisitSite site,
      {required bool isEs}) async {
    final status = await GemmaSpeciesService.checkStatus();
    if (status != GemmaModelStatus.ready) return null;

    // Check cache
    final cacheKey = 'narrator_${site.id}';
    final cached = Bootstrap.prefs.getString(cacheKey);
    if (cached != null) return cached;

    final siteName = isEs ? site.nameEs : (site.nameEn ?? site.nameEs);

    final prompt = isEs
        ? 'Eres un guia naturalista de Galapagos. Narra una breve introduccion (3-4 oraciones) sobre el sitio de visita "$siteName". '
            'Menciona que lo hace especial, que fauna se puede encontrar, y un dato historico o geologico interesante. '
            'Tono: entusiasta y educativo, como si le hablaras a un grupo de turistas.'
        : 'You are a Galapagos naturalist guide. Narrate a brief introduction (3-4 sentences) about the visit site "$siteName". '
            'Mention what makes it special, what wildlife can be found, and an interesting historical or geological fact. '
            'Tone: enthusiastic and educational, as if speaking to a group of tourists.';

    try {
      final result = await AiChatService.sendMessage(prompt);
      // Cache the result
      await Bootstrap.prefs.setString(cacheKey, result);
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Clear cached narrations
  static Future<void> clearCache() async {
    final keys =
        Bootstrap.prefs.getKeys().where((k) => k.startsWith('narrator_'));
    for (final key in keys) {
      await Bootstrap.prefs.remove(key);
    }
  }
}
