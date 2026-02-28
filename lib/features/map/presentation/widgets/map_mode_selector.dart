import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import '../../providers/pmtiles_provider.dart';

class MapModeSelector extends ConsumerWidget {
  const MapModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(mapTileModeProvider);
    final pmtilesAvailable = ref.watch(pmtilesAvailableProvider);
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.t.map;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.layers,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                t.mapModes,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Street mode (always available)
          _MapModeTile(
            mode: MapTileMode.street,
            title: t.modeStreet,
            subtitle: t.modeStreetDesc,
            icon: Icons.map_outlined,
            isSelected: currentMode == MapTileMode.street,
            isAvailable: true,
            onTap: () {
              ref.read(mapTileModeProvider.notifier).state = MapTileMode.street;
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 8),

          // Vector mode (requires PMTiles download)
          _MapModeTile(
            mode: MapTileMode.vector,
            title: t.modeVector,
            subtitle: t.modeVectorDesc,
            icon: Icons.layers,
            isSelected: currentMode == MapTileMode.vector,
            isAvailable: pmtilesAvailable.asData?.value ?? false,
            requiresDownload: !(pmtilesAvailable.asData?.value ?? false),
            onTap: () {
              final available = pmtilesAvailable.asData?.value ?? false;
              if (available) {
                ref.read(mapTileModeProvider.notifier).state = MapTileMode.vector;
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.baseMapNotDownloaded),
                    action: SnackBarAction(
                      label: t.downloadBaseMap,
                      onPressed: () {
                        Navigator.of(context).pop();
                        // TODO: Open download sheet
                      },
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 8),

          // Satellite mode (requires login)
          _MapModeTile(
            mode: MapTileMode.satellite,
            title: t.modeSatellite,
            subtitle: t.modeSatelliteDesc,
            icon: Icons.satellite_alt,
            isSelected: currentMode == MapTileMode.satellite,
            isAvailable: isLoggedIn,
            requiresLogin: !isLoggedIn,
            onTap: () {
              if (isLoggedIn) {
                ref.read(mapTileModeProvider.notifier).state = MapTileMode.satellite;
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.loginRequiredForSatellite)),
                );
              }
            },
          ),
          const SizedBox(height: 8),

          // Hybrid mode (requires login)
          _MapModeTile(
            mode: MapTileMode.hybrid,
            title: t.modeHybrid,
            subtitle: t.modeHybridDesc,
            icon: Icons.map,
            isSelected: currentMode == MapTileMode.hybrid,
            isAvailable: isLoggedIn,
            requiresLogin: !isLoggedIn,
            onTap: () {
              if (isLoggedIn) {
                ref.read(mapTileModeProvider.notifier).state = MapTileMode.hybrid;
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.loginRequiredForSatellite)),
                );
              }
            },
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _MapModeTile extends StatelessWidget {
  final MapTileMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool isAvailable;
  final bool requiresLogin;
  final bool requiresDownload;
  final VoidCallback onTap;

  const _MapModeTile({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.isAvailable,
    this.requiresLogin = false,
    this.requiresDownload = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = isAvailable;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppColors.primaryLight.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.1))
                : (isDark ? AppColors.darkCard : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark
                      ? AppColors.darkBorder
                      : Colors.grey.shade300),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? AppColors.primaryLight.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.15))
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? (isDark ? AppColors.primaryLight : AppColors.primary)
                      : (isEnabled
                          ? (isDark ? Colors.white70 : Colors.grey.shade700)
                          : Colors.grey.shade400),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isEnabled
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : Colors.grey.shade500,
                              ),
                        ),
                        if (requiresLogin) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: Colors.orange.shade700,
                          ),
                        ] else if (requiresDownload) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.download_outlined,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isEnabled
                                ? (isDark ? Colors.white54 : Colors.grey.shade600)
                                : Colors.grey.shade500,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Check mark if selected
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
