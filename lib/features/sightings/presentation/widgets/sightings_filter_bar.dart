import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sighting_filters_provider.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sightings_provider.dart';

/// Animated wrapper that shows/hides the filter bar.
class AnimatedSightingsFilterBar extends ConsumerWidget {
  final bool show;
  final Map<int, Species> speciesMap;
  final bool isDark;
  final bool isEs;

  const AnimatedSightingsFilterBar({
    super.key,
    required this.show,
    required this.speciesMap,
    required this.isDark,
    required this.isEs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: show
          ? SightingsFilterBar(
              speciesMap: speciesMap,
              isDark: isDark,
              isEs: isEs,
            )
          : const SizedBox.shrink(),
    );
  }
}

/// Filter bar with species, date-from, date-to, visit-site, photos-only,
/// favorites-only, and text-search chips.
class SightingsFilterBar extends ConsumerWidget {
  final Map<int, Species> speciesMap;
  final bool isDark;
  final bool isEs;

  const SightingsFilterBar({
    super.key,
    required this.speciesMap,
    required this.isDark,
    required this.isEs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(sightingFiltersProvider);
    final hasFilters = ref.watch(hasActiveFiltersProvider);
    final visitSiteMap =
        ref.watch(visitSiteLookupProvider).asData?.value ?? <int, VisitSite>{};

    // Build species label
    String speciesLabel;
    if (filters.speciesId != null &&
        speciesMap.containsKey(filters.speciesId)) {
      final sp = speciesMap[filters.speciesId]!;
      speciesLabel = isEs ? sp.commonNameEs : sp.commonNameEn;
    } else {
      speciesLabel = context.t.sightings.allSpecies;
    }

    // Build visit site label
    String visitSiteLabel;
    if (filters.visitSiteId != null &&
        visitSiteMap.containsKey(filters.visitSiteId)) {
      final site = visitSiteMap[filters.visitSiteId]!;
      visitSiteLabel = isEs ? site.nameEs : (site.nameEn ?? site.nameEs);
    } else {
      visitSiteLabel = context.t.sightings.allSites;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withValues(alpha: 0.6)
            : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Row 1: species, date-from, date-to, visit site ──
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Species filter chip
                  FilterChip(
                    avatar: const Icon(Icons.pets, size: 18),
                    label: Text(
                      speciesLabel,
                      overflow: TextOverflow.ellipsis,
                    ),
                    selected: filters.speciesId != null,
                    onSelected: (_) => _pickSpecies(context, ref, filters),
                  ),
                  const SizedBox(width: 8),
                  // Date From chip
                  FilterChip(
                    avatar: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      filters.dateFrom != null
                          ? '${context.t.sightings.from}: ${DateFormat.yMMMd().format(filters.dateFrom!)}'
                          : context.t.sightings.from,
                    ),
                    selected: filters.dateFrom != null,
                    onSelected: (_) => _pickDateFrom(context, ref),
                  ),
                  const SizedBox(width: 8),
                  // Date To chip
                  FilterChip(
                    avatar: const Icon(Icons.event, size: 18),
                    label: Text(
                      filters.dateTo != null
                          ? '${context.t.sightings.to}: ${DateFormat.yMMMd().format(filters.dateTo!)}'
                          : context.t.sightings.to,
                    ),
                    selected: filters.dateTo != null,
                    onSelected: (_) => _pickDateTo(context, ref),
                  ),
                  const SizedBox(width: 8),
                  // Visit site filter chip
                  FilterChip(
                    avatar: const Icon(Icons.place, size: 18),
                    label: Text(
                      visitSiteLabel,
                      overflow: TextOverflow.ellipsis,
                    ),
                    selected: filters.visitSiteId != null,
                    onSelected: (_) =>
                        _pickVisitSite(context, ref, filters, visitSiteMap),
                  ),
                ],
              ),
            ),
          ),
          // ── Row 2: toggle chips + clear ──
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Photos only chip
                  FilterChip(
                    avatar: const Icon(Icons.photo_camera, size: 18),
                    label: Text(context.t.sightings.photosOnly),
                    selected: filters.photosOnly,
                    onSelected: (v) => ref
                        .read(sightingFiltersProvider.notifier)
                        .setPhotosOnly(v),
                  ),
                  const SizedBox(width: 8),
                  // Favorites only chip
                  FilterChip(
                    avatar: const Icon(Icons.favorite, size: 18),
                    label: Text(context.t.sightings.favoritesOnly),
                    selected: filters.favoritesOnly,
                    onSelected: (v) => ref
                        .read(sightingFiltersProvider.notifier)
                        .setFavoritesOnly(v),
                  ),
                  const SizedBox(width: 8),
                  // Search query chip (tapping opens inline text field)
                  _SearchQueryChip(
                    isDark: isDark,
                    searchQuery: filters.searchQuery,
                    onQueryChanged: (q) => ref
                        .read(sightingFiltersProvider.notifier)
                        .setSearchQuery(q),
                  ),
                  const SizedBox(width: 8),
                  // Clear all filters
                  if (hasFilters)
                    ActionChip(
                      avatar: const Icon(Icons.clear_all, size: 18),
                      label: Text(context.t.sightings.clearFilters),
                      onPressed: () => ref
                          .read(sightingFiltersProvider.notifier)
                          .clearAll(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickSpecies(
      BuildContext context, WidgetRef ref, SightingFilters filters) async {
    final sortedSpecies = speciesMap.values.toList()
      ..sort((a, b) {
        final nameA = isEs ? a.commonNameEs : a.commonNameEn;
        final nameB = isEs ? b.commonNameEs : b.commonNameEn;
        return nameA.compareTo(nameB);
      });

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    final result = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkTheme ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    context.t.sightings.allSpecies,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // "All Species" option
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isDarkTheme
                              ? AppColors.primaryLight.withValues(alpha: 0.15)
                              : null,
                          child: const Icon(Icons.all_inclusive, size: 20),
                        ),
                        title: Text(context.t.sightings.allSpecies),
                        selected: filters.speciesId == null,
                        onTap: () => Navigator.of(ctx).pop(null),
                      ),
                      const Divider(),
                      ...sortedSpecies.map((sp) {
                        final name =
                            isEs ? sp.commonNameEs : sp.commonNameEn;
                        return ListTile(
                          leading: sp.thumbnailUrl != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(sp.thumbnailUrl!),
                                  onBackgroundImageError: (_, _) {},
                                )
                              : CircleAvatar(
                                  backgroundColor: isDarkTheme
                                      ? AppColors.primaryLight
                                          .withValues(alpha: 0.15)
                                      : null,
                                  child: const Icon(Icons.pets, size: 20),
                                ),
                          title: Text(name),
                          subtitle: Text(
                            sp.scientificName,
                            style: const TextStyle(
                                fontStyle: FontStyle.italic),
                          ),
                          selected: filters.speciesId == sp.id,
                          onTap: () => Navigator.of(ctx).pop(sp.id),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (!context.mounted) return;
    ref.read(sightingFiltersProvider.notifier).setSpecies(result);
  }

  Future<void> _pickVisitSite(
    BuildContext context,
    WidgetRef ref,
    SightingFilters filters,
    Map<int, VisitSite> visitSiteMap,
  ) async {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Only show sites that have at least one sighting attached.
    // If no sightings yet, show all sites.
    final sortedSites = visitSiteMap.values.toList()
      ..sort((a, b) {
        final nameA = isEs ? a.nameEs : (a.nameEn ?? a.nameEs);
        final nameB = isEs ? b.nameEs : (b.nameEn ?? b.nameEs);
        return nameA.compareTo(nameB);
      });

    final result = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkTheme ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    context.t.sightings.allSites,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isDarkTheme
                              ? AppColors.primaryLight.withValues(alpha: 0.15)
                              : null,
                          child:
                              const Icon(Icons.all_inclusive, size: 20),
                        ),
                        title: Text(context.t.sightings.allSites),
                        selected: filters.visitSiteId == null,
                        onTap: () => Navigator.of(ctx).pop(null),
                      ),
                      const Divider(),
                      ...sortedSites.map((site) {
                        final name =
                            isEs ? site.nameEs : (site.nameEn ?? site.nameEs);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isDarkTheme
                                ? AppColors.primaryLight.withValues(alpha: 0.15)
                                : null,
                            child: const Icon(Icons.place, size: 20),
                          ),
                          title: Text(name),
                          selected: filters.visitSiteId == site.id,
                          onTap: () => Navigator.of(ctx).pop(site.id),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (!context.mounted) return;
    ref.read(sightingFiltersProvider.notifier).setVisitSite(result);
  }

  Future<void> _pickDateFrom(BuildContext context, WidgetRef ref) async {
    final current = ref.read(sightingFiltersProvider).dateFrom;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(sightingFiltersProvider.notifier).setDateFrom(picked);
    }
  }

  Future<void> _pickDateTo(BuildContext context, WidgetRef ref) async {
    final current = ref.read(sightingFiltersProvider).dateTo;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(sightingFiltersProvider.notifier).setDateTo(picked);
    }
  }
}

