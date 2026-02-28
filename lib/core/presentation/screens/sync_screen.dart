import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:galapagos_wildlife/brick/repository.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/services/initial_sync_service.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';

class _SyncProgress {
  final String currentTable;
  final int currentStep;
  final int totalSteps;
  final String? error;
  final bool syncing;

  const _SyncProgress({
    this.currentTable = '',
    this.currentStep = 0,
    this.totalSteps = 6,
    this.error,
    this.syncing = true,
  });

  _SyncProgress copyWith({
    String? currentTable,
    int? currentStep,
    int? totalSteps,
    String? error,
    bool? syncing,
    bool clearError = false,
  }) =>
      _SyncProgress(
        currentTable: currentTable ?? this.currentTable,
        currentStep: currentStep ?? this.currentStep,
        totalSteps: totalSteps ?? this.totalSteps,
        error: clearError ? null : (error ?? this.error),
        syncing: syncing ?? this.syncing,
      );
}

final _syncProgressProvider = StateProvider<_SyncProgress>(
  (ref) => const _SyncProgress(),
);

class SyncScreen extends ConsumerStatefulWidget {
  final VoidCallback onSyncComplete;
  const SyncScreen({super.key, required this.onSyncComplete});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  @override
  void initState() {
    super.initState();
    // Defer until after the first frame so that any provider state updates
    // inside _startSync (via onProgress) don't fire during the build phase.
    // Calling notifier.state = ... from initState throws:
    // "Tried to modify a provider while the widget tree was building."
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSync());
  }

  Future<void> _startSync() async {
    final syncService = InitialSyncService(Repository());
    final notifier = ref.read(_syncProgressProvider.notifier);

    void updateProgress(int step, int total, String table) {
      if (!mounted) return;
      // Schedule outside the current call stack to prevent
      // "modifying provider during build" errors.
      Future(() {
        if (!mounted) return;
        notifier.state = notifier.state.copyWith(
          currentStep: step,
          totalSteps: total,
          currentTable: table,
        );
      });
    }

    // Try remote sync first
    try {
      await syncService.syncAll(onProgress: updateProgress);
      // Pre-cache images in background (fire-and-forget)
      unawaited(syncService.precacheImages());
      if (mounted) widget.onSyncComplete();
      return;
    } catch (e) {
      debugPrint('Remote sync failed: $e, falling back to seed data');
    }

    // Fallback: seed local data
    try {
      if (!mounted) return;
      notifier.state = const _SyncProgress(totalSteps: 5);
      await syncService.seedLocalData(onProgress: updateProgress);
      if (mounted) widget.onSyncComplete();
    } catch (e) {
      if (!mounted) return;
      notifier.state = notifier.state.copyWith(
        error: e.toString(),
        syncing: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(_syncProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/gwl_logo.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.t.sync.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              if (progress.error != null) ...[
                Icon(Icons.cloud_off, size: 48, color: AppColors.accentOrange),
                const SizedBox(height: 16),
                Text(
                  '${context.t.sync.errorTitle}\n${context.t.sync.errorSubtitle}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    ref.read(_syncProgressProvider.notifier).state =
                        const _SyncProgress();
                    _startSync();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(context.t.sync.retry),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: 240,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.totalSteps > 0
                          ? progress.currentStep / progress.totalSteps
                          : 0,
                      minHeight: 6,
                      backgroundColor: AppColors.darkSurface,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primaryLight),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  progress.syncing
                      ? context.t.sync.downloading(table: progress.currentTable)
                      : context.t.sync.preparing,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '${progress.currentStep} / ${progress.totalSteps}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
