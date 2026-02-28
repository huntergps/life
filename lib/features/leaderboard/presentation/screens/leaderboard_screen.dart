import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import 'package:galapagos_wildlife/core/widgets/empty_state.dart';
import 'package:galapagos_wildlife/features/leaderboard/providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.leaderboard.title),
        backgroundColor: isDark ? AppColors.darkBackground : null,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(leaderboardProvider);
        },
        child: leaderboardAsync.when(
          data: (entries) {
            if (entries.isEmpty) {
              return ListView(
                children: [
                  EmptyState(
                    icon: Icons.leaderboard_outlined,
                    title: context.t.leaderboard.empty,
                  ),
                ],
              );
            }

            final content = ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: AdaptiveLayout.responsivePadding(context),
                vertical: 8,
              ),
              itemCount: entries.length + 1, // +1 for the header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _LeaderboardHeader(
                    entries: entries,
                    isDark: isDark,
                  );
                }
                final entry = entries[index - 1];
                final isCurrentUser = entry.userId == currentUserId;
                return _LeaderboardTile(
                  entry: entry,
                  isDark: isDark,
                  isCurrentUser: isCurrentUser,
                );
              },
            );

            return AdaptiveLayout.constrainedContent(
              maxWidth: 700,
              child: content,
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
                      onPressed: () => ref.invalidate(leaderboardProvider),
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

class _LeaderboardHeader extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final bool isDark;

  const _LeaderboardHeader({
    required this.entries,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final topEntry = entries.first;
    final topColor = isDark ? Colors.amber : Colors.amber.shade700;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 48, color: topColor),
          const SizedBox(height: 8),
          Text(
            context.t.leaderboard.topExplorer,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: topColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _truncateEmail(topEntry.email),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          Text(
            '${topEntry.totalSightings} ${context.t.leaderboard.sightings}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? AppColors.darkBorder : null),
          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    context.t.leaderboard.rank,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    context.t.auth.email,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    context.t.leaderboard.sightings,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    context.t.leaderboard.species,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isDark;
  final bool isCurrentUser;

  const _LeaderboardTile({
    required this.entry,
    required this.isDark,
    required this.isCurrentUser,
  });

  Color? _rankColor(int rank) {
    return switch (rank) {
      1 => Colors.amber,
      2 => Colors.grey.shade400,
      3 => const Color(0xFFCD7F32), // bronze
      _ => null,
    };
  }

  IconData? _rankIcon(int rank) {
    return switch (rank) {
      1 => Icons.emoji_events,
      2 => Icons.emoji_events,
      3 => Icons.emoji_events,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _rankColor(entry.rank);
    final rankIcon = _rankIcon(entry.rank);

    final bgColor = isCurrentUser
        ? (isDark
            ? AppColors.primaryLight.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.06))
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: isCurrentUser
            ? Border.all(
                color: isDark
                    ? AppColors.primaryLight.withValues(alpha: 0.3)
                    : AppColors.primary.withValues(alpha: 0.2),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 40,
              child: rankIcon != null
                  ? Icon(rankIcon, color: rankColor, size: 24)
                  : Text(
                      '${entry.rank}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
            ),
            // Email + "You" label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _truncateEmail(entry.email),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentUser
                          ? (isDark ? AppColors.primaryLight : AppColors.primary)
                          : (isDark ? Colors.white : null),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isCurrentUser)
                    Text(
                      context.t.leaderboard.you,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            // Sightings count
            SizedBox(
              width: 60,
              child: Text(
                '${entry.totalSightings}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: rankColor ?? (isDark ? Colors.white70 : null),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Species count
            SizedBox(
              width: 60,
              child: Text(
                '${entry.uniqueSpecies}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Truncates email to show only the part before @ plus a few characters of the domain.
String _truncateEmail(String email) {
  final atIndex = email.indexOf('@');
  if (atIndex < 0 || email.length <= 25) return email;
  final localPart = email.substring(0, atIndex);
  final domain = email.substring(atIndex);
  if (localPart.length > 15) {
    return '${localPart.substring(0, 12)}...${domain.length > 10 ? domain.substring(0, 10) : domain}';
  }
  return email.length > 25 ? '${email.substring(0, 22)}...' : email;
}
