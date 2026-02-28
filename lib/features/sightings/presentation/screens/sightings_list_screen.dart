import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/brick/models/sighting.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import 'package:galapagos_wildlife/core/widgets/empty_state.dart';
import 'package:galapagos_wildlife/core/widgets/error_state_widget.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sightings_provider.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sighting_filters_provider.dart';
import 'package:galapagos_wildlife/features/sightings/services/sightings_service.dart';
import 'package:galapagos_wildlife/features/sightings/services/sightings_csv_export.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:intl/intl.dart';

/// Tracks the selected sighting index for master-detail on tablet.
final _selectedSightingIndexProvider = StateProvider<int?>((ref) => null);

/// Tracks whether the filter bar is visible.
final _showFiltersProvider = StateProvider<bool>((ref) => false);

/// Tracks the current view mode: list or calendar (month-grouped).
enum _ViewMode { list, calendar }

final _viewModeProvider = StateProvider<_ViewMode>((ref) => _ViewMode.list);

class SightingsListScreen extends ConsumerWidget {
  const SightingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = AdaptiveLayout.isTablet(context);

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: Text(context.t.sightings.title)),
        body: EmptyState(
          icon: Icons.camera_alt_outlined,
          title: context.t.sightings.loginRequired,
          subtitle: context.t.auth.signInSubtitle,
          action: ElevatedButton(
            onPressed: () => context.pushNamed('login'),
            child: Text(context.t.auth.signIn),
          ),
        ),
      );
    }

    final filteredAsync = ref.watch(filteredSightingsProvider);
    final allSightingsAsync = ref.watch(sightingsProvider);
    final speciesLookupAsync = ref.watch(speciesLookupProvider);
    final speciesMap = speciesLookupAsync.asData?.value ?? {};
    final locale = ref.watch(localeProvider);
    final isEs = locale == 'es';

    if (isTablet) {
      return _TabletSightings(
        filteredAsync: filteredAsync,
        allSightingsAsync: allSightingsAsync,
        speciesMap: speciesMap,
        isDark: isDark,
        isEs: isEs,
        ref: ref,
      );
    }

    return _PhoneSightings(
      filteredAsync: filteredAsync,
      allSightingsAsync: allSightingsAsync,
      speciesMap: speciesMap,
      isDark: isDark,
      isEs: isEs,
    );
  }
}

class _PhoneSightings extends ConsumerWidget {
  final AsyncValue<List<Sighting>> filteredAsync;
  final AsyncValue<List<Sighting>> allSightingsAsync;
  final Map<int, Species> speciesMap;
  final bool isDark;
  final bool isEs;

