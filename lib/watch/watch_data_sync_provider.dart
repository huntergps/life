import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/brick/repository.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/features/sightings/services/sightings_service.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sightings_provider.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import 'watch_connectivity_service.dart';

/// Provider que orquesta la sincronización entre el Watch y Supabase.
///
/// - Recibe avistamientos del Watch → guarda en Supabase.
/// - Recibe trails del Watch → log (tabla trails pendiente).
/// - Envía lista de especies al Watch cuando el usuario abre el mapa.
final watchDataSyncProvider = Provider<WatchDataSync>((ref) {
  final sync = WatchDataSync(ref);
  ref.onDispose(sync.dispose);
  return sync;
});

class WatchDataSync {
  final Ref _ref;
  final WatchConnectivityService _watch = WatchConnectivityService.instance;

  WatchDataSync(this._ref) {
    _init();
  }

  Future<void> _init() async {
    // Activa la sesión WatchConnectivity
    await _watch.activate();

    // Escucha avistamientos entrantes del Watch
    _watch.onSightingReceived.listen(_handleSighting);

    // Escucha trails entrantes del Watch
    _watch.onTrailReceived.listen(_handleTrail);

    // Envía la lista de especies al Watch en el arranque
    await syncSpeciesToWatch();
  }

  // ─────────────────────────────────────────────────────
  // Recibir avistamiento del Watch
  // ─────────────────────────────────────────────────────

  Future<void> _handleSighting(Map<String, dynamic> data) async {
    try {
      final speciesId = data['species_id'] as int;
      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();
      final notes = data['notes'] as String?;
      final observedAt = DateTime.tryParse(
            data['observed_at'] as String? ?? '',
          ) ??
          DateTime.now();

      await SightingsService().createSighting(
        speciesId: speciesId,
        observedAt: observedAt,
        notes: notes,
        latitude: lat,
        longitude: lng,
      );

      _ref.invalidate(sightingsProvider);
      AppLogger.info('Watch sighting saved: species $speciesId');
    } catch (e) {
      AppLogger.error('Error saving Watch sighting', e);
    }
  }

  // ─────────────────────────────────────────────────────
  // Recibir trail del Watch
  // ─────────────────────────────────────────────────────

  Future<void> _handleTrail(Map<String, dynamic> data) async {
    try {
      final name = data['name'] as String? ?? 'Trail Watch';
      final rawCoords = data['coordinates'] as List?;
      if (rawCoords == null || rawCoords.isEmpty) return;

      // TODO: guardar trail en Supabase cuando exista tabla trails
      AppLogger.info('Watch trail recibido: $name (${rawCoords.length} pts)');
    } catch (e) {
      AppLogger.error('Error saving Watch trail', e);
    }
  }

  // ─────────────────────────────────────────────────────
  // Enviar especies al Watch
  // ─────────────────────────────────────────────────────

  /// Llamar cuando el usuario abre el mapa o hace login.
  Future<void> syncSpeciesToWatch() async {
    try {
      final species = await Repository().get<Species>();
      final payload = species
          .map((s) => {
                'id': s.id,
                'common_name_es': s.commonNameEs,
                'common_name_en': s.commonNameEn,
                'scientific_name': s.scientificName,
                'category_id': s.categoryId,
                'conservation_status': s.conservationStatus,
              })
          .toList();

      await _watch.sendSpeciesToWatch(payload);
    } catch (e) {
      AppLogger.error('Error syncing species to Watch', e);
    }
  }

  void dispose() {
    _watch.dispose();
  }
}
