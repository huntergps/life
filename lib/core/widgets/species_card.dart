import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/widgets/favorite_heart_button.dart';
import 'package:galapagos_wildlife/features/species/providers/species_identification_provider.dart';
import 'cached_species_image.dart';
import 'conservation_badge.dart';
import '../theme/app_colors.dart';
import '../utils/species_display_helpers.dart';

class SpeciesCard extends ConsumerWidget {
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
  Widget _imageStack(bool hasInfoStrip, bool hasAiRecognition) {
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
              gradient: kCardGradient,
            ),
          ),
        ),
        // AI badge (top-left)
        if (hasAiRecognition)
          Positioned(
            top: 6,
            left: 6,
            child: aiBadge(),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasInfoStrip = conservationStatus != null ||
        dietType != null ||
        activityPattern != null ||
        populationTrend != null;
    final aiNames = ref.watch(aiRecognizedSpeciesProvider).asData?.value ?? {};
    final hasAiRecognition = aiNames.contains(scientificName.toLowerCase());

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
                  Expanded(child: _imageStack(hasInfoStrip, hasAiRecognition))
                else
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _imageStack(hasInfoStrip, hasAiRecognition),
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
                                  dietIcon(dietType!),
                                  dietLabel(dietType!),
                                  isDark ? Colors.white60 : Colors.black54,
                                ),
                              if (activityPattern != null)
                                _buildIconChip(
                                  activityIcon(activityPattern!),
                                  activityLabel(activityPattern!),
                                  isDark ? Colors.white60 : Colors.black54,
                                ),
                              if (populationTrend != null)
                                _buildIconChip(
                                  trendIcon(populationTrend!),
                                  trendLabel(populationTrend!),
                                  trendColor(populationTrend!),
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
