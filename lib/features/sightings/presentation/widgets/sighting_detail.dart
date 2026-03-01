import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:galapagos_wildlife/brick/models/sighting.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';

/// Full detail view for a single sighting (used in tablet master-detail layout).
class SightingDetail extends StatelessWidget {
  final Sighting sighting;
  final Species? species;
  final bool isDark;
  final bool isEs;
  final VoidCallback onDelete;

  const SightingDetail({
    super.key,
    required this.sighting,
    required this.species,
    required this.isDark,
    required this.isEs,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = species != null
        ? (isEs ? species!.commonNameEs : species!.commonNameEn)
        : 'Species #${sighting.speciesId}';
    final dateStr = sighting.observedAt != null
        ? DateFormat.yMMMd().add_jm().format(sighting.observedAt!)
        : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo
          if (sighting.photoUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Semantics(
                  label: context.t.sightings.sightingPhoto,
                  image: true,
                  child: Image.network(
                    sighting.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: isDark ? AppColors.darkSurface : Colors.grey[200],
                      child: const Center(
                          child: Icon(Icons.broken_image, size: 48)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Header
          Row(
            children: [
              species?.thumbnailUrl != null
                  ? CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(species!.thumbnailUrl!),
                      onBackgroundImageError: (_, _) {},
                      backgroundColor:
                          isDark ? AppColors.darkSurface : Colors.grey[200],
                      child: Icon(Icons.pets,
                          size: 24,
                          color: isDark ? Colors.white38 : Colors.grey),
                    )
                  : CircleAvatar(
                      radius: 28,
                      backgroundColor: isDark
                          ? AppColors.accentOrange.withValues(alpha: 0.15)
                          : Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.camera_alt,
                        size: 28,
                        color: isDark
                            ? AppColors.accentOrange
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (species != null)
                      Text(
                        species!.scientificName,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color:
                              isDark ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: context.t.sightings.delete,
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          // Notes
          if (sighting.notes != null) ...[
            Text(context.t.sightings.notes,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              sighting.notes!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],
          // Location
          if (sighting.latitude != null && sighting.longitude != null) ...[
            Text(context.t.sightings.location,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '${sighting.latitude!.toStringAsFixed(4)}, ${sighting.longitude!.toStringAsFixed(4)}',
              style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}
