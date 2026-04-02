import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/features/checklist/presentation/confetti_overlay.dart';
import 'package:galapagos_wildlife/features/checklist/presentation/wallpaper_unlock_sheet.dart';
import 'package:galapagos_wildlife/features/checklist/providers/checklist_stats_provider.dart';
import 'package:galapagos_wildlife/features/checklist/providers/suggested_species_provider.dart';
import 'package:galapagos_wildlife/features/checklist/services/certificate_service.dart';
import 'package:galapagos_wildlife/features/checklist/services/share_card_service.dart';
import 'package:galapagos_wildlife/features/profile/providers/profile_provider.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import 'package:galapagos_wildlife/features/checklist/services/celebration_effects_service.dart';

/// Full-screen celebration dialog shown when the user completes all 25
/// suggested iconic Galapagos species.
class ChecklistCompletionDialog extends ConsumerStatefulWidget {
  const ChecklistCompletionDialog({super.key});

  /// Shows the dialog as a full-screen modal route.
  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close celebration',
      barrierColor: Colors.black.withValues(alpha: 0.95),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, _, _) => const ChecklistCompletionDialog(),
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  @override
  ConsumerState<ChecklistCompletionDialog> createState() =>
      _ChecklistCompletionDialogState();
}

class _ChecklistCompletionDialogState
    extends ConsumerState<ChecklistCompletionDialog>
    with TickerProviderStateMixin {
  late final AnimationController _trophyController;
  late final AnimationController _textController;
  late final AnimationController _pulseController;
  late final Animation<double> _trophyScale;
  late final Animation<double> _textOpacity;

  bool _confettiActive = true;
  bool _requestingCertificate = false;

  @override
  void initState() {
    super.initState();

    // Trigger celebration haptics when the dialog opens
    CelebrationEffectsService.celebrateCompletion();

    // Trophy scale-in with elastic curve
    _trophyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _trophyScale = CurvedAnimation(
      parent: _trophyController,
      curve: Curves.elasticOut,
    );

    // Text fade-in, delayed after trophy
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    // Pulsing glow on the trophy
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      lowerBound: 0.85,
      upperBound: 1.0,
    );

    // Sequence: trophy appears, then text fades in, then pulse starts
    _trophyController.forward().then((_) {
      _textController.forward();
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _trophyController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _requestCertificate() async {
    setState(() => _requestingCertificate = true);
    try {
      final speciesCount =
          ref.read(checklistSpeciesProvider).asData?.value.length ??
              kDefaultSpeciesIds.length;
      await CertificateService.requestCertificate(
        speciesCount: speciesCount,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificate sent to your email!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      AppLogger.error('Certificate request failed', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not request certificate: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _requestingCertificate = false);
    }
  }

  Future<void> _share() async {
    final locale = LocaleSettings.currentLocale;
    final isEs = locale == AppLocale.es;
    final profile = ref.read(userProfileProvider).asData?.value;
    final stats = ref.read(checklistStatsProvider);

    await ShareCardService.shareCompletionCard(
      context: context,
      userName: profile?.displayName ?? '',
      speciesCount: stats.totalSpecies,
      daysToComplete: stats.daysToComplete,
      firstSeenDate: stats.firstSeenDate,
      lastSeenDate: stats.lastSeenDate,
      locale: isEs ? 'es' : 'en',
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).asData?.value;
    final userName = profile?.displayName ?? '';
    final locale = LocaleSettings.currentLocale;
    final isEs = locale == AppLocale.es;
    final stats = ref.watch(checklistStatsProvider);
    final dateFormat = DateFormat.yMMMd(isEs ? 'es' : 'en');

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Confetti layer
          if (_confettiActive)
            Positioned.fill(
              child: ConfettiOverlay(
                onComplete: () {
                  if (mounted) setState(() => _confettiActive = false);
                },
              ),
            ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated trophy
                  AnimatedBuilder(
                    animation: Listenable.merge([_trophyScale, _pulseController]),
                    builder: (context, _) {
                      final scale = _trophyScale.value * _pulseController.value;
                      return Transform.scale(
                        scale: scale,
                        child: _buildTrophy(),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Congratulatory text
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        // Stars row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Icon(
                                Icons.star,
                                color: Colors.amber.shade400,
                                size: i == 2 ? 28 : 20,
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 16),

                        if (userName.isNotEmpty) ...[
                          Text(
                            userName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                        ],

                        Text(
                          isEs
                              ? 'Felicitaciones!'
                              : 'Congratulations!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          isEs
                              ? 'Has visto las ${stats.totalSpecies} especies iconicas de Galapagos!'
                              : "You've seen all ${stats.totalSpecies} iconic species of Galapagos!",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        // Badge earned callout
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                            border: Border.all(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: Color(0xFFFFD700),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  context.t.checklist.earnedBadge,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: const Color(0xFFFFD700),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Trip statistics
                        _buildTripStats(context, stats, isEs, dateFormat),

                        const SizedBox(height: 28),

                        // Action buttons
                        _buildActionButtons(isEs),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Close button at top-right
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 12,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white70, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripStats(
    BuildContext context,
    ChecklistStats stats,
    bool isEs,
    DateFormat dateFormat,
  ) {
    final items = <Widget>[];

    if (stats.daysToComplete > 0) {
      items.add(_statRow(
        context,
        Icons.timer_outlined,
        context.t.checklist.completedInDays(days: stats.daysToComplete),
      ));
    }

    if (stats.firstSeenDate != null) {
      items.add(_statRow(
        context,
        Icons.flag_outlined,
        '${context.t.checklist.firstSpecies}: ${dateFormat.format(stats.firstSeenDate!)}',
      ));
    }

    if (stats.lastSeenDate != null) {
      items.add(_statRow(
        context,
        Icons.check_circle_outline,
        '${context.t.checklist.lastSpecies}: ${dateFormat.format(stats.lastSeenDate!)}',
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _statRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophy() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFFD700),
            Color(0xFFFFA000),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Icon(
        Icons.emoji_events,
        size: 64,
        color: Colors.white,
      ),
    );
  }

  Widget _buildActionButtons(bool isEs) {
    return Column(
      children: [
        // Share button — visual card
        SizedBox(
          width: 240,
          child: ElevatedButton.icon(
            onPressed: _share,
            icon: const Icon(Icons.share),
            label: Text(context.t.checklist.shareCompletion),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Wallpapers button
        SizedBox(
          width: 240,
          child: ElevatedButton.icon(
            onPressed: () => showWallpaperUnlockSheet(context),
            icon: const Icon(Icons.wallpaper),
            label: Text(isEs ? 'Fondos de Pantalla' : 'Wallpapers'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Get Certificate button
        SizedBox(
          width: 240,
          child: ElevatedButton.icon(
            onPressed: _requestingCertificate ? null : _requestCertificate,
            icon: _requestingCertificate
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.workspace_premium),
            label: Text(isEs ? 'Obtener Certificado' : 'Get Certificate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Close button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            isEs ? 'Cerrar' : 'Close',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
