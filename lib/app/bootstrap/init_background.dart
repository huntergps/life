import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:galapagos_wildlife/features/map/services/pmtiles_manager.dart';

class InitBackground {
  static Future<void> init() async {
    // Initialize background_downloader (native only)
    if (!kIsWeb) {
      try {
        FileDownloader().configureNotificationForGroup(
          FileDownloader.defaultGroup,
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
}
