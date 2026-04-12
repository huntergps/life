import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import '../../providers/settings_provider.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';
import 'package:galapagos_wildlife/features/admin/providers/admin_auth_provider.dart';
import 'package:galapagos_wildlife/data/local/drift/repository/wildlife_repository.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import 'package:galapagos_wildlife/data/sync/initial_sync_service.dart';
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';
import 'package:galapagos_wildlife/features/home/providers/home_provider.dart';
import 'package:galapagos_wildlife/features/map/providers/map_provider.dart';
import 'package:galapagos_wildlife/features/map/providers/trail_provider.dart';
import 'package:galapagos_wildlife/features/species/list/species_list_provider.dart';
import 'package:galapagos_wildlife/features/auth/services/account_deletion_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:galapagos_wildlife/features/purchases/providers/purchase_provider.dart';
import 'package:galapagos_wildlife/features/purchases/presentation/paywall_screen.dart';
import 'package:galapagos_wildlife/features/species/photo_id/providers/gemma_model_provider.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/gemma_species_service.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/gemma_model_config.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/gemma_file_receiver.dart';

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
        // Delete Account (only when authenticated)
        if (isAuthenticated)
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              locale == 'es' ? 'Eliminar cuenta' : 'Delete Account',
              style: const TextStyle(color: Colors.red),
            ),
            subtitle: Text(
              locale == 'es'
                  ? 'Elimina permanentemente tu cuenta y todos tus datos'
                  : 'Permanently delete your account and all data',
              style: TextStyle(color: isDark ? Colors.white54 : null),
            ),
            onTap: () => _showDeleteAccountDialog(context, ref, locale == 'es'),
          ),
        // Admin Panel (admin users) / Staff Panel (curator/editor)
        if (isAuthenticated)
          ref.watch(userRolesProvider).when(
            data: (roles) {
              final isAdmin = roles.contains('admin');
              final isCurator = roles.contains('curator') || isAdmin;
              final isEditor = roles.contains('editor') || isAdmin;
              if (!isAdmin && !isCurator && !isEditor) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  _SectionHeader(title: isAdmin ? context.t.admin.title : 'Panel de trabajo'),
                  if (isAdmin)
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
                  if (isCurator)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isDark
                            ? Colors.teal.withValues(alpha: 0.15)
                            : Colors.teal.withValues(alpha: 0.1),
                        child: Icon(Icons.verified_user_outlined,
                            color: isDark ? Colors.tealAccent : Colors.teal),
                      ),
                      title: Text('Panel del curador',
                          style: TextStyle(color: isDark ? Colors.white : null)),
                      subtitle: Text('Revisar propuestas y validar IA',
                          style: TextStyle(color: isDark ? Colors.white54 : null)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/admin/curator'),
                    ),
                  if (isEditor)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isDark
                            ? Colors.blue.withValues(alpha: 0.15)
                            : Colors.blue.withValues(alpha: 0.1),
                        child: Icon(Icons.edit_note,
                            color: isDark ? Colors.lightBlueAccent : Colors.blue),
                      ),
                      title: Text('Mis propuestas',
                          style: TextStyle(color: isDark ? Colors.white : null)),
                      subtitle: Text('Ver y gestionar cambios propuestos',
                          style: TextStyle(color: isDark ? Colors.white54 : null)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/admin/my-proposals'),
                    ),
                ],
              );
            },
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
      // Premium
      _PremiumSettingsTile(isDark: isDark),
      const Divider(),
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
      // Beta Features (server-controlled via roles)
      _SectionHeader(title: 'Beta'),
      Builder(builder: (context) {
        final isEs = locale == 'es';
        final isBetaAsync = ref.watch(isBetaTesterProvider);
        final isBeta = isBetaAsync.asData?.value ?? (Bootstrap.prefs.getBool('is_beta_tester') ?? false);
        return SwitchListTile(
          secondary: CircleAvatar(
            backgroundColor: isDark
                ? Colors.purple.withValues(alpha: 0.15)
                : Colors.purple.withValues(alpha: 0.1),
            child: Icon(
              Icons.science_outlined,
              color: isDark ? Colors.purpleAccent : Colors.purple,
            ),
          ),
          title: Text(isEs ? 'Funciones Beta' : 'Beta Features'),
          subtitle: Text(
            isEs
                ? isBeta ? 'Habilitado por el administrador' : 'Contacta al administrador para activar'
                : isBeta ? 'Enabled by administrator' : 'Contact administrator to enable',
            style: TextStyle(color: isDark ? Colors.white54 : null),
          ),
          value: isBeta,
          onChanged: null, // Read-only — controlled from server
        );
      }),
      const Divider(),
      // Offline Data
      _SectionHeader(title: context.t.settings.offlineImages),
      _SyncDataTile(isDark: isDark),
      const Divider(),
      // AI Model (native only)
      if (!kIsWeb) ...[
        _SectionHeader(title: 'AI'),
        _GemmaModelTile(isDark: isDark),
        const Divider(),
      ],
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
          'GalapagosTech — Elmer Salazar',
          style: TextStyle(color: isDark ? Colors.white54 : null),
        ),
        onTap: () {},
      ),
      ListTile(
        leading: const Icon(Icons.privacy_tip_outlined),
        title: Text(context.t.settings.privacyPolicy),
        onTap: () => launchUrl(Uri.parse('https://galapagos.tech/wildlife-privacy')),
      ),
      ListTile(
        leading: const Icon(Icons.description_outlined),
        title: Text(context.t.settings.termsOfService),
        onTap: () => launchUrl(Uri.parse('https://galapagos.tech/wildlife-terms')),
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

Future<void> _showDeleteAccountDialog(
    BuildContext context, WidgetRef ref, bool isEs) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(isEs ? 'Eliminar cuenta' : 'Delete Account'),
      content: Text(isEs
          ? 'Esta accion es IRREVERSIBLE. Se eliminaran todos tus avistamientos, favoritos, perfil y datos. ¿Estas seguro?'
          : 'This action is IRREVERSIBLE. All your sightings, favorites, profile, and data will be deleted. Are you sure?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(isEs ? 'Cancelar' : 'Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(isEs ? 'Si, eliminar' : 'Yes, delete'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  // Second confirmation: type DELETE / ELIMINAR
  final controller = TextEditingController();
  final keyword = isEs ? 'ELIMINAR' : 'DELETE';
  final typed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(isEs ? 'Confirmar eliminacion' : 'Confirm Deletion'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isEs
              ? 'Escribe "$keyword" para confirmar:'
              : 'Type "$keyword" to confirm:'),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: keyword),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(isEs ? 'Cancelar' : 'Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () {
            if (controller.text.trim().toUpperCase() == keyword) {
              Navigator.pop(ctx, true);
            }
          },
          child: Text(isEs ? 'Eliminar cuenta' : 'Delete Account'),
        ),
      ],
    ),
  );
  if (typed != true || !context.mounted) return;

  // Execute deletion
  try {
    await AccountDeletionService.deleteAccount();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              isEs ? 'Cuenta eliminada' : 'Account deleted')),
    );
    ref.invalidate(isAdminProvider);
    context.go('/');
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
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
      final syncService = InitialSyncService(WildlifeRepository.instance);
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


