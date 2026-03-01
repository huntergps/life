import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import 'package:galapagos_wildlife/core/constants/mapbox_constants.dart'; // Now SatelliteMapConstants
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import 'package:galapagos_wildlife/brick/models/island.model.dart';
import 'package:galapagos_wildlife/brick/models/trail.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
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
import '../widgets/map_download_sheet.dart';
import '../widgets/map_layer_builders.dart';
import '../widgets/map_mode_selector.dart';
import '../widgets/field_edit_toolbar.dart';
import '../widgets/trail_recording_panel.dart';
import '../widgets/site_info_sheet.dart';


/// Returns FMTC tile provider on native, plain NetworkTileProvider on web.
TileProvider _tileProvider(String storeName) {
  if (kIsWeb) return NetworkTileProvider();
  return FMTCTileProvider(
    stores: {storeName: BrowseStoreStrategy.readUpdateCreate},
  );
}

// Difficulty helpers are defined in map_layer_builders.dart and re-used here
// via top-level aliases to avoid breaking existing call sites.
Color _trailDifficultyColor(String? d) => trailDifficultyColor(d);
String _trailDifficultyLabel(BuildContext ctx, String? d) =>
    trailDifficultyLabel(ctx, d);

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  bool _movedToUser = false;
  TrackingService? _trackingService;

  // Cached vector tile themes (created once)
  vtr.Theme? _lightTheme;
  vtr.Theme? _darkTheme;

  // Trail move/rotate drag state (stored here to avoid provider overhead per frame)
  List<LatLng>? _preDragPoints;   // points snapshot taken at drag start
  LatLng? _dragOrigin;            // centroid (move) or handle initial pos (rotate)
  LatLng? _rotateCentroid;        // centroid used as rotation pivot

  // Site position overrides — updated immediately on drag-end to prevent
  // the marker snapping back to the stale provider position on rebuild.
  final Map<int, LatLng> _sitePositionOverrides = {};

  // Current position of the rotate handle — persisted across rebuilds so the
  // handle does not snap back to its computed initial position while dragging.
  LatLng? _rotateHandlePos;

  vtr.Theme get _cachedLightTheme =>
      _lightTheme ??= protomapsLightTheme();
  vtr.Theme get _cachedDarkTheme =>
      _darkTheme ??= protomapsDarkTheme();

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
    // Keep GPS tracking alive independently of widget lifecycle (background support)
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
        if (_sitePositionOverrides.isNotEmpty || _rotateHandlePos != null) {
          setState(() {
            _sitePositionOverrides.clear();
            _rotateHandlePos = null;
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
      isDark,
      isEs,
      islandsAsync,
      sitesAsync,
      locationAsync,
      sightingsAsync,
      speciesLookupAsync,
      trailsAsync,
      isTracking,
      trackPoints,
      editState,
      tileMode,
      pmtilesAsync,
    );

    final mapWithOverlays = _buildMapWithOverlays(
      mapWidget,
      isTracking,
      isOffRoute,
      distFromTrail,
    );

    final fabs = _buildFabs(locationAsync, isTracking, trackPoints, downloadState);

    if (isTablet) {
      return _buildTabletLayout(
        context,
        isDark,
        isEs,
        islandsAsync,
        sitesAsync,
        trailsAsync,
        mapWithOverlays,
        fabs,
      );
    }
    return _buildPhoneLayout(context, isDark, mapWithOverlays, fabs, sitesAsync, islandsAsync);
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
        // Off-route warning banner at top of map
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            child: isTracking && isOffRoute
                ? Container(
                    key: const ValueKey('offRoute'),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.t.map.offRoute,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  context.t.map.distanceFromTrail(
                                    meters: distFromTrail.toStringAsFixed(0),
                                  ),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('onRoute')),
          ),
        ),
        // Field editing toolbar (admin only)
        const FieldEditToolbar(),
        // Trail recording panel (GPS tracking)
        TrailRecordingPanel(islandId: ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId))),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Phone layout
  // ---------------------------------------------------------------------------

  Widget _buildPhoneLayout(
    BuildContext context,
    bool isDark,
    Widget mapWidget,
    Widget fabs,
    AsyncValue<List<VisitSite>> sitesAsync,
    AsyncValue<List<Island>> islandsAsync,
  ) {
    final selectedIslandId = ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId));
    final selectedMonitoringType = ref.watch(mapFiltersProvider.select((f) => f.selectedMonitoringType));
    final showTrails = ref.watch(mapFiltersProvider.select((f) => f.showTrails));
    final showSites = ref.watch(mapFiltersProvider.select((f) => f.showSites));
    final showSightings = ref.watch(mapFiltersProvider.select((f) => f.showSightings));
    final hasFilter = selectedIslandId != null || selectedMonitoringType != null;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child: Text(
                context.t.map.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Map action icons inline with title
            _buildTileModeToggle(context),
            IconButton(
              icon: Icon(showTrails ? Icons.route : Icons.route_outlined),
              onPressed: () => ref.read(mapFiltersProvider.notifier).toggleTrails(),
              tooltip: context.t.map.toggleTrails,
            ),
            IconButton(
              icon: Icon(showSites ? Icons.location_on : Icons.location_off),
              onPressed: () => ref.read(mapFiltersProvider.notifier).toggleSites(),
              tooltip: context.t.map.toggleSites,
            ),
            IconButton(
              icon: Icon(
                showSightings ? Icons.camera_alt : Icons.camera_alt_outlined,
                color: showSightings ? Colors.teal : null,
              ),
              onPressed: () => ref.read(mapFiltersProvider.notifier).toggleSightings(),
              tooltip: context.t.map.toggleSightings,
            ),
            // Filter button — orange when filters are active
            IconButton(
              icon: Icon(
                Icons.tune,
                color: hasFilter ? AppColors.accentOrange : null,
              ),
              tooltip: context.t.map.filterSites,
              onPressed: () => _showSiteFilterSheet(context, sitesAsync, islandsAsync),
            ),
          ],
        ),
        backgroundColor: isDark ? AppColors.darkBackground : null,
      ),
      // Active filter bar below AppBar
      body: Column(
        children: [
          if (hasFilter) _buildActiveFilterBar(context, isDark, sitesAsync),
          Expanded(child: mapWidget),
        ],
      ),
      floatingActionButton: fabs,
    );
  }

  /// Thin banner showing the active filters + a clear button.
  Widget _buildActiveFilterBar(
    BuildContext context,
    bool isDark,
    AsyncValue<List<VisitSite>> sitesAsync,
  ) {
    final selectedIslandId = ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId));
    final selectedMonitoringType = ref.watch(mapFiltersProvider.select((f) => f.selectedMonitoringType));
    final allSites = sitesAsync.asData?.value ?? [];
    final count = allSites
        .where((s) => s.status == 'active' || s.status == null)
        .where((s) => selectedIslandId == null || s.islandId == selectedIslandId)
        .where((s) => selectedMonitoringType == null || s.monitoringType == selectedMonitoringType)
        .where((s) => s.latitude != null)
        .length;

    final islandsData = ref.read(islandsProvider).asData?.value ?? [];
    final isEs = LocaleSettings.currentLocale == AppLocale.es;
    final islandName = selectedIslandId != null
        ? islandsData.where((i) => i.id == selectedIslandId).map((i) => isEs ? i.nameEs : (i.nameEn ?? i.nameEs)).firstOrNull
        : null;

    final parts = <String>[];
    if (islandName != null) parts.add(islandName);
    if (selectedMonitoringType != null) parts.add(selectedMonitoringType);

    return Container(
      color: isDark
          ? AppColors.accentOrange.withValues(alpha: 0.15)
          : AppColors.accentOrange.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 16, color: AppColors.accentOrange),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${parts.join(' · ')} — $count sitios',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(mapFiltersProvider.notifier).setSelectedIsland(null);
              ref.read(mapFiltersProvider.notifier).setMonitoringType(null);
            },
            child: Icon(Icons.close, size: 16, color: AppColors.accentOrange),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tile mode toggle button - opens MapModeSelector sheet
  // ---------------------------------------------------------------------------

  Widget _buildTileModeToggle(BuildContext context) {
    final tileMode = ref.watch(mapTileModeProvider);

    IconData icon;
    switch (tileMode) {
      case MapTileMode.vector:
        icon = Icons.layers;
        break;
      case MapTileMode.satellite:
        icon = Icons.satellite_alt;
        break;
      case MapTileMode.hybrid:
        icon = Icons.map;
        break;
      case MapTileMode.street:
      default:
        icon = Icons.map_outlined;
    }

    return IconButton(
      icon: Icon(icon),
      tooltip: context.t.map.switchMapMode,
      onPressed: () => _showMapModeSelector(context),
    );
  }

  void _showMapModeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const MapModeSelector(),
    );
  }

  // ---------------------------------------------------------------------------
  // Site filter bottom sheet (phone)
  // ---------------------------------------------------------------------------

  void _showSiteFilterSheet(
    BuildContext context,
    AsyncValue<List<VisitSite>> sitesAsync,
    AsyncValue<List<Island>> islandsAsync,
  ) {
    final isEs = LocaleSettings.currentLocale == AppLocale.es;
    final allSites = sitesAsync.asData?.value ?? [];
    final activeSites = allSites.where((s) => s.status == 'active' || s.status == null).toList();
    final allIslands = islandsAsync.asData?.value ?? [];

    // Only show islands that have at least one active site with coordinates
    final activeIslandIds = activeSites
        .where((s) => s.latitude != null)
        .map((s) => s.islandId)
        .whereType<int>()
        .toSet();
    final relevantIslands = allIslands
        .where((i) => activeIslandIds.contains(i.id))
        .toList()
      ..sort((a, b) {
        final nA = isEs ? a.nameEs : (a.nameEn ?? a.nameEs);
        final nB = isEs ? b.nameEs : (b.nameEn ?? b.nameEs);
        return nA.compareTo(nB);
      });

    int filteredCount(int? islandId, String? monType) => activeSites
        .where((s) => islandId == null || s.islandId == islandId)
        .where((s) => monType == null || s.monitoringType == monType)
        .where((s) => s.latitude != null)
        .length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.65,
            minChildSize: 0.4,
            maxChildSize: 0.92,
            builder: (ctx2, scrollController) => Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        ctx2.t.map.filterVisitSites,
                        style: Theme.of(ctx2).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (ref.read(mapFiltersProvider).selectedIslandId != null || ref.read(mapFiltersProvider).selectedMonitoringType != null)
                        TextButton(
                          onPressed: () {
                            ref.read(mapFiltersProvider.notifier).setSelectedIsland(null);
                            ref.read(mapFiltersProvider.notifier).setMonitoringType(null);
                            setSheetState(() {});
                          },
                          child: Text(isEs ? 'Limpiar' : 'Clear'),
                        ),
                    ],
                  ),
                ),
                // Monitoring type chips
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEs ? 'TIPO' : 'TYPE',
                        style: Theme.of(ctx2).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final (value, label, icon, color) in [
                            (null, isEs ? 'Todos' : 'All', Icons.public, Colors.grey),
                            ('MARINO', isEs ? 'Marino' : 'Marine', Icons.water, Colors.blue),
                            ('TERRESTRE', isEs ? 'Terrestre' : 'Land', Icons.terrain, Colors.green),
                          ])
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                avatar: Icon(icon, size: 16, color: ref.read(mapFiltersProvider).selectedMonitoringType == value ? color : Colors.grey),
                                label: Text(label),
                                selected: ref.read(mapFiltersProvider).selectedMonitoringType == value,
                                onSelected: (_) {
                                  ref.read(mapFiltersProvider.notifier).setMonitoringType(value);
                                  setSheetState(() {});
                                },
                                selectedColor: (color as Color).withValues(alpha: isDark ? 0.3 : 0.18),
                                checkmarkColor: color,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 20),
                // Island count header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        isEs ? 'ISLA' : 'ISLAND',
                        style: Theme.of(ctx2).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${filteredCount(ref.read(mapFiltersProvider).selectedIslandId, ref.read(mapFiltersProvider).selectedMonitoringType)} ${isEs ? 'sitios' : 'sites'}',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Island list
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: 8),
                    children: [
                      // "All islands" option
                      _islandTile(
                        ctx2,
                        name: isEs ? 'Todas las islas' : 'All islands',
                        count: filteredCount(null, ref.read(mapFiltersProvider).selectedMonitoringType),
                        icon: Icons.public,
                        isSelected: ref.read(mapFiltersProvider).selectedIslandId == null,
                        isDark: isDark,
                        accentColor: accentColor,
                        onTap: () {
                          ref.read(mapFiltersProvider.notifier).setSelectedIsland(null);
                          setSheetState(() {});
                        },
                      ),
                      // Per-island tiles
                      ...relevantIslands.map((island) {
                        final name = isEs ? island.nameEs : (island.nameEn ?? island.nameEs);
                        final isSelected = ref.read(mapFiltersProvider).selectedIslandId == island.id;
                        return _islandTile(
                          ctx2,
                          name: name,
                          count: filteredCount(island.id, ref.read(mapFiltersProvider).selectedMonitoringType),
                          icon: Icons.landscape,
                          isSelected: isSelected,
                          isDark: isDark,
                          accentColor: accentColor,
                          onTap: () {
                            ref.read(mapFiltersProvider.notifier).setSelectedIsland(island.id);
                            // Center map on island and close sheet
                            if (island.latitude != null && island.longitude != null) {
                              _mapController.move(
                                LatLng(island.latitude!, island.longitude!),
                                11.5,
                              );
                            }
                            Navigator.pop(sheetContext);
                          },
                        );
                      }),
                    ],
                  ),
                ),
                // Apply / show results button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          isEs
                              ? 'Ver ${filteredCount(ref.read(mapFiltersProvider).selectedIslandId, ref.read(mapFiltersProvider).selectedMonitoringType)} sitios'
                              : 'Show ${filteredCount(ref.read(mapFiltersProvider).selectedIslandId, ref.read(mapFiltersProvider).selectedMonitoringType)} sites',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _islandTile(
    BuildContext context, {
    required String name,
    required int count,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: isSelected
            ? accentColor.withValues(alpha: 0.15)
            : (isDark ? Colors.white10 : Colors.grey.shade100),
        child: Icon(icon, size: 18, color: isSelected ? accentColor : Colors.grey),
      ),
      title: Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      subtitle: Text(
        '$count ${LocaleSettings.currentLocale == AppLocale.es ? 'sitios' : 'sites'}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: isSelected ? Icon(Icons.check_circle, color: accentColor) : null,
      selected: isSelected,
      onTap: onTap,
    );
  }

  // ---------------------------------------------------------------------------
  // Tablet layout
  // ---------------------------------------------------------------------------

  Widget _buildTabletLayout(
    BuildContext context,
    bool isDark,
    bool isEs,
    AsyncValue<dynamic> islandsAsync,
    AsyncValue<dynamic> sitesAsync,
    AsyncValue<List<Trail>> trailsAsync,
    Widget mapWidget,
    Widget fabs,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child: Text(
                context.t.map.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            // Map action icons inline with title
            _buildTileModeToggle(context),
            IconButton(
              icon: Icon(ref.watch(mapFiltersProvider.select((f) => f.showTrails)) ? Icons.route : Icons.route_outlined),
              onPressed: () => ref.read(mapFiltersProvider.notifier).toggleTrails(),
              tooltip: context.t.map.toggleTrails,
            ),
            IconButton(
              icon: Icon(ref.watch(mapFiltersProvider.select((f) => f.showSites)) ? Icons.location_on : Icons.location_off),
              onPressed: () => ref.read(mapFiltersProvider.notifier).toggleSites(),
              tooltip: context.t.map.toggleSites,
            ),
            IconButton(
              icon: Icon(
                ref.watch(mapFiltersProvider.select((f) => f.showSightings)) ? Icons.camera_alt : Icons.camera_alt_outlined,
                color: ref.watch(mapFiltersProvider.select((f) => f.showSightings)) ? Colors.teal : null,
              ),
              onPressed: () => ref.read(mapFiltersProvider.notifier).toggleSightings(),
              tooltip: context.t.map.toggleSightings,
            ),
          ],
        ),
        backgroundColor: isDark ? AppColors.darkBackground : null,
      ),
      body: Row(
        children: [
          // Left panel - islands, visit sites, and trails list (22%)
          SizedBox(
            width: MediaQuery.sizeOf(context).width * AppConstants.mapSidebarWidthFraction,
            child: Column(
              children: [
                // Search filter
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: context.t.search.hint,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => ref.read(mapFiltersProvider.notifier).setSearchQuery(value),
                  ),
                ),
                // Selected island indicator
                if (ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId)) != null)
                  islandsAsync.when(
                    data: (islands) {
                      final selectedIslandId = ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId));
                      final selectedIsland = islands.firstWhere(
                        (Island i) => i.id == selectedIslandId,
                        orElse: () => islands.first as Island,
                      );
                      final islandName = isEs
                          ? (selectedIsland.nameEs ?? selectedIsland.nameEn)
                          : selectedIsland.nameEn;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.accentOrange.withValues(alpha: 0.2)
                              : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.accentOrange.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.filter_alt,
                              size: 16,
                              color: AppColors.accentOrange,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                islandName,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => ref.read(mapFiltersProvider.notifier).setSelectedIsland(null),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: isDark ? Colors.white70 : Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                // Islands
                islandsAsync.when(
                  data: (islands) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                        child: Text(
                          context.t.map.islands,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: isDark ? AppColors.accentOrange : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...islands
                          .where((Island i) => i.latitude != null && i.longitude != null)
                          .where((Island i) {
                            final searchQuery = ref.watch(mapFiltersProvider.select((f) => f.searchQuery));
                            if (searchQuery.isEmpty) return true;
                            final islandName = isEs ? (i.nameEs ?? i.nameEn) : i.nameEn;
                            return islandName.toLowerCase().contains(searchQuery.toLowerCase());
                          })
                          .map((island) {
                            final islandName = isEs ? (island.nameEs ?? island.nameEn) : island.nameEn;
                            final selectedIslandId = ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId));
                            final isSelected = selectedIslandId == island.id;
                            return ListTile(
                            dense: true,
                            selected: isSelected,
                            selectedTileColor: isDark
                                ? AppColors.accentOrange.withValues(alpha: 0.15)
                                : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                            leading: Icon(
                              Icons.terrain,
                              size: 20,
                              color: isSelected
                                  ? AppColors.accentOrange
                                  : (isDark ? AppColors.primaryLight : null),
                            ),
                            title: Text(
                              islandName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : null,
                              ),
                            ),
                            subtitle: island.areaKm2 != null
                                ? Text('${island.areaKm2} km\u00B2', style: const TextStyle(fontSize: 12))
                                : null,
                            onTap: () {
                              ref.read(mapFiltersProvider.notifier).setSelectedIsland(isSelected ? null : island.id);
                              _mapController.move(LatLng(island.latitude!, island.longitude!), 11);
                            },
                          );
                          }),
                    ],
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const Divider(),
                // Visit sites - only show when an island is selected or when explicitly toggled
                if (ref.watch(mapFiltersProvider.select((f) => f.showSites)) || ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId)) != null)
                  sitesAsync.when(
                    data: (sites) {
                      final selectedIslandId = ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId));
                      final selectedMonitoringType = ref.watch(mapFiltersProvider.select((f) => f.selectedMonitoringType));
                      // Filter to active tourist sites + island + monitoring type
                      final visibleSites = sites
                          .where((s) => s.status == 'active' || s.status == null)
                          .where((s) => selectedIslandId == null || s.islandId == selectedIslandId)
                          .where((s) => selectedMonitoringType == null || s.monitoringType == selectedMonitoringType)
                          .where((s) => s.latitude != null && s.longitude != null)
                          .toList();

                      if (visibleSites.isEmpty && selectedIslandId != null) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                            child: Text(
                              context.t.map.visitSites,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: isDark ? AppColors.accentOrange : Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...visibleSites.map((site) {
                            final siteName = isEs ? site.nameEs : (site.nameEn ?? site.nameEs);
                            return ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.place,
                                size: 20,
                                color: AppColors.accentOrange,
                              ),
                              title: Text(siteName, style: const TextStyle(fontSize: 14)),
                              subtitle: site.monitoringType != null
                                  ? Text(site.monitoringType!, style: const TextStyle(fontSize: 12, color: AppColors.accentOrange))
                                  : null,
                              onTap: () {
                                _mapController.move(LatLng(site.latitude!, site.longitude!), 13);
                              },
                            );
                          }),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                // Trails section in tablet sidebar
                if (ref.watch(mapFiltersProvider.select((f) => f.showTrails))) ...[
                  const Divider(),
                  _buildTrailsSidebarSection(isDark, isEs, trailsAsync, islandsAsync),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
          VerticalDivider(
            width: 1,
            color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
          ),
          // Right panel - map (70%)
          Expanded(
            child: Stack(
              children: [
                mapWidget,
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: fabs,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Trails sidebar section (tablet only) grouped by island
  // ---------------------------------------------------------------------------

  Widget _buildTrailsSidebarSection(
    bool isDark,
    bool isEs,
    AsyncValue<List<Trail>> trailsAsync,
    AsyncValue<dynamic> islandsAsync,
  ) {
    return trailsAsync.when(
      data: (trails) {
        final selectedIslandId = ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId));
        // Filter trails by selected island if one is selected
        final filteredTrails = selectedIslandId != null
            ? trails.where((t) => t.islandId == selectedIslandId).toList()
            : trails;

        if (filteredTrails.isEmpty) {
          if (selectedIslandId != null) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.t.map.noTrails,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        // Build island name lookup
        final islandsData = islandsAsync.asData?.value as List<dynamic>?;
        final islandNameMap = <int, String>{};
        if (islandsData != null) {
          for (final island in islandsData) {
            final name = isEs
                ? (island.nameEs ?? island.nameEn)
                : island.nameEn;
            islandNameMap[island.id as int] = name;
          }
        }

        // Group trails by island
        final grouped = <int?, List<Trail>>{};
        for (final trail in filteredTrails) {
          grouped.putIfAbsent(trail.islandId, () => []).add(trail);
        }

        final sortedKeys = grouped.keys.toList()
          ..sort((a, b) {
            if (a == null) return 1;
            if (b == null) return -1;
            return a.compareTo(b);
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Text(
                context.t.map.trails,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isDark ? AppColors.accentOrange : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (final islandId in sortedKeys) ...[
              // Only show island name header if not filtering by island
              if (ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId)) == null && islandId != null && islandNameMap.containsKey(islandId))
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 2),
                  child: Text(
                    islandNameMap[islandId]!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              for (final trail in grouped[islandId]!)
                _buildTrailSidebarTile(trail, isEs),
            ],
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildTrailSidebarTile(Trail trail, bool isEs) {
    final trailName = isEs ? trail.nameEs : trail.nameEn;
    final color = _trailDifficultyColor(trail.difficulty);

    return ListTile(
      dense: true,
      leading: Icon(Icons.route, size: 20, color: color),
      title: Text(trailName, style: const TextStyle(fontSize: 14)),
      subtitle: trail.distanceKm != null
          ? Text(
              context.t.map.trailDistance(km: trail.distanceKm!.toStringAsFixed(1)),
              style: const TextStyle(fontSize: 12),
            )
          : null,
      onTap: () {
        final coords = parseTrailCoordinates(trail.coordinates);
        if (coords.isNotEmpty) {
          _zoomToTrailExtent(coords);
        }
      },
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
        // Enable all interaction gestures with rotation
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
          enableMultiFingerGestureRace: true,
        ),
        // Smooth animations
        onMapEvent: (event) {
          // Trigger rebuild to update zoom indicator
          if (event is MapEventMove || event is MapEventRotate) {
            setState(() {});
          }
        },
        // Handle map taps for field editing
        onTap: (tapPosition, point) => _handleMapTap(point),
      ),
      children: [
        // --- Tile base layer: Vector / Street / Satellite / Hybrid ---
        if (tileMode == MapTileMode.vector && pmtilesAsync.asData?.value != null)
          // Vector PMTiles (offline)
          VectorTileLayer(
            tileProviders: TileProviders({
              'protomaps': pmtilesAsync.asData!.value!,
            }),
            theme: isDark ? _cachedDarkTheme : _cachedLightTheme,
            tileOffset: TileOffset.DEFAULT,
            concurrency: 4,
          )
        else if (tileMode == MapTileMode.satellite)
          // ESRI World Imagery (FREE - no API key required)
          // With opportunistic caching - stores only visited areas
          TileLayer(
            urlTemplate: SatelliteMapConstants.esriSatelliteUrl,
            userAgentPackageName: 'com.galapagos.galapagos_wildlife',
            maxNativeZoom: 19,
            maxZoom: 19,
            subdomains: const [],
            retinaMode: false,
            tileProvider: _tileProvider('satelliteCache'),
            tileBuilder: (context, tileWidget, tile) {
              // Debug: log tile loading
              return tileWidget;
            },
            errorTileCallback: (tile, error, stackTrace) {
              // Debug: log tile errors
              AppLogger.warning('Tile error at ${tile.coordinates}: $error');
            },
          )
        else if (tileMode == MapTileMode.hybrid) ...[
          // ESRI Satellite base (FREE)
          // With opportunistic caching - stores only visited areas
          TileLayer(
            urlTemplate: SatelliteMapConstants.esriSatelliteUrl,
            userAgentPackageName: 'com.galapagos.galapagos_wildlife',
            maxNativeZoom: 19,
            maxZoom: 19,
            subdomains: const [],
            retinaMode: false,
            tileProvider: _tileProvider('satelliteCache'),
            errorTileCallback: (tile, error, stackTrace) {
              AppLogger.warning('ESRI tile error at ${tile.coordinates}: $error');
            },
          ),
          // CartoDB labels overlay (FREE)
          // With opportunistic caching
          TileLayer(
            urlTemplate: SatelliteMapConstants.cartoLabelsUrl,
            userAgentPackageName: 'com.galapagos.galapagos_wildlife',
            maxNativeZoom: 19,
            maxZoom: 19,
            subdomains: const ['a', 'b', 'c'],
            retinaMode: false,
            tileProvider: _tileProvider('labelsCache'),
            errorTileCallback: (tile, error, stackTrace) {
              AppLogger.warning('CartoDB tile error at ${tile.coordinates}: $error');
            },
          ),
        ] else ...[
          // Default: OpenStreetMap street tiles with FMTC caching
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.galapagos.galapagos_wildlife',
            maxNativeZoom: 19,
            tileProvider: _tileProvider('galapagosMap'),
          ),
          // Dark overlay for street tiles in dark mode
          if (isDark)
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
                tileProvider: _tileProvider('galapagosMap'),
              ),
            ),
        ],
        // User location marker
        if (locationAsync.asData?.value case final userPos?)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(userPos.latitude, userPos.longitude),
                width: 24,
                height: 24,
                child: Semantics(
                  label: context.t.map.yourLocation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        // Island markers
        islandsAsync.when(
          data: (islands) => MarkerLayer(
            markers: islands
                .where((Island i) => i.latitude != null && i.longitude != null)
                .where((Island i) => _isWithinViewport(i.latitude, i.longitude))
                .map((island) {
                  final islandName = isEs ? (island.nameEs ?? island.nameEn) : island.nameEn;
                  return Marker(
                  point: LatLng(island.latitude!, island.longitude!),
                  width: 120,
                  height: 40,
                  child: Semantics(
                    button: true,
                    label: context.t.map.islandLabel(name: islandName),
                    child: GestureDetector(
                      onTap: () => _showIslandInfo(context, island),
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
        ),
        // Visit site markers — regular (non-drag) view
        // In moveSitesDrag mode the DragMarkers are rendered LAST so they
        // sit on top of trail and sighting markers and receive touches first.
        if (ref.watch(mapFiltersProvider.select((f) => f.showSites)))
          _buildSiteMarkersLayer(sitesAsync, isEs, editState),
        // Trail polylines (after site markers, before sighting markers)
        if (ref.watch(mapFiltersProvider.select((f) => f.showTrails)))
          _buildTrailPolylinesLayer(trailsAsync),
        // Trail midpoint tap-target markers.
        // In selectTrailForEdit mode these are moved to the END of the
        // children list (below) so they sit above the sightings layer and
        // receive taps that would otherwise be intercepted by sighting markers.
        // Hide trail markers while a trail is being edited (not useful then)
        if (ref.watch(mapFiltersProvider.select((f) => f.showTrails)) &&
            editState.mode != FieldEditMode.selectTrailForEdit &&
            editState.mode != FieldEditMode.editTrailManual)
          _buildTrailMarkers(trailsAsync, isEs),
        // User tracking polyline (blue line showing walked path)
        if (isTracking && trackPoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: trackPoints.map((tp) => tp.point).toList(),
                color: Colors.blue,
                strokeWidth: 4,
                borderColor: Colors.white,
                borderStrokeWidth: 1,
              ),
            ],
          ),
        // Sighting markers
        if (ref.watch(mapFiltersProvider.select((f) => f.showSightings)))
          _buildSightingsLayer(isEs, sightingsAsync, speciesLookupAsync),

        // Field editing layer (trail being created/edited)
        _buildFieldEditingLayer(),

        // In selectTrailForEdit mode trail markers are rendered here (LAST
        // before site drag layer) so they are above sightings and tappable.
        if (ref.watch(mapFiltersProvider.select((f) => f.showTrails)) && editState.mode == FieldEditMode.selectTrailForEdit)
          _buildTrailMarkers(trailsAsync, isEs),

        // Site DragMarkers rendered LAST so they are on top of all other
        // layers and receive touch events before trail / sighting markers do.
        if (ref.watch(mapFiltersProvider.select((f) => f.showSites)) && editState.mode == FieldEditMode.moveSitesDrag)
          _buildSiteDragMarkersLayer(sitesAsync, isEs),
      ],
    );

    // Wrap FlutterMap with UI controls in a Stack
    return Stack(
      children: [
        flutterMap,

        // iOS-style zoom controls (bottom-right corner, compact)
        Positioned(
          bottom: MediaQuery.viewPaddingOf(context).bottom + 130,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Zoom In button
              _ZoomButton(
                icon: Icons.add,
                onPressed: _safeGetZoom() >= 19 ? null : () {
                  try {
                    final zoom = _safeGetZoom();
                    _mapController.move(
                      _mapController.camera.center,
                      (zoom + 1).clamp(6, 19),
                    );
                  } catch (_) {
                    AppLogger.warning('Zoom in failed: map controller not ready', _);
                  }
                },
              ),
              const SizedBox(height: 8),
              // Zoom Out button
              _ZoomButton(
                icon: Icons.remove,
                onPressed: _safeGetZoom() <= 6 ? null : () {
                  try {
                    final zoom = _safeGetZoom();
                    _mapController.move(
                      _mapController.camera.center,
                      (zoom - 1).clamp(6, 19),
                    );
                  } catch (_) {
                    AppLogger.warning('Zoom out failed: map controller not ready', _);
                  }
                },
              ),
            ],
          ),
        ),

        // Compass indicator (top-right, if map is rotated)
        if (_safeGetRotation() != 0)
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                try {
                  _mapController.rotate(0);
                } catch (e) {
                  // Controller not ready yet
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: _safeGetRotation() * (3.14159 / 180),
                  child: Icon(
                    Icons.navigation,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Trail polylines layer
  // ---------------------------------------------------------------------------

  Widget _buildTrailPolylinesLayer(AsyncValue<List<Trail>> trailsAsync) {
    // While a trail is being edited its path is drawn by _buildFieldEditingLayer
    // as an orange overlay.  Hide the original polyline so the two do not overlap.
    return MapLayerBuilders.buildTrailPolylinesLayer(
      trailsAsync: trailsAsync,
      editingTrailId: ref.watch(fieldEditProvider.select((s) => s.selectedTrailId)),
      isEditing: ref.watch(
          fieldEditProvider.select((s) => s.mode == FieldEditMode.editTrailManual)),
    );
  }

  /// Builds small circular markers at each trail's midpoint so the user can
  /// tap to open the trail info bottom sheet or select a trail for editing.
  Widget _buildTrailMarkers(AsyncValue<List<Trail>> trailsAsync, bool isEs) {
    final isSelectingForEdit = ref.watch(
        fieldEditProvider.select((s) => s.mode == FieldEditMode.selectTrailForEdit));

    return MapLayerBuilders.buildTrailMarkers(
      context: context,
      trailsAsync: trailsAsync,
      isEs: isEs,
      isSelectingForEdit: isSelectingForEdit,
      onShowTrailInfo: (trail) => _showTrailInfo(context, trail),
      onSelectTrailForEdit: (id) => _loadTrailForEditing(id),
    );
  }

  // ---------------------------------------------------------------------------
  // FABs
  // ---------------------------------------------------------------------------

  Widget _buildFabs(
    AsyncValue<dynamic> locationAsync,
    bool isTracking,
    List<({LatLng point, DateTime time})> trackPoints,
    MapDownloadState downloadState,
  ) {
    final userPos = locationAsync.asData?.value;
    final locationLoading = locationAsync is AsyncLoading;

    // iOS-style: Only essential FABs, minimalist
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // My Location button — always visible
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: locationLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      userPos != null ? Icons.my_location : Icons.location_searching,
                      color: userPos != null ? AppColors.primary : Colors.grey,
                      size: 22,
                    ),
                    onPressed: () {
                      if (userPos != null) {
                        try {
                          _mapController.move(
                            LatLng(userPos.latitude, userPos.longitude),
                            14,
                          );
                        } catch (_) {
                          AppLogger.warning('Go to my location failed: map controller not ready', _);
                        }
                      } else {
                        // Refresh location provider
                        ref.invalidate(userLocationProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.t.map.locatingDevice),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    tooltip: context.t.map.goToMyLocation,
                  ),
          ),
        ),
        // Download / Stop Tracking button
        if (isTracking)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.stop, color: Colors.white, size: 22),
              onPressed: () => _stopTracking(),
              tooltip: context.t.map.stopTracking,
            ),
          )
        else
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: downloadState.isActive
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        value: downloadState.overallProgress,
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(Icons.download, color: AppColors.primary, size: 22),
              onPressed: () => _showDownloadSheet(context),
              tooltip: context.t.map.downloadTiles,
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Site markers layer (with drag support for editing)
  // ---------------------------------------------------------------------------

  Widget _buildSiteMarkersLayer(
    AsyncValue sitesAsync,
    bool isEs,
    FieldEditState editState,
  ) {
    return sitesAsync.when(
      data: (sites) {
        // moveSitesDrag: DragMarkers are rendered as the very last FlutterMap
        // child (see _buildSiteDragMarkersLayer) so they sit above trail and
        // sighting markers and receive touch events without being blocked.
        // Show regular static markers here so sites remain visible.

        // ── Single selected site draggable (legacy moveSiteManual) ───────────
        if (editState.mode == FieldEditMode.moveSiteManual &&
            editState.selectedSiteId != null) {
          final dragMarkers = <DragMarker>[];
          final regularMarkers = <Marker>[];

          for (final site in sites) {
            if (site.latitude == null || site.longitude == null) continue;
            if (!_isWithinViewport(site.latitude, site.longitude)) continue;
            final siteName = isEs ? site.nameEs : (site.nameEn ?? site.nameEs);
            final point = LatLng(site.latitude!, site.longitude!);
            if (site.id == editState.selectedSiteId) {
              dragMarkers.add(DragMarker(
                point: point,
                size: const Size(44, 44),
                offset: const Offset(0, -22),
                builder: (context, latLng, isDragging) => Icon(
                  Icons.place,
                  color: isDragging ? Colors.red : AppColors.accentOrange,
                  size: isDragging ? 44 : 36,
                  shadows: isDragging
                      ? const [Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4))]
                      : null,
                ),
                onDragEnd: (details, latLng) async {
                  final service = FieldEditService(ref: ref);
                  await service.updateVisitSiteLocation(
                    siteId: site.id!,
                    newLatitude: latLng.latitude,
                    newLongitude: latLng.longitude,
                  );
                  ref.read(fieldEditProvider.notifier).markUnsaved();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✅ $siteName moved'), duration: const Duration(seconds: 1)),
                    );
                  }
                },
              ));
            } else {
              regularMarkers.add(Marker(
                point: point,
                width: 30,
                height: 30,
                child: GestureDetector(
                  onTap: () => _showSiteInfo(context, site),
                  child: const Icon(Icons.place, color: AppColors.accentOrange, size: 28),
                ),
              ));
            }
          }
          return Stack(children: [
            if (regularMarkers.isNotEmpty) MarkerLayer(markers: regularMarkers),
            if (dragMarkers.isNotEmpty) DragMarkers(markers: dragMarkers),
          ]);
        }

        // ── Normal view ──────────────────────────────────────────────────────
        // Public app: only show tourist-active sites, apply island + type filter.
        final selectedIslandId = ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId));
        final selectedMonitoringType = ref.watch(mapFiltersProvider.select((f) => f.selectedMonitoringType));
        return MarkerLayer(
          markers: sites
              .where((s) => s.status == 'active' || s.status == null)
              .where((s) => selectedIslandId == null || s.islandId == selectedIslandId)
              .where((s) => selectedMonitoringType == null || s.monitoringType == selectedMonitoringType)
              .where((s) => s.latitude != null && s.longitude != null)
              .where((s) => _isWithinViewport(s.latitude, s.longitude))
              .map((site) {
                final siteName = isEs ? site.nameEs : (site.nameEn ?? site.nameEs);
                return Marker(
                  point: LatLng(site.latitude!, site.longitude!),
                  width: 30,
                  height: 30,
                  child: Semantics(
                    button: true,
                    label: context.t.map.visitSiteLabel(name: siteName),
                    child: GestureDetector(
                      onTap: () => _showSiteInfo(context, site),
                      child: const Icon(Icons.place, color: AppColors.accentOrange, size: 28),
                    ),
                  ),
                );
              })
              .toList()
              .cast<Marker>(),
        );
      },
      loading: () => const MarkerLayer(markers: []),
      error: (_, _) => const MarkerLayer(markers: []),
    );
  }

  // ---------------------------------------------------------------------------
  // Site drag-markers layer — rendered LAST so it is on top of all other
  // map layers and receives touch events without being blocked.
  // Only active in moveSitesDrag mode.
  // ---------------------------------------------------------------------------

  Widget _buildSiteDragMarkersLayer(AsyncValue sitesAsync, bool isEs) {
    return sitesAsync.when(
      data: (sites) {
        final dragMarkers = sites
            .where((s) => s.id != null && s.latitude != null && s.longitude != null)
            .map<DragMarker>((site) {
              final siteName = isEs ? site.nameEs : (site.nameEn ?? site.nameEs);
              final point = _sitePositionOverrides[site.id!] ??
                  LatLng(site.latitude!, site.longitude!);
              // Track whether this marker has been moved this session
              final wasMoved = _sitePositionOverrides.containsKey(site.id!);
              return DragMarker(
                point: point,
                size: const Size(52, 52),
                offset: const Offset(0, -26),
                builder: (context, latLng, isDragging) {
                  // Three distinct visual states:
                  //   dragging  → red    (active drag feedback)
                  //   moved     → green  (position saved, still in edit mode)
                  //   idle      → orange (editable, not yet moved)
                  final Color color;
                  final double size;
                  final IconData icon;
                  if (isDragging) {
                    color = Colors.red;
                    size  = 52;
                    icon  = Icons.place;
                  } else if (wasMoved) {
                    color = Colors.green.shade600;
                    size  = 42;
                    icon  = Icons.place;
                  } else {
                    color = Colors.orange;
                    size  = 40;
                    icon  = Icons.place;
                  }
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        icon,
                        color: color,
                        size: size,
                        shadows: isDragging
                            ? const [Shadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 5))]
                            : [const Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      // Checkmark badge when moved
                      if (wasMoved && !isDragging)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.green, size: 11),
                          ),
                        ),
                    ],
                  );
                },
                onDragEnd: (details, latLng) async {
                  setState(() => _sitePositionOverrides[site.id!] = latLng);
                  final service = FieldEditService(ref: ref);
                  await service.updateVisitSiteLocation(
                    siteId: site.id!,
                    newLatitude: latLng.latitude,
                    newLongitude: latLng.longitude,
                  );
                  ref.invalidate(visitSitesProvider);
                  ref.read(fieldEditProvider.notifier).markUnsaved();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ $siteName moved'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              );
            })
            .toList();
        return DragMarkers(markers: dragMarkers);
      },
      loading: () => const MarkerLayer(markers: []),
      error: (_, _) => const MarkerLayer(markers: []),
    );
  }

  // ---------------------------------------------------------------------------
  // Sightings layer (unchanged)
  // ---------------------------------------------------------------------------

  Widget _buildSightingsLayer(
    bool isEs,
    AsyncValue<dynamic> sightingsAsync,
    AsyncValue<dynamic> speciesLookupAsync,
  ) {
    return MapLayerBuilders.buildSightingsLayer(
      context: context,
      isEs: isEs,
      sightingsAsync: sightingsAsync,
      speciesLookupAsync: speciesLookupAsync,
      isWithinViewport: _isWithinViewport,
      onSightingTap: (sighting, species) =>
          _showSightingInfo(context, sighting, species),
    );
  }

  // ---------------------------------------------------------------------------
  // MapController helpers
  // ---------------------------------------------------------------------------

  /// Safely get current zoom level (returns default if controller not ready)
  double _safeGetZoom() {
    try {
      return _mapController.camera.zoom;
    } catch (e) {
      return AppConstants.galapagosDefaultZoom;
    }
  }

  /// Safely get current rotation (returns 0 if controller not ready)
  double _safeGetRotation() {
    try {
      return _mapController.camera.rotation;
    } catch (e) {
      return 0.0;
    }
  }

  // ---------------------------------------------------------------------------
  // Viewport culling helper
  // ---------------------------------------------------------------------------

  /// Filters items to only those within the current visible map bounds.
  /// Returns true if the point is within viewport + buffer zone for smooth transitions.
  bool _isWithinViewport(double? lat, double? lng) {
    if (lat == null || lng == null) return false;

    // Return true if MapController is not ready yet (show all items on first render)
    try {
      final camera = _mapController.camera;
      final bounds = camera.visibleBounds;

    // Add buffer zone (10% extra on each side) to prevent markers from
    // popping in/out too aggressively during pan
    final latBuffer = (bounds.north - bounds.south) * 0.1;
    final lngBuffer = (bounds.east - bounds.west) * 0.1;

      return lat >= bounds.south - latBuffer &&
             lat <= bounds.north + latBuffer &&
             lng >= bounds.west - lngBuffer &&
             lng <= bounds.east + lngBuffer;
    } catch (e) {
      // MapController not ready yet, show all items
      return true;
    }
  }

  // ---------------------------------------------------------------------------
  // Trail info bottom sheet
  // ---------------------------------------------------------------------------

  void _showTrailInfo(BuildContext context, Trail trail) {
    final isEs = LocaleSettings.currentLocale == AppLocale.es;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trailName = isEs ? trail.nameEs : trail.nameEn;
    final trailDesc = isEs
        ? (trail.descriptionEs ?? trail.descriptionEn)
        : trail.descriptionEn;
    final difficultyColor = _trailDifficultyColor(trail.difficulty);
    final difficultyLabel = _trailDifficultyLabel(context, trail.difficulty);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trail name with icon
            Row(
              children: [
                Icon(Icons.route, color: difficultyColor, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trailName,
                    style: Theme.of(sheetContext).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Difficulty badge + stats row
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                // Difficulty chip
                Chip(
                  label: Text(
                    difficultyLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: difficultyColor,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                // Distance
                if (trail.distanceKm != null)
                  _infoChip(
                    icon: Icons.straighten,
                    label: context.t.map.trailDistance(
                      km: trail.distanceKm!.toStringAsFixed(1),
                    ),
                    isDark: isDark,
                  ),
                // Estimated time
                if (trail.estimatedMinutes != null)
                  _infoChip(
                    icon: Icons.timer_outlined,
                    label: context.t.map.trailDuration(
                      min: trail.estimatedMinutes!,
                    ),
                    isDark: isDark,
                  ),
                // Elevation gain
                if (trail.elevationGainM != null)
                  _infoChip(
                    icon: Icons.terrain,
                    label: '${trail.elevationGainM!.toStringAsFixed(0)} m',
                    isDark: isDark,
                  ),
              ],
            ),
            // Description
            if (trailDesc != null && trailDesc.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                trailDesc,
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            // "Follow Trail" button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _startTrackingTrail(trail);
                },
                icon: const Icon(Icons.navigation),
                label: Text(context.t.map.startTracking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            // "Edit Trail" button — only for trail owners
            if (trail.userId != null &&
                trail.userId == Supabase.instance.client.auth.currentUser?.id) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _loadTrailForEditing(trail.id);
                  },
                  icon: const Icon(Icons.edit_road),
                  label: const Text('Editar sendero'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tracking actions
  // ---------------------------------------------------------------------------

  void _startTrackingTrail(Trail trail) {
    final coords = parseTrailCoordinates(trail.coordinates);
    if (coords.isEmpty) return;

    _trackingService = TrackingService(ref);
    _trackingService!.startTracking(coords);

    // Zoom to trail extent
    _zoomToTrailExtent(coords);
  }

  void _stopTracking() {
    if (_trackingService == null) {
      // Fallback: manually reset providers if no service instance
      ref.read(isTrackingProvider.notifier).state = false;
      ref.read(offRouteProvider.notifier).state = false;
      ref.read(activeTrailCoordsProvider.notifier).state = null;
      ref.read(trackPointsProvider.notifier).state = [];
      ref.read(distanceFromTrailProvider.notifier).state = 0;
      return;
    }

    final summary = _trackingService!.stopTracking();
    _trackingService = null;

    if (!mounted) return;

    // Build summary message
    final distanceKm = (summary.distanceMeters / 1000).toStringAsFixed(2);
    final message = StringBuffer(context.t.map.trackRecorded);
    message.write(' - ');
    message.write(context.t.map.trackDistance(km: distanceKm));

    if (summary.duration.inMinutes > 0) {
      final hours = summary.duration.inHours;
      final minutes = summary.duration.inMinutes.remainder(60);
      final durationStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
      message.write(' - ');
      message.write(context.t.map.trackDuration(duration: durationStr));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toString()),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _zoomToTrailExtent(List<LatLng> coords) {
    if (coords.isEmpty) return;

    if (coords.length == 1) {
      _mapController.move(coords.first, 14);
      return;
    }

    var minLat = coords.first.latitude;
    var maxLat = coords.first.latitude;
    var minLng = coords.first.longitude;
    var maxLng = coords.first.longitude;

    for (final coord in coords) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }

    const padding = 0.005;
    final bounds = LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(48),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Existing bottom sheets (unchanged)
  // ---------------------------------------------------------------------------

  void _showSightingInfo(BuildContext context, dynamic sighting, dynamic species) {
    final isEs = LocaleSettings.currentLocale == AppLocale.es;
    final speciesName = species != null
        ? (isEs ? species.commonNameEs : species.commonNameEn)
        : context.t.map.sightings;
    final dateStr = sighting.observedAt != null
        ? DateFormat.yMMMd(isEs ? 'es' : 'en').format(sighting.observedAt!)
        : null;
    final photoUrl = sighting.photoUrl as String?;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.teal, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    speciesName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            if (species != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  species.scientificName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ),
            if (dateStr != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(dateStr, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            if (sighting.notes != null && (sighting.notes as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  sighting.notes!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (photoUrl != null && photoUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    photoUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDownloadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const MapDownloadSheet(),
    );
  }

  void _showIslandInfo(BuildContext context, dynamic island) {
    final isEs = LocaleSettings.currentLocale == AppLocale.es;
    final islandName = isEs ? (island.nameEs ?? island.nameEn) : island.nameEn;
    final islandDesc = isEs ? (island.descriptionEs ?? island.descriptionEn) : island.descriptionEn;
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(islandName, style: Theme.of(context).textTheme.headlineSmall),
            if (island.areaKm2 != null)
              Text(context.t.map.islandArea(area: '${island.areaKm2}'), style: Theme.of(context).textTheme.bodyMedium),
            if (islandDesc != null) ...[
              const SizedBox(height: 12),
              Text(islandDesc!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

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
  // FIELD EDITING LAYER
  // ---------------------------------------------------------------------------

  /// Build layer showing trail being created/edited.
  /// Switches between Points / Move / Rotate sub-modes.
  Widget _buildFieldEditingLayer() {
    final editState = ref.watch(fieldEditProvider);

    if (editState.mode != FieldEditMode.createTrailManual &&
        editState.mode != FieldEditMode.createTrailGPS &&
        editState.mode != FieldEditMode.editTrailManual &&
        editState.mode != FieldEditMode.editTrailGPS) {
      return const SizedBox.shrink();
    }

    final points = editState.recordingPoints;
    if (points.isEmpty) return const SizedBox.shrink();

    final polyline = PolylineLayer(polylines: [
      Polyline(
        points: points,
        color: Colors.orange,
        strokeWidth: 4.0,
        borderColor: Colors.white,
        borderStrokeWidth: 1.0,
      ),
    ]);

    switch (editState.trailEditSubMode) {
      case TrailEditSubMode.points:
        return Stack(children: [polyline, _buildDraggableTrailPoints(points)]);
      case TrailEditSubMode.move:
        return Stack(children: [polyline, _buildTrailMoveHandle(points)]);
      case TrailEditSubMode.rotate:
        return Stack(children: [polyline, _buildTrailRotateHandles(points)]);
    }
  }

  /// Sub-mode Points: every trail point is a DragMarker.
  /// Tap to toggle selection. Drag a selected point → all selected points move
  /// by the same delta (multi-select move). Long-press = immediate delete.
  Widget _buildDraggableTrailPoints(List<LatLng> points) {
    final notifier = ref.read(fieldEditProvider.notifier);
    final selectedSet = ref.watch(
        fieldEditProvider.select((s) => s.selectedEditPoints));
    final dragMarkers = List.generate(points.length, (i) {
      final isFirst = i == 0;
      final isLast = i == points.length - 1;
      final isSelected = selectedSet.contains(i);
      final baseColor = isFirst ? Colors.green : (isLast ? Colors.red : Colors.orange);
      return DragMarker(
        point: points[i],
        size: const Size(36, 36),
        builder: (context, latLng, isDragging) => Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue.shade600
                : (isDragging ? baseColor.withValues(alpha: 0.7) : baseColor),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.blue.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)]
                : isDragging
                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8)]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 3)],
          ),
          child: Center(
            child: Text(
              '${i + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        onTap: (_) => notifier.selectEditPoint(i),
        onDragStart: (details, latLng) {
          _preDragPoints = [...ref.read(fieldEditProvider).recordingPoints];
          notifier.pushUndoState();
        },
        onDragEnd: (details, latLng) {
          final preDrag = _preDragPoints;
          _preDragPoints = null;
          if (preDrag == null || i >= preDrag.length) return;

          final sel = ref.read(fieldEditProvider).selectedEditPoints;
          if (sel.length > 1 && sel.contains(i)) {
            // Multi-select: apply the same lat/lng delta to all selected points
            final deltaLat = latLng.latitude  - preDrag[i].latitude;
            final deltaLng = latLng.longitude - preDrag[i].longitude;
            final updated = List<LatLng>.from(preDrag);
            for (final idx in sel) {
              if (idx < updated.length) {
                updated[idx] = LatLng(
                  updated[idx].latitude  + deltaLat,
                  updated[idx].longitude + deltaLng,
                );
              }
            }
            notifier.setRecordingPoints(updated);
          } else {
            notifier.updateRecordingPoint(i, latLng);
          }
        },
        onLongPress: (_) {
          notifier.pushUndoState();
          final current = List<LatLng>.from(
            ref.read(fieldEditProvider).recordingPoints,
          );
          if (i >= 0 && i < current.length && current.length > 2) {
            current.removeAt(i);
            notifier.setRecordingPoints(current);
          }
          notifier.clearSelection();
        },
      );
    });
    return DragMarkers(markers: dragMarkers);
  }

  /// Sub-mode Move: a single handle at the centroid translates the entire trail.
  Widget _buildTrailMoveHandle(List<LatLng> points) {
    final centroid = _computeCentroid(points);
    final notifier = ref.read(fieldEditProvider.notifier);

    return DragMarkers(markers: [
      DragMarker(
        point: centroid,
        size: const Size(64, 64),
        builder: (context, latLng, isDragging) => Container(
          decoration: BoxDecoration(
            color: isDragging ? Colors.blue.shade800 : Colors.blue.shade600,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: isDragging ? 0.6 : 0.3),
                blurRadius: isDragging ? 20 : 10,
                spreadRadius: isDragging ? 6 : 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.open_with, color: Colors.white, size: isDragging ? 26 : 24),
              Text(
                'MOVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDragging ? 8 : 7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        onDragStart: (details, latLng) {
          _preDragPoints = [...ref.read(fieldEditProvider).recordingPoints];
          _dragOrigin = latLng;
        },
        onDragUpdate: (details, latLng) {
          final base = _preDragPoints;
          final origin = _dragOrigin;
          if (base == null || origin == null) return;
          notifier.translatePoints(base, latLng.latitude - origin.latitude,
              latLng.longitude - origin.longitude);
        },
        onDragEnd: (details, latLng) {
          final base = _preDragPoints;
          final origin = _dragOrigin;
          if (base != null && origin != null) {
            notifier.translatePoints(base, latLng.latitude - origin.latitude,
                latLng.longitude - origin.longitude);
          }
          _preDragPoints = null;
          _dragOrigin = null;
        },
      ),
    ]);
  }

  /// Sub-mode Rotate: centroid anchor (purple dot) + draggable rotation handle
  /// connected by a dashed arm line.
  ///
  /// Bug fix: [_rotateHandlePos] persists the handle's screen position across
  /// rebuilds so it does not snap back to [handleInitial] every time
  /// [rotatePoints] triggers a provider update mid-drag.
  Widget _buildTrailRotateHandles(List<LatLng> points) {
    final centroid = _computeCentroid(points);
    final notifier = ref.read(fieldEditProvider.notifier);

    // Place handle at 1.5× max radius from centroid, east of centroid.
    // [_rotateHandlePos] overrides this once the user starts dragging.
    double maxDist = 0;
    for (final p in points) {
      final d = math.sqrt(math.pow(p.latitude - centroid.latitude, 2) +
          math.pow(p.longitude - centroid.longitude, 2));
      if (d > maxDist) maxDist = d;
    }
    final handleDist = math.max(maxDist * 1.5, 0.004);
    final handleInitial = LatLng(centroid.latitude, centroid.longitude + handleDist);

    // Use persisted position during/after drag; fall back to computed initial.
    final handlePoint = _rotateHandlePos ?? handleInitial;

    return Stack(
      children: [
        // Arm line from centroid to handle (helps the user find the handle)
        PolylineLayer(polylines: [
          Polyline(
            points: [centroid, handlePoint],
            color: Colors.purple.withValues(alpha: 0.7),
            strokeWidth: 2.0,
          ),
        ]),
        // Static centroid anchor (non-draggable, pure visual anchor)
        MarkerLayer(markers: [
          Marker(
            point: centroid,
            width: 32,
            height: 32,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade700,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.my_location, color: Colors.white, size: 16),
            ),
          ),
        ]),
        // Rotation handle (draggable — drag it around the centroid to rotate)
        DragMarkers(markers: [
          DragMarker(
            point: handlePoint,
            size: const Size(56, 56),
            builder: (context, latLng, isDragging) => Container(
              decoration: BoxDecoration(
                color: isDragging
                    ? Colors.deepPurple.shade700
                    : Colors.purple.shade500,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: isDragging ? 0.6 : 0.3),
                    blurRadius: isDragging ? 20 : 10,
                    spreadRadius: isDragging ? 6 : 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rotate_right, color: Colors.white, size: isDragging ? 22 : 20),
                  Text(
                    'ROTATE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDragging ? 7 : 6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            onDragStart: (details, latLng) {
              _preDragPoints = [...ref.read(fieldEditProvider).recordingPoints];
              _dragOrigin    = latLng;
              _rotateCentroid = _computeCentroid(_preDragPoints!);
              setState(() => _rotateHandlePos = latLng);
            },
            onDragUpdate: (details, latLng) {
              // Update handle position first so the rebuild uses the correct pos
              setState(() => _rotateHandlePos = latLng);
              final base   = _preDragPoints;
              final origin = _dragOrigin;
              final pivot  = _rotateCentroid;
              if (base == null || origin == null || pivot == null) return;
              final angle = _angleBetween(pivot, origin, latLng);
              notifier.rotatePoints(base, pivot, angle);
            },
            onDragEnd: (details, latLng) {
              setState(() => _rotateHandlePos = latLng);
              final base   = _preDragPoints;
              final origin = _dragOrigin;
              final pivot  = _rotateCentroid;
              if (base != null && origin != null && pivot != null) {
                final angle = _angleBetween(pivot, origin, latLng);
                notifier.rotatePoints(base, pivot, angle);
              }
              _preDragPoints  = null;
              _dragOrigin     = null;
              _rotateCentroid = null;
            },
          ),
        ]),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Geometry helpers
  // ---------------------------------------------------------------------------

  LatLng _computeCentroid(List<LatLng> points) {
    final lat = points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final lng = points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
    return LatLng(lat, lng);
  }

  /// Returns the signed angle (in radians) from [pivot→from] to [pivot→to].
  double _angleBetween(LatLng pivot, LatLng from, LatLng to) {
    final a1 = math.atan2(from.latitude - pivot.latitude, from.longitude - pivot.longitude);
    final a2 = math.atan2(to.latitude - pivot.latitude, to.longitude - pivot.longitude);
    return a2 - a1;
  }

  // ---------------------------------------------------------------------------
  // FIELD EDITING METHODS
  // ---------------------------------------------------------------------------

  /// Handle map tap for field editing modes.
  ///
  /// In Points sub-mode: inserts the new point at the closest segment rather
  /// than always appending at the end.  This lets the user add points in the
  /// middle, near the start, or near the end of the trail by simply tapping
  /// the desired location on the map.
  void _handleMapTap(LatLng point) {
    final editState = ref.read(fieldEditProvider);

    // Only handle taps in manual editing modes, and only in Points sub-mode
    if ((editState.mode == FieldEditMode.createTrailManual ||
            editState.mode == FieldEditMode.editTrailManual) &&
        editState.trailEditSubMode == TrailEditSubMode.points) {
      final notifier = ref.read(fieldEditProvider.notifier);
      notifier.clearSelection();
      notifier.pushUndoState();
      final pts = editState.recordingPoints;

      if (pts.length < 2) {
        // Not enough points for segment insertion — just append.
        notifier.addRecordingPoint(point);
      } else {
        // Find the closest segment to the tap position.
        final result = distanceToPolyline(point, pts);

        // When the projection onto a segment is clamped to an endpoint it means
        // the tap is *past* that endpoint, not inside the segment interior.
        // Detect this by checking whether the returned `nearest` point coincides
        // with the first or last trail point (within 1 m floating-point tolerance).
        final atStart = haversineDistance(result.nearest, pts.first) < 1.0;
        final atEnd   = haversineDistance(result.nearest, pts.last)  < 1.0;

        final int insertIdx;
        if (atEnd) {
          insertIdx = pts.length;      // append after last point
        } else if (atStart) {
          insertIdx = 0;               // prepend before first point
        } else {
          insertIdx = result.segmentIndex + 1; // insert inside the closest segment
        }

        final newPts = List<LatLng>.from(pts)..insert(insertIdx, point);
        notifier.setRecordingPoints(newPts);
      }
      notifier.markUnsaved();
    }
  }

  /// Load trail coordinates into editing state.
  ///
  /// Gives immediate snackbar feedback, uses a single [loadPoints] call (not a
  /// loop of [addRecordingPoint]) so it does not mark the trail as unsaved
  /// before the user actually edits anything.
  Future<void> _loadTrailForEditing(int trailId) async {
    _showSnackBar('Loading trail…');
    setState(() => _rotateHandlePos = null); // reset rotate handle for new trail
    try {
      final service = FieldEditService(ref: ref);
      final trail = await service.getTrail(trailId);

      if (!mounted) return;

      if (trail == null) {
        _showSnackBar('❌ Trail not found (id $trailId)');
        return;
      }

      final coords = parseTrailCoordinates(trail.coordinates);

      if (coords.isEmpty) {
        _showSnackBar('❌ Trail has no coordinates');
        return;
      }

      final editNotifier = ref.read(fieldEditProvider.notifier);
      editNotifier.startEditingTrailManual(trailId);
      // Load all points at once — does NOT mark hasUnsavedChanges
      editNotifier.loadPoints(coords);

      _showSnackBar('✅ Trail loaded — use Points / Move / Rotate to edit');
    } catch (e) {
      if (mounted) _showSnackBar('❌ Error loading trail: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

/// Botón circular de zoom con estado deshabilitado cuando se llega al límite.
class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _ZoomButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade200,
        shape: BoxShape.circle,
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 20),
        color: enabled ? Colors.grey.shade700 : Colors.grey.shade400,
        onPressed: onPressed,
      ),
    );
  }
}
