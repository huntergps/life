import 'dart:async' show unawaited;
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_constants.dart';
import 'brick/repository.dart';
import 'features/map/services/field_edit_service.dart';
import 'features/map/services/pmtiles_manager.dart';

class Bootstrap {
  /// Pre-loaded SharedPreferences instance, available synchronously after init.
  static late final SharedPreferences prefs;

  /// Whether Supabase connected successfully during init.
  static bool supabaseConnected = false;

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Load SharedPreferences early so providers can read synchronously
    prefs = await SharedPreferences.getInstance();

    // Initialize intl date formatting for locale-aware DateFormat
    await initializeDateFormatting();

    // Initialize FMTC for offline map tile caching
    try {
      await FMTCObjectBoxBackend().initialise();

      // Create all map tile stores
      const stores = [
        'galapagosMap',      // Street/OSM tiles
        'satelliteCache',    // ESRI satellite tiles
        'labelsCache',       // CartoDB label overlay tiles
      ];

      for (final storeName in stores) {
        try {
          final store = FMTCStore(storeName);
          await store.manage.create();
          debugPrint('✅ FMTC store created: $storeName');
        } catch (e) {
          debugPrint('⚠️ FMTC store $storeName already exists or failed: $e');
        }
      }
    } catch (e) {
      debugPrint('FMTC init failed: $e');
    }

    // Initialize Supabase for auth/storage
    try {
      await Supabase.initialize(
        url: SupabaseConstants.url,
        anonKey: SupabaseConstants.anonKey,
      );
      supabaseConnected = true;
    } catch (e) {
      debugPrint('Supabase init failed (offline mode): $e');
    }

    // Configure Brick repository (offline-first, works without backend)
    Repository.configure(
      supabaseUrl: SupabaseConstants.url,
      supabaseAnonKey: SupabaseConstants.anonKey,
    );

    await Repository().initialize();

    // Clear any offline queue requests that have failed too many times
    // (prevents log spam from stuck requests like old admin trail updates)
    try {
      final queueManager =
          Repository().offlineRequestQueue.client.requestManager;
      final pending = await queueManager.unprocessedRequests();
      int cleared = 0;
      for (final req in pending) {
        final id = req[queueManager.primaryKeyColumn] as int?;
        final attempts = req['attempts'] as int? ?? 0;
        if (id != null && attempts > 10) {
          await queueManager.deleteUnprocessedRequest(id);
          cleared++;
        }
      }
      if (cleared > 0) {
        debugPrint('🧹 Cleared $cleared stuck offline queue request(s)');
      }
    } catch (e) {
      debugPrint('⚠️ Could not clear offline queue: $e');
    }

    // Record sync timestamp if Supabase connected
    if (supabaseConnected) {
      await prefs.setInt(
        'last_synced',
        DateTime.now().millisecondsSinceEpoch,
      );
      // Upload any trails that were recorded offline in a previous session.
      final pending = FieldEditService.pendingTrailCount();
      if (pending > 0) {
        debugPrint('📤 Found $pending pending trail(s) — syncing now…');
        unawaited(FieldEditService.syncPendingTrails());
      }
    }

    // Initialize background_downloader (uses iOS URLSession background config)
    try {
      FileDownloader().configureNotificationForGroup(
        FileDownloader.defaultGroup,
        // Show a persistent notification while downloading
        running: const TaskNotification(
          'Descargando mapa',
          'La descarga continúa en segundo plano',
        ),
        complete: const TaskNotification(
          'Mapa descargado',
          'El mapa HD de Galápagos está listo',
        ),
        error: const TaskNotification(
          'Error en descarga',
          'No se pudo descargar el mapa. Intenta de nuevo.',
        ),
        progressBar: true,
      );
    } catch (e) {
      debugPrint('FileDownloader init failed: $e');
    }

    // Ensure PMTiles base map is available (copy from assets if needed)
    try {
      await PmTilesManager.ensureAvailable();
    } catch (e) {
      debugPrint('PMTiles setup failed: $e');
    }
  }
}
