import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/models/island.model.dart';
import 'package:galapagos_wildlife/models/visit_site.model.dart';

import '../providers/map_filters_provider.dart';
import '../providers/map_provider.dart';
import '../sheets/site_filter_sheet.dart';

/// Phone layout: full-width map with an AppBar, filter bar, and FABs.
class MapPhoneLayout extends ConsumerWidget {
  const MapPhoneLayout({
    super.key,
    required this.isDark,
    required this.mapWidget,
    required this.fabs,
    required this.sitesAsync,
    required this.islandsAsync,
    required this.mapController,
    required this.onBuildTileModeToggle,
  });

  final bool isDark;
  final Widget mapWidget;
  final Widget fabs;
  final AsyncValue<List<VisitSite>> sitesAsync;
  final AsyncValue<List<Island>> islandsAsync;
  final MapController mapController;
  final Widget Function(BuildContext context) onBuildTileModeToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIslandId =
        ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId));
    final selectedMonitoringType = ref
        .watch(mapFiltersProvider.select((f) => f.selectedMonitoringType));
    final showTrails =
        ref.watch(mapFiltersProvider.select((f) => f.showTrails));
    final showSites =
        ref.watch(mapFiltersProvider.select((f) => f.showSites));
    final showSightings =
        ref.watch(mapFiltersProvider.select((f) => f.showSightings));
    final hasFilter =
        selectedIslandId != null || selectedMonitoringType != null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child:
                  Text(context.t.map.title, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            onBuildTileModeToggle(context),
            IconButton(
              icon:
                  Icon(showTrails ? Icons.route : Icons.route_outlined),
              onPressed: () =>
                  ref.read(mapFiltersProvider.notifier).toggleTrails(),
              tooltip: context.t.map.toggleTrails,
            ),
            IconButton(
              icon: Icon(
                  showSites ? Icons.location_on : Icons.location_off),
              onPressed: () =>
                  ref.read(mapFiltersProvider.notifier).toggleSites(),
              tooltip: context.t.map.toggleSites,
            ),
            IconButton(
              icon: Icon(
                showSightings
                    ? Icons.camera_alt
                    : Icons.camera_alt_outlined,
                color: showSightings ? Colors.teal : null,
              ),
              onPressed: () =>
                  ref.read(mapFiltersProvider.notifier).toggleSightings(),
              tooltip: context.t.map.toggleSightings,
            ),
            IconButton(
              icon: Icon(Icons.tune,
                  color: hasFilter ? AppColors.accentOrange : null),
              tooltip: context.t.map.filterSites,
              onPressed: () => showSiteFilterSheet(
                context: context,
                ref: ref,
                sitesAsync: sitesAsync,
                islandsAsync: islandsAsync,
                mapController: mapController,
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? AppColors.darkBackground : null,
      ),
      body: Column(
        children: [
          if (hasFilter)
            _ActiveFilterBar(isDark: isDark, sitesAsync: sitesAsync),
          Expanded(child: mapWidget),
        ],
      ),
      floatingActionButton: fabs,
    );
  }
}

// ---------------------------------------------------------------------------
// Thin banner showing the active filters + a clear button.
// ---------------------------------------------------------------------------

class _ActiveFilterBar extends ConsumerWidget {
  const _ActiveFilterBar({
    required this.isDark,
    required this.sitesAsync,
  });

  final bool isDark;
  final AsyncValue<List<VisitSite>> sitesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIslandId =
        ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId));
    final selectedMonitoringType = ref
        .watch(mapFiltersProvider.select((f) => f.selectedMonitoringType));
    final allSites = sitesAsync.asData?.value ?? [];
    final count = allSites
        .where((s) => s.status == 'active' || s.status == null)
        .where(
            (s) => selectedIslandId == null || s.islandId == selectedIslandId)
        .where((s) =>
            selectedMonitoringType == null ||
            s.monitoringType == selectedMonitoringType)
        .where((s) => s.latitude != null)
        .length;

    final islandsData =
        ref.read(islandsProvider).asData?.value ?? [];
    final isEs = LocaleSettings.currentLocale == AppLocale.es;
    final islandName = selectedIslandId != null
        ? islandsData
            .where((i) => i.id == selectedIslandId)
            .map((i) => isEs ? i.nameEs : i.nameEn)
            .firstOrNull
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
              '${parts.join(' \u00b7 ')} \u2014 $count sitios',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref
                  .read(mapFiltersProvider.notifier)
                  .setSelectedIsland(null);
              ref
                  .read(mapFiltersProvider.notifier)
                  .setMonitoringType(null);
            },
            child: Icon(Icons.close,
                size: 16, color: AppColors.accentOrange),
          ),
        ],
      ),
    );
  }
}
