import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/constants/supabase_constants.dart';

class InitSupabase {
  static bool connected = false;

  static Future<void> init() async {
    // Initialize Supabase for auth/storage
    try {
      await Supabase.initialize(
        url: SupabaseConstants.url,
        anonKey: SupabaseConstants.anonKey,
      );
      connected = true;
    } catch (e) {
      debugPrint('Supabase init failed (offline mode): $e');
    }
  }
}
