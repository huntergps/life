import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: implementation_imports
import 'package:flutter_riverpod/legacy.dart';
import 'package:pmtiles/pmtiles.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../services/pmtiles_manager.dart';

// ---------------------------------------------------------------------------
// State: whether the PMTiles base map is available locally
// ---------------------------------------------------------------------------

/// Checks if the PMTiles file exists on disk.
/// Invalidated by MapDownloadNotifier after PMTiles download completes.
final pmtilesAvailableProvider = FutureProvider<bool>((ref) async {
  if (kIsWeb) return false;
  return PmTilesManager.isDownloaded;
});

/// Local file size in bytes (0 if not present).
/// Invalidated by MapDownloadNotifier after PMTiles download completes.
final pmtilesFileSizeProvider = FutureProvider<int>((ref) async {
  if (kIsWeb) return 0;
  return PmTilesManager.localFileSize;
});

// ---------------------------------------------------------------------------
// Map tile mode
// ---------------------------------------------------------------------------

/// Which tile layer to show.
/// - street: OpenStreetMap raster tiles (FMTC cached)
/// - vector: PMTiles vector tiles (offline)
/// - satellite: Mapbox Satellite (requires login)
/// - hybrid: Mapbox Satellite + labels (requires login)
enum MapTileMode { street, vector, satellite, hybrid }

/// Current tile mode — defaults to street (OSM/FMTC).
final mapTileModeProvider = StateProvider<MapTileMode>((ref) => MapTileMode.street);

// ---------------------------------------------------------------------------
// PmTiles vector tile provider for vector_map_tiles
// ---------------------------------------------------------------------------

/// Opens the local PMTiles archive and exposes a [VectorTileProvider].
final pmtilesVectorTileProvider =
    FutureProvider<PmTilesVectorProvider?>((ref) async {
  if (kIsWeb) return null;
  final available = await ref.watch(pmtilesAvailableProvider.future);
  if (!available) return null;

  final path = await PmTilesManager.localPath;
  final archive = await PmTilesArchive.from(path);
  final header = archive.header;

  ref.onDispose(() => archive.close());

  return PmTilesVectorProvider(
    archive: archive,
    minimumZoom: header.minZoom,
    maximumZoom: header.maxZoom,
  );
});

// ---------------------------------------------------------------------------
// Custom VectorTileProvider backed by a local PMTiles archive
// ---------------------------------------------------------------------------

class PmTilesVectorProvider extends VectorTileProvider {
  final PmTilesArchive archive;

  @override
  final int maximumZoom;

  @override
  final int minimumZoom;

  @override
  TileProviderType get type => TileProviderType.vector;

  @override
  TileOffset get tileOffset => TileOffset.DEFAULT;

  PmTilesVectorProvider({
    required this.archive,
    required this.maximumZoom,
    required this.minimumZoom,
  });

  @override
  Future<Uint8List> provide(TileIdentity tile) async {
    final zxy = ZXY(tile.z, tile.x, tile.y);
    final tileId = zxy.toTileId();
    final pmTile = await archive.tile(tileId);
    final bytes = pmTile.bytes();
    if (bytes.isEmpty) {
      throw ProviderException(
        message: 'Tile not found',
        retryable: Retryable.none,
        statusCode: 404,
      );
    }
    return Uint8List.fromList(bytes);
  }
}
