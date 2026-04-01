import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/models/trail.model.dart';
import 'package:galapagos_wildlife/models/visit_site.model.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import '../providers/map_filters_provider.dart';
import '../providers/pmtiles_provider.dart';
import '../providers/field_edit_provider.dart';
import '../layers/tile_layers.dart';
import '../layers/site_markers_layer.dart';
import '../layers/field_editing_layer.dart';
import '../layers/island_markers_layer.dart';
import '../controls/zoom_controls.dart';
import '../utils/viewport_helpers.dart';
import '../presentation/widgets/map_layer_builders.dart';
import '../sheets/sighting_info_sheet.dart';

/// Builds the main [FlutterMap] widget with all layers, zoom controls, and
/// compass indicator.
///
/// This was extracted from [_MapScreenState._buildMap] to reduce the size of
/// the map screen file.
class MapBuilder extends StatelessWidget {
  const MapBuilder({
    super.key,
    required this.mapController,
    required this.isDark,
    required this.isEs,
    required this.islandsAsync,
    required this.sitesAsync,
    required this.locationAsync,
    required this.sightingsAsync,
    required this.speciesLookupAsync,
    required this.trailsAsync,
    required this.isTracking,
    required this.trackPoints,
    required this.editState,
    required this.tileMode,
    required this.pmtilesAsync,
    required this.fieldEditBuilder,
    required this.ref,
    required this.onMapTap,
    required this.onShowSiteInfo,
    required this.onShowTrailInfo,
    required this.onLoadTrailForEditing,
    required this.onViewportChanged,
    required this.lightTheme,
    required this.darkTheme,
    required this.sitePositionOverrides,
    required this.onSiteDragged,
  });

  final MapController mapController;
  final bool isDark;
  final bool isEs;
  final AsyncValue<dynamic> islandsAsync;
  final AsyncValue<dynamic> sitesAsync;
  final AsyncValue<dynamic> locationAsync;
  final AsyncValue<dynamic> sightingsAsync;
  final AsyncValue<dynamic> speciesLookupAsync;
  final AsyncValue<List<Trail>> trailsAsync;
  final bool isTracking;
  final List<({LatLng point, DateTime time})> trackPoints;
  final FieldEditState editState;
  final MapTileMode tileMode;
  final AsyncValue<PmTilesVectorProvider?> pmtilesAsync;
  final FieldEditingLayerBuilder fieldEditBuilder;
  final WidgetRef ref;
  final void Function(LatLng) onMapTap;
  final void Function(VisitSite) onShowSiteInfo;
  final void Function(Trail trail) onShowTrailInfo;
  final void Function(int) onLoadTrailForEditing;
  final VoidCallback onViewportChanged;
  final vtr.Theme lightTheme;
  final vtr.Theme darkTheme;
  final Map<int, LatLng> sitePositionOverrides;
  final void Function(int siteId, LatLng newPos) onSiteDragged;

