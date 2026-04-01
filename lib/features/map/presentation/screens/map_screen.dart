import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
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
import '../../themes/protomaps_theme.dart';
import '../widgets/map_mode_selector.dart';
import '../widgets/field_edit_toolbar.dart';
import '../widgets/trail_recording_panel.dart';
import '../widgets/site_info_sheet.dart';
// Extracted modules
import '../../controls/off_route_banner.dart';
import '../../controls/map_fabs.dart';
import '../../layers/field_editing_layer.dart';
import '../../sheets/trail_info_sheet.dart';
import '../../shell/map_phone_layout.dart';
import '../../shell/map_tablet_layout.dart';
import '../../shell/map_builder.dart';
import '../../editing/field_tap_handler.dart';
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
  late final FieldTapHandler _fieldTapHandler;

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
    _fieldTapHandler = FieldTapHandler(
      ref: ref,
      fieldEditBuilder: _fieldEditBuilder,
      showSnackBar: _showSnackBar,
      onResetRotateHandle: () =>
          setState(() => _fieldEditBuilder.rotateHandlePos = null),
    );
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

    final mapWidget = MapBuilder(
      mapController: _mapController,
      isDark: isDark,
      isEs: isEs,
      islandsAsync: islandsAsync,
      sitesAsync: sitesAsync,
      locationAsync: locationAsync,
      sightingsAsync: sightingsAsync,
      speciesLookupAsync: speciesLookupAsync,
      trailsAsync: trailsAsync,
      isTracking: isTracking,
      trackPoints: trackPoints,
      editState: editState,
      tileMode: tileMode,
      pmtilesAsync: pmtilesAsync,
      fieldEditBuilder: _fieldEditBuilder,
      ref: ref,
      onMapTap: _fieldTapHandler.handleMapTap,
      onShowSiteInfo: (site) => _showSiteInfo(context, site),
      onShowTrailInfo: (trail) => showTrailInfoSheet(
        context: context,
        trail: trail,
        onStartTracking: () => _trackingCtrl.startTrackingTrail(trail.coordinates),
        onEditTrail: () => _fieldTapHandler.loadTrailForEditing(trail.id),
      ),
      onLoadTrailForEditing: _fieldTapHandler.loadTrailForEditing,
      onViewportChanged: () => setState(() {}),
      lightTheme: _cachedLightTheme,
      darkTheme: _cachedDarkTheme,
      sitePositionOverrides: _sitePositionOverrides,
      onSiteDragged: (siteId, newPos) {
        setState(() => _sitePositionOverrides[siteId] = newPos);
      },
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

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
