import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:galapagos_wildlife/brick/models/sighting.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Recent activity section
// ---------------------------------------------------------------------------
class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({
    super.key,
    required this.isDark,
    required this.sightings,
    required this.speciesMap,
    required this.isEs,
  });

  final bool isDark;
  final List<Sighting> sightings;
  final Map<int, Species> speciesMap;
  final bool isEs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: isDark ? AppColors.darkCard : Colors.white,
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark
              ? BorderSide(color: AppColors.darkBorder)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.t.auth.recentActivity,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (sightings.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      context.t.auth.noRecentSightings,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                    ),
                  ),
                )
              else
                ...sightings.map((s) {
                  final species = speciesMap[s.speciesId];
                  final name = species != null
                      ? (isEs ? species.commonNameEs : species.commonNameEn)
                      : 'Species #${s.speciesId}';
                  final date = s.observedAt != null
                      ? DateFormat.yMMMd(isEs ? 'es' : 'en')
                          .format(s.observedAt!)
                      : '';
                  final hasPhoto = s.photoUrl != null;

                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: isDark
                          ? AppColors.primaryLight.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.08),
                      child: Icon(
                        hasPhoto ? Icons.photo_camera : Icons.visibility,
                        size: 16,
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      date,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    onTap: () => context.go('/sightings'),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
