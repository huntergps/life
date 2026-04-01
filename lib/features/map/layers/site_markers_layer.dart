import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:galapagos_wildlife/models/visit_site.model.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import '../providers/field_edit_provider.dart';
import '../providers/map_filters_provider.dart';
import '../providers/map_provider.dart';
import '../services/field_edit_service.dart';

/// Builds the site markers layer (regular non-drag view).
Widget buildSiteMarkersLayer({
  required AsyncValue sitesAsync,
  required bool isEs,
  required FieldEditState editState,
  required WidgetRef ref,
  required BuildContext context,
  required bool Function(double?, double?) isWithinViewport,
  required void Function(VisitSite site) onShowSiteInfo,
}) {
  return sitesAsync.when(
    data: (sites) {
      // Single selected site draggable (legacy moveSiteManual)
      if (editState.mode == FieldEditMode.moveSiteManual &&
          editState.selectedSiteId != null) {
        final dragMarkers = <DragMarker>[];
        final regularMarkers = <Marker>[];

        for (final site in sites) {
          if (site.latitude == null || site.longitude == null) continue;
          if (!isWithinViewport(site.latitude, site.longitude)) continue;
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
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$siteName moved'), duration: const Duration(seconds: 1)),
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
                onTap: () => onShowSiteInfo(site),
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

      // Normal view: only show tourist-active sites, apply island + type filter.
      final selectedIslandId = ref.watch(mapFiltersProvider.select((f) => f.selectedIslandId));
      final selectedMonitoringType = ref.watch(mapFiltersProvider.select((f) => f.selectedMonitoringType));
      return MarkerLayer(
        markers: sites
            .where((s) => s.status == 'active' || s.status == null)
            .where((s) => selectedIslandId == null || s.islandId == selectedIslandId)
            .where((s) => selectedMonitoringType == null || s.monitoringType == selectedMonitoringType)
            .where((s) => s.latitude != null && s.longitude != null)
            .where((s) => isWithinViewport(s.latitude, s.longitude))
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
                    onTap: () => onShowSiteInfo(site),
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

/// Builds the drag markers layer for moveSitesDrag mode.
/// Rendered last so it sits on top of all other layers.
Widget buildSiteDragMarkersLayer({
  required AsyncValue sitesAsync,
  required bool isEs,
  required WidgetRef ref,
  required BuildContext context,
  required Map<int, LatLng> sitePositionOverrides,
  required void Function(int siteId, LatLng newPos) onSiteDragged,
}) {
  return sitesAsync.when(
    data: (sites) {
      final dragMarkers = sites
          .where((s) => s.id != null && s.latitude != null && s.longitude != null)
          .map<DragMarker>((site) {
            final siteName = isEs ? site.nameEs : (site.nameEn ?? site.nameEs);
            final point = sitePositionOverrides[site.id!] ??
                LatLng(site.latitude!, site.longitude!);
            final wasMoved = sitePositionOverrides.containsKey(site.id!);
            return DragMarker(
              point: point,
              size: const Size(52, 52),
              offset: const Offset(0, -26),
              builder: (context, latLng, isDragging) {
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
                onSiteDragged(site.id!, latLng);
                final service = FieldEditService(ref: ref);
                await service.updateVisitSiteLocation(
                  siteId: site.id!,
                  newLatitude: latLng.latitude,
                  newLongitude: latLng.longitude,
                );
                ref.invalidate(visitSitesProvider);
                ref.read(fieldEditProvider.notifier).markUnsaved();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$siteName moved'),
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