// ---------------------------------------------------------------------------
// Search query chip with inline text input
// ---------------------------------------------------------------------------

class _SearchQueryChip extends StatefulWidget {
  final bool isDark;
  final String? searchQuery;
  final ValueChanged<String?> onQueryChanged;

  const _SearchQueryChip({
    required this.isDark,
    required this.searchQuery,
    required this.onQueryChanged,
  });

  @override
  State<_SearchQueryChip> createState() => _SearchQueryChipState();
}

class _SearchQueryChipState extends State<_SearchQueryChip> {
  bool _isEditing = false;
  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery ?? '');
  }

  @override
  void didUpdateWidget(_SearchQueryChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync external clear (e.g. "Clear all" button)
    if (widget.searchQuery == null && _controller.text.isNotEmpty) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() => _isEditing = true);
    _focus.requestFocus();
  }

  void _commit() {
    final query = _controller.text.trim();
    widget.onQueryChanged(query.isEmpty ? null : query);
    setState(() => _isEditing = false);
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery =
        widget.searchQuery != null && widget.searchQuery!.isNotEmpty;

    if (_isEditing) {
      return SizedBox(
        width: 180,
        height: 36,
        child: TextField(
          controller: _controller,
          focusNode: _focus,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.t.sightings.searchNotes,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.check, size: 18),
              onPressed: _commit,
              visualDensity: VisualDensity.compact,
            ),
          ),
          onSubmitted: (_) => _commit(),
        ),
      );
    }

    return FilterChip(
      avatar: const Icon(Icons.search, size: 18),
      label: Text(
        hasQuery ? widget.searchQuery! : context.t.sightings.searchNotes,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      selected: hasQuery,
      onSelected: (_) => _startEditing(),
      deleteIcon: hasQuery ? const Icon(Icons.close, size: 16) : null,
      onDeleted: hasQuery
          ? () {
              _controller.clear();
              widget.onQueryChanged(null);
            }
          : null,
    );
  }
}
