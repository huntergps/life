import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import '../../../providers/admin_species_provider.dart';
import '../../../providers/admin_category_provider.dart';
import '../../../providers/admin_list_state_providers.dart';
import '../../widgets/admin_delete_dialog.dart';
import '../../widgets/admin_list_helpers.dart';

class AdminSpeciesListScreen extends ConsumerStatefulWidget {
  const AdminSpeciesListScreen({super.key});

  @override
  ConsumerState<AdminSpeciesListScreen> createState() => _AdminSpeciesListScreenState();
}

class _AdminSpeciesListScreenState extends ConsumerState<AdminSpeciesListScreen> {
  final _searchController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Sync search controller text with provider value
    _searchController.text = ref.read(adminSearchQueryProvider);
    _searchController.addListener(() {
      final current = ref.read(adminSearchQueryProvider);
      if (_searchController.text != current) {
        ref.read(adminSearchQueryProvider.notifier).state = _searchController.text;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resetAdminListState(ref);
    });
    super.dispose();
  }

  List<Map<String, dynamic>> _filter(
    List<Map<String, dynamic>> list, {
    required String query,
    required bool showDeleted,
  }) {
    var result = list;

    // Category filter (only for active species, trash shows all categories)
    if (_selectedCategoryId != null && !showDeleted) {
      result = result.where((s) => s['category_id'] == _selectedCategoryId).toList();
    }

    // Text search
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((s) {
        final en = (s['common_name_en'] as String? ?? '').toLowerCase();
        final es = (s['common_name_es'] as String? ?? '').toLowerCase();
        final sci = (s['scientific_name'] as String? ?? '').toLowerCase();
        return en.contains(q) || es.contains(q) || sci.contains(q);
      }).toList();
    }

