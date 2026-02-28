import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
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
    _searchController.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    ref.read(speciesCategoryFilterProvider.notifier).state = null;
    ref.read(speciesConservationFilterProvider.notifier).state = null;
    ref.read(speciesEndemicFilterProvider.notifier).state = null;
    ref.read(speciesSearchQueryProvider.notifier).state = '';
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final speciesAsync = ref.watch(speciesListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final countsAsync = ref.watch(speciesCountByCategoryProvider);
    final selectedCategory = ref.watch(speciesCategoryFilterProvider);
    final selectedConservation = ref.watch(speciesConservationFilterProvider);
    final endemicFilter = ref.watch(speciesEndemicFilterProvider);
    final hasFilters = ref.watch(hasActiveFiltersProvider);
    final locale = ref.watch(localeProvider);
    final crossAxisCount = AdaptiveLayout.gridColumns(context);
    final padding = AdaptiveLayout.responsivePadding(context);
    final counts = countsAsync.asData?.value ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.species.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: context.t.species.compare,
            onPressed: () => context.goNamed('species-compare'),
          ),
        ],
      ),
      body: AdaptiveLayout.constrainedContent(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: SearchBarWidget(
                hintText: context.t.species.search,
                controller: _searchController,
                onChanged: (value) {
                  ref.read(speciesSearchQueryProvider.notifier).state = value;
                },
                onClear: () {
                  ref.read(speciesSearchQueryProvider.notifier).state = '';
                },
              ),
            ),
            // Category filter section with header
            Padding(
              padding: EdgeInsets.fromLTRB(padding, 8, padding, 4),
              child: Row(
                children: [
                  Text(
                    context.t.species.categoryFilter,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.help_outline, size: 18),
                    iconSize: 18,
                    tooltip: context.t.species.filterHelp,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(context.t.species.filterHelp),
                          content: Text(context.t.species.filterHelpText),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(context.t.common.ok),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Category filter chips with counts
            categoriesAsync.when(
              data: (categories) {
                final totalCount = counts[null] ?? 0;

                return SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text('${context.t.species.all} ($totalCount)'),
                          selected: selectedCategory == null,
                          onSelected: (_) {
                            ref.read(speciesCategoryFilterProvider.notifier).state = null;
                          },
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
                              ref.read(speciesCategoryFilterProvider.notifier).state =
                                  selectedCategory == cat.id ? null : cat.id;
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            // Conservation & Endemic filter section with header
            Padding(
              padding: EdgeInsets.fromLTRB(padding, 12, padding, 4),
              child: Text(
                context.t.species.conservationFilter,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            // Conservation + Endemic filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  // Endemic toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      avatar: endemicFilter == true
                          ? null
                          : Icon(Icons.eco, size: 16, color: Colors.green),
                      label: Text(context.t.species.endemic),
                      selected: endemicFilter == true,
                      selectedColor: Colors.green.withValues(alpha: 0.2),
                      checkmarkColor: Colors.green,
                      onSelected: (val) {
                        ref.read(speciesEndemicFilterProvider.notifier).state =
                            val ? true : null;
                      },
                    ),
                  ),
                  const VerticalDivider(width: 16, indent: 8, endIndent: 8),
                  // Conservation status chips
                  ..._conservationStatuses.map((status) {
                    final color = _statusColor(status);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: FilterChip(
                        label: Text(status),
                        selected: selectedConservation == status,
                        selectedColor: color.withValues(alpha: 0.25),
                        checkmarkColor: color,
                        side: selectedConservation == status
                            ? BorderSide(color: color, width: 1.5)
                            : null,
                        onSelected: (val) {
                          ref.read(speciesConservationFilterProvider.notifier).state =
                              val ? status : null;
                        },
                      ),
                    );
                  }),
                  // Clear all button (always visible, disabled when no filters)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.clear, size: 16),
                      label: Text(context.t.species.clearFilters),
                      onPressed: (hasFilters || selectedCategory != null) ? _clearAllFilters : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Result count
            speciesAsync.when(
              data: (species) => Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${species.length} ${context.t.species.title.toLowerCase()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 4),
            // Species grid with pull-to-refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(allSpeciesProvider);
                  ref.invalidate(categoriesProvider);
                  await ref.read(allSpeciesProvider.future);
                },
                child: speciesAsync.when(
                  data: (species) {
                    if (species.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: EmptyState(
                              icon: Icons.search_off,
                              title: context.t.species.noResults,
                              subtitle: context.t.species.noResultsSubtitle,
                            ),
                          ),
                        ],
                      );
                    }
                    // Phone → single-column ListView (natural height per card)
                    // Tablet/desktop → multi-column GridView
                    if (crossAxisCount == 1) {
                      return ListView.builder(
                        padding: EdgeInsets.all(padding * 0.75),
                        itemCount: species.length,
                        itemBuilder: (context, index) {
                          final s = species[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: RepaintBoundary(
                              child: SpeciesListCard(
                                key: ValueKey(s.id),
                                commonName: locale == 'es' ? s.commonNameEs : s.commonNameEn,
                                scientificName: s.scientificName,
                                thumbnailUrl: s.thumbnailUrl ?? SpeciesAssets.thumbnail(s.id),
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
                      );
                    }
                    return GridView.builder(
                      padding: EdgeInsets.all(padding * 0.75),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: species.length,
                      itemBuilder: (context, index) {
                        final s = species[index];
                        return RepaintBoundary(
                          child: SpeciesListCard(
                            key: ValueKey(s.id),
                            commonName: locale == 'es' ? s.commonNameEs : s.commonNameEn,
                            scientificName: s.scientificName,
                            thumbnailUrl: s.thumbnailUrl ?? SpeciesAssets.thumbnail(s.id),
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
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.t.common.error),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.invalidate(allSpeciesProvider),
                          child: Text(context.t.common.retry),
                        ),
                      ],
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

  static const _conservationStatuses = ['CR', 'EN', 'VU', 'NT', 'LC', 'DD'];

  static Color _statusColor(String status) {
    return switch (status) {
      'CR' => AppColors.statusCR,
      'EN' => AppColors.statusEN,
      'VU' => AppColors.statusVU,
      'NT' => AppColors.statusNT,
      'LC' => AppColors.statusLC,
      'DD' => AppColors.statusDD,
      _ => AppColors.statusNE,
    };
  }
}
