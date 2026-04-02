import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import 'package:galapagos_wildlife/core/widgets/cached_species_image.dart';
import 'package:galapagos_wildlife/models/species.model.dart';
import 'package:galapagos_wildlife/features/species/shared/species_checklist_provider.dart';
import 'package:galapagos_wildlife/features/species/list/species_list_provider.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';
import 'package:galapagos_wildlife/features/purchases/providers/purchase_provider.dart';
import 'package:galapagos_wildlife/features/purchases/presentation/paywall_screen.dart';
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';
import '../providers/suggested_species_provider.dart';
import '../services/celebration_effects_service.dart';
import 'checklist_detail_sheet.dart';
import 'checklist_completion_dialog.dart';

// ── View mode enum ──

enum _ViewMode { grid, list }

// ══════════════════════════════════════════════════════════════════════════════
// ChecklistScreen
// ══════════════════════════════════════════════════════════════════════════════

class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key});

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  _ViewMode _viewMode = _ViewMode.grid;

  @override
  Widget build(BuildContext context) {
    final tr = context.t;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEs = ref.watch(localeProvider.select((l) => l == 'es'));
    final allSpeciesAsync = ref.watch(allSpeciesProvider);
    final checklistAsync = ref.watch(userChecklistProvider);
    final myListAsync = ref.watch(checklistSpeciesProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isPremium = ref.watch(isPremiumProvider);

    final seenSet = checklistAsync.asData?.value ?? <int>{};
    final myListIds = myListAsync.asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.checklist.title),
        actions: [
          // View mode toggle
          IconButton(
            icon: Icon(
              _viewMode == _ViewMode.grid ? Icons.grid_view_rounded : Icons.view_list_rounded,
            ),
            tooltip: _viewMode == _ViewMode.grid
                ? (isEs ? 'Vista de lista' : 'List view')
                : (isEs ? 'Vista de cuadricula' : 'Grid view'),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == _ViewMode.grid ? _ViewMode.list : _ViewMode.grid;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'reset') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(isEs ? 'Restablecer lista' : 'Reset list'),
                    content: Text(isEs
                        ? 'Volver a las 10 especies predeterminadas?'
                        : 'Reset to the 10 default species?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(tr.common.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(isEs ? 'Restablecer' : 'Reset'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(checklistSpeciesProvider.notifier).resetToDefaults();
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    const Icon(Icons.restart_alt, size: 20),
                    const SizedBox(width: 8),
                    Text(isEs ? 'Restablecer predeterminados' : 'Reset to defaults'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: allSpeciesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(tr.common.error)),
        data: (allSpecies) {
          final speciesMap = <int, Species>{
            for (final s in allSpecies) s.id: s,
          };

          final displaySpecies = <Species>[
            for (final id in myListIds)
              if (speciesMap.containsKey(id)) speciesMap[id]!,
          ];

          final seenInScope = myListIds.where((id) => seenSet.contains(id)).length;
          final total = myListIds.length;

          return Column(
            children: [
              // Gamified progress header
              _ProgressHeader(
                seen: seenInScope,
                total: total,
                isDark: isDark,
                isEs: isEs,
              ),
              if (seenInScope == total && total > 0)
                _RewardsBanner(isDark: isDark, isEs: isEs),
              if (!_isUserPremium()) _UpgradeHint(isEs: isEs, isDark: isDark),
              const SizedBox(height: 8),
              // Content area
              Expanded(
                child: displaySpecies.isEmpty
                    ? _EmptyState(isDark: isDark, isEs: isEs, onReset: () {
                        ref.read(checklistSpeciesProvider.notifier).resetToDefaults();
                      })
                    : _viewMode == _ViewMode.grid
                        ? _GridView(
                            displaySpecies: displaySpecies,
                            seenSet: seenSet,
                            isEs: isEs,
                            isDark: isDark,
                            isAuthenticated: isAuthenticated,
                            isPremium: isPremium,
                            total: total,
                            ref: ref,
                          )
                        : _ListView(
                            displaySpecies: displaySpecies,
                            seenSet: seenSet,
                            isEs: isEs,
                            isDark: isDark,
                            isAuthenticated: isAuthenticated,
                            isPremium: isPremium,
                            total: total,
                            ref: ref,
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddSpeciesSheet(context, ref, myListIds, isDark, isEs);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Progress Header — gamified, animated
// ══════════════════════════════════════════════════════════════════════════════

class _ProgressHeader extends StatelessWidget {
  final int seen;
  final int total;
  final bool isDark;
  final bool isEs;

  const _ProgressHeader({
    required this.seen,
    required this.total,
    required this.isDark,
    required this.isEs,
  });

  /// Motivational text that changes with progress.
  String _motivationalText(double progress) {
    if (progress <= 0) return isEs ? 'Comienza tu aventura!' : 'Start your adventure!';
    if (progress <= 0.25) return isEs ? 'Explorador en entrenamiento!' : 'Explorer in training!';
    if (progress <= 0.50) return isEs ? 'Gran explorador!' : 'Great explorer!';
    if (progress <= 0.75) return isEs ? 'Casi un naturalista!' : 'Almost a naturalist!';
    if (progress < 1.0) return isEs ? 'Tan cerca de ser legendario!' : 'So close to legendary!';
    return isEs ? 'Maestro de Galapagos!' : 'Galapagos Master!';
  }

  /// Level badge emoji that evolves.
  String _levelBadge(double progress) {
    if (progress <= 0) return '\u{1F95A}';       // egg
    if (progress <= 0.25) return '\u{1F423}';     // hatching chick
    if (progress <= 0.50) return '\u{1F426}';     // bird
    if (progress <= 0.75) return '\u{1F985}';     // eagle
    return '\u{1F3C6}';                           // trophy
  }

  /// Gradient color: green at low progress, gold at high progress.
  Color _progressColor(double progress) {
    if (progress >= 1.0) return const Color(0xFFFFD700); // gold
    return Color.lerp(AppColors.primary, const Color(0xFFFFD700), progress) ?? AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? seen / total : 0.0;
    final progressColor = _progressColor(progress);
    final isComplete = progress >= 1.0;

    // Background gradient tint
    Color bgStart, bgEnd;
    if (isComplete) {
      bgStart = const Color(0xFFFFD700).withValues(alpha: isDark ? 0.12 : 0.08);
      bgEnd = const Color(0xFFFFA000).withValues(alpha: isDark ? 0.06 : 0.03);
    } else if (progress > 0.5) {
      bgStart = AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06);
      bgEnd = AppColors.primaryLight.withValues(alpha: isDark ? 0.06 : 0.02);
    } else {
      bgStart = isDark ? AppColors.darkCard : Colors.white;
      bgEnd = isDark ? AppColors.darkCard : Colors.white;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgStart, bgEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete
              ? const Color(0xFFFFD700).withValues(alpha: 0.5)
              : (progress > 0.5
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : (isDark ? AppColors.darkBorder : Colors.grey.shade200)),
          width: isComplete ? 2 : 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Level badge
              Text(
                _levelBadge(progress),
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 16),
              // Circular progress indicator
              SizedBox(
                width: 80,
                height: 80,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return CustomPaint(
                      painter: _CircularProgressPainter(
                        progress: value,
                        progressColor: progressColor,
                        trackColor: isDark ? AppColors.darkBorder : Colors.grey.shade200,
                        strokeWidth: 8,
                      ),
                      child: Center(
                        child: Text(
                          '${(value * 100).round()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$seen / $total ${isEs ? 'especies vistas' : 'species seen'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _motivationalText(progress),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: isComplete
                            ? const Color(0xFFFFD700)
                            : (isDark ? Colors.white60 : Colors.black54),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Linear progress bar
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 8,
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: isDark ? AppColors.darkBorder : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$seen/$total',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Circular progress painter with gradient stroke ──

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc with gradient
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          AppColors.primary,
          progressColor,
        ],
        transform: const GradientRotation(-math.pi / 2),
      );
      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter old) =>
      old.progress != progress || old.progressColor != progressColor;
}

// ══════════════════════════════════════════════════════════════════════════════
// Empty State
// ══════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final bool isEs;
  final VoidCallback onReset;

  const _EmptyState({
    required this.isDark,
    required this.isEs,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration-like emoji
            Text(
              '\u{1F98E}', // lizard emoji
              style: const TextStyle(fontSize: 72),
            ),
            const SizedBox(height: 20),
            Text(
              isEs ? 'Tu lista esta vacia' : 'Your list is empty',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isEs
                  ? 'Toca + para comenzar tu aventura en Galapagos!'
                  : 'Tap + to start your Galapagos adventure!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt),
              label: Text(isEs ? 'Restablecer predeterminados' : 'Reset to defaults'),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Grid View — 2-column photo cards
// ══════════════════════════════════════════════════════════════════════════════

class _GridView extends StatelessWidget {
  final List<Species> displaySpecies;
  final Set<int> seenSet;
  final bool isEs;
  final bool isDark;
  final bool isAuthenticated;
  final bool isPremium;
  final int total;
  final WidgetRef ref;

  const _GridView({
    required this.displaySpecies,
    required this.seenSet,
    required this.isEs,
    required this.isDark,
    required this.isAuthenticated,
    required this.isPremium,
    required this.total,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: displaySpecies.length,
      itemBuilder: (context, index) {
        final species = displaySpecies[index];
        final isSeen = seenSet.contains(species.id);
        return _GridCard(
          species: species,
          index: index,
          totalCount: displaySpecies.length,
          isSeen: isSeen,
          isEs: isEs,
          isDark: isDark,
          seenAt: isSeen
              ? ref.read(userChecklistProvider.notifier).entryFor(species.id)?.seenAt
              : null,
          onTap: () {
            if (isSeen) {
              final entry = ref.read(userChecklistProvider.notifier).entryFor(species.id);
              showChecklistDetailSheet(
                context: context,
                species: species,
                entry: entry,
                isPremium: isPremium,
              );
            } else {
              context.goNamed(
                'species-detail',
                pathParameters: {'id': '${species.id}'},
              );
            }
          },
          onToggle: () async {
            await ref.read(userChecklistProvider.notifier).toggle(species.id);
            CelebrationEffectsService.celebrateCheckmark();
            _checkMilestones(context, ref);
          },
          onRemove: () {
            ref.read(checklistSpeciesProvider.notifier).removeSpecies(species.id);
          },
          onMoveUp: index > 0 ? () {
            ref.read(checklistSpeciesProvider.notifier).reorder(index, index - 1);
          } : null,
          onMoveDown: index < displaySpecies.length - 1 ? () {
            ref.read(checklistSpeciesProvider.notifier).reorder(index, index + 2);
          } : null,
        );
      },
    );
  }

  void _checkMilestones(BuildContext context, WidgetRef ref) {
    final currentSeen = ref.read(userChecklistProvider).asData?.value ?? <int>{};
    final myIds = ref.read(checklistSpeciesProvider).asData?.value ?? [];
    final newSeenCount = myIds.where((id) => currentSeen.contains(id)).length;

    if (newSeenCount > 0 && newSeenCount % 5 == 0 && newSeenCount < total) {
      CelebrationEffectsService.celebrateMilestone();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('\u{2B50} $newSeenCount ${isEs ? 'especies vistas!' : 'species seen!'}'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (newSeenCount == (total / 2).round() && newSeenCount > 0) {
      CelebrationEffectsService.celebrateMilestone();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('\u{1F949} ${isEs ? 'A mitad de camino!' : 'Halfway there!'}'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (newSeenCount == total && total > 0) {
      CelebrationEffectsService.celebrateCompletion();
      ChecklistCompletionDialog.show(context);
    }
  }
}

// ── Grid Card ──

class _GridCard extends StatelessWidget {
  final Species species;
  final int index;
  final int totalCount;
  final bool isSeen;
  final bool isEs;
  final bool isDark;
  final DateTime? seenAt;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const _GridCard({
    required this.species,
    required this.index,
    required this.totalCount,
    required this.isSeen,
    required this.isEs,
    required this.isDark,
    required this.seenAt,
    required this.onTap,
    required this.onToggle,
    required this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
  });

  static const _grayscaleMatrix = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final name = isEs ? species.commonNameEs : species.commonNameEn;
    final imageUrl = species.thumbnailUrl ?? SpeciesAssets.thumbnail(species.id);

    final image = CachedSpeciesImage(
      imageUrl: imageUrl,
      speciesId: species.id,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );

    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        _showCardPopupMenu(context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Species image — full color or grayscale
            isSeen
                ? image
                : ColorFiltered(
                    colorFilter: _grayscaleMatrix,
                    child: image,
                  ),

            // Dark gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isSeen && seenAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(seenAt!),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Seen check badge (top-right) — large hit area for easy tapping
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onToggle,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: isSeen
                      ? Container(
                          key: const ValueKey(true),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.check, color: Colors.white, size: 20),
                        )
                      : Container(
                          key: const ValueKey(false),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.radio_button_unchecked,
                              color: Colors.white70, size: 20),
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardPopupMenu(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy + box.size.height, offset.dx + box.size.width, 0),
      items: [
        if (index > 0)
          PopupMenuItem(
            value: 'up',
            child: Row(
              children: [
                const Icon(Icons.arrow_upward, size: 20),
                const SizedBox(width: 8),
                Text(isEs ? 'Mover arriba' : 'Move up'),
              ],
            ),
          ),
        if (index < totalCount - 1)
          PopupMenuItem(
            value: 'down',
            child: Row(
              children: [
                const Icon(Icons.arrow_downward, size: 20),
                const SizedBox(width: 8),
                Text(isEs ? 'Mover abajo' : 'Move down'),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              Text(isEs ? 'Quitar de la lista' : 'Remove from list'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'up') onMoveUp?.call();
      if (value == 'down') onMoveDown?.call();
      if (value == 'remove') onRemove();
    });
  }

  String _formatDate(DateTime date) {
    final months = isEs
        ? ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']
        : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// List View — reorderable, swipe to remove
// ══════════════════════════════════════════════════════════════════════════════

class _ListView extends StatelessWidget {
  final List<Species> displaySpecies;
  final Set<int> seenSet;
  final bool isEs;
  final bool isDark;
  final bool isAuthenticated;
  final bool isPremium;
  final int total;
  final WidgetRef ref;

  const _ListView({
    required this.displaySpecies,
    required this.seenSet,
    required this.isEs,
    required this.isDark,
    required this.isAuthenticated,
    required this.isPremium,
    required this.total,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: displaySpecies.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(checklistSpeciesProvider.notifier).reorder(oldIndex, newIndex);
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) => Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(14),
            shadowColor: AppColors.primary.withValues(alpha: 0.3),
            child: child,
          ),
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final species = displaySpecies[index];
        final isSeen = seenSet.contains(species.id);
        return _ListRow(
          key: ValueKey('row-${species.id}'),
          species: species,
          index: index,
          isSeen: isSeen,
          isEs: isEs,
          isDark: isDark,
          isAuthenticated: isAuthenticated,
          onRemove: () {
            ref.read(checklistSpeciesProvider.notifier).removeSpecies(species.id);
          },
          onToggle: () async {
            await ref.read(userChecklistProvider.notifier).toggle(species.id);
            CelebrationEffectsService.celebrateCheckmark();
            _checkMilestones(context);
          },
          onTap: () {
            if (isSeen) {
              final entry = ref.read(userChecklistProvider.notifier).entryFor(species.id);
              showChecklistDetailSheet(
                context: context,
                species: species,
                entry: entry,
                isPremium: isPremium,
              );
            } else {
              context.goNamed(
                'species-detail',
                pathParameters: {'id': '${species.id}'},
              );
            }
          },
        );
      },
    );
  }

  void _checkMilestones(BuildContext context) {
    final currentSeen = ref.read(userChecklistProvider).asData?.value ?? <int>{};
    final myIds = ref.read(checklistSpeciesProvider).asData?.value ?? [];
    final newSeenCount = myIds.where((id) => currentSeen.contains(id)).length;

    if (newSeenCount > 0 && newSeenCount % 5 == 0 && newSeenCount < total) {
      CelebrationEffectsService.celebrateMilestone();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('\u{2B50} $newSeenCount ${isEs ? 'especies vistas!' : 'species seen!'}'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (newSeenCount == (total / 2).round() && newSeenCount > 0) {
      CelebrationEffectsService.celebrateMilestone();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('\u{1F949} ${isEs ? 'A mitad de camino!' : 'Halfway there!'}'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (newSeenCount == total && total > 0) {
      CelebrationEffectsService.celebrateCompletion();
      ChecklistCompletionDialog.show(context);
    }
  }
}

// ── List Row ──

class _ListRow extends StatelessWidget {
  final Species species;
  final int index;
  final bool isSeen;
  final bool isEs;
  final bool isDark;
  final bool isAuthenticated;
  final VoidCallback onRemove;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _ListRow({
    super.key,
    required this.species,
    required this.index,
    required this.isSeen,
    required this.isEs,
    required this.isDark,
    required this.isAuthenticated,
    required this.onRemove,
    required this.onToggle,
    required this.onTap,
  });

  static const _grayscaleMatrix = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final name = isEs ? species.commonNameEs : species.commonNameEn;
    final imageUrl = species.thumbnailUrl ?? SpeciesAssets.thumbnail(species.id);

    final thumbnail = ClipOval(
      child: SizedBox(
        width: 50,
        height: 50,
        child: CachedSpeciesImage(
          imageUrl: imageUrl,
          speciesId: species.id,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
    );

    return Dismissible(
      key: ValueKey('dismiss-${species.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onRemove(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSeen
              ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.06)
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSeen
                ? AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.25)
                : (isDark ? AppColors.darkBorder : Colors.grey.shade200),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.drag_handle,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                  ),
                ),
              ),
              // Circular thumbnail — color or grayscale
              isSeen
                  ? thumbnail
                  : ColorFiltered(
                      colorFilter: _grayscaleMatrix,
                      child: thumbnail,
                    ),
            ],
          ),
          title: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            species.scientificName,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
          trailing: GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: isSeen
                    ? Icon(Icons.check_circle,
                        key: const ValueKey(true), color: AppColors.primary, size: 28)
                    : Icon(Icons.radio_button_unchecked,
                        key: const ValueKey(false),
                        color: isDark ? Colors.white38 : Colors.grey,
                        size: 28),
              ),
            ),
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Add Species Bottom Sheet
// ══════════════════════════════════════════════════════════════════════════════

void _showAddSpeciesSheet(
  BuildContext context,
  WidgetRef ref,
  List<int> currentIds,
  bool isDark,
  bool isEs,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => _AddSpeciesContent(
        currentIds: currentIds,
        scrollController: scrollController,
        isDark: isDark,
        isEs: isEs,
      ),
    ),
  );
}

class _AddSpeciesContent extends ConsumerStatefulWidget {
  final List<int> currentIds;
  final ScrollController scrollController;
  final bool isDark;
  final bool isEs;

  const _AddSpeciesContent({
    required this.currentIds,
    required this.scrollController,
    required this.isDark,
    required this.isEs,
  });

  @override
  ConsumerState<_AddSpeciesContent> createState() => _AddSpeciesContentState();
}

class _AddSpeciesContentState extends ConsumerState<_AddSpeciesContent> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final allSpeciesAsync = ref.watch(allSpeciesProvider);
    final currentIds = ref.watch(checklistSpeciesProvider).asData?.value ?? [];

    return Column(
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            widget.isEs ? 'Agregar especie' : 'Add species',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: widget.isEs ? 'Buscar especie...' : 'Search species...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v.toLowerCase()),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: allSpeciesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(widget.isEs ? 'Error' : 'Error')),
            data: (allSpecies) {
              final currentIdSet = currentIds.toSet();
              var available = allSpecies.where((s) => !currentIdSet.contains(s.id)).toList();

              if (_query.isNotEmpty) {
                available = available.where((s) {
                  final name = widget.isEs
                      ? s.commonNameEs.toLowerCase()
                      : s.commonNameEn.toLowerCase();
                  final sci = s.scientificName.toLowerCase();
                  return name.contains(_query) || sci.contains(_query);
                }).toList();
              }

              // Sort alphabetically
              available.sort((a, b) {
                final aName = widget.isEs ? a.commonNameEs : a.commonNameEn;
                final bName = widget.isEs ? b.commonNameEs : b.commonNameEn;
                return aName.compareTo(bName);
              });

              if (available.isEmpty) {
                return Center(
                  child: Text(
                    widget.isEs ? 'No hay especies disponibles' : 'No species available',
                    style: TextStyle(color: widget.isDark ? Colors.white54 : Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                controller: widget.scrollController,
                itemCount: available.length,
                itemBuilder: (context, index) {
                  final species = available[index];
                  final name = widget.isEs ? species.commonNameEs : species.commonNameEn;
                  final imageUrl =
                      species.thumbnailUrl ?? SpeciesAssets.thumbnail(species.id);

                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedSpeciesImage(
                        imageUrl: imageUrl,
                        speciesId: species.id,
                        width: 44,
                        height: 44,
                      ),
                    ),
                    title: Text(name),
                    subtitle: Text(
                      species.scientificName,
                      style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                      onPressed: () {
                        ref.read(checklistSpeciesProvider.notifier).addSpecies(species.id);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Premium check helper ────────────────────────────────────────────────────

bool _isUserPremium() {
  final prefs = Bootstrap.prefs;
  return (prefs.getBool('has_premium_role') ?? false)
      || (prefs.getBool('is_beta_tester') ?? false)
      || (prefs.getBool('has_pack') ?? false)
      || (prefs.getBool('has_pro') ?? false);
}

// ─── Upgrade Hint (subtle banner for free users) ─────────────────────────────

class _UpgradeHint extends StatelessWidget {
  final bool isEs;
  final bool isDark;

  const _UpgradeHint({required this.isEs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPaywall(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.15),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_outline, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isEs
                    ? 'Actualiza para ver fechas, GPS y fotos de tus avistamientos'
                    : 'Upgrade to see dates, GPS & photos of your sightings',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

// ── Rewards Banner (shown when checklist is 100% complete) ──

class _RewardsBanner extends StatelessWidget {
  final bool isDark;
  final bool isEs;

  const _RewardsBanner({required this.isDark, required this.isEs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ChecklistCompletionDialog.show(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEs ? '¡Checklist completado!' : 'Checklist Complete!',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    isEs ? 'Ver premios, certificado y wallpapers' : 'View rewards, certificate & wallpapers',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
