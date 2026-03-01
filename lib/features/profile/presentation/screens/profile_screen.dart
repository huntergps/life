import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import 'package:galapagos_wildlife/core/constants/countries.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';
import 'package:galapagos_wildlife/features/badges/providers/badges_provider.dart';
import 'package:galapagos_wildlife/features/badges/models/badge_definition.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sightings_provider.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:galapagos_wildlife/features/profile/providers/profile_provider.dart';
import 'package:galapagos_wildlife/features/profile/providers/profile_stats_provider.dart';
import 'package:galapagos_wildlife/features/profile/presentation/widgets/badge_progress_section.dart';
import 'package:galapagos_wildlife/features/profile/presentation/widgets/recent_activity_section.dart';
import 'package:galapagos_wildlife/brick/models/sighting.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/user_profile.model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.auth.profile),
        backgroundColor: isDark ? AppColors.darkBackground : null,
      ),
      body: isAuthenticated
          ? _AuthenticatedProfile(isDark: isDark)
          : _UnauthenticatedProfile(isDark: isDark),
    );
  }
}

// ---------------------------------------------------------------------------
// Unauthenticated state
// ---------------------------------------------------------------------------
class _UnauthenticatedProfile extends StatelessWidget {
  const _UnauthenticatedProfile({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: isDark
                  ? AppColors.primaryLight.withValues(alpha: 0.4)
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              context.t.auth.signInToViewProfile,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.pushNamed('login'),
              icon: const Icon(Icons.login),
              label: Text(context.t.auth.signIn),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pushNamed('login'),
              child: Text(
                context.t.auth.signUpPrompt,
                style: TextStyle(
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Authenticated profile
// ---------------------------------------------------------------------------
class _AuthenticatedProfile extends ConsumerWidget {
  const _AuthenticatedProfile({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sightingsAsync = ref.watch(sightingsProvider);
    final speciesMapAsync = ref.watch(speciesLookupProvider);
    final badgesAsync = ref.watch(badgeProgressProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final locale = ref.watch(localeProvider);
    final isEs = locale == 'es';
    final isTablet = AdaptiveLayout.isTablet(context);

    final statsAsync = ref.watch(profileStatsProvider);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (stats) {
        final speciesMap = speciesMapAsync.asData?.value ?? {};
        final badgeProgress = badgesAsync.asData?.value ?? [];
        final profile = profileAsync.asData?.value;
        final sightings = sightingsAsync.asData?.value ?? [];

        // Level
        final level = _levelLabel(context, stats.totalSightings);
        final levelIcon = _levelIcon(stats.totalSightings);

        // Recent sightings (last 5)
        final recent = sightings.take(5).toList();

        if (isTablet) {
          return _TabletLayout(
            isDark: isDark,
            level: level,
            levelIcon: levelIcon,
            totalSightings: stats.totalSightings,
            speciesSeen: stats.uniqueSpecies,
            islandsVisited: stats.uniqueSites,
            photosTaken: stats.photosCount,
            profile: profile,
            badgeProgress: badgeProgress,
            recentSightings: recent,
            speciesMap: speciesMap,
            isEs: isEs,
            onEdit: () => _showEditDialog(context, ref, profile),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            _ProfileHeader(
              isDark: isDark,
              level: level,
              levelIcon: levelIcon,
              totalSightings: stats.totalSightings,
              profile: profile,
              onEdit: () => _showEditDialog(context, ref, profile),
            ),
            const SizedBox(height: 12),
            _StatsRow(
              isDark: isDark,
              totalSightings: stats.totalSightings,
              speciesSeen: stats.uniqueSpecies,
              islandsVisited: stats.uniqueSites,
              photosTaken: stats.photosCount,
            ),
            const SizedBox(height: 16),
            BadgeProgressSection(
              isDark: isDark,
              badgeProgress: badgeProgress,
            ),
            const SizedBox(height: 16),
            RecentActivitySection(
              isDark: isDark,
              sightings: recent,
              speciesMap: speciesMap,
              isEs: isEs,
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, UserProfile? profile) {
    final isTablet = AdaptiveLayout.isTablet(context);
    if (isTablet) {
      // Side sheet on tablet
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Edit Profile',
        barrierColor: Colors.black38,
        pageBuilder: (ctx, anim1, anim2) {
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              elevation: 8,
              child: SizedBox(
                width: 420,
                child: _EditProfilePanel(
                  profile: profile,
                  onSaved: () => ref.invalidate(userProfileProvider),
                ),
              ),
            ),
          );
        },
        transitionBuilder: (ctx, anim1, anim2, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      );
    } else {
      // Bottom sheet on phone
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => _EditProfileSheet(
          profile: profile,
          onSaved: () => ref.invalidate(userProfileProvider),
        ),
      );
    }
  }

  String _levelLabel(BuildContext context, int total) {
    if (total >= 50) return context.t.auth.expert;
    if (total >= 20) return context.t.auth.advanced;
    if (total >= 5) return context.t.auth.intermediate;
    return context.t.auth.beginner;
  }

  IconData _levelIcon(int total) {
    if (total >= 50) return Icons.star;
    if (total >= 20) return Icons.eco;
    if (total >= 5) return Icons.explore;
    return Icons.nature_people;
  }
}

// ---------------------------------------------------------------------------
// Tablet two-column layout
// ---------------------------------------------------------------------------
class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.isDark,
    required this.level,
    required this.levelIcon,
    required this.totalSightings,
    required this.speciesSeen,
    required this.islandsVisited,
    required this.photosTaken,
    required this.profile,
    required this.badgeProgress,
    required this.recentSightings,
    required this.speciesMap,
    required this.isEs,
    required this.onEdit,
  });

  final bool isDark;
  final String level;
  final IconData levelIcon;
  final int totalSightings;
  final int speciesSeen;
  final int islandsVisited;
  final int photosTaken;
  final UserProfile? profile;
  final List<BadgeProgress> badgeProgress;
  final List<Sighting> recentSightings;
  final Map<int, Species> speciesMap;
  final bool isEs;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout.constrainedContent(
      maxWidth: 1000,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column — avatar, name, level, edit
          SizedBox(
            width: 340,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _LargeProfileCard(
                  isDark: isDark,
                  level: level,
                  levelIcon: levelIcon,
                  totalSightings: totalSightings,
                  profile: profile,
                  onEdit: onEdit,
                ),
                const SizedBox(height: 16),
                _StatsGrid(
                  isDark: isDark,
                  totalSightings: totalSightings,
                  speciesSeen: speciesSeen,
                  islandsVisited: islandsVisited,
                  photosTaken: photosTaken,
                ),
              ],
            ),
          ),
          // Right column — badges, recent
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 16, 16, 32),
              children: [
                BadgeProgressSection(
                  isDark: isDark,
                  badgeProgress: badgeProgress,
                ),
                const SizedBox(height: 16),
                RecentActivitySection(
                  isDark: isDark,
                  sightings: recentSightings,
                  speciesMap: speciesMap,
                  isEs: isEs,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Large profile card for tablet left column
// ---------------------------------------------------------------------------
class _LargeProfileCard extends StatelessWidget {
  const _LargeProfileCard({
    required this.isDark,
    required this.level,
    required this.levelIcon,
    required this.totalSightings,
    required this.profile,
    required this.onEdit,
  });

  final bool isDark;
  final String level;
  final IconData levelIcon;
  final int totalSightings;
  final UserProfile? profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';
    final createdAt = user?.createdAt != null
        ? DateTime.tryParse(user!.createdAt)
        : null;
    final memberSinceText = createdAt != null
        ? context.t.auth.memberSince(
            date: DateFormat.yMMMM(
              Localizations.localeOf(context).languageCode,
            ).format(createdAt),
          )
        : '';
    final displayName = profile?.displayName;
    final levelColor = _levelColor(totalSightings, isDark);
    final avatarUrl = profile?.avatarUrl;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.darkCard, AppColors.darkSurface]
              : [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.background,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          // Large avatar
          _AvatarWidget(
            avatarUrl: avatarUrl,
            radius: 56,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          if (displayName != null && displayName.isNotEmpty)
            Text(
              displayName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            email,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (memberSinceText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              memberSinceText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
            ),
          ],
          const SizedBox(height: 10),
          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: levelColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(levelIcon, size: 16, color: levelColor),
                const SizedBox(width: 4),
                Text(
                  level,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: levelColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(context.t.auth.editProfile),
            ),
          ),
        ],
      ),
    );
  }

  Color _levelColor(int total, bool isDark) {
    if (total >= 50) return Colors.amber.shade600;
    if (total >= 20) return AppColors.primaryLight;
    if (total >= 5) return Colors.blue;
    return isDark ? Colors.white60 : Colors.grey.shade600;
  }
}

// ---------------------------------------------------------------------------
// Stats grid (2x2) for tablet
// ---------------------------------------------------------------------------
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.isDark,
    required this.totalSightings,
    required this.speciesSeen,
    required this.islandsVisited,
    required this.photosTaken,
  });

  final bool isDark;
  final int totalSightings;
  final int speciesSeen;
  final int islandsVisited;
  final int photosTaken;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _StatChip(
              isDark: isDark,
              icon: Icons.visibility,
              iconColor: AppColors.primary,
              label: context.t.sightings.totalSightings,
              value: '$totalSightings',
            ),
            const SizedBox(width: 8),
            _StatChip(
              isDark: isDark,
              icon: Icons.pets,
              iconColor: Colors.teal,
              label: context.t.auth.speciesSeen,
              value: '$speciesSeen',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _StatChip(
              isDark: isDark,
              icon: Icons.sailing,
              iconColor: Colors.cyan,
              label: context.t.auth.islandsVisited,
              value: '$islandsVisited',
            ),
            const SizedBox(width: 8),
            _StatChip(
              isDark: isDark,
              icon: Icons.photo_camera,
              iconColor: Colors.orange,
              label: context.t.auth.photosTaken,
              value: '$photosTaken',
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar widget with optional upload overlay
// ---------------------------------------------------------------------------
class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({
    required this.avatarUrl,
    required this.radius,
    required this.isDark,
  });

  final String? avatarUrl;
  final double radius;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: isDark
          ? AppColors.primaryLight.withValues(alpha: 0.15)
          : AppColors.primary.withValues(alpha: 0.1),
      backgroundImage:
          avatarUrl != null && avatarUrl!.isNotEmpty ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null || avatarUrl!.isEmpty
          ? Icon(
              Icons.person,
              size: radius * 1.1,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Header — compact: avatar + name/email + member since + level badge in a row
// ---------------------------------------------------------------------------
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.isDark,
    required this.level,
    required this.levelIcon,
    required this.totalSightings,
    required this.profile,
    required this.onEdit,
  });

  final bool isDark;
  final String level;
  final IconData levelIcon;
  final int totalSightings;
  final UserProfile? profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';
    final createdAt = user?.createdAt != null
        ? DateTime.tryParse(user!.createdAt)
        : null;
    final memberSinceText = createdAt != null
        ? context.t.auth.memberSince(
            date: DateFormat.yMMMM(
              Localizations.localeOf(context).languageCode,
            ).format(createdAt),
          )
        : '';

    final displayName = profile?.displayName;
    final levelColor = _levelColor(totalSightings, isDark);
    final avatarUrl = profile?.avatarUrl;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.darkCard, AppColors.darkSurface]
              : [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.background,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          _AvatarWidget(
            avatarUrl: avatarUrl,
            radius: 32,
            isDark: isDark,
          ),
          const SizedBox(width: 14),
          // Name / email / member since
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (displayName != null && displayName.isNotEmpty)
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (memberSinceText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    memberSinceText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                  ),
                ],
                const SizedBox(height: 6),
                // Level badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: levelColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(levelIcon, size: 14, color: levelColor),
                      const SizedBox(width: 4),
                      Text(
                        level,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: levelColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Edit button
          IconButton(
            onPressed: onEdit,
            icon: Icon(
              Icons.edit_outlined,
              size: 20,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            tooltip: context.t.auth.editProfile,
          ),
        ],
      ),
    );
  }

  Color _levelColor(int total, bool isDark) {
    if (total >= 50) return Colors.amber.shade600;
    if (total >= 20) return AppColors.primaryLight;
    if (total >= 5) return Colors.blue;
    return isDark ? Colors.white60 : Colors.grey.shade600;
  }
}

