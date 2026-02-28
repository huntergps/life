import 'dart:async';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:galapagos_wildlife/brick/repository.dart';

/// Fetches a list from Brick with local-first strategy.
///
/// By default returns local SQLite data immediately and fires a background
/// sync so the next read gets fresh data.
///
/// Set [awaitRemote] = true to wait for Supabase before returning.
/// When online this guarantees all columns are populated from the server;
/// when offline it falls back to the local cache automatically.
///
/// Deduplicates results by [idSelector] (last occurrence wins = freshest data).
Future<List<T>> fetchDeduped<T extends OfflineFirstWithSupabaseModel>({
  required int Function(T) idSelector,
  OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.awaitRemote,
  Query? query,
  bool awaitRemote = false,
}) async {
  final repo = Repository();

  List<T> raw;

  if (awaitRemote) {
    // Await Supabase response so all server-side columns are populated.
    // Falls back to local cache on any network error.
    try {
      raw = await repo.get<T>(
        policy: OfflineFirstGetPolicy.awaitRemote,
        query: query,
      );
    } catch (_) {
      raw = await repo.get<T>(
        policy: OfflineFirstGetPolicy.localOnly,
        query: query,
      );
    }
  } else {
    // Fast local-first path: return SQLite immediately.
    raw = await repo.get<T>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: query,
    );

    // Fire background sync so next invalidation has fresh data.
    if (policy != OfflineFirstGetPolicy.localOnly) {
      unawaited(
        repo
            .get<T>(policy: OfflineFirstGetPolicy.awaitRemote, query: query)
            .catchError((_) => <T>[]),
      );
    }
  }

  final deduped = <int, T>{};
  for (final item in raw) {
    deduped[idSelector(item)] = item;
  }
  return deduped.values.toList();
}

/// Builds a lookup map from Brick results, deduplicating by [idSelector].
Future<Map<int, T>> fetchLookup<T extends OfflineFirstWithSupabaseModel>({
  required int Function(T) idSelector,
  OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.localOnly,
  Query? query,
}) async {
  final raw = await Repository().get<T>(policy: policy, query: query);
  final map = <int, T>{};
  for (final item in raw) {
    map[idSelector(item)] = item;
  }
  return map;
}
