import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import '../../../providers/admin_species_provider.dart';
import '../../../providers/admin_visit_site_provider.dart';
import '../../../providers/admin_category_provider.dart';
import '../../widgets/admin_delete_dialog.dart';

final _allSpeciesSitesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(adminSupabaseServiceProvider);
  return service.getSpeciesSites();
});

class AdminSpeciesSitesScreen extends ConsumerStatefulWidget {
  const AdminSpeciesSitesScreen({super.key});

  @override
  ConsumerState<AdminSpeciesSitesScreen> createState() => _AdminSpeciesSitesScreenState();
}

class _AdminSpeciesSitesScreenState extends ConsumerState<AdminSpeciesSitesScreen> {
  int? _selectedSpeciesId;
  int? _selectedSiteId;
  String _selectedFrequency = 'common';

  static const _frequencies = ['common', 'uncommon', 'rare', 'occasional'];

  /// Check if the currently selected species+site combination already exists.
  bool _isDuplicate(List<Map<String, dynamic>> relationships) {
    if (_selectedSpeciesId == null || _selectedSiteId == null) return false;
    return relationships.any((r) =>
        r['species_id'] == _selectedSpeciesId &&
        r['visit_site_id'] == _selectedSiteId);
  }

  Future<void> _add() async {
    if (_selectedSpeciesId == null || _selectedSiteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.admin.selectBothRequired)),
      );
      return;
    }

    // Check for duplicates against the already-loaded list
    final currentData = ref.read(_allSpeciesSitesProvider);
    final relationships = currentData.asData?.value ?? [];
    if (_isDuplicate(relationships)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t.admin.relationshipAlreadyExists),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final service = ref.read(adminSupabaseServiceProvider);
      await service.upsertSpeciesSite({
        'species_id': _selectedSpeciesId,
        'visit_site_id': _selectedSiteId,
        'frequency': _selectedFrequency,
      });
      ref.invalidate(_allSpeciesSitesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.admin.relationshipAdded)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.common.error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sitesDataAsync = ref.watch(_allSpeciesSitesProvider);
    final speciesListAsync = ref.watch(adminSpeciesListProvider);
    final visitSitesAsync = ref.watch(adminVisitSitesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.admin.speciesSites),
        backgroundColor: isDark ? AppColors.darkBackground : null,
      ),
      body: AdaptiveLayout.constrainedContent(
        maxWidth: 900,
        child: Column(
          children: [
            // Add relationship card
            Card(
              margin: EdgeInsets.symmetric(
                horizontal: AdaptiveLayout.responsivePadding(context),
                vertical: 16,
              ),
            color: isDark ? AppColors.darkCard : null,
            elevation: isDark ? 0 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isDark ? const BorderSide(color: AppColors.darkBorder, width: 0.5) : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.t.admin.addRelationship,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isDark ? AppColors.accentOrange : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Species dropdown
                  speciesListAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('${context.t.common.error}: $e'),
                    data: (species) => DropdownButtonFormField<int>(
                      initialValue: _selectedSpeciesId,
                      decoration: InputDecoration(
                        labelText: context.t.admin.species,
                        border: const OutlineInputBorder(),
                        filled: isDark,
                        fillColor: isDark ? AppColors.darkSurface : null,
                      ),
                      dropdownColor: isDark ? AppColors.darkCard : null,
                      isExpanded: true,
                      items: species.map((s) => DropdownMenuItem(
                        value: s['id'] as int,
                        child: Text(s['common_name_en'] ?? '', style: TextStyle(color: isDark ? Colors.white : null)),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedSpeciesId = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Visit site dropdown
                  visitSitesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('${context.t.common.error}: $e'),
                    data: (sites) => DropdownButtonFormField<int>(
                      initialValue: _selectedSiteId,
                      decoration: InputDecoration(
                        labelText: context.t.admin.visitSites,
                        border: const OutlineInputBorder(),
                        filled: isDark,
                        fillColor: isDark ? AppColors.darkSurface : null,
                      ),
                      dropdownColor: isDark ? AppColors.darkCard : null,
                      isExpanded: true,
                      items: sites.map((s) => DropdownMenuItem(
                        value: s['id'] as int,
                        child: Text(s['name_en'] ?? '', style: TextStyle(color: isDark ? Colors.white : null)),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedSiteId = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Frequency dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFrequency,
                    decoration: InputDecoration(
                      labelText: context.t.admin.frequency,
                      border: const OutlineInputBorder(),
                      filled: isDark,
                      fillColor: isDark ? AppColors.darkSurface : null,
                    ),
                    dropdownColor: isDark ? AppColors.darkCard : null,
                    items: _frequencies.map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(f[0].toUpperCase() + f.substring(1), style: TextStyle(color: isDark ? Colors.white : null)),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedFrequency = v ?? 'common'),
                  ),
                  // Duplicate warning
                  if (sitesDataAsync.asData != null && _isDuplicate(sitesDataAsync.asData!.value))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.error),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              context.t.admin.relationshipAlreadyExists,
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: (sitesDataAsync.asData != null && _isDuplicate(sitesDataAsync.asData!.value))
                        ? null
                        : _add,
                    icon: const Icon(Icons.add),
                    label: Text(context.t.common.add),
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // List
          Expanded(
            child: sitesDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${context.t.common.error}: $e')),
              data: (relationships) {
                if (relationships.isEmpty) {
                  return Center(child: Text(context.t.admin.noRelationshipsYet));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(_allSpeciesSitesProvider),
                  child: ListView.builder(
                    itemCount: relationships.length,
                    itemBuilder: (context, index) {
                      final rel = relationships[index];
                      final speciesName = rel['species'] is Map ? rel['species']['common_name_en'] : 'Species ${rel['species_id']}';
                      final siteName = rel['visit_sites'] is Map ? rel['visit_sites']['name_en'] : 'Site ${rel['visit_site_id']}';
                      return ListTile(
                        leading: Icon(Icons.link, color: isDark ? AppColors.primaryLight : AppColors.primary),
                        title: Text(
                          '$speciesName',
                          style: TextStyle(color: isDark ? Colors.white : null),
                        ),
                        subtitle: Text(
                          '$siteName · ${rel['frequency'] ?? 'unknown'}',
                          style: TextStyle(color: isDark ? Colors.white54 : null),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: AppColors.error),
                          tooltip: context.t.common.delete,
                          onPressed: () => AdminDeleteDialog.show(
                            context,
                            entityName: '$speciesName at $siteName',
                            onConfirm: () async {
                              final service = ref.read(adminSupabaseServiceProvider);
                              await service.deleteSpeciesSite(
                                rel['species_id'] as int,
                                rel['visit_site_id'] as int,
                              );
                              ref.invalidate(_allSpeciesSitesProvider);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          ],
        ),
      ),
    );
  }
}