class _PremiumSettingsTile extends ConsumerWidget {
  final bool isDark;
  const _PremiumSettingsTile({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPack = ref.watch(hasPackProvider);
    final hasPro = ref.watch(hasProProvider);
    final isEs = ref.watch(localeProvider) == 'es';

    final String statusText;
    final IconData statusIcon;
    final Color statusColor;

    if (hasPro) {
      statusText = isEs ? 'Pro activo' : 'Pro active';
      statusIcon = Icons.star;
      statusColor = Colors.amber.shade700;
    } else if (hasPack) {
      statusText = isEs ? 'Pack activo' : 'Pack active';
      statusIcon = Icons.check_circle;
      statusColor = AppColors.primary;
    } else {
      statusText = isEs ? 'Desbloquea funciones premium' : 'Unlock premium features';
      statusIcon = Icons.lock_outline;
      statusColor = isDark ? Colors.white54 : Colors.grey;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Premium'),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: isDark
                ? statusColor.withValues(alpha: 0.15)
                : statusColor.withValues(alpha: 0.1),
            child: Icon(statusIcon, color: statusColor),
          ),
          title: Text(
            hasPro ? 'Galapagos Pro' : hasPack ? 'Galapagos Pack' : (isEs ? 'Galapagos Premium' : 'Galapagos Premium'),
            style: TextStyle(color: isDark ? Colors.white : null),
          ),
          subtitle: Text(
            statusText,
            style: TextStyle(color: isDark ? Colors.white54 : null),
          ),
          trailing: (hasPro)
              ? null
              : const Icon(Icons.chevron_right),
          onTap: (hasPro)
              ? null
              : () => showPaywall(context),
        ),
      ],
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

class _GemmaModelTile extends ConsumerStatefulWidget {
  final bool isDark;
  const _GemmaModelTile({required this.isDark});

