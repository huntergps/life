import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';
import 'package:galapagos_wildlife/data/sync/initial_sync_service.dart';
import 'package:galapagos_wildlife/data/sync/realtime_service.dart';
import 'package:galapagos_wildlife/core/providers/connectivity_provider.dart';
import 'package:galapagos_wildlife/data/local/drift/repository/wildlife_repository.dart';
import 'package:galapagos_wildlife/features/watch/sync/watch_data_sync_provider.dart';
import 'package:galapagos_wildlife/features/purchases/providers/purchase_provider.dart';

// ---------------------------------------------------------------------------
// Startup phase enum
// ---------------------------------------------------------------------------

enum StartupPhase { loading, syncing, ready }

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Tracks the current startup phase.
final startupPhaseProvider =
    NotifierProvider<StartupPhaseNotifier, StartupPhase>(
  StartupPhaseNotifier.new,
);

class StartupPhaseNotifier extends Notifier<StartupPhase> {
  @override
  StartupPhase build() => StartupPhase.loading;

  void setPhase(StartupPhase phase) => state = phase;
}

/// Whether onboarding has been completed.
final onboardingCompleteProvider =
    NotifierProvider<OnboardingCompleteNotifier, bool>(
  OnboardingCompleteNotifier.new,
);

class OnboardingCompleteNotifier extends Notifier<bool> {
  @override
  bool build() => Bootstrap.prefs.getBool('onboarding_complete') ?? false;

  void complete() => state = true;
}

// ---------------------------------------------------------------------------
// Startup initialisation function
// ---------------------------------------------------------------------------

/// Call once from the app widget's [initState] to kick off all startup tasks.
///
/// This checks whether initial data sync is needed (mobile/macOS only),
/// activates Realtime subscriptions, connectivity refresh, and Watch sync.
Future<void> initializeApp(WidgetRef ref) async {
  final phaseNotifier = ref.read(startupPhaseProvider.notifier);

  // Brick/SQLite runs on iOS, Android and macOS. Web uses Supabase-direct.
  if (!Bootstrap.isMobile) {
    phaseNotifier.setPhase(StartupPhase.ready);
    return;
  }

  final syncService = InitialSyncService(WildlifeRepository.instance);
  final complete = await syncService.isSyncComplete();

  if (complete) {
    phaseNotifier.setPhase(StartupPhase.ready);
  } else {
    phaseNotifier.setPhase(StartupPhase.syncing);
  }
}

/// Activate background providers that need to run throughout the app lifetime.
///
/// Should be called from [build] so watchers stay alive.
void activateBackgroundProviders(WidgetRef ref) {
  // Activate Supabase Realtime subscriptions
  ref.watch(realtimeServiceProvider);

  // Auto-refresh data providers when connectivity returns
  ref.watch(connectivityRefreshProvider);

  // Activate Apple Watch connectivity (WCSession) — native only
  if (!kIsWeb) ref.watch(watchDataSyncProvider);

  // Initialize in-app purchases
  ref.watch(purchaseInitProvider);
}
