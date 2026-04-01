import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// True on all native platforms where Brick + SQLite is supported:
  /// iOS, Android, macOS (sqflite_darwin), Linux and Windows (sqflite_common_ffi).
  /// Excludes web only.
  static bool get isMobile => !kIsWeb;

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await InitStorage.init();
    await InitMaps.init();
    await InitSupabase.init();
    await InitRepository.init();
    await InitBackground.init();
  }
}
