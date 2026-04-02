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
import '../providers/suggested_species_provider.dart';
import 'checklist_detail_sheet.dart';

class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key});

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
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
                  await ref
                      .read(checklistSpeciesProvider.notifier)
                      .resetToDefaults();
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
                    Text(isEs
                        ? 'Restablecer predeterminados'
                        : 'Reset to defaults'),
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
          // Build a map for quick lookup
          final speciesMap = <int, Species>{
            for (final s in allSpecies) s.id: s,
          };

          // Build display list from user's custom list
          final displaySpecies = <Species>[
            for (final id in myListIds)
              if (speciesMap.containsKey(id)) speciesMap[id]!,
          ];

          final seenInScope =
              myListIds.where((id) => seenSet.contains(id)).length;
          final total = myListIds.length;
          final allDone =
              total > 0 && myListIds.every((id) => seenSet.contains(id));

          return Column(
            children: [
              // Progress header
              _ProgressHeader(
                seen: seenInScope,
                total: total,
                isDark: isDark,
                allDone: allDone,
              ),
              const SizedBox(height: 8),
              // Species list with reorder + swipe-to-remove
              Expanded(
                child: displaySpecies.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.playlist_add,
                                  size: 64,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                isEs
                                    ? 'Tu lista esta vacia.\nToca + para agregar especies.'
                                    : 'Your list is empty.\nTap + to add species.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? Colors.white54 : Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: displaySpecies.length,
                        onReorder: (oldIndex, newIndex) {
                          ref
                              .read(checklistSpeciesProvider.notifier)
                              .reorder(oldIndex, newIndex);
                        },
                        proxyDecorator: (child, index, animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) => Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(12),
                              child: child,
                            ),
                            child: child,
                          );
                        },
                        itemBuilder: (context, index) {
                          final species = displaySpecies[index];
                          final isSeen = seenSet.contains(species.id);
                          return _SpeciesCheckRow(
                            key: ValueKey('row-${species.id}'),
                            species: species,
                            index: index,
                            isSeen: isSeen,
                            isEs: isEs,
                            isDark: isDark,
                            isAuthenticated: isAuthenticated,
                            onRemove: () {
                              ref
                                  .read(checklistSpeciesProvider.notifier)
                                  .removeSpecies(species.id);
                            },
                            onToggle: () async {
                              if (!isAuthenticated) {
                                context.push('/login');
                                return;
                              }
                              await ref
                                  .read(userChecklistProvider.notifier)
                                  .toggle(species.id);
                            },
                            onTap: () {
                              if (isSeen) {
                                final entry = ref
                                    .read(userChecklistProvider.notifier)
                                    .entryFor(species.id);
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
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!isAuthenticated) {
            context.push('/login');
            return;
          }
          _showAddSpeciesSheet(context, ref, myListIds, isDark, isEs);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── Add Species Bottom Sheet ──

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
  ConsumerState<_AddSpeciesContent> createState() =>
      _AddSpeciesContentState();
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
            error: (e, _) =>
                Center(child: Text(widget.isEs ? 'Error' : 'Error')),
            data: (allSpecies) {
              final currentIdSet = currentIds.toSet();
              var available = allSpecies
                  .where((s) => !currentIdSet.contains(s.id))
                  .toList();

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
                final aName =
                    widget.isEs ? a.commonNameEs : a.commonNameEn;
                final bName =
                    widget.isEs ? b.commonNameEs : b.commonNameEn;
                return aName.compareTo(bName);
              });

              if (available.isEmpty) {
                return Center(
                  child: Text(
                    widget.isEs
                        ? 'No hay especies disponibles'
                        : 'No species available',
                    style: TextStyle(
                        color: widget.isDark ? Colors.white54 : Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                controller: widget.scrollController,
                itemCount: available.length,
                itemBuilder: (context, index) {
                  final species = available[index];
                  final name = widget.isEs
                      ? species.commonNameEs
                      : species.commonNameEn;
                  final imageUrl = species.thumbnailUrl ??
                      SpeciesAssets.thumbnail(species.id);

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
                      style: const TextStyle(
                          fontStyle: FontStyle.italic, fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                      onPressed: () {
                        ref
                            .read(checklistSpeciesProvider.notifier)
                            .addSpecies(species.id);
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

// ── Progress Header ──

class _ProgressHeader extends StatelessWidget {
  final int seen;
  final int total;
  final bool isDark;
  final bool allDone;

  const _ProgressHeader({
    required this.seen,
    required this.total,
    required this.isDark,
    required this.allDone,
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
          color: allDone
              ? AppColors.primaryLight
              : (isDark ? AppColors.darkBorder : Colors.grey.shade200),
          width: allDone ? 2 : 1,
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
                    allDone ? AppColors.primaryLight : AppColors.primary,
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
                  tr.checklist.progress(
                      seen: seen.toString(), total: total.toString()),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (allDone) ...[
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

// ── Species Check Row ──

class _SpeciesCheckRow extends StatelessWidget {
  final Species species;
  final int index;
  final bool isSeen;
  final bool isEs;
  final bool isDark;
  final bool isAuthenticated;
  final VoidCallback onRemove;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _SpeciesCheckRow({
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

  @override
  Widget build(BuildContext context) {
    final name = isEs ? species.commonNameEs : species.commonNameEn;
    final imageUrl =
        species.thumbnailUrl ?? SpeciesAssets.thumbnail(species.id);

    return Dismissible(
      key: ValueKey('dismiss-${species.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onRemove(),
      child: Container(
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedSpeciesImage(
                  imageUrl: imageUrl,
                  speciesId: species.id,
                  width: 48,
                  height: 48,
                ),
              ),
            ],
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
          isSeen ? Icons.check : Icons.radio_button_unchecked,
          size: 20,
          color: isSeen
              ? Colors.white
              : (isDark ? Colors.white54 : Colors.grey.shade600),
        ),
      ),
    );
  }
}
