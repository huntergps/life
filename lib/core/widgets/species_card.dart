import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/core/widgets/favorite_heart_button.dart';
import 'cached_species_image.dart';
import 'conservation_badge.dart';
import '../theme/app_colors.dart';

class SpeciesCard extends StatelessWidget {
  final String commonName;
  final String scientificName;
  final String? thumbnailUrl;
  final String? conservationStatus;
  final bool isEndemic;
  final VoidCallback? onTap;
  final int? speciesId;
  // Extended behavior fields (optional — card degrades gracefully if null)
  final String? dietType;
  final String? activityPattern;
  final String? populationTrend;
  /// When true the image expands to fill all available height (use in
  /// horizontal ListViews where the cross-axis height is fixed by the parent).
  /// When false (default) the image uses a fixed 16:9 AspectRatio.
  final bool expandImage;

  const SpeciesCard({
    super.key,
    required this.commonName,
    required this.scientificName,
    this.thumbnailUrl,
    this.conservationStatus,
    this.isEndemic = false,
    this.onTap,
    this.speciesId,
    this.dietType,
    this.activityPattern,
    this.populationTrend,
    this.expandImage = false,
  });

  // ── Image stack (shared between expandImage and AspectRatio modes) ──────────
  Widget _imageStack(bool hasInfoStrip) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedSpeciesImage(
          imageUrl: thumbnailUrl,
          speciesId: speciesId,
          width: double.infinity,
          height: double.infinity,
          borderRadius: hasInfoStrip
              ? const BorderRadius.vertical(top: Radius.circular(16))
              : BorderRadius.circular(16),
          memCacheWidth: 400,
          memCacheHeight: 225,
        ),
        // Bottom gradient for text readability
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: hasInfoStrip
                  ? const BorderRadius.vertical(top: Radius.circular(16))
                  : BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.35, 1.0],
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
        ),
        // Text overlay on gradient (bottom)
        Positioned(
          left: 8,
          right: speciesId != null ? 36 : 8,
          bottom: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      commonName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isEndemic)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Endemic',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                scientificName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  shadows: [Shadow(blurRadius: 3, color: Colors.black54)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Favorite button (top-right)
        if (speciesId != null)
          Positioned(
            top: 4,
            right: 4,
            child: FavoriteHeartButton(
              speciesId: speciesId!,
              iconSize: 20,
              showBackground: true,
              compact: true,
            ),
          ),
      ],
    );
  }

  // ── Diet icon ──────────────────────────────────────────────────────────────
  IconData _dietIcon(String diet) {
    switch (diet) {
      case 'herbivore':   return Icons.eco_outlined;
      case 'carnivore':   return Icons.set_meal_outlined;
      case 'omnivore':    return Icons.restaurant_outlined;
      case 'piscivore':   return Icons.phishing_outlined;
      case 'insectivore': return Icons.bug_report_outlined;
      case 'nectarivore': return Icons.local_florist_outlined;
      case 'frugivore':   return Icons.apple_outlined;
      default:            return Icons.restaurant_outlined;
    }
  }

  // ── Activity icon ──────────────────────────────────────────────────────────
  IconData _activityIcon(String pattern) {
    switch (pattern) {
      case 'diurnal':    return Icons.wb_sunny_outlined;
      case 'nocturnal':  return Icons.nightlight_outlined;
      case 'crepuscular':return Icons.wb_twilight_outlined;
      default:           return Icons.access_time_outlined;
    }
  }

  // ── Population trend ───────────────────────────────────────────────────────
  IconData _trendIcon(String trend) {
    switch (trend) {
      case 'increasing': return Icons.trending_up;
      case 'stable':     return Icons.trending_flat;
      case 'decreasing': return Icons.trending_down;
      default:           return Icons.remove;
    }
  }

  Color _trendColor(String trend) {
    switch (trend) {
      case 'increasing': return Colors.green;
      case 'stable':     return Colors.amber;
      case 'decreasing': return Colors.red;
      default:           return Colors.grey;
    }
  }

  // ── Short labels for info strip ─────────────────────────────────────────
  String _dietLabel(String diet) {
    switch (diet) {
      case 'herbivore':   return 'Herbív.';
      case 'carnivore':   return 'Carnív.';
      case 'omnivore':    return 'Omnív.';
      case 'piscivore':   return 'Piscív.';
      case 'insectivore': return 'Insect.';
      case 'nectarivore': return 'Néctar.';
      case 'frugivore':   return 'Fruqív.';
      default:            return 'Dieta';
    }
  }

  String _activityLabel(String pattern) {
    switch (pattern) {
      case 'diurnal':     return 'Diurno';
      case 'nocturnal':   return 'Noct.';
      case 'crepuscular': return 'Crepu.';
      default:            return 'Activ.';
    }
  }

  String _trendLabel(String trend) {
    switch (trend) {
      case 'increasing': return 'Aumento';
      case 'stable':     return 'Estable';
      case 'decreasing': return 'Declive';
      default:           return 'Tend.';
    }
  }

  // ── Icon + label chip (icon above text) ─────────────────────────────────
  Widget _buildIconChip(IconData icon, String label, Color color,
      {double iconSize = 20, double fontSize = 8}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: color),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasInfoStrip = conservationStatus != null ||
        dietType != null ||
        activityPattern != null ||
        populationTrend != null;

    return Semantics(
      button: onTap != null,
      label: '$commonName, $scientificName'
          '${conservationStatus != null ? ', conservation status $conservationStatus' : ''}'
          '${isEndemic ? ', endemic species' : ''}',
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: Card(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // expandImage: fill available height (horizontal ListView).
              // default:     shrink-wrap around 16:9 image (grid/list).
              mainAxisSize: expandImage ? MainAxisSize.max : MainAxisSize.min,
              children: [
                // ── Image + gradient overlay ─────────────────────────────────
                // expandImage=true  → Expanded fills all available height
                // expandImage=false → AspectRatio(16:9) fixed height
                if (expandImage)
                  Expanded(child: _imageStack(hasInfoStrip))
                else
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _imageStack(hasInfoStrip),
                  ),

                // ── Info strip: badge left · icon+label chips right ──────────
                if (hasInfoStrip)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (conservationStatus != null) ...[
                          ConservationBadge(status: conservationStatus!, compact: true),
                          const SizedBox(width: 4),
                        ],
                        // Icon+label chips distributed across remaining space
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (dietType != null)
                                _buildIconChip(
                                  _dietIcon(dietType!),
                                  _dietLabel(dietType!),
                                  isDark ? Colors.white60 : Colors.black54,
                                ),
                              if (activityPattern != null)
                                _buildIconChip(
                                  _activityIcon(activityPattern!),
                                  _activityLabel(activityPattern!),
                                  isDark ? Colors.white60 : Colors.black54,
                                ),
                              if (populationTrend != null)
                                _buildIconChip(
                                  _trendIcon(populationTrend!),
                                  _trendLabel(populationTrend!),
                                  _trendColor(populationTrend!),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
