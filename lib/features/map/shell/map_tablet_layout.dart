import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/models/island.model.dart';
import 'package:galapagos_wildlife/models/trail.model.dart';
import 'package:latlong2/latlong.dart';

import '../presentation/widgets/map_layer_builders.dart' show trailDifficultyColor;
import '../providers/map_filters_provider.dart';
import '../utils/route_utils.dart';

/// Tablet layout: sidebar (islands + sites + trails) on the left, map on the right.
class MapTabletLayout extends ConsumerWidget {
  const MapTabletLayout({
    super.key,
    required this.isDark,
    required this.isEs,
    required this.islandsAsync,
    required this.sitesAsync,
    required this.trailsAsync,
    required this.mapWidget,
    required this.fabs,
    required this.mapController,
    required this.onBuildTileModeToggle,
    required this.onZoomToTrailExtent,
  });

  final bool isDark;
  final bool isEs;
  final AsyncValue<dynamic> islandsAsync;
  final AsyncValue<dynamic> sitesAsync;
  final AsyncValue<List<Trail>> trailsAsync;
  final Widget mapWidget;
  final Widget fabs;
  final MapController mapController;
  final Widget Function(BuildContext context) onBuildTileModeToggle;
  final void Function(List<LatLng> coords) onZoomToTrailExtent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child:
                  Text(context.t.map.title, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 16),
            onBuildTileModeToggle(context),
            IconButton(
              icon: Icon(ref.watch(mapFiltersProvider
                      .select((f) => f.showTrails))
                  ? Icons.route
                  : Icons.route_outlined),
              onPressed: () =>
                  ref.read(mapFiltersProvider.notifier).toggleTrails(),
              tooltip: context.t.map.toggleTrails,
            ),
            IconButton(
              icon: Icon(ref.watch(mapFiltersProvider
                      .select((f) => f.showSites))
                  ? Icons.location_on
                  : Icons.location_off),
              onPressed: () =>
                  ref.read(mapFiltersProvider.notifier).toggleSites(),
              tooltip: context.t.map.toggleSites,
            ),
            IconButton(
              icon: Icon(
                ref.watch(mapFiltersProvider
                        .select((f) => f.showSightings))
                    ? Icons.camera_alt
                    : Icons.camera_alt_outlined,
                color: ref.watch(mapFiltersProvider
                        .select((f) => f.showSightings))
                    ? Colors.teal
                    : null,
              ),
              onPressed: () =>
                  ref.read(mapFiltersProvider.notifier).toggleSightings(),
              tooltip: context.t.map.toggleSightings,
            ),
          ],
        ),
        backgroundColor: isDark ? AppColors.darkBackground : null,
      ),
      body: Row(
        children: [
          // Left panel — sidebar
          SizedBox(
            width: MediaQuery.sizeOf(context).width *
                AppConstants.mapSidebarWidthFraction,
            child: Column(
              children: [
                // Search
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: context.t.search.hint,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (value) => ref
                        .read(mapFiltersProvider.notifier)
                        .setSearchQuery(value),
                  ),
                ),
                // Selected island indicator
                if (ref.watch(mapFiltersProvider
                        .select((f) => f.selectedIslandId)) !=
                    null)
                  _SelectedIslandIndicator(
                    isDark: isDark,
                    isEs: isEs,
                    islandsAsync: islandsAsync,
                  ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      _IslandsSidebarSection(
                        isDark: isDark,
                        isEs: isEs,
                        islandsAsync: islandsAsync,
                        mapController: mapController,
                      ),
                      const Divider(),
                      if (ref.watch(mapFiltersProvider
                              .select((f) => f.showSites)) ||
                          ref.watch(mapFiltersProvider.select(
                                  (f) => f.selectedIslandId)) !=
                              null)
                        _SitesSidebarSection(
                          isDark: isDark,
                          isEs: isEs,
                          sitesAsync: sitesAsync,
                          mapController: mapController,
                        ),
                      if (ref.watch(mapFiltersProvider
                          .select((f) => f.showTrails))) ...[
                        const Divider(),
                        _TrailsSidebarSection(
                          isDark: isDark,
                          isEs: isEs,
                          trailsAsync: trailsAsync,
                          islandsAsync: islandsAsync,
                          onZoomToTrailExtent: onZoomToTrailExtent,
                        ),
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
          // Right panel — map
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
}

// ---------------------------------------------------------------------------
// Selected island indicator chip
// ---------------------------------------------------------------------------

class _SelectedIslandIndicator extends ConsumerWidget {
  const _SelectedIslandIndicator({
    required this.isDark,
    required this.isEs,
    required this.islandsAsync,
  });

  final bool isDark;
  final bool isEs;
  final AsyncValue<dynamic> islandsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return islandsAsync.when(
      data: (islands) {
        final selectedIslandId = ref
            .watch(mapFiltersProvider.select((f) => f.selectedIslandId));
        final selectedIsland = islands.firstWhere(
          (Island i) => i.id == selectedIslandId,
          orElse: () => islands.first as Island,
        );
        final islandName =
            isEs ? (selectedIsland.nameEs ?? selectedIsland.nameEn) : selectedIsland.nameEn;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.accentOrange.withValues(alpha: 0.2)
                : Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.accentOrange.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.filter_alt,
                  size: 16, color: AppColors.accentOrange),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  islandName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white
                            : Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => ref
                    .read(mapFiltersProvider.notifier)
                    .setSelectedIsland(null),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isDark
                      ? Colors.white70
                      : Theme.of(context).colorScheme.onPrimaryContainer,
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
}

// ---------------------------------------------------------------------------
// Islands list
// ---------------------------------------------------------------------------

class _IslandsSidebarSection extends ConsumerWidget {
  const _IslandsSidebarSection({
    required this.isDark,
    required this.isEs,
    required this.islandsAsync,
    required this.mapController,
  });

  final bool isDark;
  final bool isEs;
  final AsyncValue<dynamic> islandsAsync;
  final MapController mapController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return islandsAsync.when(
      data: (islands) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
            child: Text(
              context.t.map.islands,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isDark
                        ? AppColors.accentOrange
                        : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...islands
              .where((Island i) => i.latitude != null && i.longitude != null)
              .where((Island i) {
            final searchQuery = ref
                .watch(mapFiltersProvider.select((f) => f.searchQuery));
            if (searchQuery.isEmpty) return true;
            final islandName = isEs ? i.nameEs : i.nameEn;
            return islandName
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
          }).map((island) {
            final islandName = isEs ? island.nameEs : island.nameEn;
            final selectedIslandId = ref.watch(
                mapFiltersProvider.select((f) => f.selectedIslandId));
            final isSelected = selectedIslandId == island.id;
            return ListTile(
              dense: true,
              selected: isSelected,
              selectedTileColor: isDark
                  ? AppColors.accentOrange.withValues(alpha: 0.15)
                  : Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.3),
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
                    fontWeight: isSelected ? FontWeight.w600 : null),
              ),
              subtitle: island.areaKm2 != null
                  ? Text('${island.areaKm2} km\u00B2',
                      style: const TextStyle(fontSize: 12))
                  : null,
              onTap: () {
                ref
                    .read(mapFiltersProvider.notifier)
                    .setSelectedIsland(isSelected ? null : island.id);
                mapController.move(
                    LatLng(island.latitude!, island.longitude!), 11);
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
}

// ---------------------------------------------------------------------------
// Sites list
// ---------------------------------------------------------------------------

class _SitesSidebarSection extends ConsumerWidget {
  const _SitesSidebarSection({
    required this.isDark,
    required this.isEs,
    required this.sitesAsync,
    required this.mapController,
  });

  final bool isDark;
  final bool isEs;
  final AsyncValue<dynamic> sitesAsync;
  final MapController mapController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return sitesAsync.when(
      data: (sites) {
        final selectedIslandId = ref
            .watch(mapFiltersProvider.select((f) => f.selectedIslandId));
        final selectedMonitoringType = ref.watch(
            mapFiltersProvider.select((f) => f.selectedMonitoringType));
        final visibleSites = sites
            .where((s) => s.status == 'active' || s.status == null)
            .where((s) =>
                selectedIslandId == null || s.islandId == selectedIslandId)
            .where((s) =>
                selectedMonitoringType == null ||
                s.monitoringType == selectedMonitoringType)
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
                      color: isDark
                          ? AppColors.accentOrange
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...visibleSites.map((site) {
              final siteName =
                  isEs ? site.nameEs : (site.nameEn ?? site.nameEs);
              return ListTile(
                dense: true,
                leading: const Icon(Icons.place,
                    size: 20, color: AppColors.accentOrange),
                title:
                    Text(siteName, style: const TextStyle(fontSize: 14)),
                subtitle: site.monitoringType != null
                    ? Text(site.monitoringType!,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.accentOrange))
                    : null,
                onTap: () => mapController.move(
                    LatLng(site.latitude!, site.longitude!), 13),
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
}

// ---------------------------------------------------------------------------
// Trails sidebar section — grouped by island
// ---------------------------------------------------------------------------

class _TrailsSidebarSection extends ConsumerWidget {
  const _TrailsSidebarSection({
    required this.isDark,
    required this.isEs,
    required this.trailsAsync,
    required this.islandsAsync,
    required this.onZoomToTrailExtent,
  });

  final bool isDark;
  final bool isEs;
  final AsyncValue<List<Trail>> trailsAsync;
  final AsyncValue<dynamic> islandsAsync;
  final void Function(List<LatLng> coords) onZoomToTrailExtent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return trailsAsync.when(
      data: (trails) {
        final selectedIslandId = ref
            .watch(mapFiltersProvider.select((f) => f.selectedIslandId));
        final filteredTrails = selectedIslandId != null
            ? trails
                .where((t) => t.islandId == selectedIslandId)
                .toList()
            : trails;

        if (filteredTrails.isEmpty) {
          if (selectedIslandId != null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.t.map.noTrails,
                style: Theme.of(context).textTheme.bodyMedium),
          );
        }

        final islandsData =
            islandsAsync.asData?.value as List<dynamic>?;
        final islandNameMap = <int, String>{};
        if (islandsData != null) {
          for (final island in islandsData) {
            final name = isEs
                ? (island.nameEs ?? island.nameEn)
                : island.nameEn;
            islandNameMap[island.id as int] = name;
          }
        }

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
                      color: isDark
                          ? AppColors.accentOrange
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            for (final islandId in sortedKeys) ...[
              if (ref.watch(mapFiltersProvider
                          .select((f) => f.selectedIslandId)) ==
                      null &&
                  islandId != null &&
                  islandNameMap.containsKey(islandId))
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 2),
                  child: Text(
                    islandNameMap[islandId]!,
                    style:
                        Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                ),
              for (final trail in grouped[islandId]!)
                _buildTrailTile(context, trail),
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

  Widget _buildTrailTile(BuildContext context, Trail trail) {
    final trailName = isEs ? trail.nameEs : trail.nameEn;
    final color = trailDifficultyColor(trail.difficulty);
    return ListTile(
      dense: true,
      leading: Icon(Icons.route, size: 20, color: color),
      title: Text(trailName, style: const TextStyle(fontSize: 14)),
      subtitle: trail.distanceKm != null
          ? Text(
              context.t.map.trailDistance(
                  km: trail.distanceKm!.toStringAsFixed(1)),
              style: const TextStyle(fontSize: 12),
            )
          : null,
      onTap: () {
        final coords = parseTrailCoordinates(trail.coordinates);
        if (coords.isNotEmpty) onZoomToTrailExtent(coords);
      },
    );
  }
}
