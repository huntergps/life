import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/models/trail.model.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/features/map/presentation/widgets/map_layer_builders.dart';

/// Shows a modal bottom sheet with trail information.
void showTrailInfoSheet({
  required BuildContext context,
  required Trail trail,
  required VoidCallback onStartTracking,
  required VoidCallback onEditTrail,
}) {
  final isEs = LocaleSettings.currentLocale == AppLocale.es;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final trailName = isEs ? trail.nameEs : trail.nameEn;
  final trailDesc = isEs
      ? (trail.descriptionEs ?? trail.descriptionEn)
      : trail.descriptionEn;
  final difficultyColor = trailDifficultyColor(trail.difficulty);
  final difficultyLabel = trailDifficultyLabel(context, trail.difficulty);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trail name with icon
          Row(
            children: [
              Icon(Icons.route, color: difficultyColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trailName,
                  style: Theme.of(sheetContext).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Difficulty badge + stats row
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              // Difficulty chip
              Chip(
                label: Text(
                  difficultyLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: difficultyColor,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              // Distance
              if (trail.distanceKm != null)
                _infoChip(
                  icon: Icons.straighten,
                  label: context.t.map.trailDistance(
                    km: trail.distanceKm!.toStringAsFixed(1),
                  ),
                  isDark: isDark,
                ),
              // Estimated time
              if (trail.estimatedMinutes != null)
                _infoChip(
                  icon: Icons.timer_outlined,
                  label: context.t.map.trailDuration(
                    min: trail.estimatedMinutes!,
                  ),
                  isDark: isDark,
                ),
              // Elevation gain
              if (trail.elevationGainM != null)
                _infoChip(
                  icon: Icons.terrain,
                  label: '${trail.elevationGainM!.toStringAsFixed(0)} m',
                  isDark: isDark,
                ),
            ],
          ),
          // Description
          if (trailDesc != null && trailDesc.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              trailDesc,
              style: Theme.of(sheetContext).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 16),
          // "Follow Trail" button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                onStartTracking();
              },
              icon: const Icon(Icons.navigation),
              label: Text(context.t.map.startTracking),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // "Edit Trail" button -- only for trail owners
          if (trail.userId != null &&
              trail.userId == Supabase.instance.client.auth.currentUser?.id) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  onEditTrail();
                },
                icon: const Icon(Icons.edit_road),
                label: const Text('Editar sendero'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Widget _infoChip({
  required IconData icon,
  required String label,
  required bool isDark,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 16,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        ),
      ),
    ],
  );
}
