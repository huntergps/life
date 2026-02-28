import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import 'package:galapagos_wildlife/core/widgets/empty_state.dart';
import 'package:galapagos_wildlife/features/badges/models/badge_definition.dart';
import 'package:galapagos_wildlife/features/badges/providers/badges_provider.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(badgeProgressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final crossAxisCount = AdaptiveLayout.gridColumns(context);
    final padding = AdaptiveLayout.responsivePadding(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.t.badges.title)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(badgeProgressProvider);
        },
        child: progressAsync.when(
          data: (badges) {
            if (badges.isEmpty) {
              return ListView(
                children: [
                  EmptyState(
                    icon: Icons.emoji_events_outlined,
                    title: context.t.badges.empty,
                    subtitle: context.t.badges.emptySubtitle,
                  ),
                ],
              );
            }

            final unlocked = badges.where((b) => b.isUnlocked).toList();
            final locked = badges.where((b) => !b.isUnlocked).toList();

            return ListView(
              padding: EdgeInsets.all(padding),
              children: [
                if (unlocked.isNotEmpty) ...[
                  _SectionHeader(
                    '${context.t.badges.unlocked} (${unlocked.length}/${badges.length})',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: unlocked.length,
                    itemBuilder: (context, index) => _BadgeCard(
                      progress: unlocked[index],
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (locked.isNotEmpty) ...[
                  _SectionHeader(
                    '${context.t.badges.locked} (${locked.length})',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: locked.length,
                    itemBuilder: (context, index) => _BadgeCard(
                      progress: locked[index],
                      isDark: isDark,
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 32),
                    Text(context.t.common.error),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(badgeProgressProvider),
                      child: Text(context.t.common.retry),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader(this.title, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.primaryLight : null,
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeProgress progress;
  final bool isDark;

  const _BadgeCard({required this.progress, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final badge = progress.badge;
    final t = Translations.of(context);
    final unlocked = progress.isUnlocked;

    return Card(
      color: unlocked
          ? (isDark
              ? badge.color.withValues(alpha: 0.15)
              : badge.color.withValues(alpha: 0.08))
          : (isDark ? AppColors.darkSurface : null),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unlocked
                    ? badge.color.withValues(alpha: 0.2)
                    : (isDark ? Colors.white10 : Colors.grey.shade200),
                border: unlocked
                    ? Border.all(color: badge.color, width: 2)
                    : null,
              ),
              child: Icon(
                badge.icon,
                size: 28,
                color: unlocked
                    ? badge.color
                    : (isDark ? Colors.white54 : Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 8),
            // Name
            Text(
              badge.name(t),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: unlocked
                    ? null
                    : (isDark ? Colors.white60 : Colors.grey.shade700),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Description
            Text(
              badge.description(t),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Progress
            if (!unlocked) ...[
              SizedBox(
                width: 80,
                child: LinearProgressIndicator(
                  value: progress.progress,
                  backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(badge.color),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.t.badges.progress(
                  current: progress.current.toString(),
                  target: badge.target.toString(),
                ),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
            ] else
              Icon(Icons.check_circle, color: badge.color, size: 20),
          ],
        ),
      ),
    );
  }
}
