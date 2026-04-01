import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import 'package:galapagos_wildlife/models/trail.model.dart';
import 'package:galapagos_wildlife/models/visit_site.model.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sightings_provider.dart';
import '../../providers/map_download_provider.dart';
import '../../providers/map_filters_provider.dart';
import '../../providers/map_provider.dart';
import '../../providers/pmtiles_provider.dart';
import '../../providers/trail_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../providers/field_edit_provider.dart';
import '../../providers/gps_tracking_provider.dart';
import '../../services/field_edit_service.dart';
import '../../themes/protomaps_theme.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import '../../utils/route_utils.dart';
import '../../utils/viewport_helpers.dart';
import '../widgets/map_layer_builders.dart';
import '../widgets/map_mode_selector.dart';
import '../widgets/field_edit_toolbar.dart';
import '../widgets/trail_recording_panel.dart';
import '../widgets/site_info_sheet.dart';
// Extracted modules
import '../../controls/zoom_controls.dart';
import '../../controls/off_route_banner.dart';
import '../../controls/map_fabs.dart';
import '../../layers/tile_layers.dart';
import '../../layers/site_markers_layer.dart';
import '../../layers/field_editing_layer.dart';
import '../../sheets/trail_info_sheet.dart';
import '../../sheets/sighting_info_sheet.dart';
import '../../sheets/island_info_sheet.dart';
import '../../shell/map_phone_layout.dart';
import '../../shell/map_tablet_layout.dart';
import '../../tracking/tracking_controller.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  bool _movedToUser = false;
  late final TrackingController _trackingCtrl;

  // Cached vector tile themes (created once)
  vtr.Theme? _lightTheme;
  vtr.Theme? _darkTheme;

  // Site position overrides for drag editing
  final Map<int, LatLng> _sitePositionOverrides = {};

  // Field editing layer builder (holds drag state)
  final FieldEditingLayerBuilder _fieldEditBuilder = FieldEditingLayerBuilder();

  vtr.Theme get _cachedLightTheme =>
      _lightTheme ??= protomapsLightTheme();
  vtr.Theme get _cachedDarkTheme =>
      _darkTheme ??= protomapsDarkTheme();

  @override
  void initState() {
    super.initState();
    _trackingCtrl = TrackingController(ref: ref, mapController: _mapController);
  }

  @override
  Widget build(BuildContext context) {
    final islandsAsync = ref.watch(islandsProvider);
    final sitesAsync = ref.watch(visitSitesProvider);
    final locationAsync = ref.watch(userLocationProvider);
    final sightingsAsync = ref.watch(sightingsProvider);
    final speciesLookupAsync = ref.watch(speciesLookupProvider);
    final trailsAsync = ref.watch(trailsProvider);
    final isTracking = ref.watch(isTrackingProvider);
    final trackPoints = ref.watch(trackPointsProvider);
    final isOffRoute = ref.watch(offRouteProvider);
    final distFromTrail = ref.watch(distanceFromTrailProvider);
    final tileMode = ref.watch(mapTileModeProvider);
    final pmtilesAsync = ref.watch(pmtilesVectorTileProvider);
    final downloadState = ref.watch(mapDownloadProvider);
    final editState = ref.watch(fieldEditProvider);
    // Keep GPS tracking alive independently of widget lifecycle
    ref.watch(gpsTrackingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = AdaptiveLayout.isTablet(context);
    final isEs = LocaleSettings.currentLocale == AppLocale.es;

    // Show snackbar on download complete / cancel
    ref.listen(mapDownloadProvider, (prev, next) {
      if (prev?.status == DownloadStatus.downloading) {
        if (next.status == DownloadStatus.completed) {
          final msg = prev?.activeType == DownloadType.hdPmtiles
              ? context.t.map.baseMapReady
              : context.t.map.downloadComplete;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        } else if (next.status == DownloadStatus.cancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.t.map.downloadCancelled)),
          );
        }
      }
    });

    // Clear overrides when leaving edit mode
    ref.listen(fieldEditProvider.select((s) => s.mode), (prev, next) {
      if (next == FieldEditMode.none) {
        if (_sitePositionOverrides.isNotEmpty || _fieldEditBuilder.rotateHandlePos != null) {
          setState(() {
            _sitePositionOverrides.clear();
            _fieldEditBuilder.rotateHandlePos = null;
          });
        }
      }
    });

    // Move to user location once when data arrives
    locationAsync.whenData((pos) {
      if (pos != null && !_movedToUser && isInGalapagos(pos)) {
        _movedToUser = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(LatLng(pos.latitude, pos.longitude), 12);
        });
      }
    });

    final mapWidget = _buildMap(
      isDark, isEs, islandsAsync, sitesAsync, locationAsync,
      sightingsAsync, speciesLookupAsync, trailsAsync,
      isTracking, trackPoints, editState, tileMode, pmtilesAsync,
    );

    final mapWithOverlays = _buildMapWithOverlays(
      mapWidget, isTracking, isOffRoute, distFromTrail,
    );

    final fabs = MapFabs(
      locationAsync: locationAsync,
      isTracking: isTracking,
      trackPoints: trackPoints,
      downloadState: downloadState,
      mapController: _mapController,
      onStopTracking: () => _trackingCtrl.stopTracking(context),
    );

    if (isTablet) {
      return MapTabletLayout(
        isDark: isDark,
        isEs: isEs,
        islandsAsync: islandsAsync,
        sitesAsync: sitesAsync,
        trailsAsync: trailsAsync,
        mapWidget: mapWithOverlays,
        fabs: fabs,
        mapController: _mapController,
        onBuildTileModeToggle: _buildTileModeToggle,
        onZoomToTrailExtent: _trackingCtrl.zoomToTrailExtent,
      );
    }
    return MapPhoneLayout(
      isDark: isDark,
      mapWidget: mapWithOverlays,
      fabs: fabs,
      sitesAsync: sitesAsync,
      islandsAsync: islandsAsync,
      mapController: _mapController,
      onBuildTileModeToggle: _buildTileModeToggle,
    );
  }

  // ---------------------------------------------------------------------------
  // Off-route warning overlay
  // ---------------------------------------------------------------------------

  Widget _buildMapWithOverlays(
    Widget mapWidget,
    bool isTracking,
    bool isOffRoute,
    double distFromTrail,
  ) {
    return Stack(
      children: [
        mapWidget,
        Positioned(
          top: 0, left: 0, right: 0,
          child: OffRouteBanner(
            isTracking: isTracking,
            isOffRoute: isOffRoute,
            distFromTrail: distFromTrail,
          ),
        ),
        const FieldEditToolbar(),
        TrailRecordingPanel(islandId: ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId))),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tile mode toggle
  // ---------------------------------------------------------------------------

  Widget _buildTileModeToggle(BuildContext context) {
    final tileMode = ref.watch(mapTileModeProvider);
    IconData icon;
    switch (tileMode) {
      case MapTileMode.vector:   icon = Icons.layers; break;
      case MapTileMode.satellite: icon = Icons.satellite_alt; break;
      case MapTileMode.hybrid:   icon = Icons.map; break;
      case MapTileMode.street:   icon = Icons.map_outlined;
    }
    return IconButton(
      icon: Icon(icon),
      tooltip: context.t.map.switchMapMode,
      onPressed: () => showModalBottomSheet(
        context: context,
        builder: (context) => const MapModeSelector(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Map builder
  // ---------------------------------------------------------------------------

  Widget _buildMap(
    bool isDark,
    bool isEs,
    AsyncValue<dynamic> islandsAsync,
    AsyncValue<dynamic> sitesAsync,
    AsyncValue<dynamic> locationAsync,
    AsyncValue<dynamic> sightingsAsync,
    AsyncValue<dynamic> speciesLookupAsync,
    AsyncValue<List<Trail>> trailsAsync,
    bool isTracking,
    List<({LatLng point, DateTime time})> trackPoints,
    FieldEditState editState,
    MapTileMode tileMode,
    AsyncValue<PmTilesVectorProvider?> pmtilesAsync,
  ) {
    final tileModeStr = tileMode.name; // 'vector'|'satellite'|'hybrid'|'street'

    bool viewportCheck(double? lat, double? lng) =>
        isWithinViewport(_mapController, lat, lng);

    final flutterMap = FlutterMap(
      mapController: _mapController,
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
            setState(() {});
          }
        },
        onTap: (tapPosition, point) => _handleMapTap(point),
      ),
      children: [
        // Tile base layers
        ...buildTileLayers(
          tileMode: tileModeStr,
          isDark: isDark,
          lightTheme: _cachedLightTheme,
          darkTheme: _cachedDarkTheme,
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
        _buildIslandMarkers(islandsAsync, isEs, isDark),
        // Visit site markers
        if (ref.watch(mapFiltersProvider.select((f) => f.showSites)))
          buildSiteMarkersLayer(
            sitesAsync: sitesAsync,
            isEs: isEs,
            editState: editState,
            ref: ref,
            context: context,
            isWithinViewport: viewportCheck,
            onShowSiteInfo: (site) => _showSiteInfo(context, site),
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
          _buildTrailMarkers(trailsAsync, isEs),
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
        _fieldEditBuilder.build(ref),
        // Trail markers in selectTrailForEdit mode (rendered last for tap priority)
        if (ref.watch(mapFiltersProvider.select((f) => f.showTrails)) && editState.mode == FieldEditMode.selectTrailForEdit)
          _buildTrailMarkers(trailsAsync, isEs),
        // Site DragMarkers rendered LAST in moveSitesDrag mode
        if (ref.watch(mapFiltersProvider.select((f) => f.showSites)) && editState.mode == FieldEditMode.moveSitesDrag)
          buildSiteDragMarkersLayer(
            sitesAsync: sitesAsync,
            isEs: isEs,
            ref: ref,
            context: context,
            sitePositionOverrides: _sitePositionOverrides,
            onSiteDragged: (siteId, newPos) {
              setState(() => _sitePositionOverrides[siteId] = newPos);
            },
          ),
      ],
    );

    // Wrap FlutterMap with UI controls in a Stack
    final zoom = safeGetZoom(_mapController);
    final rotation = safeGetRotation(_mapController);

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
                    final z = safeGetZoom(_mapController);
                    _mapController.move(_mapController.camera.center, (z + 1).clamp(6, 19));
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
                    final z = safeGetZoom(_mapController);
                    _mapController.move(_mapController.camera.center, (z - 1).clamp(6, 19));
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
                try { _mapController.rotate(0); } catch (e) { /* not ready */ }
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

  // ---------------------------------------------------------------------------
  // Island markers layer
  // ---------------------------------------------------------------------------

  Widget _buildIslandMarkers(AsyncValue<dynamic> islandsAsync, bool isEs, bool isDark) {
    return islandsAsync.when(
      data: (islands) => MarkerLayer(
        markers: islands
            .where((island) => island.latitude != null && island.longitude != null)
            .where((island) => isWithinViewport(_mapController, island.latitude, island.longitude))
            .map((island) {
              final islandName = isEs ? (island.nameEs ?? island.nameEn) : island.nameEn;
              return Marker(
                point: LatLng(island.latitude!, island.longitude!),
                width: 120, height: 40,
                child: Semantics(
                  button: true,
                  label: context.t.map.islandLabel(name: islandName),
                  child: GestureDetector(
                    onTap: () => showIslandInfoSheet(context: context, island: island),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface.withValues(alpha: 0.9)
                            : AppColors.primaryDark.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                        border: isDark
                            ? Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3))
                            : null,
                      ),
                      child: Text(
                        islandName,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList().cast<Marker>(),
      ),
      loading: () => const MarkerLayer(markers: []),
      error: (_, _) => const MarkerLayer(markers: []),
    );
  }

  // ---------------------------------------------------------------------------
  // Trail markers
  // ---------------------------------------------------------------------------

  Widget _buildTrailMarkers(AsyncValue<List<Trail>> trailsAsync, bool isEs) {
    final isSelectingForEdit = ref.watch(
        fieldEditProvider.select((s) => s.mode == FieldEditMode.selectTrailForEdit));
    return MapLayerBuilders.buildTrailMarkers(
      context: context,
      trailsAsync: trailsAsync,
      isEs: isEs,
      isSelectingForEdit: isSelectingForEdit,
      onShowTrailInfo: (trail) => showTrailInfoSheet(
        context: context,
        trail: trail,
        onStartTracking: () => _trackingCtrl.startTrackingTrail(trail.coordinates),
        onEditTrail: () => _loadTrailForEditing(trail.id),
      ),
      onSelectTrailForEdit: (id) => _loadTrailForEditing(id),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom sheet helpers
  // ---------------------------------------------------------------------------

  void _showSiteInfo(BuildContext context, VisitSite site) {
    final islands = ref.read(islandsProvider).asData?.value ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SiteInfoSheet(site: site, islands: islands),
    );
  }

  // ---------------------------------------------------------------------------
  // Field editing
  // ---------------------------------------------------------------------------

  void _handleMapTap(LatLng point) {
    final editState = ref.read(fieldEditProvider);
    if ((editState.mode == FieldEditMode.createTrailManual ||
            editState.mode == FieldEditMode.editTrailManual) &&
        editState.trailEditSubMode == TrailEditSubMode.points) {
      final notifier = ref.read(fieldEditProvider.notifier);
      notifier.clearSelection();
      notifier.pushUndoState();
      final pts = editState.recordingPoints;

      if (pts.length < 2) {
        notifier.addRecordingPoint(point);
      } else {
        final result = distanceToPolyline(point, pts);
        final atStart = haversineDistance(result.nearest, pts.first) < 1.0;
        final atEnd   = haversineDistance(result.nearest, pts.last)  < 1.0;

        final int insertIdx;
        if (atEnd) {
          insertIdx = pts.length;
        } else if (atStart) {
          insertIdx = 0;
        } else {
          insertIdx = result.segmentIndex + 1;
        }

        final newPts = List<LatLng>.from(pts)..insert(insertIdx, point);
        notifier.setRecordingPoints(newPts);
      }
      notifier.markUnsaved();
    }
  }

  Future<void> _loadTrailForEditing(int trailId) async {
    _showSnackBar('Loading trail...');
    setState(() => _fieldEditBuilder.rotateHandlePos = null);
    try {
      final service = FieldEditService(ref: ref);
      final trail = await service.getTrail(trailId);
      if (!mounted) return;
      if (trail == null) { _showSnackBar('Trail not found (id $trailId)'); return; }
      final coords = parseTrailCoordinates(trail.coordinates);
      if (coords.isEmpty) { _showSnackBar('Trail has no coordinates'); return; }
      final editNotifier = ref.read(fieldEditProvider.notifier);
      editNotifier.startEditingTrailManual(trailId);
      editNotifier.loadPoints(coords);
      _showSnackBar('Trail loaded -- use Points / Move / Rotate to edit');
    } catch (e) {
      if (mounted) _showSnackBar('Error loading trail: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
