import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/widgets/favorite_heart_button.dart';
import 'cached_species_image.dart';
import '../theme/app_colors.dart';
import '../utils/species_display_helpers.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:galapagos_wildlife/features/species/providers/species_identification_provider.dart';

/// Card designed for grid/list views (species list & favorites).
/// Shows a 16:9 image on top with name overlay, then a 2-column attribute
/// grid below with icon · label · value for each attribute.
class SpeciesListCard extends ConsumerWidget {
  final String commonName;
  final String scientificName;
  final String? thumbnailUrl;
  final String? conservationStatus;
  final bool isEndemic;
  final VoidCallback? onTap;
  final int? speciesId;
  final String? dietType;
  final String? activityPattern;
  final String? populationTrend;

  const SpeciesListCard({
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
  });

  Widget _buildIucnBadge() {
    final color = conservationStatusColor(conservationStatus!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        conservationStatus!,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }


  // ── Image + name overlay ──────────────────────────────────────────────────
  Widget _buildImageStack(bool hasAiRecognition) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedSpeciesImage(
          imageUrl: thumbnailUrl,
          speciesId: speciesId,
          width: double.infinity,
          height: double.infinity,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          memCacheWidth: 600,
          memCacheHeight: 338,
        ),
        // Bottom gradient
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: kCardGradient,
            ),
          ),
        ),
        // IUCN + AI badges (top-left, stacked vertically)
        Positioned(
          top: 6,
          left: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (conservationStatus != null) _buildIucnBadge(),
              if (hasAiRecognition) ...[
                if (conservationStatus != null) const SizedBox(height: 4),
                aiBadge(),
              ],
            ],
          ),
        ),
        // Name + endemic badge
        Positioned(
          left: 10,
          right: speciesId != null ? 44 : 10,
          bottom: 10,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isEndemic)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Endemic',
                        style: TextStyle(
                          fontSize: 10,
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
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  shadows: [Shadow(blurRadius: 3, color: Colors.black54)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Favorite button
        if (speciesId != null)
          Positioned(
            top: 6,
            right: 6,
            child: FavoriteHeartButton(
              speciesId: speciesId!,
              iconSize: 22,
              showBackground: true,
              compact: true,
            ),
          ),
      ],
    );
  }

  // ── Single attribute cell: icon · label · value ───────────────────────────
  Widget _buildCell({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Status cell: colored code badge · label · full name ───────────────────
  Widget _buildStatusCell({
    required String status,
    required bool isEs,
    required Color labelColor,
    required Color valueColor,
  }) {
    final color = conservationStatusColor(status);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEs ? 'ESTADO' : 'STATUS',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  conservationStatusLabel(status, spanish: isEs),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2-column attribute grid ───────────────────────────────────────────────
  Widget _buildAttributeGrid(bool isEs, bool isDark) {
    final labelColor = isDark ? Colors.white38 : Colors.black38;
    final valueColor = isDark ? Colors.white : Colors.black87;
    final iconColor  = isDark ? Colors.white60 : Colors.black54;

    // Build ordered list of cells (only non-null)
    final cells = <Widget>[];

    if (conservationStatus != null) {
      cells.add(_buildStatusCell(
        status: conservationStatus!,
        isEs: isEs,
        labelColor: labelColor,
        valueColor: valueColor,
      ));
    }

    if (dietType != null) {
      cells.add(_buildCell(
        icon: dietIcon(dietType!),
        iconColor: iconColor,
        label: isEs ? 'DIETA' : 'DIET',
        value: dietLabel(dietType!, spanish: isEs),
        labelColor: labelColor,
        valueColor: valueColor,
      ));
    }

    if (activityPattern != null) {
      cells.add(_buildCell(
        icon: activityIcon(activityPattern!),
        iconColor: iconColor,
        label: isEs ? 'ACTIVIDAD' : 'ACTIVITY',
        value: activityLabel(activityPattern!, spanish: isEs),
        labelColor: labelColor,
        valueColor: valueColor,
      ));
    }

    if (populationTrend != null) {
      cells.add(_buildCell(
        icon: trendIcon(populationTrend!),
        iconColor: trendColor(populationTrend!),
        label: isEs ? 'TENDENCIA' : 'TREND',
        value: trendLabel(populationTrend!, spanish: isEs),
        labelColor: labelColor,
        valueColor: trendColor(populationTrend!),
      ));
    }

    if (cells.isEmpty) return const SizedBox.shrink();

    // Arrange cells in rows of 2 with dividers
    final dividerColor = isDark ? Colors.white12 : Colors.black12;
    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 2) {
      if (i > 0) rows.add(Divider(height: 1, color: dividerColor));
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: cells[i]),
            if (i + 1 < cells.length) ...[
              VerticalDivider(width: 1, color: dividerColor),
              Expanded(child: cells[i + 1]),
            ] else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale  = ref.watch(localeProvider);
    final isEs    = locale == 'es';
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final aiNames = ref.watch(aiRecognizedSpeciesProvider).asData?.value ?? {};
    final hasAiRecognition = aiNames.contains(scientificName.toLowerCase());

    return Semantics(
      button: onTap != null,
      label: '$commonName, $scientificName'
          '${conservationStatus != null ? ', estado $conservationStatus' : ''}'
          '${isEndemic ? ', especie endémica' : ''}',
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: Card(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildImageStack(hasAiRecognition),
                ),
                _buildAttributeGrid(isEs, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
