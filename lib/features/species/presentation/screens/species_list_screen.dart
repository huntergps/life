import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/utils/species_display_helpers.dart';
import 'package:galapagos_wildlife/core/widgets/error_state_widget.dart';
import '../../providers/species_list_provider.dart';
import 'package:galapagos_wildlife/core/widgets/species_list_card.dart';
import 'package:galapagos_wildlife/core/widgets/search_bar_widget.dart';
import 'package:galapagos_wildlife/core/widgets/empty_state.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import 'package:galapagos_wildlife/features/home/providers/home_provider.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';

class SpeciesListScreen extends ConsumerStatefulWidget {
  final int? categoryId;
  const SpeciesListScreen({super.key, this.categoryId});

  @override
  ConsumerState<SpeciesListScreen> createState() => _SpeciesListScreenState();
}

class _SpeciesListScreenState extends ConsumerState<SpeciesListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      Future.microtask(() {
        ref.read(speciesCategoryFilterProvider.notifier).state = widget.categoryId;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(speciesSearchQueryProvider.notifier).state = value;
    });
  }

  void _clearAllFilters() {
    _debounce?.cancel();
    ref.read(speciesCategoryFilterProvider.notifier).state = null;
    ref.read(speciesConservationFilterProvider.notifier).state = null;
    ref.read(speciesEndemicFilterProvider.notifier).state = null;
    ref.read(speciesDietFilterProvider.notifier).state = null;
    ref.read(speciesActivityFilterProvider.notifier).state = null;
    ref.read(speciesSearchQueryProvider.notifier).state = '';
    _searchController.clear();
  }

  void _showSortPicker(BuildContext context) {
    final current = ref.read(speciesSortProvider);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                context.t.species.sortBy,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ..._sortOptions(context).map((opt) => ListTile(
              leading: Icon(opt.$3, color: current == opt.$1 ? Theme.of(context).colorScheme.primary : null),
              title: Text(opt.$2),
              selected: current == opt.$1,
              onTap: () {
                ref.read(speciesSortProvider.notifier).state = opt.$1;
                Navigator.pop(ctx);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FilterSheet(
        onClear: _clearAllFilters,
      ),
    );
  }

  List<(SpeciesSort, String, IconData)> _sortOptions(BuildContext context) => [
    (SpeciesSort.nameAsc,     context.t.species.sortNameAsc,     Icons.sort_by_alpha),
    (SpeciesSort.nameDesc,    context.t.species.sortNameDesc,    Icons.sort),
    (SpeciesSort.rarityFirst, context.t.species.sortRarityFirst, Icons.warning_amber_outlined),
    (SpeciesSort.endemicFirst,context.t.species.sortEndemicFirst,Icons.eco_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final speciesAsync    = ref.watch(speciesListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final countsAsync     = ref.watch(speciesCountByCategoryProvider);
    final selectedCategory = ref.watch(speciesCategoryFilterProvider);
    final selectedConservation = ref.watch(speciesConservationFilterProvider);
    final endemicFilter   = ref.watch(speciesEndemicFilterProvider);
    final dietFilter      = ref.watch(speciesDietFilterProvider);
    final activityFilter  = ref.watch(speciesActivityFilterProvider);
    final currentSort     = ref.watch(speciesSortProvider);
    final locale          = ref.watch(localeProvider);
    final crossAxisCount  = AdaptiveLayout.gridColumns(context);
    final padding         = AdaptiveLayout.responsivePadding(context);
    final counts          = countsAsync.asData?.value ?? {};

    final hasAdvancedFilters = selectedConservation != null ||
        endemicFilter != null || dietFilter != null || activityFilter != null;
    final hasAnyFilter = hasAdvancedFilters || selectedCategory != null;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allSpeciesProvider);
          ref.invalidate(categoriesProvider);
          await ref.read(allSpeciesProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            // ── Floating header: title + search + category chips ───────────────
            SliverAppBar(
              title: Text(context.t.species.title),
              floating: true,
              snap: false,
              pinned: false,
              forceElevated: true,
              actions: [
                // Advanced filters button — badge when active
                IconButton(
                  icon: Badge(
                    isLabelVisible: hasAdvancedFilters,
                    child: const Icon(Icons.tune),
                  ),
                  tooltip: context.t.species.filterHelp,
                  onPressed: () => _showFilterSheet(context),
                ),
                // Sort
                IconButton(
                  icon: Icon(
                    Icons.swap_vert,
                    color: currentSort != SpeciesSort.nameAsc
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  tooltip: context.t.species.sortBy,
                  onPressed: () => _showSortPicker(context),
                ),
                // Compare
                IconButton(
                  icon: const Icon(Icons.compare_arrows),
                  tooltip: context.t.species.compare,
                  onPressed: () => context.goNamed('species-compare'),
                ),
              ],
              // Search bar + category chips collapse with the app bar
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(104),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(padding, 0, padding, 6),
                      child: SearchBarWidget(
                        hintText: context.t.species.search,
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onClear: () {
                          _debounce?.cancel();
                          ref.read(speciesSearchQueryProvider.notifier).state = '';
                        },
                      ),
                    ),
                    // Category chips
                    SizedBox(
                      height: 40,
                      child: categoriesAsync.when(
                        data: (categories) => ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: FilterChip(
                                label: Text('${context.t.species.all} (${counts[null] ?? 0})'),
                                selected: selectedCategory == null,
                                onSelected: (_) => ref
                                    .read(speciesCategoryFilterProvider.notifier)
                                    .state = null,
                              ),
                            ),
                            ...categories.map((cat) {
                              final catCount = counts[cat.id] ?? 0;
                              final name = locale == 'es' ? cat.nameEs : cat.nameEn;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: FilterChip(
                                  label: Text('$name ($catCount)'),
                                  selected: selectedCategory == cat.id,
                                  onSelected: (_) {
                                    ref
                                        .read(speciesCategoryFilterProvider.notifier)
                                        .state = selectedCategory == cat.id
                                        ? null
                                        : cat.id;
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),

            // ── Active filters summary + result count ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padding, 8, padding, 2),
                child: Row(
                  children: [
                    // Active filter chips (compact)
                    if (hasAdvancedFilters) ...[
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (endemicFilter == true)
                                _ActiveFilterChip(
                                  label: context.t.species.endemic,
                                  onRemove: () => ref
                                      .read(speciesEndemicFilterProvider.notifier)
                                      .state = null,
                                ),
                              if (selectedConservation != null)
                                _ActiveFilterChip(
                                  label: selectedConservation,
                                  color: conservationStatusColor(selectedConservation),
                                  onRemove: () => ref
                                      .read(speciesConservationFilterProvider.notifier)
                                      .state = null,
                                ),
                              if (dietFilter != null)
                                _ActiveFilterChip(
                                  label: dietLabel(dietFilter, spanish: locale == 'es'),
                                  onRemove: () => ref
                                      .read(speciesDietFilterProvider.notifier)
                                      .state = null,
                                ),
                              if (activityFilter != null)
                                _ActiveFilterChip(
                                  label: activityLabel(activityFilter, spanish: locale == 'es'),
                                  onRemove: () => ref
                                      .read(speciesActivityFilterProvider.notifier)
                                      .state = null,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Result count
                    speciesAsync.maybeWhen(
                      data: (species) => Text(
                        '${species.length} ${context.t.species.title.toLowerCase()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                    // Clear all
                    if (hasAnyFilter) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _clearAllFilters,
                        child: Icon(
                          Icons.clear_all,
                          size: 18,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Species list / grid ────────────────────────────────────────────
            ...speciesAsync.when(
              data: (species) {
                if (species.isEmpty) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.search_off,
                        title: context.t.species.noResults,
                        subtitle: context.t.species.noResultsSubtitle,
                      ),
                    ),
                  ];
                }

                if (crossAxisCount == 1) {
                  return [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                          padding * 0.75, 0, padding * 0.75, padding * 0.75),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final s = species[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: RepaintBoundary(
                                child: SpeciesListCard(
                                  key: ValueKey(s.id),
                                  commonName: locale == 'es'
                                      ? s.commonNameEs
                                      : s.commonNameEn,
                                  scientificName: s.scientificName,
                                  thumbnailUrl: s.thumbnailUrl ??
                                      SpeciesAssets.thumbnail(s.id),
                                  conservationStatus: s.conservationStatus,
                                  isEndemic: s.isEndemic,
                                  speciesId: s.id,
                                  dietType: s.dietType,
                                  activityPattern: s.activityPattern,
                                  populationTrend: s.populationTrend,
                                  onTap: () => context.goNamed(
                                    'species-detail',
                                    pathParameters: {'id': '${s.id}'},
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: species.length,
                        ),
                      ),
                    ),
                  ];
                }

                return [
                  SliverPadding(
                    padding: EdgeInsets.all(padding * 0.75),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final s = species[index];
                          return RepaintBoundary(
                            child: SpeciesListCard(
                              key: ValueKey(s.id),
                              commonName: locale == 'es'
                                  ? s.commonNameEs
                                  : s.commonNameEn,
                              scientificName: s.scientificName,
                              thumbnailUrl: s.thumbnailUrl ??
                                  SpeciesAssets.thumbnail(s.id),
                              conservationStatus: s.conservationStatus,
                              isEndemic: s.isEndemic,
                              speciesId: s.id,
                              dietType: s.dietType,
                              activityPattern: s.activityPattern,
                              populationTrend: s.populationTrend,
                              onTap: () => context.goNamed(
                                'species-detail',
                                pathParameters: {'id': '${s.id}'},
                              ),
                            ),
                          );
                        },
                        childCount: species.length,
                      ),
                    ),
                  ),
                ];
              },
              loading: () => [
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (e, _) => [
                SliverFillRemaining(
                  child: ErrorStateWidget(
                    error: e,
                    onRetry: () => ref.invalidate(allSpeciesProvider),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

// ── Small chip shown in the active filters row ────────────────────────────────

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback onRemove;

  const _ActiveFilterChip({
    required this.label,
    required this.onRemove,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        label: Text(label, style: TextStyle(fontSize: 12, color: c)),
        side: BorderSide(color: c.withValues(alpha: 0.5)),
        backgroundColor: c.withValues(alpha: 0.1),
        deleteIcon: Icon(Icons.close, size: 14, color: c),
        onDeleted: onRemove,
      ),
    );
  }
}

// ── Advanced filter bottom sheet ──────────────────────────────────────────────

class _FilterSheet extends ConsumerWidget {
  final VoidCallback onClear;
  const _FilterSheet({required this.onClear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedConservation = ref.watch(speciesConservationFilterProvider);
    final endemicFilter  = ref.watch(speciesEndemicFilterProvider);
    final dietFilter     = ref.watch(speciesDietFilterProvider);
    final activityFilter = ref.watch(speciesActivityFilterProvider);

    final hasAny = selectedConservation != null || endemicFilter != null ||
        dietFilter != null || activityFilter != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle + title row
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  context.t.species.filterHelp,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (hasAny)
                  TextButton.icon(
                    onPressed: () {
                      onClear();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: Text(context.t.species.clearFilters),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Conservation & Endemic
            _SheetSectionLabel(context.t.species.conservationFilter),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                FilterChip(
                  avatar: endemicFilter == true
                      ? null
                      : const Icon(Icons.eco, size: 16, color: Colors.green),
                  label: Text(context.t.species.endemic),
                  selected: endemicFilter == true,
                  selectedColor: Colors.green.withValues(alpha: 0.2),
                  checkmarkColor: Colors.green,
                  onSelected: (val) => ref
                      .read(speciesEndemicFilterProvider.notifier)
                      .state = val ? true : null,
                ),
                ..._conservationStatuses.map((status) {
                  final color = conservationStatusColor(status);
                  return FilterChip(
                    label: Text(status),
                    selected: selectedConservation == status,
                    selectedColor: color.withValues(alpha: 0.25),
                    checkmarkColor: color,
                    side: selectedConservation == status
                        ? BorderSide(color: color, width: 1.5)
                        : null,
                    onSelected: (val) => ref
                        .read(speciesConservationFilterProvider.notifier)
                        .state = val ? status : null,
                  );
                }),
              ],
            ),
            const SizedBox(height: 14),

            // Diet
            _SheetSectionLabel(context.t.species.dietFilter),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _dietOptions.map((diet) => FilterChip(
                avatar: dietFilter == diet.$1
                    ? null
                    : Icon(diet.$3, size: 16),
                label: Text(diet.$2),
                selected: dietFilter == diet.$1,
                onSelected: (val) => ref
                    .read(speciesDietFilterProvider.notifier)
                    .state = val ? diet.$1 : null,
              )).toList(),
            ),
            const SizedBox(height: 14),

            // Activity
            _SheetSectionLabel(context.t.species.activityFilter),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _activityOptions.map((act) => FilterChip(
                label: Text(act.$2),
                selected: activityFilter == act.$1,
                onSelected: (val) => ref
                    .read(speciesActivityFilterProvider.notifier)
                    .state = val ? act.$1 : null,
              )).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static const _conservationStatuses = ['CR', 'EN', 'VU', 'NT', 'LC', 'DD'];

  static const _dietOptions = [
    ('herbivore',   'Herbívoro',   Icons.eco_outlined),
    ('carnivore',   'Carnívoro',   Icons.set_meal_outlined),
    ('omnivore',    'Omnívoro',    Icons.restaurant_outlined),
    ('piscivore',   'Piscívoro',   Icons.phishing_outlined),
    ('insectivore', 'Insectívoro', Icons.bug_report_outlined),
    ('nectarivore', 'Nectarívoro', Icons.local_florist_outlined),
  ];

  static const _activityOptions = [
    ('diurnal',     '☀ Diurno'),
    ('nocturnal',   '🌙 Nocturno'),
    ('crepuscular', '🌅 Crepuscular'),
    ('cathemeral',  '🔄 Cathemeral'),
  ];
}

class _SheetSectionLabel extends StatelessWidget {
  final String text;
  const _SheetSectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
    ),
  );
}
