import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/app/theme/app_theme.dart';
import 'package:galapagos_wildlife/app/router/app_router.dart';
import 'package:galapagos_wildlife/app/router/router_keys.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/services/initial_sync_service.dart';
import 'package:galapagos_wildlife/core/services/realtime_service.dart';
import 'package:galapagos_wildlife/core/providers/connectivity_provider.dart';
import 'package:galapagos_wildlife/core/widgets/offline_banner.dart';
import 'package:galapagos_wildlife/drift/repository/wildlife_repository.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:galapagos_wildlife/core/presentation/screens/sync_screen.dart';
import 'package:galapagos_wildlife/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:galapagos_wildlife/features/badges/models/badge_definition.dart';
import 'package:galapagos_wildlife/features/badges/providers/badge_notification_provider.dart';
import 'package:galapagos_wildlife/features/badges/presentation/widgets/badge_unlock_dialog.dart';
import 'package:galapagos_wildlife/features/profile/providers/celebration_events_provider.dart';
import 'package:galapagos_wildlife/features/profile/presentation/widgets/birthday_dialog.dart';
import 'package:galapagos_wildlife/watch/watch_data_sync_provider.dart';

class GalapagosWildlifeApp extends ConsumerStatefulWidget {
  const GalapagosWildlifeApp({super.key});

  @override
  ConsumerState<GalapagosWildlifeApp> createState() => _GalapagosWildlifeAppState();
}

class _GalapagosWildlifeAppState extends ConsumerState<GalapagosWildlifeApp> {
  bool _syncChecked = false;
  bool _needsSync = false;
  bool _onboardingComplete = Bootstrap.prefs.getBool('onboarding_complete') ?? false;

  @override
  void initState() {
    super.initState();
    _checkSync();
  }

  Future<void> _checkSync() async {
    // Brick/SQLite runs on iOS, Android and macOS. Web uses Supabase-direct.
    if (!Bootstrap.isMobile) {
      setState(() {
        _syncChecked = true;
        _needsSync = false;
      });
      return;
    }
    final syncService = InitialSyncService(WildlifeRepository.instance);
    final complete = await syncService.isSyncComplete();
    if (!mounted) return;
    setState(() {
      _syncChecked = true;
      _needsSync = !complete;
    });
  }

  /// Shows one dialog per newly unlocked badge, sequentially.
  Future<void> _showBadgeDialogs(
    BuildContext navContext,
    List<BadgeProgress> badges,
  ) async {
    for (final badge in badges) {
      if (!mounted) return;
      await BadgeUnlockDialog.show(navContext, badge);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final textScale = ref.watch(textScaleProvider);

    // Activate Supabase Realtime subscriptions
    ref.watch(realtimeServiceProvider);

    // Auto-refresh data providers when connectivity returns
    ref.watch(connectivityRefreshProvider);

    // Activate Apple Watch connectivity (WCSession) — native only
    if (!kIsWeb) ref.watch(watchDataSyncProvider);

    // Show loading or sync screen BEFORE the router is created
    if (!_syncChecked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: Center(
            child: CircularProgressIndicator(color: Colors.white54),
          ),
        ),
      );
    }

    if (_needsSync) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: SyncScreen(
          onSyncComplete: () {
            if (!mounted) return;
            setState(() {
              _needsSync = false;
            });
          },
        ),
      );
    }

    if (!_onboardingComplete) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ref.watch(themeModeProvider),
        locale: TranslationProvider.of(context).flutterLocale,
        home: OnboardingScreen(
          onComplete: () {
            if (!mounted) return;
            setState(() {
              _onboardingComplete = true;
            });
          },
        ),
      );
    }

    // Check for birthday and show dialog
    ref.listen<bool>(
      isBirthdayTodayProvider,
      (_, next) {
        if (!next) return;
        final navContext = rootNavigatorKey.currentContext;
        if (navContext == null) return;
        BirthdayDialog.show(navContext);
      },
    );

    // Listen for newly unlocked badges and show celebratory dialog
    ref.listen<AsyncValue<List<BadgeProgress>>>(
      newlyUnlockedBadgesProvider,
      (_, next) {
        final badges = next.asData?.value;
        if (badges == null || badges.isEmpty) return;

        // Check if badge notifications are enabled
        final badgeNotificationsEnabled = ref.read(badgeNotificationsProvider);

        // Use rootNavigatorKey so the dialog appears above the whole app
        final navContext = rootNavigatorKey.currentContext;
        if (navContext == null) return;

        // Show one dialog per new badge, sequentially (only if enabled)
        if (badgeNotificationsEnabled) {
          _showBadgeDialogs(navContext, badges);
        }

        // Persist so they are not shown again (regardless of notification pref)
        markBadgesAsSeen(badges);
      },
    );

    // Connectivity state for offline banner
    final isOnline = ref.watch(connectivityProvider).asData?.value ?? true;

    // Main app with router - builder handles responsive framework + offline banner
    return MaterialApp.router(
      title: 'Galapagos Wildlife',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: TranslationProvider.of(context).flutterLocale,
      routerConfig: appRouter,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: ResponsiveBreakpoints.builder(
          breakpoints: const [
            Breakpoint(start: 0, end: 450, name: MOBILE),
            Breakpoint(start: 451, end: 800, name: TABLET),
            Breakpoint(start: 801, end: 1920, name: DESKTOP),
            Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
                child: isOnline
                    ? const SizedBox.shrink(key: ValueKey('online'))
                    : const OfflineBanner(key: ValueKey('offline')),
              ),
              Expanded(child: child!),
            ],
          ),
        ),
      ),
    );
  }
}
