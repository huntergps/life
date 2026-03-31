import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: implementation_imports
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' show ByteStream;
import 'package:pmtiles/pmtiles.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../services/pmtiles_manager.dart';

// ---------------------------------------------------------------------------
// State: whether the PMTiles base map is available locally
// ---------------------------------------------------------------------------

/// Checks if the PMTiles file exists on disk (native) or as a bundled asset (web).
/// Invalidated by MapDownloadNotifier after PMTiles download completes.
final pmtilesAvailableProvider = FutureProvider<bool>((ref) async {
  if (kIsWeb) return true; // always bundled in the Flutter web asset
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

/// Current tile mode — defaults to vector on web (offline-capable asset),
/// street (OSM/FMTC) on native.
final mapTileModeProvider = StateProvider<MapTileMode>(
  (ref) => kIsWeb ? MapTileMode.vector : MapTileMode.street,
);

// ---------------------------------------------------------------------------
// Web-only: ReadAt implementation backed by in-memory bytes from rootBundle
// ---------------------------------------------------------------------------

class _BytesReadAt implements ReadAt {
  final Uint8List _bytes;
  _BytesReadAt(this._bytes);

  @override
  Future<ByteStream> readAt(int offset, int length) async {
    final end = (offset + length).clamp(0, _bytes.length);
    return ByteStream.fromBytes(_bytes.sublist(offset, end));
  }

  @override
  Future<void> close() async {}
}

// ---------------------------------------------------------------------------
// PmTiles vector tile provider for vector_map_tiles
// ---------------------------------------------------------------------------

/// Opens the local PMTiles archive and exposes a [VectorTileProvider].
/// On web, loads the bundled asset into memory (2.9 MB).
/// On native, reads from the downloaded file on disk.
final pmtilesVectorTileProvider =
    FutureProvider<PmTilesVectorProvider?>((ref) async {
  final available = await ref.watch(pmtilesAvailableProvider.future);
  if (!available) return null;

  final PmTilesArchive archive;

  if (kIsWeb) {
    final byteData = await rootBundle.load('assets/maps/galapagos.pmtiles');
    final bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    // ignore: invalid_use_of_visible_for_testing_member
    archive = await PmTilesArchive.fromReadAt(_BytesReadAt(bytes));
  } else {
    final path = await PmTilesManager.localPath;
    archive = await PmTilesArchive.from(path);
  }

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
