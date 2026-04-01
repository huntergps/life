import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import 'package:galapagos_wildlife/models/island.model.dart';
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
import '../../sheets/site_filter_sheet.dart';

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

  // Site position overrides for drag editing
  final Map<int, LatLng> _sitePositionOverrides = {};

  // Field editing layer builder (holds drag state)
  final FieldEditingLayerBuilder _fieldEditBuilder = FieldEditingLayerBuilder();

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
      onStopTracking: _stopTracking,
    );

    if (isTablet) {
      return _buildTabletLayout(
        context, isDark, isEs, islandsAsync, sitesAsync, trailsAsync,
        mapWithOverlays, fabs,
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
              child: Text(context.t.map.title, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
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
            IconButton(
              icon: Icon(Icons.tune, color: hasFilter ? AppColors.accentOrange : null),
              tooltip: context.t.map.filterSites,
              onPressed: () => showSiteFilterSheet(
                context: context,
                ref: ref,
                sitesAsync: sitesAsync,
                islandsAsync: islandsAsync,
                mapController: _mapController,
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? AppColors.darkBackground : null,
      ),
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
        ? islandsData.where((i) => i.id == selectedIslandId).map((i) => isEs ? i.nameEs : i.nameEn).firstOrNull
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
              child: Text(context.t.map.title, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 16),
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
          // Left panel - islands, visit sites, and trails list
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (value) => ref.read(mapFiltersProvider.notifier).setSearchQuery(value),
                  ),
                ),
                // Selected island indicator
                if (ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId)) != null)
                  _buildSelectedIslandIndicator(context, isDark, isEs, islandsAsync),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      _buildIslandsList(context, isDark, isEs, islandsAsync),
                      const Divider(),
                      if (ref.watch(mapFiltersProvider.select((f) => f.showSites)) || ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId)) != null)
                        _buildSitesList(context, isDark, isEs, sitesAsync),
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
          // Right panel - map
          Expanded(
            child: Stack(
              children: [
                mapWidget,
                Positioned(right: 16, bottom: 16, child: fabs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedIslandIndicator(
    BuildContext context,
    bool isDark,
    bool isEs,
    AsyncValue<dynamic> islandsAsync,
  ) {
    return islandsAsync.when(
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
            border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.filter_alt, size: 16, color: AppColors.accentOrange),
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
                  Icons.close, size: 16,
                  color: isDark ? Colors.white70 : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildIslandsList(
    BuildContext context,
    bool isDark,
    bool isEs,
    AsyncValue<dynamic> islandsAsync,
  ) {
    return islandsAsync.when(
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
                final islandName = isEs ? i.nameEs : i.nameEn;
                return islandName.toLowerCase().contains(searchQuery.toLowerCase());
              })
              .map((island) {
                final islandName = isEs ? island.nameEs : island.nameEn;
                final selectedIslandId = ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId));
                final isSelected = selectedIslandId == island.id;
                return ListTile(
                  dense: true,
                  selected: isSelected,
                  selectedTileColor: isDark
                      ? AppColors.accentOrange.withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  leading: Icon(
                    Icons.terrain, size: 20,
                    color: isSelected ? AppColors.accentOrange : (isDark ? AppColors.primaryLight : null),
                  ),
                  title: Text(
                    islandName,
                    style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : null),
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
    );
  }

  Widget _buildSitesList(
    BuildContext context,
    bool isDark,
    bool isEs,
    AsyncValue<dynamic> sitesAsync,
  ) {
    return sitesAsync.when(
      data: (sites) {
        final selectedIslandId = ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId));
        final selectedMonitoringType = ref.watch(mapFiltersProvider.select((f) => f.selectedMonitoringType));
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
                leading: const Icon(Icons.place, size: 20, color: AppColors.accentOrange),
                title: Text(siteName, style: const TextStyle(fontSize: 14)),
                subtitle: site.monitoringType != null
                    ? Text(site.monitoringType!, style: const TextStyle(fontSize: 12, color: AppColors.accentOrange))
                    : null,
                onTap: () => _mapController.move(LatLng(site.latitude!, site.longitude!), 13),
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
        final filteredTrails = selectedIslandId != null
            ? trails.where((t) => t.islandId == selectedIslandId).toList()
            : trails;

        if (filteredTrails.isEmpty) {
          if (selectedIslandId != null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.t.map.noTrails, style: Theme.of(context).textTheme.bodyMedium),
          );
        }

        final islandsData = islandsAsync.asData?.value as List<dynamic>?;
        final islandNameMap = <int, String>{};
        if (islandsData != null) {
          for (final island in islandsData) {
            final name = isEs ? (island.nameEs ?? island.nameEn) : island.nameEn;
            islandNameMap[island.id as int] = name;
          }
        }

        final grouped = <int?, List<Trail>>{};
        for (final trail in filteredTrails) {
          grouped.putIfAbsent(trail.islandId, () => []).add(trail);
        }
        final sortedKeys = grouped.keys.toList()
          ..sort((a, b) { if (a == null) return 1; if (b == null) return -1; return a.compareTo(b); });

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
    final color = trailDifficultyColor(trail.difficulty);
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
        if (coords.isNotEmpty) _zoomToTrailExtent(coords);
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
    final tileModeStr = tileMode.name; // 'vector'|'satellite'|'hybrid'|'street'

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
            isWithinViewport: _isWithinViewport,
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
            isWithinViewport: _isWithinViewport,
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
                onPressed: _safeGetZoom() >= 19 ? null : () {
                  try {
                    final zoom = _safeGetZoom();
                    _mapController.move(_mapController.camera.center, (zoom + 1).clamp(6, 19));
                  } catch (e) {
                    AppLogger.warning('Zoom in failed: map controller not ready', e);
                  }
                },
              ),
              const SizedBox(height: 8),
              ZoomButton(
                icon: Icons.remove,
                onPressed: _safeGetZoom() <= 6 ? null : () {
                  try {
                    final zoom = _safeGetZoom();
                    _mapController.move(_mapController.camera.center, (zoom - 1).clamp(6, 19));
                  } catch (e) {
                    AppLogger.warning('Zoom out failed: map controller not ready', e);
                  }
                },
              ),
            ],
          ),
        ),
        // Compass indicator
        if (_safeGetRotation() != 0)
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
                  angle: _safeGetRotation() * (3.14159 / 180),
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
            .where((Island i) => i.latitude != null && i.longitude != null)
            .where((Island i) => _isWithinViewport(i.latitude, i.longitude))
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
        onStartTracking: () => _startTrackingTrail(trail),
        onEditTrail: () => _loadTrailForEditing(trail.id),
      ),
      onSelectTrailForEdit: (id) => _loadTrailForEditing(id),
    );
  }

  // ---------------------------------------------------------------------------
  // MapController helpers
  // ---------------------------------------------------------------------------

  double _safeGetZoom() {
    try { return _mapController.camera.zoom; } catch (e) { return AppConstants.galapagosDefaultZoom; }
  }

  double _safeGetRotation() {
    try { return _mapController.camera.rotation; } catch (e) { return 0.0; }
  }

  // ---------------------------------------------------------------------------
  // Viewport culling helper
  // ---------------------------------------------------------------------------

  bool _isWithinViewport(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    try {
      final camera = _mapController.camera;
      final bounds = camera.visibleBounds;
      final latBuffer = (bounds.north - bounds.south) * 0.1;
      final lngBuffer = (bounds.east - bounds.west) * 0.1;
      return lat >= bounds.south - latBuffer &&
             lat <= bounds.north + latBuffer &&
             lng >= bounds.west - lngBuffer &&
             lng <= bounds.east + lngBuffer;
    } catch (e) {
      return true;
    }
  }

  // ---------------------------------------------------------------------------
  // Bottom sheet helpers (delegate to extracted modules)
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
  // Tracking actions
  // ---------------------------------------------------------------------------

  void _startTrackingTrail(Trail trail) {
    final coords = parseTrailCoordinates(trail.coordinates);
    if (coords.isEmpty) return;
    _trackingService = TrackingService(ref);
    _trackingService!.startTracking(coords);
    _zoomToTrailExtent(coords);
  }

  void _stopTracking() {
    if (_trackingService == null) {
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
      SnackBar(content: Text(message.toString()), duration: const Duration(seconds: 4)),
    );
  }

  void _zoomToTrailExtent(List<LatLng> coords) {
    if (coords.isEmpty) return;
    if (coords.length == 1) { _mapController.move(coords.first, 14); return; }

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
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)));
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
