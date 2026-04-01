// ignore_for_file: invalid_use_of_protected_member
import 'dart:async' show unawaited;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' show databaseFactory;
import 'package:galapagos_wildlife/core/constants/supabase_constants.dart';
import 'package:galapagos_wildlife/data/local/drift/repository/wildlife_repository.dart';
import 'package:galapagos_wildlife/features/map/services/field_edit_service.dart';
import 'init_storage.dart';
import 'init_supabase.dart';

class InitRepository {
  static Future<void> init() async {
    // Configure WildlifeRepository (Drift local DB + Supabase remote sync).
    if (!kIsWeb) {
      await WildlifeRepository.configure(
        supabaseUrl: SupabaseConstants.url,
        supabaseKey: SupabaseConstants.anonKey,
        databaseFactory: databaseFactory,
      );

      // Clear any offline queue requests that have failed too many times
      try {
        final queueManager =
            WildlifeRepository.instance.offlineQueueClient.requestManager;
        final pending = await queueManager.unprocessedRequests();
        int cleared = 0;
        for (final req in pending) {
          final id = req['id'] as int?;
          final attempts = req['attempts'] as int? ?? 0;
          if (id != null && attempts > 10) {
            await queueManager.delete(id);
            cleared++;
          }
        }
        if (cleared > 0) {
          debugPrint('🧹 Cleared $cleared stuck offline queue request(s)');
        }
      } catch (e) {
        debugPrint('⚠️ Could not clear offline queue: $e');
      }
    } else {
      await WildlifeRepository.configure(
        supabaseUrl: SupabaseConstants.url,
        supabaseKey: SupabaseConstants.anonKey,
      );
    }

    // Record sync timestamp if Supabase connected
    if (InitSupabase.connected) {
      await InitStorage.prefs.setInt(
        'last_synced',
        DateTime.now().millisecondsSinceEpoch,
      );
      // Upload any trails that were recorded offline in a previous session (mobile only).
      if (!kIsWeb) {
        final pendingCount = FieldEditService.pendingTrailCount();
        if (pendingCount > 0) {
          debugPrint('📤 Found $pendingCount pending trail(s) — syncing now…');
          unawaited(FieldEditService.syncPendingTrails());
        }
      }
    }
  }
}
