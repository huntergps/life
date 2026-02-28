import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:galapagos_wildlife/core/constants/mapbox_constants.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import 'package:galapagos_wildlife/features/map/providers/pmtiles_provider.dart';
import 'package:galapagos_wildlife/features/map/services/pmtiles_manager.dart';

// ---------------------------------------------------------------------------
// Shared constants
// ---------------------------------------------------------------------------

/// FMTC store name — kept for backward compatibility but FMTC tile-by-tile
/// downloading has been replaced by the single HD PMTiles file approach.
const mapDownloadStoreName = 'galapagosMap';

/// FMTC instance ID for satellite bulk downloads (separate from default 0).
const _satelliteInstanceId = 'satellite';

/// Galápagos archipelago bounding box used for satellite tile pre-download.
/// Covers all islands from Española (south) to Wolf/Darwin (north).
const _galapagosNorth = 1.9;
const _galapagosSouth = -1.6;
const _galapagosEast = -89.0;
const _galapagosWest = -92.2;

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum DownloadStatus { idle, downloading, paused, completed, cancelled, error }

/// Only one PMTiles download type now: the HD PMTiles file.
enum DownloadType { none, hdPmtiles }

@immutable
class MapDownloadState {
  // ── PMTiles (base vector map) ──────────────────────────────────────────────
  final DownloadStatus status;
  final DownloadType activeType;
  final double overallProgress;
  final String? errorMessage;

  // ── Satellite tile bulk download ───────────────────────────────────────────
  final DownloadStatus satelliteStatus;
  final double satelliteProgress; // 0.0 – 1.0
  final String? satelliteErrorMessage;
  final int satelliteTilesAttempted;
  final int satelliteMaxTiles;

  const MapDownloadState({
    this.status = DownloadStatus.idle,
    this.activeType = DownloadType.none,
    this.overallProgress = 0,
    this.errorMessage,
    this.satelliteStatus = DownloadStatus.idle,
    this.satelliteProgress = 0,
    this.satelliteErrorMessage,
    this.satelliteTilesAttempted = 0,
    this.satelliteMaxTiles = 0,
  });

  bool get isActive => status == DownloadStatus.downloading;
  bool get isPaused => status == DownloadStatus.paused;
  bool get isSatelliteActive => satelliteStatus == DownloadStatus.downloading;
  bool get isSatellitePaused => satelliteStatus == DownloadStatus.paused;

  MapDownloadState copyWith({
    DownloadStatus? status,
    DownloadType? activeType,
    double? overallProgress,
    String? errorMessage,
    DownloadStatus? satelliteStatus,
    double? satelliteProgress,
    String? satelliteErrorMessage,
    int? satelliteTilesAttempted,
    int? satelliteMaxTiles,
  }) {
    return MapDownloadState(
      status: status ?? this.status,
      activeType: activeType ?? this.activeType,
      overallProgress: overallProgress ?? this.overallProgress,
      errorMessage: errorMessage ?? this.errorMessage,
      satelliteStatus: satelliteStatus ?? this.satelliteStatus,
      satelliteProgress: satelliteProgress ?? this.satelliteProgress,
      satelliteErrorMessage:
          satelliteErrorMessage ?? this.satelliteErrorMessage,
      satelliteTilesAttempted:
          satelliteTilesAttempted ?? this.satelliteTilesAttempted,
      satelliteMaxTiles: satelliteMaxTiles ?? this.satelliteMaxTiles,
    );
  }

  /// Returns a copy with only PMTiles fields updated, satellite state preserved.
  MapDownloadState _withPmtiles({
    required DownloadStatus status,
    DownloadType activeType = DownloadType.none,
    double overallProgress = 0,
    String? errorMessage,
  }) =>
      MapDownloadState(
        status: status,
        activeType: activeType,
        overallProgress: overallProgress,
        errorMessage: errorMessage,
        satelliteStatus: satelliteStatus,
        satelliteProgress: satelliteProgress,
        satelliteErrorMessage: satelliteErrorMessage,
        satelliteTilesAttempted: satelliteTilesAttempted,
        satelliteMaxTiles: satelliteMaxTiles,
      );

