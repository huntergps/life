import 'package:geolocator/geolocator.dart';
import 'package:galapagos_wildlife/features/ai_chat/services/ai_chat_service.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/gemma_species_service.dart';
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';

class AiWhatToSeeService {
  static const _cacheKey = 'ai_what_to_see';
  static const _cacheDateKey = 'ai_what_to_see_date';

  /// Generate contextual species suggestions based on location, time, and season.
  /// Cached for the current half-day (morning/afternoon).
  static Future<String?> getWhatToSee({required bool isEs}) async {
    final status = await GemmaSpeciesService.checkStatus();
    if (status != GemmaModelStatus.ready) return null;

    // Cache key includes date + AM/PM
    final now = DateTime.now();
    final period = now.hour < 12 ? 'AM' : 'PM';
    final cacheId = '${now.toIso8601String().substring(0, 10)}_$period';
    final cached = Bootstrap.prefs.getString(_cacheDateKey);
    if (cached == cacheId) {
      return Bootstrap.prefs.getString(_cacheKey);
    }

    // Get location
    String locationHint = 'Galapagos Islands';
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
      locationHint =
          'latitude ${pos.latitude.toStringAsFixed(2)}, longitude ${pos.longitude.toStringAsFixed(2)} in the Galapagos Islands';
    } catch (_) {}

    final month = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][now.month - 1];
    final timeOfDay = now.hour < 6
        ? 'early morning'
        : now.hour < 12
            ? 'morning'
            : now.hour < 17
                ? 'afternoon'
                : 'evening';

    final prompt = isEs
        ? 'Estoy en $locationHint. Es $month, $timeOfDay. Que 5 especies de Galapagos tengo mas probabilidad de ver ahora mismo? Lista breve con emoji y 1 dato de cada una.'
        : 'I am at $locationHint. It is $month, $timeOfDay. What 5 Galapagos species am I most likely to see right now? Brief list with emoji and 1 fact each.';

    try {
      final result = await AiChatService.sendMessage(prompt);
      await Bootstrap.prefs.setString(_cacheKey, result);
      await Bootstrap.prefs.setString(_cacheDateKey, cacheId);
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Clear the cache so the next call regenerates.
  static Future<void> clearCache() async {
    await Bootstrap.prefs.remove(_cacheDateKey);
    await Bootstrap.prefs.remove(_cacheKey);
  }
}
