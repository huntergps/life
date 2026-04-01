import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:galapagos_wildlife/models/island.model.dart';
import 'package:galapagos_wildlife/models/visit_site.model.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import '../providers/map_filters_provider.dart';

/// Shows the site filter bottom sheet (phone layout).
void showSiteFilterSheet({
  required BuildContext context,
  required WidgetRef ref,
  required AsyncValue<List<VisitSite>> sitesAsync,
  required AsyncValue<List<Island>> islandsAsync,
  required MapController mapController,
}) {
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
      final nA = isEs ? a.nameEs : a.nameEn;
      final nB = isEs ? b.nameEs : b.nameEn;
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
                      final name = isEs ? island.nameEs : island.nameEn;
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
                            mapController.move(
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
