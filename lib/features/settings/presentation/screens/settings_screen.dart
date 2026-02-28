import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import '../../providers/settings_provider.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';
import 'package:galapagos_wildlife/features/admin/providers/admin_auth_provider.dart';
import 'package:galapagos_wildlife/brick/repository.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import 'package:galapagos_wildlife/core/services/initial_sync_service.dart';
import 'package:galapagos_wildlife/features/home/providers/home_provider.dart';
import 'package:galapagos_wildlife/features/map/providers/map_provider.dart';
import 'package:galapagos_wildlife/features/map/providers/trail_provider.dart';
import 'package:galapagos_wildlife/features/species/providers/species_list_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = AdaptiveLayout.isTablet(context);

    final settingsContent = <Widget>[
      // Account section (phone only — tablet/desktop has it in NavigationRail)
      if (!isTablet) ...[
        _SectionHeader(title: context.t.auth.signIn),
        if (isAuthenticated)
          ListTile(
            leading: CircleAvatar(
              backgroundColor: isDark ? AppColors.primaryLight.withValues(alpha: 0.15) : null,
              child: Icon(Icons.person, color: isDark ? AppColors.primaryLight : null),
            ),
            title: Text(user?.email ?? 'User'),
            subtitle: Text(context.t.settings.signedIn, style: TextStyle(color: isDark ? Colors.white54 : null)),
            trailing: TextButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                ref.invalidate(isAdminProvider);
              },
              child: Text(context.t.auth.signOut),
            ),
          )
        else
          ListTile(
            leading: const Icon(Icons.login),
            title: Text(context.t.auth.signIn),
            subtitle: Text(context.t.auth.signInSubtitle, style: TextStyle(color: isDark ? Colors.white54 : null)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed('login'),
          ),
        // Admin Panel (only for admin users)
        if (isAuthenticated)
          ref.watch(isAdminProvider).when(
            data: (isAdmin) => isAdmin
                ? Column(
                    children: [
                      const Divider(),
                      _SectionHeader(title: context.t.admin.title),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isDark
                              ? AppColors.accentOrange.withValues(alpha: 0.15)
                              : AppColors.secondary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.admin_panel_settings,
                            color: isDark ? AppColors.accentOrange : AppColors.secondary,
                          ),
                        ),
                        title: Text(
                          context.t.admin.panel,
                          style: TextStyle(color: isDark ? Colors.white : null),
                        ),
                        subtitle: Text(
                          context.t.admin.panelSubtitle,
                          style: TextStyle(color: isDark ? Colors.white54 : null),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/admin'),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        const Divider(),
      ],
      // My Profile
      if (isAuthenticated) ...[
        ListTile(
          leading: CircleAvatar(
            backgroundColor: isDark
                ? AppColors.primaryLight.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.person_outline,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
            ),
          ),
          title: Text(context.t.auth.profile),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/profile'),
        ),
      ],
      // Badges / Achievements
      if (isAuthenticated) ...[
        ListTile(
          leading: CircleAvatar(
            backgroundColor: isDark
                ? Colors.amber.withValues(alpha: 0.15)
                : Colors.amber.withValues(alpha: 0.1),
            child: Icon(
              Icons.emoji_events,
              color: isDark ? Colors.amber : Colors.amber.shade700,
            ),
          ),
          title: Text(context.t.badges.title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.goNamed('badges'),
        ),
        // Leaderboard
        ListTile(
          leading: CircleAvatar(
            backgroundColor: isDark
                ? Colors.deepPurple.withValues(alpha: 0.15)
                : Colors.deepPurple.withValues(alpha: 0.1),
            child: Icon(
              Icons.leaderboard,
              color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
            ),
          ),
          title: Text(context.t.leaderboard.title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/leaderboard'),
        ),
        const Divider(),
      ],
      // Language
      _SectionHeader(title: context.t.settings.language),
      RadioGroup<String>(
        groupValue: locale,
        onChanged: (v) { if (v != null) ref.read(localeProvider.notifier).setLocale(v); },
        child: Column(
          children: [
            RadioListTile<String>(
              title: Text(context.t.settings.english),
              value: 'en',
            ),
            RadioListTile<String>(
              title: Text(context.t.settings.spanish),
              value: 'es',
            ),
          ],
        ),
      ),
      const Divider(),
      // Theme
      _SectionHeader(title: context.t.settings.theme),
      RadioGroup<ThemeMode>(
        groupValue: themeMode,
        onChanged: (v) { if (v != null) ref.read(themeModeProvider.notifier).setThemeMode(v); },
        child: Column(
          children: [
            RadioListTile<ThemeMode>(
              title: Text(context.t.settings.system),
              value: ThemeMode.system,
            ),
            RadioListTile<ThemeMode>(
              title: Text(context.t.settings.light),
              value: ThemeMode.light,
            ),
            RadioListTile<ThemeMode>(
              title: Text(context.t.settings.dark),
              value: ThemeMode.dark,
            ),
          ],
        ),
      ),
      const Divider(),
      // Text size
      _SectionHeader(title: context.t.settings.textSize),
      _TextSizeSlider(isDark: isDark),
      const Divider(),
      // Notifications
      _SectionHeader(title: context.t.settings.notifications),
      SwitchListTile(
        secondary: CircleAvatar(
          backgroundColor: isDark
              ? Colors.amber.withValues(alpha: 0.15)
              : Colors.amber.withValues(alpha: 0.1),
          child: Icon(
            Icons.emoji_events,
            color: isDark ? Colors.amber : Colors.amber.shade700,
          ),
        ),
        title: Text(context.t.settings.badgeNotifications),
        subtitle: Text(
          context.t.settings.badgeNotificationsDesc,
          style: TextStyle(color: isDark ? Colors.white54 : null),
        ),
        value: ref.watch(badgeNotificationsProvider),
        onChanged: (_) => ref.read(badgeNotificationsProvider.notifier).toggle(),
      ),
      const Divider(),
      // Offline Data
      _SectionHeader(title: context.t.settings.offlineImages),
      _SyncDataTile(isDark: isDark),
      const Divider(),
      // About
      _SectionHeader(title: context.t.settings.about),
      ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(context.t.settings.version),
        subtitle: Text(AppConstants.appVersion, style: TextStyle(color: isDark ? Colors.white54 : null)),
      ),
      ListTile(
        leading: const Icon(Icons.description),
        title: Text(context.t.settings.credits),
        subtitle: Text(
          'Charles Darwin Foundation, Galapagos National Park',
          style: TextStyle(color: isDark ? Colors.white54 : null),
        ),
        onTap: () {},
      ),
    ];

    if (isTablet) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.t.settings.title),
          backgroundColor: isDark ? AppColors.darkBackground : null,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: settingsContent,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.settings.title),
        backgroundColor: isDark ? AppColors.darkBackground : null,
      ),
      body: ListView(
        children: settingsContent,
      ),
    );
  }
}

