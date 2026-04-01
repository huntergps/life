import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/app/theme/app_theme.dart';
import 'package:galapagos_wildlife/app/router/app_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/presentation/screens/sync_screen.dart';
import 'package:galapagos_wildlife/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:galapagos_wildlife/app/shell/app_startup_coordinator.dart';
import 'package:galapagos_wildlife/app/shell/app_dialogs.dart';
import 'package:galapagos_wildlife/app/shell/offline_banner_wrapper.dart';

class GalapagosWildlifeApp extends ConsumerStatefulWidget {
  const GalapagosWildlifeApp({super.key});

  @override
  ConsumerState<GalapagosWildlifeApp> createState() =>
      _GalapagosWildlifeAppState();
}

class _GalapagosWildlifeAppState extends ConsumerState<GalapagosWildlifeApp> {
  @override
  void initState() {
    super.initState();
    initializeApp(ref);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final textScale = ref.watch(textScaleProvider);
    final phase = ref.watch(startupPhaseProvider);
    final onboardingComplete = ref.watch(onboardingCompleteProvider);

    // Keep background providers alive (realtime, connectivity, watch)
    activateBackgroundProviders(ref);

    // Show loading spinner while checking sync status
    if (phase == StartupPhase.loading) {
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

    // Show sync screen if initial data sync is needed
    if (phase == StartupPhase.syncing) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: SyncScreen(
          onSyncComplete: () {
            ref.read(startupPhaseProvider.notifier).setPhase(StartupPhase.ready);
          },
        ),
      );
    }

    // Show onboarding if not yet completed
    if (!onboardingComplete) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        locale: TranslationProvider.of(context).flutterLocale,
        home: OnboardingScreen(
          onComplete: () {
            ref.read(onboardingCompleteProvider.notifier).complete();
          },
        ),
      );
    }

    // Main app with router
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
          child: OfflineBannerWrapper(
            child: AppDialogs(
              child: child!,
            ),
          ),
        ),
      ),
    );
  }
}