  @override
  ConsumerState<_GemmaModelTile> createState() => _GemmaModelTileState();
}

class _GemmaModelTileState extends ConsumerState<_GemmaModelTile> {
  double? _downloadProgress;
  bool _isDownloading = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _checkForReceivedModel();
  }

  /// Check if a model file was received via AirDrop or Finder File Sharing.
  Future<void> _checkForReceivedModel() async {
    final received = await GemmaFileReceiver.checkForReceivedModel();
    if (received && mounted) {
      ref.invalidate(gemmaModelStatusProvider);
      final isEs = ref.read(localeProvider) == 'es';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEs
              ? 'Modelo de IA recibido e instalado'
              : 'AI model received and installed!'),
        ),
      );
    }
  }

  Future<void> _startDownload() async {
    if (_isDownloading) return;
    setState(() {
      _isDownloading = true;
      _isPaused = false;
      _downloadProgress = 0;
    });
    await GemmaSpeciesService.startDownload(
      onProgress: (progress) {
        if (mounted) setState(() => _downloadProgress = progress);
      },
      onDone: () {
        if (mounted) {
          setState(() { _isDownloading = false; _downloadProgress = null; });
          ref.invalidate(gemmaModelStatusProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ref.read(localeProvider) == 'es' ? 'Modelo descargado' : 'Model downloaded')),
          );
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() { _isDownloading = false; _downloadProgress = null; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      },
    );
  }

  Future<void> _pauseDownload() async {
    await GemmaSpeciesService.pauseDownload();
    if (mounted) setState(() => _isPaused = true);
  }

  Future<void> _resumeDownload() async {
    await GemmaSpeciesService.resumeDownload();
    if (mounted) setState(() => _isPaused = false);
  }

  Future<void> _cancelDownload() async {
    await GemmaSpeciesService.cancelDownload();
    if (mounted) setState(() { _isDownloading = false; _isPaused = false; _downloadProgress = null; });
    ref.invalidate(gemmaModelStatusProvider);
  }

  Future<void> _deleteModel() async {
    await GemmaSpeciesService.deleteModel();
    ref.invalidate(gemmaModelStatusProvider);
  }

  void _showUrlConfig() {
    final isEs = ref.read(localeProvider) == 'es';
    final controller = TextEditingController(
      text: GemmaSpeciesService.hasCustomUrl ? GemmaSpeciesService.modelUrl : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEs ? 'URL de descarga' : 'Download URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEs ? 'Para descargar desde una red local:' : 'To download from a local network:', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text('python3 -m http.server 8080', style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'http://192.168.x.x:8080/$_modelFileName',
                hintStyle: const TextStyle(fontSize: 12),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          if (GemmaSpeciesService.hasCustomUrl)
            TextButton(
              onPressed: () async {
                await GemmaSpeciesService.clearCustomUrl();
                Navigator.pop(ctx);
                if (mounted) setState(() {});
              },
              child: Text(isEs ? 'Usar HuggingFace' : 'Use HuggingFace'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEs ? 'Cancelar' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                await GemmaSpeciesService.setCustomUrl(url);
              }
              Navigator.pop(ctx);
              if (mounted) setState(() {});
            },
            child: Text(isEs ? 'Guardar' : 'Save'),
          ),
        ],
      ),
    );
  }

  static const _modelFileName = 'gemma-4-E2B-it.litertlm';

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(gemmaModelStatusProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final locale = ref.watch(localeProvider);
    final isEs = locale == 'es';

    return statusAsync.when(
      data: (status) {
        final String subtitle;
        final Widget? trailing;

        if (_isDownloading && _downloadProgress != null) {
          final pct = (_downloadProgress! * 100).toInt();
          subtitle = _isPaused
              ? (isEs ? 'Pausado $pct%' : 'Paused $pct%')
              : (isEs ? 'Descargando... $pct%' : 'Downloading... $pct%');
          trailing = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pause/Resume button
              IconButton(
                icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 20),
                tooltip: _isPaused
                    ? (isEs ? 'Reanudar' : 'Resume')
                    : (isEs ? 'Pausar' : 'Pause'),
                onPressed: _isPaused ? _resumeDownload : _pauseDownload,
              ),
              // Cancel button
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.red),
                tooltip: isEs ? 'Cancelar' : 'Cancel',
                onPressed: _cancelDownload,
              ),
            ],
          );
        } else {
          switch (status) {
            case GemmaModelStatus.ready:
              subtitle = isEs
                  ? 'Listo (${GemmaSpeciesService.modelSizeLabel})'
                  : 'Ready (${GemmaSpeciesService.modelSizeLabel})';
              trailing = IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: isEs ? 'Eliminar modelo' : 'Delete model',
                onPressed: _deleteModel,
              );
            case GemmaModelStatus.notDownloaded:
              final model = GemmaModelConfig.selected;
              final source = GemmaSpeciesService.hasCustomUrl ? 'Local' : 'HuggingFace';
              subtitle = isEs
                  ? '${model.label} (${model.sizeLabel}) · $source'
                  : '${model.label} (${model.sizeLabel}) · $source';
              trailing = isPremium
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Model selector (E2B/E4B)
                        PopupMenuButton<GemmaModelTier>(
                          icon: const Icon(Icons.memory, size: 20),
                          tooltip: isEs ? 'Seleccionar modelo' : 'Select model',
                          onSelected: (tier) async {
                            await GemmaModelConfig.selectTier(tier);
                            if (mounted) setState(() {});
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: GemmaModelTier.e2b,
                              child: Row(
                                children: [
                                  if (model.tier == GemmaModelTier.e2b) const Icon(Icons.check, size: 16, color: Colors.green),
                                  if (model.tier != GemmaModelTier.e2b) const SizedBox(width: 16),
                                  const SizedBox(width: 8),
                                  const Expanded(child: Text('E2B (2.5 GB) — Standard', style: TextStyle(fontSize: 13))),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              enabled: GemmaModelConfig.canRunE4B,
                              value: GemmaModelTier.e4b,
                              child: Row(
                                children: [
                                  if (model.tier == GemmaModelTier.e4b) const Icon(Icons.check, size: 16, color: Colors.green),
                                  if (model.tier != GemmaModelTier.e4b) const SizedBox(width: 16),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(
                                    'E4B (4.3 GB) — High-end${GemmaModelConfig.canRunE4B ? "" : " (not supported)"}',
                                    style: const TextStyle(fontSize: 13),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // URL config
                        IconButton(
                          icon: const Icon(Icons.settings_ethernet, size: 20),
                          tooltip: isEs ? 'Configurar URL' : 'Configure URL',
                          onPressed: _showUrlConfig,
                        ),
                        // Download button with space check
                        ElevatedButton(
                          onPressed: () async {
                            final (hasSpace, freeLabel) = await GemmaSpeciesService.checkDiskSpace();
                            if (!hasSpace && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(
                                  isEs
                                      ? 'Espacio insuficiente ($freeLabel libre, necesita ${model.sizeLabel})'
                                      : 'Not enough space ($freeLabel free, needs ${model.sizeLabel})',
                                )),
                              );
                              return;
                            }
                            _startDownload();
                          },
                          child: Text(isEs ? 'Descargar' : 'Download'),
                        ),
                      ],
                    )
                  : TextButton(
                      onPressed: () => showPaywall(context),
                      child: Text(isEs ? 'Pro' : 'Pro'),
                    );
            case GemmaModelStatus.downloading:
              subtitle = isEs ? 'Descargando...' : 'Downloading...';
              trailing = const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            case GemmaModelStatus.unsupported:
              subtitle = isEs
                  ? 'No soportado en este dispositivo'
                  : 'Not supported on this device';
              trailing = null;
          }
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: widget.isDark
                ? Colors.deepPurple.withValues(alpha: 0.15)
                : Colors.deepPurple.withValues(alpha: 0.1),
            child: Icon(
              Icons.auto_awesome,
              color: widget.isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
            ),
          ),
          title: Text(
            isEs ? 'IA avanzada (${GemmaSpeciesService.modelSizeLabel})' : 'Enhanced AI (${GemmaSpeciesService.modelSizeLabel})',
            style: TextStyle(color: widget.isDark ? Colors.white : null),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: widget.isDark ? Colors.white54 : null),
          ),
          trailing: trailing,
        );
      },
      loading: () => ListTile(
        leading: CircleAvatar(
          backgroundColor: widget.isDark
              ? Colors.deepPurple.withValues(alpha: 0.15)
              : Colors.deepPurple.withValues(alpha: 0.1),
          child: Icon(
            Icons.auto_awesome,
            color: widget.isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
          ),
        ),
        title: Text(isEs ? 'IA avanzada' : 'Enhanced AI'),
        trailing: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
