import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';

/// Shows a modal bottom sheet with island information.
void showIslandInfoSheet({
  required BuildContext context,
  required dynamic island,
}) {
  final isEs = LocaleSettings.currentLocale == AppLocale.es;
  final islandName = isEs ? (island.nameEs ?? island.nameEn) : island.nameEn;
  final islandDesc = isEs ? (island.descriptionEs ?? island.descriptionEn) : island.descriptionEn;
  showModalBottomSheet(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(islandName, style: Theme.of(context).textTheme.headlineSmall),
          if (island.areaKm2 != null)
            Text(context.t.map.islandArea(area: '${island.areaKm2}'), style: Theme.of(context).textTheme.bodyMedium),
          if (islandDesc != null) ...[
            const SizedBox(height: 12),
            Text(islandDesc!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
