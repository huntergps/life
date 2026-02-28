import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'brick.g.dart';
import 'db/schema.g.dart';

class Repository extends OfflineFirstWithSupabaseRepository {
  static late Repository? _singleton;

  Repository._({
    required super.supabaseProvider,
    required super.sqliteProvider,
    required super.migrations,
    required super.offlineRequestQueue,
    super.memoryCacheProvider,
  });

  factory Repository() => _singleton!;

  /// Writes [instance] to local SQLite only — bypasses the Supabase offline
  /// queue entirely. Use this after a successful direct Supabase write to keep
  /// the local cache in sync without re-queuing the same write.
  Future<void> upsertSqlite<T extends OfflineFirstModel>(T instance) async {
    await sqliteProvider.upsert<T>(instance, repository: this);
  }

  static void configure({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) {
    final (client, queue) = OfflineFirstWithSupabaseRepository.clientQueue(
      databaseFactory: databaseFactory,
    );

    final provider = SupabaseProvider(
      SupabaseClient(supabaseUrl, supabaseAnonKey, httpClient: client),
      modelDictionary: supabaseModelDictionary,
    );

    _singleton = Repository._(
      supabaseProvider: provider,
      sqliteProvider: SqliteProvider(
        'galapagos_wildlife.sqlite',
        databaseFactory: databaseFactory,
        modelDictionary: sqliteModelDictionary,
      ),
      migrations: migrations,
      offlineRequestQueue: queue,
      memoryCacheProvider: MemoryCacheProvider(),
    );
  }
}
