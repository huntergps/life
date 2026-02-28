import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/bootstrap.dart';
import 'package:galapagos_wildlife/features/badges/models/badge_definition.dart';
import 'package:galapagos_wildlife/features/badges/providers/badges_provider.dart';

const _prefsKey = 'unlocked_badges';

/// Returns a list of [BadgeProgress] items that were NEWLY unlocked
/// (i.e. not yet stored in SharedPreferences).
///
/// After the caller shows the notification dialog it must call
/// [markBadgesAsSeen] to persist the updated set.
final newlyUnlockedBadgesProvider =
    FutureProvider<List<BadgeProgress>>((ref) async {
  final allProgress = await ref.watch(badgeProgressProvider.future);

  // Current unlocked badge IDs from the computed progress
  final currentUnlocked = allProgress
      .where((p) => p.isUnlocked)
      .map((p) => p.badge.id)
      .toSet();

  // Previously seen unlocked IDs persisted in SharedPreferences
  final storedIds =
      Bootstrap.prefs.getStringList(_prefsKey)?.toSet() ?? <String>{};

  // New = currently unlocked but not yet stored
  final newIds = currentUnlocked.difference(storedIds);

  if (newIds.isEmpty) return [];

  return allProgress
      .where((p) => newIds.contains(p.badge.id))
      .toList();
});

/// Persists badge IDs so they are not shown again.
void markBadgesAsSeen(List<BadgeProgress> badges) {
  final storedIds =
      Bootstrap.prefs.getStringList(_prefsKey)?.toSet() ?? <String>{};
  storedIds.addAll(badges.map((b) => b.badge.id));
  Bootstrap.prefs.setStringList(_prefsKey, storedIds.toList());
}
