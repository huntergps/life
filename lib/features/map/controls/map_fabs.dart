import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:galapagos_wildlife/models/visit_site.model.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import '../providers/map_download_provider.dart';
import '../providers/map_provider.dart';
import '../presentation/widgets/map_download_sheet.dart';
import 'package:galapagos_wildlife/features/map/sheets/nearby_species_panel.dart';

/// Builds the FAB column for the map (my location, download, stop tracking, nearby species).
class MapFabs extends ConsumerWidget {
  final AsyncValue<dynamic> locationAsync;
  final bool isTracking;
  final List<({LatLng point, DateTime time})> trackPoints;
  final MapDownloadState downloadState;
  final MapController mapController;
  final VoidCallback onStopTracking;

  const MapFabs({
    super.key,
    required this.locationAsync,
    required this.isTracking,
    required this.trackPoints,
    required this.downloadState,
    required this.mapController,
    required this.onStopTracking,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPos = locationAsync.asData?.value;
    final locationLoading = locationAsync is AsyncLoading;

    // Nearby species chip
    final nearbyAsync = ref.watch(nearbyMapSiteProvider);
    final nearbySite = nearbyAsync.asData?.value;
    final nearbySiteSpeciesAsync = nearbySite != null
        ? ref.watch(siteSpeciesProvider(nearbySite.site.id))
        : null;
    final nearbyCount = nearbySiteSpeciesAsync?.asData?.value.length ?? 0;
    final isEs = LocaleSettings.currentLocale == AppLocale.es;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Nearby species chip (appears only when near a site)
        if (nearbySite != null && nearbyCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => _showNearbySpeciesSheet(context, nearbySite.site, isEs),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isEs
                            ? nearbySite.site.nameEs
                            : (nearbySite.site.nameEn ?? nearbySite.site.nameEs),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$nearbyCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // My Location button
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
                          mapController.move(
                            LatLng(userPos.latitude, userPos.longitude),
                            14,
                          );
                        } catch (e) {
                          AppLogger.warning('Go to my location failed: map controller not ready', e);
                        }
                      } else {
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
              onPressed: onStopTracking,
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

  void _showDownloadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const MapDownloadSheet(),
    );
  }

  void _showNearbySpeciesSheet(BuildContext context, VisitSite site, bool isEs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NearbySpeciesPanel(site: site, isEs: isEs),
    );
  }
}
