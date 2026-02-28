import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/features/species/providers/species_list_provider.dart';

/// Bottom sheet that lets the user search and pick a species.
/// Returns the selected [Species] via Navigator.pop.
class SpeciesPickerSheet extends ConsumerStatefulWidget {
  const SpeciesPickerSheet({super.key});

  @override
  ConsumerState<SpeciesPickerSheet> createState() => _SpeciesPickerSheetState();
}

class _SpeciesPickerSheetState extends ConsumerState<SpeciesPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allSpeciesAsync = ref.watch(allSpeciesProvider);
    final isEs = LocaleSettings.currentLocale == AppLocale.es;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.t.sightings.selectSpecies,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: context.t.species.search,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
              ),
            ),
            const SizedBox(height: 8),
            // Species list
            Expanded(
              child: allSpeciesAsync.when(
                data: (species) {
                  final filtered = _query.isEmpty
                      ? species
                      : species.where((s) {
                          return s.commonNameEn.toLowerCase().contains(_query) ||
                              s.commonNameEs.toLowerCase().contains(_query) ||
                              s.scientificName.toLowerCase().contains(_query);
                        }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        context.t.species.noResults,
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final s = filtered[index];
                      final name = isEs ? s.commonNameEs : s.commonNameEn;
                      return ListTile(
                        leading: s.thumbnailUrl != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(s.thumbnailUrl!),
                                onBackgroundImageError: (_, _) {},
                              )
                            : CircleAvatar(
                                backgroundColor: isDark
                                    ? AppColors.primaryLight.withValues(alpha: 0.15)
                                    : null,
                                child: const Icon(Icons.pets, size: 20),
                              ),
                        title: Text(name),
                        subtitle: Text(
                          s.scientificName,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        onTap: () => Navigator.of(context).pop(s),
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
          ],
        );
      },
    );
  }
}

/// Helper to show the species picker and return the selected species.
Future<Species?> showSpeciesPickerSheet(BuildContext context) {
  return showModalBottomSheet<Species>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const SpeciesPickerSheet(),
  );
}
