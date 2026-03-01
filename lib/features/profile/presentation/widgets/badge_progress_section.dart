import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/features/badges/models/badge_definition.dart';

// ---------------------------------------------------------------------------
// Badge progress section
// ---------------------------------------------------------------------------
class BadgeProgressSection extends StatelessWidget {
  const BadgeProgressSection({
    super.key,
    required this.isDark,
    required this.badgeProgress,
  });

  final bool isDark;
  final List<BadgeProgress> badgeProgress;

  @override
  Widget build(BuildContext context) {
    final unlockedCount = badgeProgress.where((p) => p.isUnlocked).length;
    final totalBadges = badgeProgress.length;

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
              // Header row
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: isDark ? Colors.amber : Colors.amber.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.t.badges.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    context.t.auth.badgesUnlocked(
                      count: unlockedCount,
                      total: totalBadges,
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Badge icons row
              if (badgeProgress.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      context.t.auth.noBadgesYet,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: badgeProgress.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final bp = badgeProgress[index];
                      final unlocked = bp.isUnlocked;
                      return Tooltip(
                        message: bp.badge.name(context.t),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: unlocked
                                ? bp.badge.color.withValues(alpha: 0.15)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey.withValues(alpha: 0.1)),
                            border: Border.all(
                              color: unlocked
                                  ? bp.badge.color.withValues(alpha: 0.4)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.2)),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            bp.badge.icon,
                            size: 20,
                            color: unlocked
                                ? bp.badge.color
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.4)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              // "View All Badges" button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.goNamed('badges'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? AppColors.primaryLight.withValues(alpha: 0.3)
                          : AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(context.t.auth.viewAllBadges),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
