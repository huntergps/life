import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import '../../../providers/admin_category_provider.dart';
import '../../../providers/admin_list_state_providers.dart';
import '../../widgets/admin_delete_dialog.dart';
import '../../widgets/admin_list_helpers.dart';

class AdminCategoryListScreen extends ConsumerStatefulWidget {
  const AdminCategoryListScreen({super.key});

  @override
  ConsumerState<AdminCategoryListScreen> createState() => _AdminCategoryListScreenState();
}

class _AdminCategoryListScreenState extends ConsumerState<AdminCategoryListScreen> {
  final _searchController = TextEditingController();

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
        await service.permanentlyDeleteCategory(int.parse(id));
      } else {
        await service.deleteCategory(int.parse(id));
      }
    }
    ref.invalidate(adminCategoriesProvider);
    ref.invalidate(deletedCategoriesProvider);
    exitSelectionMode(ref);
  }

  Future<void> _restoreCategory(Map<String, dynamic> cat) async {
    final service = ref.read(adminSupabaseServiceProvider);
    await service.restoreCategory(cat['id'] as int);
    ref.invalidate(adminCategoriesProvider);
    ref.invalidate(deletedCategoriesProvider);
  }

  Future<void> _permanentlyDeleteCategory(Map<String, dynamic> cat) async {
    final confirmed = await showAdminDeleteConfirmation(
      context,
      name: cat['name_en'] ?? context.t.admin.unnamed,
      permanent: true,
    );
    if (!confirmed) return;

    final service = ref.read(adminSupabaseServiceProvider);
    await service.permanentlyDeleteCategory(cat['id'] as int);
    ref.invalidate(adminCategoriesProvider);
    ref.invalidate(deletedCategoriesProvider);
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> items, String query) {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((item) {
      return (item['name_es']?.toString().toLowerCase() ?? '').contains(q) ||
          (item['name_en']?.toString().toLowerCase() ?? '').contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final deletedAsync = ref.watch(deletedCategoriesProvider);
    final deletedCount = deletedAsync.asData?.value.length ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.sizeOf(context).width >= 700;

    final searchQuery = ref.watch(adminSearchQueryProvider);
    final selectionMode = ref.watch(adminSelectionModeProvider);
    final showDeleted = ref.watch(adminShowDeletedProvider);
    final selectedIds = ref.watch(adminSelectedIdsProvider);

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
              title: Text(context.t.admin.categories),
              backgroundColor: isDark ? AppColors.darkBackground : null,
            ),
      floatingActionButton: (selectionMode || showDeleted)
          ? null
          : FloatingActionButton(
              onPressed: () => context.go('/admin/categories/new'),
              tooltip: context.t.admin.newItem,
              backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: showDeleted
          ? _buildDeletedBody(context, deletedAsync, isDark, isWide, searchQuery, selectionMode, selectedIds)
          : _buildActiveBody(context, categoriesAsync, isDark, isWide, deletedCount, searchQuery, selectionMode, selectedIds),
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
    return deletedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${context.t.common.error}: $e')),
      data: (deletedItems) {
        final filtered = _filter(deletedItems, searchQuery);
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
                onRefresh: () async => ref.invalidate(deletedCategoriesProvider),
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
                            ? _buildDeletedGrid(context, ref, filtered, isDark, padding, selectionMode, selectedIds)
                            : _buildDeletedList(context, ref, filtered, isDark, selectionMode, selectedIds),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveBody(
    BuildContext context,
    AsyncValue<List<Map<String, dynamic>>> categoriesAsync,
    bool isDark,
    bool isWide,
    int deletedCount,
    String searchQuery,
    bool selectionMode,
    Set<String> selectedIds,
  ) {
    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${context.t.common.error}: $e')),
      data: (categories) {
        if (categories.isEmpty && deletedCount == 0) {
          return Center(child: Text(context.t.admin.noCategoriesYet));
        }
        final filtered = _filter(categories, searchQuery);
        final padding = AdaptiveLayout.responsivePadding(context);
        return Column(
          children: [
            AdminListHeader(
              searchController: _searchController,
              deletedCount: deletedCount,
              countLabel: '${filtered.length} ${context.t.admin.categories.toLowerCase()}',
              padding: padding,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(adminCategoriesProvider),
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          context.t.admin.noResultsFor(query: searchQuery),
                          style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                        ),
                      )
                    : isWide
                        ? _buildGrid(context, ref, filtered, isDark, padding, selectionMode, selectedIds)
                        : _buildList(context, ref, filtered, isDark, selectionMode, selectedIds),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> categories, bool isDark, double padding, bool selectionMode, Set<String> selectedIds) {
    final width = MediaQuery.sizeOf(context).width;
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: adminGridDelegate(width),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final id = cat['id'].toString();
        final isSelected = selectedIds.contains(id);
        return AdminGridCard(
          title: cat['name_en'] ?? '',
          subtitle: cat['name_es'] ?? '',
          icon: Icons.category,
          isSelected: isSelected,
          selectionMode: selectionMode,
          isDark: isDark,
          onTap: selectionMode
              ? () => toggleSelection(ref, id)
              : () => context.go('/admin/categories/${cat['id']}/edit'),
          onLongPress: selectionMode ? null : () => enterSelectionMode(ref, id),
          badge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '#${cat['sort_order'] ?? 0}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
          trailing: SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              icon: Icon(Icons.delete_outline, size: 14, color: AppColors.error),
              tooltip: context.t.common.delete,
              onPressed: () => AdminDeleteDialog.show(
                context,
                entityName: cat['name_en'] ?? context.t.admin.unnamed,
                onConfirm: () async {
                  final service = ref.read(adminSupabaseServiceProvider);
                  await service.deleteCategory(cat['id']);
                  ref.invalidate(adminCategoriesProvider);
                  ref.invalidate(deletedCategoriesProvider);
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

  Widget _buildList(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> categories, bool isDark, bool selectionMode, Set<String> selectedIds) {
    return ListView.builder(
      itemCount: categories.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final cat = categories[index];
        final id = cat['id'].toString();
        final isSelected = selectedIds.contains(id);
        return AdminActiveListTile(
          title: cat['name_en'] ?? '',
          subtitle: cat['name_es'] ?? '',
          icon: Icons.category,
          isSelected: isSelected,
          selectionMode: selectionMode,
          isDark: isDark,
          onTap: selectionMode
              ? () => toggleSelection(ref, id)
              : () => context.go('/admin/categories/${cat['id']}/edit'),
          onLongPress: selectionMode ? null : () => enterSelectionMode(ref, id),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${context.t.admin.sortOrder}: ${cat['sort_order'] ?? 0}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline, color: AppColors.error),
                tooltip: context.t.common.delete,
                onPressed: () => AdminDeleteDialog.show(
                  context,
                  entityName: cat['name_en'] ?? context.t.admin.unnamed,
                  onConfirm: () async {
                    final service = ref.read(adminSupabaseServiceProvider);
                    await service.deleteCategory(cat['id']);
                    ref.invalidate(adminCategoriesProvider);
                    ref.invalidate(deletedCategoriesProvider);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Deleted (trash) grid and list builders ---

  Widget _buildDeletedGrid(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> categories, bool isDark, double padding, bool selectionMode, Set<String> selectedIds) {
    final width = MediaQuery.sizeOf(context).width;

    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: adminGridDelegate(width),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final id = cat['id'].toString();
        final isSelected = selectedIds.contains(id);
        return AdminDeletedGridCard(
          title: cat['name_en'] ?? '',
          subtitle: cat['name_es'] ?? '',
          deletedAt: cat['deleted_at']?.toString() ?? '',
          icon: Icons.category,
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
          onRestore: () => _restoreCategory(cat),
          onPermanentDelete: () => _permanentlyDeleteCategory(cat),
        );
      },
    );
  }

  Widget _buildDeletedList(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> categories, bool isDark, bool selectionMode, Set<String> selectedIds) {
    return ListView.builder(
      itemCount: categories.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final cat = categories[index];
        final id = cat['id'].toString();
        final isSelected = selectedIds.contains(id);
        return AdminDeletedListTile(
          title: cat['name_en'] ?? '',
          subtitle: cat['name_es'] ?? '',
          deletedAt: cat['deleted_at']?.toString() ?? '',
          icon: Icons.category,
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
          onRestore: () => _restoreCategory(cat),
          onPermanentDelete: () => _permanentlyDeleteCategory(cat),
        );
      },
    );
  }
}
