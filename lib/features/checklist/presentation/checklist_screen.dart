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
import '../providers/suggested_species_provider.dart';

enum _ChecklistFilter { all, seen, unseen }

class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key});

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  bool _showSuggestedOnly = true;
  _ChecklistFilter _filter = _ChecklistFilter.all;

  @override
  Widget build(BuildContext context) {
    final tr = context.t;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEs = ref.watch(localeProvider.select((l) => l == 'es'));
    final allSpeciesAsync = ref.watch(allSpeciesProvider);
    final checklistAsync = ref.watch(userChecklistProvider);
    final suggestedIds = ref.watch(suggestedSpeciesIdsProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    final seenSet = checklistAsync.asData?.value ?? <int>{};

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.checklist.title),
        actions: [
          // Filter popup
          PopupMenuButton<_ChecklistFilter>(
            icon: Icon(
              Icons.filter_list,
              color: _filter != _ChecklistFilter.all
                  ? AppColors.primary
                  : null,
            ),
            onSelected: (f) => setState(() => _filter = f),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _ChecklistFilter.all,
                child: Text(tr.checklist.filterAll),
              ),
              PopupMenuItem(
                value: _ChecklistFilter.seen,
                child: Text(tr.checklist.filterSeen),
              ),
              PopupMenuItem(
                value: _ChecklistFilter.unseen,
                child: Text(tr.checklist.filterUnseen),
              ),
            ],
          ),
        ],
      ),
      body: allSpeciesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(tr.common.error)),
        data: (allSpecies) {
          // Determine which species to display
          List<Species> displaySpecies;
          if (_showSuggestedOnly) {
            final idSet = suggestedIds.toSet();
            displaySpecies = allSpecies
                .where((s) => idSet.contains(s.id))
                .toList();
            // Sort by the order in suggestedIds
            displaySpecies.sort((a, b) =>
                suggestedIds.indexOf(a.id).compareTo(suggestedIds.indexOf(b.id)));
          } else {
            displaySpecies = List.of(allSpecies)
              ..sort((a, b) {
                final aName = isEs ? a.commonNameEs : a.commonNameEn;
                final bName = isEs ? b.commonNameEs : b.commonNameEn;
                return aName.compareTo(bName);
              });
          }

          // Apply seen/unseen filter
          if (_filter == _ChecklistFilter.seen) {
            displaySpecies =
                displaySpecies.where((s) => seenSet.contains(s.id)).toList();
          } else if (_filter == _ChecklistFilter.unseen) {
            displaySpecies =
                displaySpecies.where((s) => !seenSet.contains(s.id)).toList();
          }

          final totalForProgress =
              _showSuggestedOnly ? suggestedIds.length : allSpecies.length;
          final seenInScope = _showSuggestedOnly
              ? seenSet.where((id) => suggestedIds.contains(id)).length
              : seenSet.length;

          // Check if all suggested are completed
          final allSuggestedDone = _showSuggestedOnly &&
              suggestedIds.every((id) => seenSet.contains(id));

          return Column(
            children: [
              // Progress header
              _ProgressHeader(
                seen: seenInScope,
                total: totalForProgress,
                isDark: isDark,
                allSuggestedDone: allSuggestedDone,
              ),
              // Toggle row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _ToggleChip(
                        label: tr.checklist.suggested,
                        selected: _showSuggestedOnly,
                        onTap: () =>
                            setState(() => _showSuggestedOnly = true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ToggleChip(
                        label:
                            '${tr.checklist.allSpecies} (${allSpecies.length})',
                        selected: !_showSuggestedOnly,
                        onTap: () =>
                            setState(() => _showSuggestedOnly = false),
                      ),
                    ),
                  ],
                ),
              ),
              // Species list
              Expanded(
                child: displaySpecies.isEmpty
                    ? Center(
                        child: Text(
                          tr.species.noResults,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: displaySpecies.length,
                        itemBuilder: (context, index) {
                          final species = displaySpecies[index];
                          final isSeen = seenSet.contains(species.id);
                          return _SpeciesCheckRow(
                            species: species,
                            isSeen: isSeen,
                            isEs: isEs,
                            isDark: isDark,
                            isAuthenticated: isAuthenticated,
                            onToggle: () async {
                              if (!isAuthenticated) {
                                context.push('/login');
                                return;
                              }
                              await ref
                                  .read(userChecklistProvider.notifier)
                                  .toggle(species.id);
                            },
                            onTap: () => context.goNamed(
                              'species-detail',
                              pathParameters: {'id': '${species.id}'},
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Progress Header ──

class _ProgressHeader extends StatelessWidget {
  final int seen;
  final int total;
  final bool isDark;
  final bool allSuggestedDone;

  const _ProgressHeader({
    required this.seen,
    required this.total,
    required this.isDark,
    required this.allSuggestedDone,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.t;
    final progress = total > 0 ? seen / total : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: allSuggestedDone
              ? AppColors.primaryLight
              : (isDark ? AppColors.darkBorder : Colors.grey.shade200),
          width: allSuggestedDone ? 2 : 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor:
                      isDark ? AppColors.darkBorder : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    allSuggestedDone
                        ? AppColors.primaryLight
                        : AppColors.primary,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr.checklist.progress(seen: seen.toString(), total: total.toString()),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (allSuggestedDone) ...[
                  const SizedBox(height: 4),
                  Text(
                    tr.checklist.allSuggested,
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toggle Chip ──

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.12)
              : (isDark ? AppColors.darkCard : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : Colors.grey.shade300),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? AppColors.primary
                : (isDark ? Colors.white70 : Colors.black54),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── Species Check Row ──

class _SpeciesCheckRow extends StatelessWidget {
  final Species species;
  final bool isSeen;
  final bool isEs;
  final bool isDark;
  final bool isAuthenticated;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _SpeciesCheckRow({
    required this.species,
    required this.isSeen,
    required this.isEs,
    required this.isDark,
    required this.isAuthenticated,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = isEs ? species.commonNameEs : species.commonNameEn;
    final imageUrl =
        species.thumbnailUrl ?? SpeciesAssets.thumbnail(species.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: isSeen
            ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.06)
            : (isDark ? AppColors.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSeen
              ? AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.25)
              : (isDark ? AppColors.darkBorder : Colors.grey.shade200),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedSpeciesImage(
            imageUrl: imageUrl,
            speciesId: species.id,
            width: 52,
            height: 52,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
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
        trailing: _CheckButton(
          isSeen: isSeen,
          isDark: isDark,
          onTap: onToggle,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// ── Check Button ──

class _CheckButton extends StatelessWidget {
  final bool isSeen;
  final bool isDark;
  final VoidCallback onTap;

  const _CheckButton({
    required this.isSeen,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSeen
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : Colors.grey.shade200),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSeen
                ? AppColors.primaryDark
                : (isDark ? Colors.white24 : Colors.grey.shade400),
            width: 1.5,
          ),
        ),
        child: Icon(
          isSeen ? Icons.check : Icons.add,
          size: 20,
          color: isSeen
              ? Colors.white
              : (isDark ? Colors.white54 : Colors.grey.shade600),
        ),
      ),
    );
  }
}
