import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/bootstrap.dart';
import 'package:galapagos_wildlife/features/daily_facts/models/daily_fact_definition.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sightings_provider.dart';

/// Provides progress for all daily facts based on user's sighting count
/// Pattern copied from: lib/features/badges/providers/badges_provider.dart
final dailyFactsProvider = FutureProvider<List<FactProgress>>((ref) async {
  // Get all sightings to calculate total count
  final sightings = await ref.watch(sightingsProvider.future);
  final totalSightings = sightings.length;

  // Get all fact definitions
  final facts = allFacts();

  // Map each fact to its progress
  return facts.map((fact) {
    return FactProgress(
      fact: fact,
      currentSightings: totalSightings,
    );
  }).toList();
});

/// Provider for count of unlocked facts
final unlockedFactCountProvider = FutureProvider<int>((ref) async {
  final progress = await ref.watch(dailyFactsProvider.future);
  return progress.where((p) => p.isUnlocked).length;
});

/// Provider for total fact count
final totalFactCountProvider = Provider<int>((ref) {
  return allFacts().length;
});

/// Detects newly unlocked facts since last check
/// Pattern copied from: lib/features/badges/providers/badge_notification_provider.dart
final newlyUnlockedFactsProvider =
    FutureProvider<List<FactProgress>>((ref) async {
  const prefsKey = 'unlocked_facts';

  // Get all current progress
  final allProgress = await ref.watch(dailyFactsProvider.future);

  // Get currently unlocked fact IDs
  final currentUnlocked =
      allProgress.where((p) => p.isUnlocked).map((p) => p.fact.id).toSet();

  // Get previously stored unlocked fact IDs
  final storedIds =
      Bootstrap.prefs.getStringList(prefsKey)?.toSet() ?? <String>{};

  // Find newly unlocked facts (in current but not in stored)
  final newIds = currentUnlocked.difference(storedIds);

  // Return only newly unlocked facts
  return allProgress.where((p) => newIds.contains(p.fact.id)).toList();
});

/// Marks facts as seen (stores in SharedPreferences)
void markFactsAsSeen(List<FactProgress> facts) {
  const prefsKey = 'unlocked_facts';

  // Get existing stored IDs
  final storedIds =
      Bootstrap.prefs.getStringList(prefsKey)?.toSet() ?? <String>{};

  // Add new fact IDs
  storedIds.addAll(facts.map((f) => f.fact.id));

  // Save back to preferences
  Bootstrap.prefs.setStringList(prefsKey, storedIds.toList());
}
