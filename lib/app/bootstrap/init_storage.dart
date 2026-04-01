import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show sqfliteFfiInit, databaseFactoryFfi, databaseFactory;
import 'package:intl/date_symbol_data_local.dart';

class InitStorage {
  static late final SharedPreferences prefs;

  static Future<void> init() async {
    // Initialize sqflite FFI for Linux and Windows (sqflite_darwin handles macOS natively)
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Load SharedPreferences early so providers can read synchronously
    prefs = await SharedPreferences.getInstance();

    // Initialize intl date formatting for locale-aware DateFormat
    await initializeDateFormatting();
  }
}