  @override
  Widget build(BuildContext context) {
    final tileModeStr = tileMode.name;

    bool viewportCheck(double? lat, double? lng) =>
        isWithinViewport(mapController, lat, lng);

    final flutterMap = FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: const LatLng(
          AppConstants.galapagosDefaultLat,
          AppConstants.galapagosDefaultLng,
        ),
        initialZoom: AppConstants.galapagosDefaultZoom,
        minZoom: 6,
        maxZoom: 19,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
          enableMultiFingerGestureRace: true,
        ),
        onMapEvent: (event) {
          if (event is MapEventMove || event is MapEventRotate) {
            onViewportChanged();
          }
        },
        onTap: (tapPosition, point) => onMapTap(point),
      ),
      children: [
        // Tile base layers
        ...buildTileLayers(
          tileMode: tileModeStr,
          isDark: isDark,
          lightTheme: lightTheme,
          darkTheme: darkTheme,
          pmtilesProvider: pmtilesAsync.asData?.value,
        ),
        // User location marker
        if (locationAsync.asData?.value case final userPos?)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(userPos.latitude, userPos.longitude),
                width: 24, height: 24,
                child: Semantics(
                  label: context.t.map.yourLocation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        // Island markers
        buildIslandMarkersLayer(
          islandsAsync: islandsAsync,
          isEs: isEs,
          isDark: isDark,
          context: context,
          mapController: mapController,
        ),
        // Visit site markers
        if (ref.watch(mapFiltersProvider.select((f) => f.showSites)))
          buildSiteMarkersLayer(
            sitesAsync: sitesAsync,
            isEs: isEs,
            editState: editState,
            ref: ref,
            context: context,
            isWithinViewport: viewportCheck,
            onShowSiteInfo: onShowSiteInfo,
          ),
        // Trail polylines
        if (ref.watch(mapFiltersProvider.select((f) => f.showTrails)))
          MapLayerBuilders.buildTrailPolylinesLayer(
            trailsAsync: trailsAsync,
            editingTrailId: ref.watch(fieldEditProvider.select((s) => s.selectedTrailId)),
            isEditing: ref.watch(fieldEditProvider.select((s) => s.mode == FieldEditMode.editTrailManual)),
          ),
        // Trail midpoint markers (normal mode)
        if (ref.watch(mapFiltersProvider.select((f) => f.showTrails)) &&
            editState.mode != FieldEditMode.selectTrailForEdit &&
            editState.mode != FieldEditMode.editTrailManual)
          _buildTrailMarkers(context, trailsAsync, isEs),
        // User tracking polyline
        if (isTracking && trackPoints.isNotEmpty)
          PolylineLayer(polylines: [
            Polyline(
              points: trackPoints.map((tp) => tp.point).toList(),
              color: Colors.blue,
              strokeWidth: 4,
              borderColor: Colors.white,
              borderStrokeWidth: 1,
            ),
          ]),
        // Sighting markers
        if (ref.watch(mapFiltersProvider.select((f) => f.showSightings)))
          MapLayerBuilders.buildSightingsLayer(
            context: context,
            isEs: isEs,
            sightingsAsync: sightingsAsync,
            speciesLookupAsync: speciesLookupAsync,
            isWithinViewport: viewportCheck,
            onSightingTap: (sighting, species) => showSightingInfoSheet(
              context: context,
              sighting: sighting,
              species: species,
            ),
          ),
        // Field editing layer
        fieldEditBuilder.build(ref),
        // Trail markers in selectTrailForEdit mode (rendered last for tap priority)
        if (ref.watch(mapFiltersProvider.select((f) => f.showTrails)) && editState.mode == FieldEditMode.selectTrailForEdit)
          _buildTrailMarkers(context, trailsAsync, isEs),
        // Site DragMarkers rendered LAST in moveSitesDrag mode
        if (ref.watch(mapFiltersProvider.select((f) => f.showSites)) && editState.mode == FieldEditMode.moveSitesDrag)
          buildSiteDragMarkersLayer(
            sitesAsync: sitesAsync,
            isEs: isEs,
            ref: ref,
            context: context,
            sitePositionOverrides: sitePositionOverrides,
            onSiteDragged: onSiteDragged,
          ),
      ],
    );

    // Wrap FlutterMap with UI controls in a Stack
    final zoom = safeGetZoom(mapController);
    final rotation = safeGetRotation(mapController);

    return Stack(
      children: [
        flutterMap,
        // Zoom controls
        Positioned(
          bottom: MediaQuery.viewPaddingOf(context).bottom + 130,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ZoomButton(
                icon: Icons.add,
                onPressed: zoom >= 19 ? null : () {
                  try {
                    final z = safeGetZoom(mapController);
                    mapController.move(mapController.camera.center, (z + 1).clamp(6, 19));
                  } catch (e) {
                    AppLogger.warning('Zoom in failed: map controller not ready', e);
                  }
                },
              ),
              const SizedBox(height: 8),
              ZoomButton(
                icon: Icons.remove,
                onPressed: zoom <= 6 ? null : () {
                  try {
                    final z = safeGetZoom(mapController);
                    mapController.move(mapController.camera.center, (z - 1).clamp(6, 19));
                  } catch (e) {
                    AppLogger.warning('Zoom out failed: map controller not ready', e);
                  }
                },
              ),
            ],
          ),
        ),
        // Compass indicator
        if (rotation != 0)
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                try { mapController.rotate(0); } catch (e) { /* not ready */ }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
                ),
                child: Transform.rotate(
                  angle: rotation * (3.14159 / 180),
                  child: Icon(Icons.navigation, color: AppColors.primary, size: 24),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTrailMarkers(BuildContext context, AsyncValue<List<Trail>> trailsAsync, bool isEs) {
    final isSelectingForEdit = ref.watch(
        fieldEditProvider.select((s) => s.mode == FieldEditMode.selectTrailForEdit));
    return MapLayerBuilders.buildTrailMarkers(
      context: context,
      trailsAsync: trailsAsync,
      isEs: isEs,
      isSelectingForEdit: isSelectingForEdit,
      onShowTrailInfo: onShowTrailInfo,
      onSelectTrailForEdit: onLoadTrailForEditing,
    );
  }
}
