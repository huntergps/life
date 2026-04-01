import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
import 'package:galapagos_wildlife/core/constants/mapbox_constants.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import '../providers/pmtiles_provider.dart';

/// Returns FMTC tile provider on native, plain NetworkTileProvider on web.
TileProvider tileProvider(String storeName) {
  if (kIsWeb) return NetworkTileProvider();
  return FMTCTileProvider(
    stores: {storeName: BrowseStoreStrategy.readUpdateCreate},
  );
}

/// Builds the list of tile layer children for FlutterMap based on the current
/// [tileMode].
///
/// Returns a list of widgets that should be inserted at the beginning of the
/// FlutterMap children list.
List<Widget> buildTileLayers({
  required String tileMode, // 'vector' | 'satellite' | 'hybrid' | 'street'
  required bool isDark,
  required vtr.Theme lightTheme,
  required vtr.Theme darkTheme,
  required PmTilesVectorProvider? pmtilesProvider,
}) {
  final layers = <Widget>[];

  if (tileMode == 'vector' && pmtilesProvider != null) {
    layers.add(
      VectorTileLayer(
        tileProviders: TileProviders({
          'protomaps': pmtilesProvider,
        }),
        theme: isDark ? darkTheme : lightTheme,
        tileOffset: TileOffset.DEFAULT,
        concurrency: 4,
      ),
    );
  } else if (tileMode == 'satellite') {
    layers.add(
      TileLayer(
        urlTemplate: SatelliteMapConstants.esriSatelliteUrl,
        userAgentPackageName: 'com.galapagos.galapagos_wildlife',
        maxNativeZoom: 19,
        maxZoom: 19,
        subdomains: const [],
        retinaMode: false,
        tileProvider: tileProvider('satelliteCache'),
        tileBuilder: (context, tileWidget, tile) => tileWidget,
        errorTileCallback: (tile, error, stackTrace) {
          AppLogger.warning('Tile error at ${tile.coordinates}: $error');
        },
      ),
    );
  } else if (tileMode == 'hybrid') {
    layers.add(
      TileLayer(
        urlTemplate: SatelliteMapConstants.esriSatelliteUrl,
        userAgentPackageName: 'com.galapagos.galapagos_wildlife',
        maxNativeZoom: 19,
        maxZoom: 19,
        subdomains: const [],
        retinaMode: false,
        tileProvider: tileProvider('satelliteCache'),
        errorTileCallback: (tile, error, stackTrace) {
          AppLogger.warning('ESRI tile error at ${tile.coordinates}: $error');
        },
      ),
    );
    layers.add(
      TileLayer(
        urlTemplate: SatelliteMapConstants.cartoLabelsUrl,
        userAgentPackageName: 'com.galapagos.galapagos_wildlife',
        maxNativeZoom: 19,
        maxZoom: 19,
        subdomains: const ['a', 'b', 'c'],
        retinaMode: false,
        tileProvider: tileProvider('labelsCache'),
        errorTileCallback: (tile, error, stackTrace) {
          AppLogger.warning('CartoDB tile error at ${tile.coordinates}: $error');
        },
      ),
    );
  } else {
    // Default: OpenStreetMap street tiles
    layers.add(
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.galapagos.galapagos_wildlife',
        maxNativeZoom: 19,
        tileProvider: tileProvider('galapagosMap'),
      ),
    );
    if (isDark) {
      layers.add(
        ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            -1, 0, 0, 0, 255,
            0, -1, 0, 0, 255,
            0, 0, -1, 0, 255,
            0, 0, 0, 0.7, 0,
          ]),
          child: TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.galapagos.galapagos_wildlife',
            maxNativeZoom: 19,
            tileProvider: tileProvider('galapagosMap'),
          ),
        ),
      );
    }
  }

  return layers;
}
