import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:galapagos_wildlife/features/species/providers/species_list_provider.dart';

class SpeciesCompareScreen extends ConsumerStatefulWidget {
  final int? speciesIdA;
  const SpeciesCompareScreen({super.key, this.speciesIdA});

  @override
  ConsumerState<SpeciesCompareScreen> createState() => _SpeciesCompareScreenState();
}

class _SpeciesCompareScreenState extends ConsumerState<SpeciesCompareScreen> {
  Species? _speciesA;
  Species? _speciesB;

  @override
  Widget build(BuildContext context) {
    final allSpeciesAsync = ref.watch(allSpeciesProvider);
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(context.t.species.compareSpecies)),
      body: allSpeciesAsync.when(
        data: (allSpecies) {
          // Pre-select species A if provided
          if (widget.speciesIdA != null && _speciesA == null) {
            final matches = allSpecies.where((s) => s.id == widget.speciesIdA);
            if (matches.isNotEmpty) _speciesA = matches.first;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Selection row
                Row(
                  children: [
                    Expanded(
                      child: _SpeciesSelector(
                        species: _speciesA,
                        allSpecies: allSpecies,
                        locale: locale,
                        isDark: isDark,
                        onSelected: (s) => setState(() => _speciesA = s),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        context.t.species.vsLabel,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _SpeciesSelector(
                        species: _speciesB,
                        allSpecies: allSpecies,
                        locale: locale,
                        isDark: isDark,
                        onSelected: (s) => setState(() => _speciesB = s),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Comparison table
                if (_speciesA != null && _speciesB != null)
                  _ComparisonTable(
                    a: _speciesA!,
                    b: _speciesB!,
                    locale: locale,
                    isDark: isDark,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Text(
                      context.t.species.selectTwoSpecies,
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
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
    );
  }
}

class _SpeciesSelector extends StatelessWidget {
  final Species? species;
  final List<Species> allSpecies;
  final String locale;
  final bool isDark;
  final ValueChanged<Species> onSelected;

  const _SpeciesSelector({
    required this.species,
    required this.allSpecies,
    required this.locale,
    required this.isDark,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
          ),
        ),
        child: species != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: species!.thumbnailUrl != null
                        ? NetworkImage(species!.thumbnailUrl!)
                        : SpeciesAssets.thumbnail(species!.id) != null
                            ? AssetImage(SpeciesAssets.thumbnail(species!.id)!)
                                as ImageProvider
                            : null,
                    onBackgroundImageError: (_, _) {},
                    child: species!.thumbnailUrl == null &&
                            SpeciesAssets.thumbnail(species!.id) == null
                        ? const Icon(Icons.pets, size: 28)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    locale == 'es' ? species!.commonNameEs : species!.commonNameEn,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 40,
                      color: isDark ? Colors.white38 : Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    context.t.species.compare,
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView.builder(
          controller: scrollController,
          itemCount: allSpecies.length,
          itemBuilder: (context, index) {
            final s = allSpecies[index];
            final name = locale == 'es' ? s.commonNameEs : s.commonNameEn;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: s.thumbnailUrl != null
                    ? NetworkImage(s.thumbnailUrl!)
                    : SpeciesAssets.thumbnail(s.id) != null
                        ? AssetImage(SpeciesAssets.thumbnail(s.id)!)
                            as ImageProvider
                        : null,
                onBackgroundImageError: (_, _) {},
                child: s.thumbnailUrl == null && SpeciesAssets.thumbnail(s.id) == null
                    ? const Icon(Icons.pets, size: 20)
                    : null,
              ),
              title: Text(name),
              subtitle: Text(s.scientificName, style: const TextStyle(fontStyle: FontStyle.italic)),
              onTap: () {
                onSelected(s);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  final Species a;
  final Species b;
  final String locale;
  final bool isDark;

  const _ComparisonTable({
    required this.a,
    required this.b,
    required this.locale,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.species;
    final rows = <_CompareRow>[
      _CompareRow(t.scientificName, a.scientificName, b.scientificName, italic: true),
      _CompareRow(t.conservationStatus,
          a.conservationStatus ?? '-', b.conservationStatus ?? '-'),
      _CompareRow(t.endemic,
          a.isEndemic ? '✓' : '✗', b.isEndemic ? '✓' : '✗'),
      if (a.weightKg != null || b.weightKg != null)
        _CompareRow(t.weight,
            a.weightKg != null ? '${a.weightKg} ${t.kg}' : '-',
            b.weightKg != null ? '${b.weightKg} ${t.kg}' : '-'),
      if (a.sizeCm != null || b.sizeCm != null)
        _CompareRow(t.size,
            a.sizeCm != null ? '${a.sizeCm} ${t.cm}' : '-',
            b.sizeCm != null ? '${b.sizeCm} ${t.cm}' : '-'),
      if (a.populationEstimate != null || b.populationEstimate != null)
        _CompareRow(t.population,
            a.populationEstimate?.toString() ?? '-',
            b.populationEstimate?.toString() ?? '-'),
      if (a.lifespanYears != null || b.lifespanYears != null)
        _CompareRow(t.lifespan,
            a.lifespanYears != null ? '${a.lifespanYears} ${t.years}' : '-',
            b.lifespanYears != null ? '${b.lifespanYears} ${t.years}' : '-'),
      if (a.habitatEn != null || b.habitatEn != null)
        _CompareRow(t.habitat,
            (locale == 'es' ? a.habitatEs : a.habitatEn) ?? '-',
            (locale == 'es' ? b.habitatEs : b.habitatEn) ?? '-'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                  ),
                ),
              ),
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox.shrink(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    locale == 'es' ? a.commonNameEs : a.commonNameEn,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    locale == 'es' ? b.commonNameEs : b.commonNameEn,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            // Data rows
            ...rows.map((row) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        row.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        row.valueA,
                        textAlign: TextAlign.center,
                        style: row.italic
                            ? const TextStyle(fontStyle: FontStyle.italic)
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        row.valueB,
                        textAlign: TextAlign.center,
                        style: row.italic
                            ? const TextStyle(fontStyle: FontStyle.italic)
                            : null,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class _CompareRow {
  final String label;
  final String valueA;
  final String valueB;
  final bool italic;

  const _CompareRow(this.label, this.valueA, this.valueB, {this.italic = false});
}