class _SyncDataTile extends ConsumerStatefulWidget {
  final bool isDark;
  const _SyncDataTile({required this.isDark});

  @override
  ConsumerState<_SyncDataTile> createState() => _SyncDataTileState();
}

class _SyncDataTileState extends ConsumerState<_SyncDataTile> {
  bool _isSyncing = false;

  Future<void> _sync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      final syncService = InitialSyncService(Repository());
      await syncService.syncAll();
      await ref.read(lastSyncedProvider.notifier).recordSync();
      ref.invalidate(islandsProvider);
      ref.invalidate(visitSitesProvider);
      ref.invalidate(allSpeciesProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(featuredSpeciesProvider);
      ref.invalidate(trailsProvider);
      // Precache images in background, same as initial sync
      unawaited(syncService.precacheImages());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  String _subtitleText(BuildContext context, DateTime? lastSynced) {
    if (_isSyncing) return context.t.sync.preparing;
    if (lastSynced == null) return context.t.settings.neverSynced;
    final diff = DateTime.now().difference(lastSynced);
    if (diff.inMinutes < 1) return context.t.settings.justNow;
    if (diff.inMinutes < 60) return context.t.settings.minutesAgo(minutes: diff.inMinutes);
    if (diff.inHours < 24) return context.t.settings.hoursAgo(hours: diff.inHours);
    return context.t.settings.daysAgo(days: diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final lastSynced = ref.watch(lastSyncedProvider);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: widget.isDark
            ? AppColors.primaryLight.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.1),
        child: Icon(
          _isSyncing ? Icons.cloud_sync : Icons.cloud_done,
          color: widget.isDark ? AppColors.primaryLight : AppColors.primary,
        ),
      ),
      title: Text(context.t.settings.lastSynced),
      subtitle: Text(
        _subtitleText(context, lastSynced),
        style: TextStyle(color: widget.isDark ? Colors.white54 : null),
      ),
      trailing: _isSyncing
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : ElevatedButton.icon(
              onPressed: _sync,
              icon: const Icon(Icons.sync, size: 18),
              label: Text(context.t.offline.syncNow),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: isDark ? AppColors.accentOrange : Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


class _TextSizeSlider extends ConsumerWidget {
  final bool isDark;
  const _TextSizeSlider({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(textScaleProvider);
    final percent = (scale * 100).round();
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t.settings.textSizeDesc,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                context.t.settings.textSizeSmall,
                style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45),
              ),
              Expanded(
                child: Slider(
                  value: scale,
                  min: TextScaleNotifier.minScale,
                  max: TextScaleNotifier.maxScale,
                  divisions: 14,
                  activeColor: primaryColor,
                  onChanged: (v) => ref.read(textScaleProvider.notifier).setScale(v),
                ),
              ),
              Text(
                context.t.settings.textSizeLarge,
                style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t.settings.textSizeCurrent(percent: percent.toString()),
                style: TextStyle(
                  fontSize: 12,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (scale != 1.0)
                TextButton(
                  onPressed: () => ref.read(textScaleProvider.notifier).setScale(1.0),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    context.t.settings.textSizeNormal,
                    style: TextStyle(fontSize: 12, color: primaryColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Live preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marine Iguana',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  'Amblyrhynchus cristatus',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
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
