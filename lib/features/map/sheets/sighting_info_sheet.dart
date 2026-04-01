import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';

/// Shows a modal bottom sheet with sighting information.
void showSightingInfoSheet({
  required BuildContext context,
  required dynamic sighting,
  required dynamic species,
}) {
  final isEs = LocaleSettings.currentLocale == AppLocale.es;
  final speciesName = species != null
      ? (isEs ? species.commonNameEs : species.commonNameEn)
      : context.t.map.sightings;
  final dateStr = sighting.observedAt != null
      ? DateFormat.yMMMd(isEs ? 'es' : 'en').format(sighting.observedAt!)
      : null;
  final photoUrl = sighting.photoUrl as String?;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  speciesName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          if (species != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                species.scientificName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ),
          if (dateStr != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(dateStr, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          if (sighting.notes != null && (sighting.notes as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                sighting.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (photoUrl != null && photoUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  photoUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