// ---------------------------------------------------------------------------
// Stats row — 4 stats in a single horizontal row
// ---------------------------------------------------------------------------
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.isDark,
    required this.totalSightings,
    required this.speciesSeen,
    required this.islandsVisited,
    required this.photosTaken,
  });

  final bool isDark;
  final int totalSightings;
  final int speciesSeen;
  final int islandsVisited;
  final int photosTaken;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatChip(
            isDark: isDark,
            icon: Icons.visibility,
            iconColor: AppColors.primary,
            label: context.t.sightings.totalSightings,
            value: '$totalSightings',
          ),
          const SizedBox(width: 8),
          _StatChip(
            isDark: isDark,
            icon: Icons.pets,
            iconColor: Colors.teal,
            label: context.t.auth.speciesSeen,
            value: '$speciesSeen',
          ),
          const SizedBox(width: 8),
          _StatChip(
            isDark: isDark,
            icon: Icons.sailing,
            iconColor: Colors.cyan,
            label: context.t.auth.islandsVisited,
            value: '$islandsVisited',
          ),
          const SizedBox(width: 8),
          _StatChip(
            isDark: isDark,
            icon: Icons.photo_camera,
            iconColor: Colors.orange,
            label: context.t.auth.photosTaken,
            value: '$photosTaken',
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: isDark ? AppColors.darkCard : Colors.white,
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isDark
              ? BorderSide(color: AppColors.darkBorder)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// Edit profile side panel (tablet)
// ---------------------------------------------------------------------------
class _EditProfilePanel extends StatefulWidget {
  const _EditProfilePanel({required this.profile, required this.onSaved});
  final UserProfile? profile;
  final VoidCallback onSaved;

  @override
  State<_EditProfilePanel> createState() => _EditProfilePanelState();
}

class _EditProfilePanelState extends State<_EditProfilePanel> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  DateTime? _birthDate;
  String? _country;
  String? _countryCode;
  String? _avatarUrl;
  bool _saving = false;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile?.displayName ?? '');
    _bioCtrl = TextEditingController(text: widget.profile?.bio ?? '');
    _birthDate = widget.profile?.birthDate;
    _country = widget.profile?.country;
    _countryCode = widget.profile?.countryCode;
    _avatarUrl = widget.profile?.avatarUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    setState(() => _uploadingAvatar = true);
    try {
      final url = await pickAndUploadAvatar(user.id);
      if (url != null && mounted) {
        setState(() => _avatarUrl = url);
        // Also update the profile immediately
        await updateProfile(userId: user.id, avatarUrl: url);
        widget.onSaved();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.t.auth.avatarUpdated)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime(2020, 12, 31),
      helpText: context.t.auth.selectBirthday,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      await updateProfile(
        userId: user.id,
        displayName: _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        birthDate: _birthDate,
        country: _country,
        countryCode: _countryCode,
        avatarUrl: _avatarUrl,
      );
      widget.onSaved();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.auth.profileUpdated)),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.auth.editProfile),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar
          Center(
            child: GestureDetector(
              onTap: _uploadingAvatar ? null : _pickAvatar,
              child: Stack(
                children: [
                  _AvatarWidget(
                    avatarUrl: _avatarUrl,
                    radius: 48,
                    isDark: isDark,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: _uploadingAvatar
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              context.t.auth.tapToChangePhoto,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: context.t.auth.displayName,
              border: const OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioCtrl,
            decoration: InputDecoration(
              labelText: context.t.auth.bio,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          // Birthday picker
          InkWell(
            onTap: _pickBirthDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: context.t.auth.birthday,
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today, size: 20),
              ),
              child: Text(
                _birthDate != null
                    ? DateFormat.yMMMd(
                        Localizations.localeOf(context).languageCode,
                      ).format(_birthDate!)
                    : context.t.auth.selectBirthday,
                style: TextStyle(
                  color: _birthDate != null
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Country picker
          _CountryAutocomplete(
            initialCountryCode: _countryCode,
            initialCountryName: _country,
            isDark: isDark,
            onSelected: (item) {
              setState(() {
                _country = item.nameEn;
                _countryCode = item.code;
              });
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.t.auth.saveProfile),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit profile bottom sheet (phone)
// ---------------------------------------------------------------------------
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.profile, required this.onSaved});
  final UserProfile? profile;
  final VoidCallback onSaved;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  DateTime? _birthDate;
  String? _country;
  String? _countryCode;
  String? _avatarUrl;
  bool _saving = false;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile?.displayName ?? '');
    _bioCtrl = TextEditingController(text: widget.profile?.bio ?? '');
    _birthDate = widget.profile?.birthDate;
    _country = widget.profile?.country;
    _countryCode = widget.profile?.countryCode;
    _avatarUrl = widget.profile?.avatarUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    setState(() => _uploadingAvatar = true);
    try {
      final url = await pickAndUploadAvatar(user.id);
      if (url != null && mounted) {
        setState(() => _avatarUrl = url);
        await updateProfile(userId: user.id, avatarUrl: url);
        widget.onSaved();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.t.auth.avatarUpdated)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime(2020, 12, 31),
      helpText: context.t.auth.selectBirthday,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      await updateProfile(
        userId: user.id,
        displayName: _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        birthDate: _birthDate,
        country: _country,
        countryCode: _countryCode,
        avatarUrl: _avatarUrl,
      );
      widget.onSaved();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.auth.profileUpdated)),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.t.auth.editProfile,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
            ),
            const SizedBox(height: 16),
            // Avatar
            Center(
              child: GestureDetector(
                onTap: _uploadingAvatar ? null : _pickAvatar,
                child: Stack(
                  children: [
                    _AvatarWidget(
                      avatarUrl: _avatarUrl,
                      radius: 40,
                      isDark: isDark,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: _uploadingAvatar
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: context.t.auth.displayName,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bioCtrl,
              decoration: InputDecoration(
                labelText: context.t.auth.bio,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            // Birthday picker
            InkWell(
              onTap: _pickBirthDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: context.t.auth.birthday,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today, size: 20),
                ),
                child: Text(
                  _birthDate != null
                      ? DateFormat.yMMMd(
                          Localizations.localeOf(context).languageCode,
                        ).format(_birthDate!)
                      : context.t.auth.selectBirthday,
                  style: TextStyle(
                    color: _birthDate != null
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white38 : Colors.black38),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Country picker
            _CountryAutocomplete(
              initialCountryCode: _countryCode,
              initialCountryName: _country,
              isDark: isDark,
              onSelected: (item) {
                setState(() {
                  _country = item.nameEn;
                  _countryCode = item.code;
                });
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.t.auth.saveProfile),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Country autocomplete widget
// ---------------------------------------------------------------------------
class _CountryAutocomplete extends StatefulWidget {
  const _CountryAutocomplete({
    required this.initialCountryCode,
    required this.initialCountryName,
    required this.isDark,
    required this.onSelected,
  });

  final String? initialCountryCode;
  final String? initialCountryName;
  final bool isDark;
  final void Function(CountryItem) onSelected;

  @override
  State<_CountryAutocomplete> createState() => _CountryAutocompleteState();
}

class _CountryAutocompleteState extends State<_CountryAutocomplete> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set initial text based on locale (safe to access context here)
    if (_ctrl.text.isEmpty) {
      String initial = '';
      if (widget.initialCountryCode != null) {
        final match = Countries.all
            .where((c) => c.code == widget.initialCountryCode)
            .firstOrNull;
        if (match != null) {
          final isEs =
              Localizations.localeOf(context).languageCode == 'es';
          initial = isEs ? match.nameEs : match.nameEn;
        }
      }
      if (initial.isEmpty && widget.initialCountryName != null) {
        initial = widget.initialCountryName!;
      }
      if (initial.isNotEmpty) _ctrl.text = initial;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Autocomplete<CountryItem>(
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.toLowerCase();
        if (query.isEmpty) return Countries.all;
        return Countries.all.where((c) =>
            c.nameEn.toLowerCase().contains(query) ||
            c.nameEs.toLowerCase().contains(query) ||
            c.code.toLowerCase() == query);
      },
      displayStringForOption: (item) =>
          isEs ? item.nameEs : item.nameEn,
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        // Sync initial text
        if (controller.text.isEmpty && _ctrl.text.isNotEmpty) {
          controller.text = _ctrl.text;
        }
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: context.t.auth.country,
            hintText: context.t.auth.selectCountry,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.arrow_drop_down, size: 20),
          ),
          textCapitalization: TextCapitalization.words,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250, maxWidth: 360),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final item = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(isEs ? item.nameEs : item.nameEn),
                    subtitle: Text(
                      item.code,
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () => onSelected(item),
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: (item) {
        _ctrl.text = isEs ? item.nameEs : item.nameEn;
        widget.onSelected(item);
      },
    );
  }
}
