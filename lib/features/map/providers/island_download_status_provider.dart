import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'downloaded_island_ids';

/// Tracks which islands have had their map tiles fully downloaded.
/// Persists across app restarts using SharedPreferences.
class IslandDownloadStatusNotifier extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_prefKey) ?? [];
    return ids.map((s) => int.tryParse(s)).whereType<int>().toSet();
  }

  Future<void> markDownloaded(int islandId) async {
    final current = state.asData?.value ?? {};
    final updated = {...current, islandId};
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, updated.map((id) => '$id').toList());
  }

  Future<void> markAllDownloaded(Iterable<int> islandIds) async {
    final current = state.asData?.value ?? {};
    final updated = {...current, ...islandIds};
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, updated.map((id) => '$id').toList());
  }

  Future<void> clearAll() async {
    state = const AsyncData({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  bool isDownloaded(int islandId) {
    return state.asData?.value.contains(islandId) ?? false;
  }
}

final islandDownloadStatusProvider =
    AsyncNotifierProvider<IslandDownloadStatusNotifier, Set<int>>(
  IslandDownloadStatusNotifier.new,
);