    return result;
  }

  void _invalidateBothProviders() {
    ref.invalidate(adminSpeciesListProvider);
    ref.invalidate(deletedSpeciesListProvider);
  }

  Future<void> _deleteSelected() async {
    final selectedIds = ref.read(adminSelectedIdsProvider);
    final showDeleted = ref.read(adminShowDeletedProvider);
    final isPermanent = showDeleted;

    final confirmed = await showAdminDeleteConfirmation(
      context,
      permanent: isPermanent,
      count: selectedIds.length,
    );
    if (!confirmed) return;

    final service = ref.read(adminSupabaseServiceProvider);
    for (final id in selectedIds) {
      if (isPermanent) {
        await service.permanentlyDeleteSpecies(int.parse(id));
      } else {
        await service.deleteSpecies(int.parse(id));
      }
    }
    _invalidateBothProviders();
    exitSelectionMode(ref);
  }

  Future<void> _restoreSpecies(Map<String, dynamic> species) async {
    final service = ref.read(adminSupabaseServiceProvider);
    await service.restoreSpecies(species['id'] as int);
    _invalidateBothProviders();
  }

  Future<void> _permanentlyDeleteSpecies(Map<String, dynamic> species) async {
    final locale = ref.read(localeProvider);
    final isEs = locale == 'es';
    final name = isEs
        ? (species['common_name_es'] as String? ?? species['common_name_en'] as String? ?? context.t.admin.unnamed)
        : (species['common_name_en'] as String? ?? context.t.admin.unnamed);

    final confirmed = await showAdminDeleteConfirmation(
      context,
      name: name,
      permanent: true,
    );
    if (!confirmed) return;

    final service = ref.read(adminSupabaseServiceProvider);
    await service.permanentlyDeleteSpecies(species['id'] as int);
    _invalidateBothProviders();
  }

  String _speciesName(Map<String, dynamic> species, bool isEs) {
    if (isEs) {
      return species['common_name_es'] as String? ??
          species['common_name_en'] as String? ??
          context.t.admin.unnamed;
    }
    return species['common_name_en'] as String? ?? context.t.admin.unnamed;
  }

  @override
  Widget build(BuildContext context) {
    final deletedAsync = ref.watch(deletedSpeciesListProvider);
    final deletedCount = deletedAsync.asData?.value.length ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.sizeOf(context).width >= 700;

    final searchQuery = ref.watch(adminSearchQueryProvider);
    final selectionMode = ref.watch(adminSelectionModeProvider);
    final showDeleted = ref.watch(adminShowDeletedProvider);
    final selectedIds = ref.watch(adminSelectedIdsProvider);

    final speciesAsync = showDeleted
        ? ref.watch(deletedSpeciesListProvider)
        : ref.watch(adminSpeciesListProvider);

    return Scaffold(
      appBar: selectionMode
          ? AdminSelectionAppBar(
              selectedCount: selectedIds.length,
              showDeleted: showDeleted,
              onDelete: _deleteSelected,
              onClose: () => exitSelectionMode(ref),
              isDark: isDark,
            )
          : AppBar(
              title: Text(context.t.admin.species),
              backgroundColor: isDark ? AppColors.darkBackground : null,
            ),
      floatingActionButton: (selectionMode || showDeleted)
          ? null
          : FloatingActionButton(
              onPressed: () => context.go('/admin/species/new'),
              tooltip: context.t.admin.newItem,
              backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: showDeleted
          ? _buildDeletedBody(context, speciesAsync, isDark, isWide, searchQuery, selectionMode, selectedIds)
          : _buildActiveBody(context, speciesAsync, isDark, isWide, deletedCount, searchQuery, selectionMode, selectedIds),
    );
  }

  Widget _buildActiveBody(
    BuildContext context,
    AsyncValue<List<Map<String, dynamic>>> speciesAsync,
    bool isDark,
    bool isWide,
    int deletedCount,
    String searchQuery,
    bool selectionMode,
    Set<String> selectedIds,
  ) {
    final locale = ref.watch(localeProvider);
    final isEs = locale == 'es';
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    return speciesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${context.t.common.error}: $e')),
      data: (speciesList) {
        if (speciesList.isEmpty && deletedCount == 0) {
          return Center(child: Text(context.t.admin.noSpeciesYet));
        }
        final filtered = _filter(speciesList, query: searchQuery, showDeleted: false);
        final padding = AdaptiveLayout.responsivePadding(context);
        return Column(
          children: [
            AdminListHeader(
              searchController: _searchController,
              deletedCount: deletedCount,
              countLabel: '${filtered.length} ${context.t.admin.species.toLowerCase()}',
              padding: padding,
            ),
            // Category filter chips (species-specific)
            categoriesAsync.when(
              data: (categories) => SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(context.t.species.all),
                        selected: _selectedCategoryId == null,
                        onSelected: (_) => setState(() => _selectedCategoryId = null),
                      ),
                    ),
                    ...categories.map((cat) {
                      final catId = cat['id'] as int;
                      final catName = isEs
                          ? (cat['name_es'] as String? ?? cat['name_en'] as String? ?? '')
                          : (cat['name_en'] as String? ?? '');
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(catName),
                          selected: _selectedCategoryId == catId,
                          onSelected: (_) => setState(() {
                            _selectedCategoryId = _selectedCategoryId == catId ? null : catId;
                          }),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(adminSpeciesListProvider),
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          context.t.admin.noResultsFor(query: searchQuery),
                          style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                        ),
                      )
                    : isWide
                        ? _buildGrid(context, filtered, isDark, padding, selectionMode, selectedIds, isEs)
                        : _buildList(context, filtered, isDark, selectionMode, selectedIds, isEs),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeletedBody(
    BuildContext context,
    AsyncValue<List<Map<String, dynamic>>> deletedAsync,
    bool isDark,
    bool isWide,
    String searchQuery,
    bool selectionMode,
    Set<String> selectedIds,
  ) {
    final locale = ref.watch(localeProvider);
    final isEs = locale == 'es';

    return deletedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${context.t.common.error}: $e')),
      data: (deletedItems) {
        final filtered = _filter(deletedItems, query: searchQuery, showDeleted: true);
        final padding = AdaptiveLayout.responsivePadding(context);
        return Column(
          children: [
            AdminListHeader(
              searchController: _searchController,
              deletedCount: deletedItems.length,
              countLabel: context.t.admin.inTrash(count: filtered.length.toString()),
              padding: padding,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(deletedSpeciesListProvider),
                child: deletedItems.isEmpty
                    ? AdminEmptyTrash(isDark: isDark)
                    : filtered.isEmpty
                        ? Center(
                            child: Text(
                              context.t.admin.noResultsFor(query: searchQuery),
                              style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                            ),
                          )
                        : isWide
                            ? _buildDeletedGrid(context, filtered, isDark, padding, selectionMode, selectedIds, isEs)
                            : _buildDeletedList(context, filtered, isDark, selectionMode, selectedIds, isEs),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Active grid & list builders ---

  Widget _buildGrid(
    BuildContext context,
    List<Map<String, dynamic>> species,
    bool isDark,
    double padding,
    bool selectionMode,
    Set<String> selectedIds,
    bool isEs,
  ) {
    final width = MediaQuery.sizeOf(context).width;
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: adminGridDelegate(width),
      itemCount: species.length,
      itemBuilder: (context, index) {
        final s = species[index];
        final id = s['id'].toString();
        final isSelected = selectedIds.contains(id);
        final name = _speciesName(s, isEs);
        final scientificName = s['scientific_name'] as String? ?? '';
        final status = s['conservation_status'] as String?;

        return AdminGridCard(
          title: name,
          subtitle: scientificName,
          icon: Icons.pets,
          isSelected: isSelected,
          selectionMode: selectionMode,
          isDark: isDark,
          onTap: selectionMode
              ? () => toggleSelection(ref, id)
              : () => context.go('/admin/species/${s['id']}/edit'),
          onLongPress: selectionMode ? null : () => enterSelectionMode(ref, id),
          badge: status != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                )
              : null,
          trailing: SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              icon: Icon(Icons.delete_outline, size: 14, color: AppColors.error),
              tooltip: context.t.common.delete,
              onPressed: () => AdminDeleteDialog.show(
                context,
                entityName: name,
                onConfirm: () async {
                  final service = ref.read(adminSupabaseServiceProvider);
                  await service.deleteSpecies(s['id'] as int);
                  _invalidateBothProviders();
                },
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    List<Map<String, dynamic>> species,
    bool isDark,
    bool selectionMode,
    Set<String> selectedIds,
    bool isEs,
  ) {
    return ListView.builder(
      itemCount: species.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final s = species[index];
        final id = s['id'].toString();
        final isSelected = selectedIds.contains(id);
        final name = _speciesName(s, isEs);
        final scientificName = s['scientific_name'] as String? ?? '';

        return AdminActiveListTile(
          title: name,
          subtitle: scientificName,
          icon: Icons.pets,
          isSelected: isSelected,
          selectionMode: selectionMode,
          isDark: isDark,
          onTap: selectionMode
              ? () => toggleSelection(ref, id)
              : () => context.go('/admin/species/${s['id']}/edit'),
          onLongPress: selectionMode ? null : () => enterSelectionMode(ref, id),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s['conservation_status'] != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    s['conservation_status'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                  ),
                ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: AppColors.error),
                tooltip: context.t.common.delete,
                onPressed: () => AdminDeleteDialog.show(
                  context,
                  entityName: name,
                  onConfirm: () async {
                    final service = ref.read(adminSupabaseServiceProvider);
                    await service.deleteSpecies(s['id'] as int);
                    _invalidateBothProviders();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Deleted (trash) grid & list builders ---

  Widget _buildDeletedGrid(
    BuildContext context,
    List<Map<String, dynamic>> species,
    bool isDark,
    double padding,
    bool selectionMode,
    Set<String> selectedIds,
    bool isEs,
  ) {
    final width = MediaQuery.sizeOf(context).width;

    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: adminGridDelegate(width),
      itemCount: species.length,
      itemBuilder: (context, index) {
        final s = species[index];
        final id = s['id'].toString();
        final isSelected = selectedIds.contains(id);
        final name = _speciesName(s, isEs);
        final scientificName = s['scientific_name'] as String? ?? '';

        return AdminDeletedGridCard(
          title: name,
          subtitle: scientificName,
          deletedAt: s['deleted_at']?.toString() ?? '',
          icon: Icons.pets,
          isSelected: isSelected,
          selectionMode: selectionMode,
          isDark: isDark,
          onTap: selectionMode
              ? () => toggleSelection(ref, id)
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.t.admin.restoreToEdit)),
                  );
                },
          onLongPress: selectionMode ? null : () => enterSelectionMode(ref, id),
          onRestore: () => _restoreSpecies(s),
          onPermanentDelete: () => _permanentlyDeleteSpecies(s),
        );
      },
    );
  }

  Widget _buildDeletedList(
    BuildContext context,
    List<Map<String, dynamic>> species,
    bool isDark,
    bool selectionMode,
    Set<String> selectedIds,
    bool isEs,
  ) {
    return ListView.builder(
      itemCount: species.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final s = species[index];
        final id = s['id'].toString();
        final isSelected = selectedIds.contains(id);
        final name = _speciesName(s, isEs);
        final scientificName = s['scientific_name'] as String? ?? '';

        return AdminDeletedListTile(
          title: name,
          subtitle: scientificName,
          deletedAt: s['deleted_at']?.toString() ?? '',
          icon: Icons.pets,
          isSelected: isSelected,
          selectionMode: selectionMode,
          isDark: isDark,
          onTap: selectionMode
              ? () => toggleSelection(ref, id)
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.t.admin.restoreToEdit)),
                  );
                },
          onLongPress: selectionMode ? null : () => enterSelectionMode(ref, id),
          onRestore: () => _restoreSpecies(s),
          onPermanentDelete: () => _permanentlyDeleteSpecies(s),
        );
      },
    );
  }
}
