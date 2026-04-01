import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class InitMaps {
  static Future<void> init() async {
    // Initialize FMTC for offline map tile caching (native only)
    if (!kIsWeb) {
      try {
        await FMTCObjectBoxBackend().initialise();

        const stores = [
          'galapagosMap', // Street/OSM tiles
          'satelliteCache', // ESRI satellite tiles
          'labelsCache', // CartoDB label overlay tiles
        ];

        for (final storeName in stores) {
          try {
            final store = FMTCStore(storeName);
            await store.manage.create();
            debugPrint('✅ FMTC store created: $storeName');
          } catch (e) {
            debugPrint(
                '⚠️ FMTC store $storeName already exists or failed: $e');
          }
        }
      } catch (e) {
        debugPrint('FMTC init failed: $e');
      }
    }
  }
}
