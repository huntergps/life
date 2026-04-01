import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import '../sheets/island_info_sheet.dart';
import '../utils/viewport_helpers.dart';

/// Builds the island name label markers layer.
///
/// Each island that has lat/lng and is within the current viewport gets a
/// tappable label that opens the island info bottom sheet.
Widget buildIslandMarkersLayer({
  required AsyncValue<dynamic> islandsAsync,
  required bool isEs,
  required bool isDark,
  required BuildContext context,
  required MapController mapController,
}) {
  return islandsAsync.when(
    data: (islands) => MarkerLayer(
      markers: islands
          .where((island) => island.latitude != null && island.longitude != null)
          .where((island) => isWithinViewport(mapController, island.latitude, island.longitude))
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