  /// Returns a copy with satellite fields reset, PMTiles state preserved.
  MapDownloadState _withSatelliteReset() => MapDownloadState(
        status: status,
        activeType: activeType,
        overallProgress: overallProgress,
        errorMessage: errorMessage,
        satelliteStatus: DownloadStatus.idle,
      );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class MapDownloadNotifier extends Notifier<MapDownloadState> {
  StreamSubscription<DownloadProgress>? _satelliteSubscription;

  @override
  MapDownloadState build() => const MapDownloadState();

  // ── PMTiles (HD base vector map) ────────────────────────────────────────────

  /// Download the HD PMTiles file (zoom 0-15) using iOS URLSession background.
  /// The download continues even if the user locks the screen or switches apps.
  Future<void> downloadBaseMap() async {
    if (state.isActive) return;

    state = state._withPmtiles(
      status: DownloadStatus.downloading,
      activeType: DownloadType.hdPmtiles,
    );

    try {
      await PmTilesManager.downloadHd(
        onProgress: (p) {
          if (state.status != DownloadStatus.downloading) return;
          state = state.copyWith(overallProgress: p);
        },
        onDone: () {
          ref.invalidate(pmtilesAvailableProvider);
          ref.invalidate(pmtilesFileSizeProvider);
          ref.invalidate(pmtilesVectorTileProvider);
          ref.read(mapTileModeProvider.notifier).state = MapTileMode.vector;
          state = state._withPmtiles(
            status: DownloadStatus.completed,
            overallProgress: 1,
          );
        },
        onError: (message) {
          AppLogger.error('HD PMTiles download failed: $message');
          state = state._withPmtiles(
            status: DownloadStatus.error,
            errorMessage: message,
          );
        },
      );
    } catch (e) {
      AppLogger.error('HD PMTiles download exception', e);
      state = state._withPmtiles(
        status: DownloadStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> pause() async {
    if (!state.isActive) return;
    await PmTilesManager.pauseDownload();
    state = state.copyWith(status: DownloadStatus.paused);
  }

  Future<void> resume() async {
    if (!state.isPaused) return;
    state = state.copyWith(status: DownloadStatus.downloading);
    await PmTilesManager.resumeDownload(
      onProgress: (p) => state = state.copyWith(overallProgress: p),
      onDone: () {
        ref.invalidate(pmtilesAvailableProvider);
        ref.invalidate(pmtilesFileSizeProvider);
        ref.invalidate(pmtilesVectorTileProvider);
        ref.read(mapTileModeProvider.notifier).state = MapTileMode.vector;
        state = state._withPmtiles(
          status: DownloadStatus.completed,
          overallProgress: 1,
        );
      },
      onError: (msg) => state = state._withPmtiles(
        status: DownloadStatus.error,
        errorMessage: msg,
      ),
    );
  }

  Future<void> cancel() async {
    await PmTilesManager.cancelDownload();
    state = state._withPmtiles(status: DownloadStatus.cancelled);
  }

  // ── Satellite tile bulk download ────────────────────────────────────────────

  /// Bulk-download ESRI satellite tiles for the entire Galápagos archipelago
  /// (zoom 5–13) into the FMTC 'satelliteCache' store.
  ///
  /// Sea tiles are skipped (not stored) and existing tiles are not re-fetched,
  /// so re-running only downloads genuinely missing tiles.
  Future<void> downloadSatelliteTiles() async {
    if (state.isSatelliteActive) return;

    // Reset satellite state (null errorMessage via direct constructor)
    state = MapDownloadState(
      status: state.status,
      activeType: state.activeType,
      overallProgress: state.overallProgress,
      errorMessage: state.errorMessage,
      satelliteStatus: DownloadStatus.downloading,
    );

    try {
      final region = RectangleRegion(
        LatLngBounds(
          LatLng(_galapagosSouth, _galapagosWest),
          LatLng(_galapagosNorth, _galapagosEast),
        ),
      ).toDownloadable(
        minZoom: 5,
        maxZoom: 13,
        options: TileLayer(
          urlTemplate: SatelliteMapConstants.esriSatelliteUrl,
          userAgentPackageName: 'com.galapagos.galapagos_wildlife',
        ),
      );

      final streams = FMTCStore('satelliteCache').download.startForeground(
        region: region,
        parallelThreads: 3,
        maxBufferLength: 100,
        skipExistingTiles: true,
        skipSeaTiles: true,
        rateLimit: 10, // max 10 tiles/sec – be respectful to ESRI's free API
        instanceId: _satelliteInstanceId,
      );

      await _satelliteSubscription?.cancel();
      _satelliteSubscription = streams.downloadProgress.listen(
        (progress) {
          if (!state.isSatelliteActive && !state.isSatellitePaused) return;
          state = state.copyWith(
            satelliteProgress: progress.percentageProgress / 100,
            satelliteTilesAttempted: progress.attemptedTilesCount,
            satelliteMaxTiles: progress.maxTilesCount,
          );
        },
        onDone: () {
          _satelliteSubscription = null;
          // Guard: cancelSatellite() sets status to cancelled before calling
          // FMTC cancel, so when onDone fires we won't overwrite it.
          if (state.satelliteStatus != DownloadStatus.cancelled) {
            state = state.copyWith(
              satelliteStatus: DownloadStatus.completed,
              satelliteProgress: 1.0,
            );
          }
        },
        onError: (Object error) {
          AppLogger.error('Satellite tile download error', error);
          state = state.copyWith(
            satelliteStatus: DownloadStatus.error,
            satelliteErrorMessage: error.toString(),
          );
        },
        cancelOnError: true,
      );
    } catch (e) {
      AppLogger.error('Satellite tile download exception', e);
      state = state.copyWith(
        satelliteStatus: DownloadStatus.error,
        satelliteErrorMessage: e.toString(),
      );
    }
  }

  Future<void> pauseSatellite() async {
    if (!state.isSatelliteActive) return;
    await FMTCStore('satelliteCache')
        .download
        .pause(instanceId: _satelliteInstanceId);
    state = state.copyWith(satelliteStatus: DownloadStatus.paused);
  }

  void resumeSatellite() {
    if (!state.isSatellitePaused) return;
    FMTCStore('satelliteCache')
        .download
        .resume(instanceId: _satelliteInstanceId);
    state = state.copyWith(satelliteStatus: DownloadStatus.downloading);
  }

  Future<void> cancelSatellite() async {
    // Set status first so onDone doesn't overwrite with 'completed'
    state = state.copyWith(satelliteStatus: DownloadStatus.cancelled);
    await FMTCStore('satelliteCache')
        .download
        .cancel(instanceId: _satelliteInstanceId);
    await _satelliteSubscription?.cancel();
    _satelliteSubscription = null;
  }

  /// Clear all cached satellite tiles from the FMTC store.
  Future<void> deleteSatelliteTiles() async {
    try {
      await FMTCStore('satelliteCache').manage.reset();
      state = state._withSatelliteReset();
    } catch (e) {
      AppLogger.error('Failed to delete satellite tiles', e);
    }
  }

  // ---- Legacy stubs (kept so existing call sites compile) ------------------

  /// @deprecated Use [downloadBaseMap] instead.
  Future<void> downloadIslands(List<dynamic> islands,
      {required int minZoom, required int maxZoom}) async {
    await downloadBaseMap();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final mapDownloadProvider =
    NotifierProvider<MapDownloadNotifier, MapDownloadState>(
  MapDownloadNotifier.new,
);