  const _PhoneSightings({
    required this.filteredAsync,
    required this.allSightingsAsync,
    required this.speciesMap,
    required this.isDark,
    required this.isEs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speciesLookupAsync = ref.watch(speciesLookupProvider);
    final speciesMapForExport = speciesLookupAsync.asData?.value ?? {};
    final showFilters = ref.watch(_showFiltersProvider);
    final hasFilters = ref.watch(hasActiveFiltersProvider);
    final viewMode = ref.watch(_viewModeProvider);
    final isCalendar = viewMode == _ViewMode.calendar;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.sightings.title),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: hasFilters,
              smallSize: 8,
              child: Icon(
                showFilters ? Icons.filter_list_off : Icons.filter_list,
              ),
            ),
            tooltip: context.t.sightings.filters,
            onPressed: () {
              ref.read(_showFiltersProvider.notifier).state = !showFilters;
            },
          ),
          IconButton(
            icon: Icon(
              isCalendar ? Icons.view_list : Icons.calendar_month,
            ),
            tooltip: isCalendar
                ? context.t.sightings.listView
                : context.t.sightings.calendarView,
            onPressed: () {
              ref.read(_viewModeProvider.notifier).state =
                  isCalendar ? _ViewMode.list : _ViewMode.calendar;
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: context.t.sightings.export,
            onPressed: () {
              final data = filteredAsync.asData?.value ?? [];
              exportSightingsCsv(
                context: context,
                sightings: data,
                speciesMap: speciesMapForExport,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('add-sighting'),
        icon: const Icon(Icons.add),
        label: Text(context.t.sightings.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sightingsProvider);
        },
        child: Column(
          children: [
            // Filter bar
            _AnimatedFilterBar(
              show: showFilters,
              speciesMap: speciesMap,
              isDark: isDark,
              isEs: isEs,
            ),
            // Stats summary
            if (allSightingsAsync.asData != null)
              _StatsSummary(
                allSightings: allSightingsAsync.asData!.value,
                filteredSightings: filteredAsync.asData?.value ?? [],
                isDark: isDark,
              ),
            // List or Calendar
            Expanded(
              child: filteredAsync.when(
                data: (sightings) {
                  if (sightings.isEmpty) {
                    return ListView(
                      children: [
                        EmptyState(
                          icon: isCalendar
                              ? Icons.calendar_month
                              : Icons.camera_alt_outlined,
                          title: isCalendar
                              ? context.t.sightings.noSightingsInMonth
                              : context.t.sightings.empty,
                          subtitle: isCalendar
                              ? null
                              : context.t.sightings.emptySubtitle,
                        ),
                      ],
                    );
                  }
                  if (isCalendar) {
                    return _CalendarGroupedView(
                      sightings: sightings,
                      speciesMap: speciesMap,
                      isDark: isDark,
                      isEs: isEs,
                      onDelete: (s) => _confirmDelete(context, ref, s),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sightings.length,
                    itemBuilder: (context, index) {
                      return _SightingCard(
                        sighting: sightings[index],
                        species: speciesMap[sightings[index].speciesId],
                        isDark: isDark,
                        isEs: isEs,
                        onDelete: () =>
                            _confirmDelete(context, ref, sightings[index]),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, st) => ErrorStateWidget(
                  error: e,
                  stackTrace: st,
                  onRetry: () => ref.invalidate(sightingsProvider),
                  showOfflineOption: true,
                  onOfflineMode: () {
                    // Already offline-first with Brick, just refresh
                    ref.invalidate(sightingsProvider);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabletSightings extends StatelessWidget {
  final AsyncValue<List<Sighting>> filteredAsync;
  final AsyncValue<List<Sighting>> allSightingsAsync;
  final Map<int, Species> speciesMap;
  final bool isDark;
  final bool isEs;
  final WidgetRef ref;

  const _TabletSightings({
    required this.filteredAsync,
    required this.allSightingsAsync,
    required this.speciesMap,
    required this.isDark,
    required this.isEs,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(_selectedSightingIndexProvider);
    final showFilters = ref.watch(_showFiltersProvider);
    final hasFilters = ref.watch(hasActiveFiltersProvider);
    final viewMode = ref.watch(_viewModeProvider);
    final isCalendar = viewMode == _ViewMode.calendar;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.sightings.title),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: hasFilters,
              smallSize: 8,
              child: Icon(
                showFilters ? Icons.filter_list_off : Icons.filter_list,
              ),
            ),
            tooltip: context.t.sightings.filters,
            onPressed: () {
              ref.read(_showFiltersProvider.notifier).state = !showFilters;
            },
          ),
          IconButton(
            icon: Icon(
              isCalendar ? Icons.view_list : Icons.calendar_month,
            ),
            tooltip: isCalendar
                ? context.t.sightings.listView
                : context.t.sightings.calendarView,
            onPressed: () {
              ref.read(_viewModeProvider.notifier).state =
                  isCalendar ? _ViewMode.list : _ViewMode.calendar;
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: context.t.sightings.export,
            onPressed: () {
              final data = filteredAsync.asData?.value ?? [];
              exportSightingsCsv(
                context: context,
                sightings: data,
                speciesMap: speciesMap,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('add-sighting'),
        icon: const Icon(Icons.add),
        label: Text(context.t.sightings.add),
      ),
      body: Column(
        children: [
          // Filter bar
          _AnimatedFilterBar(
            show: showFilters,
            speciesMap: speciesMap,
            isDark: isDark,
            isEs: isEs,
          ),
          // Stats summary
          if (allSightingsAsync.asData != null)
            _StatsSummary(
              allSightings: allSightingsAsync.asData!.value,
              filteredSightings: filteredAsync.asData?.value ?? [],
              isDark: isDark,
            ),
          // Master-detail
          Expanded(
            child: filteredAsync.when(
              data: (sightings) {
                if (sightings.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(sightingsProvider);
                    },
                    child: ListView(
                      children: [
                        EmptyState(
                          icon: isCalendar
                              ? Icons.calendar_month
                              : Icons.camera_alt_outlined,
                          title: isCalendar
                              ? context.t.sightings.noSightingsInMonth
                              : context.t.sightings.empty,
                          subtitle: isCalendar
                              ? null
                              : context.t.sightings.emptySubtitle,
                        ),
                      ],
                    ),
                  );
                }
                return Row(
                  children: [
                    // Left panel - sightings list or calendar
                    SizedBox(
                      width: 360,
                      child: isCalendar
                          ? _CalendarGroupedView(
                              sightings: sightings,
                              speciesMap: speciesMap,
                              isDark: isDark,
                              isEs: isEs,
                              onTapSighting: (sighting) {
                                final idx = sightings.indexOf(sighting);
                                if (idx >= 0) {
                                  ref
                                      .read(_selectedSightingIndexProvider
                                          .notifier)
                                      .state = idx;
                                }
                              },
                              selectedSighting: selectedIndex != null &&
                                      selectedIndex < sightings.length
                                  ? sightings[selectedIndex]
                                  : null,
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                ref.invalidate(sightingsProvider);
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: sightings.length,
                                itemBuilder: (context, index) {
                                  final isSelected = selectedIndex == index;
                                  return Card(
                                    color: isSelected
                                        ? (isDark
                                            ? AppColors.primaryLight
                                                .withValues(alpha: 0.15)
                                            : Theme.of(context)
                                                .colorScheme
                                                .primaryContainer)
                                        : null,
                                    child: InkWell(
                                      onTap: () {
                                        ref
                                            .read(_selectedSightingIndexProvider
                                                .notifier)
                                            .state = index;
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: _SightingListTile(
                                        sighting: sightings[index],
                                        species: speciesMap[
                                            sightings[index].speciesId],
                                        isDark: isDark,
                                        isEs: isEs,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                    VerticalDivider(
                      width: 1,
                      color:
                          isDark ? AppColors.darkBorder : Colors.grey.shade300,
                    ),
                    // Right panel - detail
                    Expanded(
                      child: selectedIndex != null &&
                              selectedIndex < sightings.length
                          ? _SightingDetail(
                              sighting: sightings[selectedIndex],
                              species: speciesMap[
                                  sightings[selectedIndex].speciesId],
                              isDark: isDark,
                              isEs: isEs,
                              onDelete: () => _confirmDelete(
                                  context, ref, sightings[selectedIndex]),
                            )
                          : Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.touch_app_outlined,
                                    size: 64,
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.t.sightings.selectDetail,
                                    style: TextStyle(
                                      color:
                                          isDark ? Colors.white38 : Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, st) => ErrorStateWidget(
                error: e,
                stackTrace: st,
                onRetry: () => ref.invalidate(sightingsProvider),
                showOfflineOption: true,
                onOfflineMode: () => ref.invalidate(sightingsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Calendar/month-grouped view ──

/// Groups sightings by year-month and displays them with section headers.
class _CalendarGroupedView extends StatelessWidget {
  final List<Sighting> sightings;
  final Map<int, Species> speciesMap;
  final bool isDark;
  final bool isEs;
  final void Function(Sighting)? onDelete;
  final void Function(Sighting)? onTapSighting;
  final Sighting? selectedSighting;

  const _CalendarGroupedView({
    required this.sightings,
    required this.speciesMap,
    required this.isDark,
    required this.isEs,
    this.onDelete,
    this.onTapSighting,
    this.selectedSighting,
  });

  /// Groups sightings by "yyyy-MM" key, ordered newest first.
  Map<String, List<Sighting>> _groupByMonth(List<Sighting> sightings) {
    final grouped = <String, List<Sighting>>{};
    for (final s in sightings) {
      final date = s.observedAt ?? DateTime(1970);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(s);
    }
    // Sort keys newest first
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: grouped[k]!};
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByMonth(sightings);
    final locale = isEs ? 'es' : 'en';
    final monthFormat = DateFormat.yMMMM(locale);

    // Build a flat list of items: headers + sighting tiles
    final items = <_CalendarListItem>[];
    for (final entry in grouped.entries) {
      // Parse the key back to a DateTime for formatting
      final parts = entry.key.split('-');
      final headerDate = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      items.add(_CalendarListItem.header(monthFormat.format(headerDate)));
      for (final s in entry.value) {
        items.add(_CalendarListItem.sighting(s));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item.isHeader) {
          return _MonthHeader(
            title: item.headerTitle!,
            isDark: isDark,
          );
        }
        final sighting = item.sighting!;
        final isSelected = selectedSighting?.id == sighting.id;
        return _CalendarSightingTile(
          sighting: sighting,
          species: speciesMap[sighting.speciesId],
          isDark: isDark,
          isEs: isEs,
          isSelected: isSelected,
          onTap: onTapSighting != null
              ? () => onTapSighting!(sighting)
              : null,
          onDelete: onDelete != null
              ? () => onDelete!(sighting)
              : null,
        );
      },
    );
  }
}

/// Union type for calendar list items (header or sighting).
class _CalendarListItem {
  final bool isHeader;
  final String? headerTitle;
  final Sighting? sighting;

  _CalendarListItem.header(this.headerTitle)
      : isHeader = true,
        sighting = null;

  _CalendarListItem.sighting(this.sighting)
      : isHeader = false,
        headerTitle = null;
}

/// Month section header widget.
class _MonthHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _MonthHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month,
            size: 20,
            color: isDark ? AppColors.accentOrange : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primaryDark,
                  ),
            ),
          ),
          Expanded(
            child: Divider(
              color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact sighting card used in calendar/month-grouped view.
class _CalendarSightingTile extends StatelessWidget {
  final Sighting sighting;
  final Species? species;
  final bool isDark;
  final bool isEs;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _CalendarSightingTile({
    required this.sighting,
    required this.species,
    required this.isDark,
    required this.isEs,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = species != null
        ? (isEs ? species!.commonNameEs : species!.commonNameEn)
        : 'Species #${sighting.speciesId}';
    final date = sighting.observedAt;
    final dayStr = date != null ? date.day.toString() : '?';
    final weekdayStr = date != null
        ? DateFormat.E(isEs ? 'es' : 'en').format(date)
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      color: isSelected
          ? (isDark
              ? AppColors.primaryLight.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.primaryContainer)
          : (isDark ? AppColors.darkCard : null),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Day number circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.primaryLight.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.08),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dayStr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.accentOrange : AppColors.primary,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      weekdayStr,
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Thumbnail
              if (sighting.photoUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.network(
                      sighting.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: isDark ? AppColors.darkSurface : Colors.grey[200],
                        child: Icon(
                          Icons.broken_image,
                          size: 18,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ] else if (species?.thumbnailUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.network(
                      species!.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: isDark ? AppColors.darkSurface : Colors.grey[200],
                        child: Icon(
                          Icons.pets,
                          size: 18,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              // Species name + notes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : null,
                      ),
                    ),
                    if (sighting.notes != null)
                      Text(
                        sighting.notes!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              // Delete button (only for phone layout where onDelete is provided)
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  tooltip: context.t.sightings.delete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Filter bar ──

class _AnimatedFilterBar extends ConsumerWidget {
  final bool show;
  final Map<int, Species> speciesMap;
  final bool isDark;
  final bool isEs;

  const _AnimatedFilterBar({
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
          ? _FilterBar(
              speciesMap: speciesMap,
              isDark: isDark,
              isEs: isEs,
            )
          : const SizedBox.shrink(),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  final Map<int, Species> speciesMap;
  final bool isDark;
  final bool isEs;

  const _FilterBar({
    required this.speciesMap,
    required this.isDark,
    required this.isEs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speciesFilter = ref.watch(sightingSpeciesFilterProvider);
    final dateFrom = ref.watch(sightingDateFromProvider);
    final dateTo = ref.watch(sightingDateToProvider);
    final hasFilters = ref.watch(hasActiveFiltersProvider);

    // Build species label
    String speciesLabel;
    if (speciesFilter != null && speciesMap.containsKey(speciesFilter)) {
      final sp = speciesMap[speciesFilter]!;
      speciesLabel = isEs ? sp.commonNameEs : sp.commonNameEn;
    } else {
      speciesLabel = context.t.sightings.allSpecies;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              selected: speciesFilter != null,
              onSelected: (_) => _pickSpecies(context, ref),
            ),
            const SizedBox(width: 8),
            // Date From chip
            FilterChip(
              avatar: const Icon(Icons.calendar_today, size: 18),
              label: Text(
                dateFrom != null
                    ? '${context.t.sightings.from}: ${DateFormat.yMMMd().format(dateFrom)}'
                    : context.t.sightings.from,
              ),
              selected: dateFrom != null,
              onSelected: (_) => _pickDateFrom(context, ref),
            ),
            const SizedBox(width: 8),
            // Date To chip
            FilterChip(
              avatar: const Icon(Icons.event, size: 18),
              label: Text(
                dateTo != null
                    ? '${context.t.sightings.to}: ${DateFormat.yMMMd().format(dateTo)}'
                    : context.t.sightings.to,
              ),
              selected: dateTo != null,
              onSelected: (_) => _pickDateTo(context, ref),
            ),
            const SizedBox(width: 8),
            // Clear all filters
            if (hasFilters)
              ActionChip(
                avatar: const Icon(Icons.clear_all, size: 18),
                label: Text(context.t.sightings.clearFilters),
                onPressed: () {
                  ref.read(sightingSpeciesFilterProvider.notifier).state = null;
                  ref.read(sightingDateFromProvider.notifier).state = null;
                  ref.read(sightingDateToProvider.notifier).state = null;
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSpecies(BuildContext context, WidgetRef ref) async {
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
                        selected:
                            ref.read(sightingSpeciesFilterProvider) == null,
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
                            style:
                                const TextStyle(fontStyle: FontStyle.italic),
                          ),
                          selected: ref.read(sightingSpeciesFilterProvider) ==
                              sp.id,
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
    // result is null when "All Species" is tapped or sheet is dismissed
    // We use a sentinel to differentiate "All Species" tap from dismiss
    ref.read(sightingSpeciesFilterProvider.notifier).state = result;
  }

  Future<void> _pickDateFrom(BuildContext context, WidgetRef ref) async {
    final current = ref.read(sightingDateFromProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(sightingDateFromProvider.notifier).state = picked;
    }
  }

  Future<void> _pickDateTo(BuildContext context, WidgetRef ref) async {
    final current = ref.read(sightingDateToProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(sightingDateToProvider.notifier).state = picked;
    }
  }
}

// ── Stats summary ──

class _StatsSummary extends StatelessWidget {
  final List<Sighting> allSightings;
  final List<Sighting> filteredSightings;
  final bool isDark;

  const _StatsSummary({
    required this.allSightings,
    required this.filteredSightings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (allSightings.isEmpty) return const SizedBox.shrink();

    final total = filteredSightings.length;
    final uniqueSpecies =
        filteredSightings.map((s) => s.speciesId).toSet().length;

    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month);
    final thisMonthCount = filteredSightings
        .where((s) =>
            s.observedAt != null && !s.observedAt!.isBefore(thisMonthStart))
        .length;

    final withPhotos =
        filteredSightings.where((s) => s.photoUrl != null).length;

    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _StatCard(
            icon: Icons.visibility,
            value: total.toString(),
            label: context.t.sightings.totalSightings,
            isDark: isDark,
          ),
          _StatCard(
            icon: Icons.pets,
            value: uniqueSpecies.toString(),
            label: context.t.sightings.uniqueSpecies,
            isDark: isDark,
          ),
          _StatCard(
            icon: Icons.calendar_month,
            value: thisMonthCount.toString(),
            label: context.t.sightings.thisMonth,
            isDark: isDark,
          ),
          _StatCard(
            icon: Icons.photo_camera,
            value: withPhotos.toString(),
            label: context.t.sightings.withPhotos,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 8),
      color: isDark ? AppColors.darkCard : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.accentOrange : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : null,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                        fontSize: 11,
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

// ── Shared widgets ──

class _SightingCard extends StatelessWidget {
  final Sighting sighting;
  final Species? species;
  final bool isDark;
  final bool isEs;
  final VoidCallback onDelete;

  const _SightingCard({
    required this.sighting,
    required this.species,
    required this.isDark,
    required this.isEs,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = species != null
        ? (isEs ? species!.commonNameEs : species!.commonNameEn)
        : 'Species #${sighting.speciesId}';
    final dateStr = sighting.observedAt != null
        ? DateFormat.yMMMd().format(sighting.observedAt!)
        : '';

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo (if present)
          if (sighting.photoUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Semantics(
                label: context.t.sightings.sightingPhoto,
                image: true,
                child: Image.network(
                  sighting.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: isDark ? AppColors.darkSurface : Colors.grey[200],
                    child: const Center(
                        child: Icon(Icons.broken_image, size: 40)),
                  ),
                ),
              ),
            ),
          ListTile(
            leading: species?.thumbnailUrl != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(species!.thumbnailUrl!),
                    onBackgroundImageError: (_, _) {},
                    backgroundColor:
                        isDark ? AppColors.darkSurface : Colors.grey[200],
                    child: Icon(Icons.pets,
                        size: 16,
                        color: isDark ? Colors.white38 : Colors.grey),
                  )
                : CircleAvatar(
                    backgroundColor: isDark
                        ? AppColors.accentOrange.withValues(alpha: 0.15)
                        : null,
                    child: Icon(
                      Icons.camera_alt,
                      color: isDark ? AppColors.accentOrange : null,
                    ),
                  ),
            title: Text(name),
            subtitle: Text(
              '$dateStr${sighting.notes != null ? '\n${sighting.notes}' : ''}',
              style: TextStyle(color: isDark ? Colors.white54 : null),
            ),
            isThreeLine: sighting.notes != null,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: context.t.sightings.delete,
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _SightingListTile extends StatelessWidget {
  final Sighting sighting;
  final Species? species;
  final bool isDark;
  final bool isEs;

  const _SightingListTile({
    required this.sighting,
    required this.species,
    required this.isDark,
    required this.isEs,
  });

  @override
  Widget build(BuildContext context) {
    final name = species != null
        ? (isEs ? species!.commonNameEs : species!.commonNameEn)
        : 'Species #${sighting.speciesId}';
    final dateStr = sighting.observedAt != null
        ? DateFormat.yMMMd().format(sighting.observedAt!)
        : '';

    return ListTile(
      leading: species?.thumbnailUrl != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(species!.thumbnailUrl!),
              onBackgroundImageError: (_, _) {},
              backgroundColor:
                  isDark ? AppColors.darkSurface : Colors.grey[200],
              child: Icon(Icons.pets,
                  size: 16, color: isDark ? Colors.white38 : Colors.grey),
            )
          : CircleAvatar(
              backgroundColor: isDark
                  ? AppColors.accentOrange.withValues(alpha: 0.15)
                  : null,
              child: Icon(
                Icons.camera_alt,
                color: isDark ? AppColors.accentOrange : null,
              ),
            ),
      title: Text(name),
      subtitle: Text(
        '$dateStr${sighting.notes != null ? '\n${sighting.notes}' : ''}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: isDark ? Colors.white54 : null),
      ),
      isThreeLine: sighting.notes != null,
    );
  }
}

class _SightingDetail extends StatelessWidget {
  final Sighting sighting;
  final Species? species;
  final bool isDark;
  final bool isEs;
  final VoidCallback onDelete;

  const _SightingDetail({
    required this.sighting,
    required this.species,
    required this.isDark,
    required this.isEs,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = species != null
        ? (isEs ? species!.commonNameEs : species!.commonNameEn)
        : 'Species #${sighting.speciesId}';
    final dateStr = sighting.observedAt != null
        ? DateFormat.yMMMd().add_jm().format(sighting.observedAt!)
        : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo
          if (sighting.photoUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Semantics(
                  label: context.t.sightings.sightingPhoto,
                  image: true,
                  child: Image.network(
                    sighting.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: isDark ? AppColors.darkSurface : Colors.grey[200],
                      child: const Center(
                          child: Icon(Icons.broken_image, size: 48)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Header
          Row(
            children: [
              species?.thumbnailUrl != null
                  ? CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(species!.thumbnailUrl!),
                      onBackgroundImageError: (_, _) {},
                      backgroundColor:
                          isDark ? AppColors.darkSurface : Colors.grey[200],
                      child: Icon(Icons.pets,
                          size: 24,
                          color: isDark ? Colors.white38 : Colors.grey),
                    )
                  : CircleAvatar(
                      radius: 28,
                      backgroundColor: isDark
                          ? AppColors.accentOrange.withValues(alpha: 0.15)
                          : Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.camera_alt,
                        size: 28,
                        color: isDark
                            ? AppColors.accentOrange
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (species != null)
                      Text(
                        species!.scientificName,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color:
                              isDark ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: context.t.sightings.delete,
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          // Notes
          if (sighting.notes != null) ...[
            Text(context.t.sightings.notes,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              sighting.notes!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],
          // Location
          if (sighting.latitude != null && sighting.longitude != null) ...[
            Text(context.t.sightings.location,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '${sighting.latitude!.toStringAsFixed(4)}, ${sighting.longitude!.toStringAsFixed(4)}',
              style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Delete confirmation ──

Future<void> _confirmDelete(
    BuildContext context, WidgetRef ref, Sighting sighting) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.t.sightings.delete),
      content: Text(context.t.sightings.deleteConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(context.t.common.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(context.t.common.delete),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      final service = SightingsService();
      if (sighting.photoUrl != null) {
        await service.deletePhoto(sighting.photoUrl!);
      }
      await service.deleteSighting(sighting.id);
      ref.invalidate(sightingsProvider);
      ref.read(_selectedSightingIndexProvider.notifier).state = null;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.sightings.deleted)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.common.error)),
        );
      }
    }
  }
}
