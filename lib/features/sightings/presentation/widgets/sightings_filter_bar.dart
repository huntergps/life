import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sighting_filters_provider.dart';

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

/// Filter bar with species, date-from, and date-to chips.
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
