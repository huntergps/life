import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'init_storage.dart';
import 'init_supabase.dart';
import 'init_maps.dart';
import 'init_repository.dart';
import 'init_background.dart';

class Bootstrap {
  /// Pre-loaded SharedPreferences instance, available synchronously after init.
  static SharedPreferences get prefs => InitStorage.prefs;

  /// Whether Supabase connected successfully during init.
  static bool get supabaseConnected => InitSupabase.connected;

  /// True on all native platforms where SQLite is supported.
  static bool get isMobile => !kIsWeb;

  /// Shorebird updater instance.
  static final shorebirdUpdater = ShorebirdUpdater();

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await InitStorage.init();
    await InitMaps.init();
    await InitSupabase.init();
    await InitRepository.init();
    await InitBackground.init();

    // Check for Shorebird patches (non-blocking, native only — not available on web)
    if (!kIsWeb) _checkForUpdate();
  }

  /// Checks for OTA patches from Shorebird. Downloads silently in background.
  /// The patch is applied on next app restart.
  static Future<void> _checkForUpdate() async {
    try {
      final status = await shorebirdUpdater.checkForUpdate();
      if (status == UpdateStatus.outdated) {
        debugPrint('Shorebird: patch available, downloading...');
        await shorebirdUpdater.update();
        debugPrint('Shorebird: patch downloaded. Will apply on next restart.');
      } else {
        debugPrint('Shorebird: app is up to date.');
      }
    } catch (e) {
      debugPrint('Shorebird: update check failed (offline?): $e');
    }
  }
}
