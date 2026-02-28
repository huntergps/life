import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import '../../../providers/admin_island_provider.dart';
import '../../../providers/admin_category_provider.dart';
import '../../../providers/admin_list_state_providers.dart';
import '../../widgets/admin_delete_dialog.dart';
import '../../widgets/admin_list_helpers.dart';

class AdminIslandListScreen extends ConsumerStatefulWidget {
  const AdminIslandListScreen({super.key});

  @override
  ConsumerState<AdminIslandListScreen> createState() => _AdminIslandListScreenState();
}

class _AdminIslandListScreenState extends ConsumerState<AdminIslandListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) => resetAdminListState(ref));
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
        await service.permanentlyDeleteIsland(int.parse(id));
      } else {
        await service.deleteIsland(int.parse(id));
      }
    }
    ref.invalidate(adminIslandsProvider);
    ref.invalidate(deletedIslandsProvider);
    exitSelectionMode(ref);
  }

  Future<void> _restoreIsland(Map<String, dynamic> island) async {
    final service = ref.read(adminSupabaseServiceProvider);
    await service.restoreIsland(island['id'] as int);
    ref.invalidate(adminIslandsProvider);
    ref.invalidate(deletedIslandsProvider);
  }

  Future<void> _permanentlyDeleteIsland(Map<String, dynamic> island) async {
    final confirmed = await showAdminDeleteConfirmation(
      context,
      name: island['name_en'] ?? context.t.admin.unnamed,
      permanent: true,
    );
    if (!confirmed) return;

    final service = ref.read(adminSupabaseServiceProvider);
    await service.permanentlyDeleteIsland(island['id'] as int);
    ref.invalidate(adminIslandsProvider);
    ref.invalidate(deletedIslandsProvider);
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> items, String searchQuery) {
    if (searchQuery.isEmpty) return items;
    final query = searchQuery.toLowerCase();
    return items.where((item) {
      return (item['name_es']?.toString().toLowerCase() ?? '').contains(query) ||
          (item['name_en']?.toString().toLowerCase() ?? '').contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(adminSearchQueryProvider);
    final selectionMode = ref.watch(adminSelectionModeProvider);
    final showDeleted = ref.watch(adminShowDeletedProvider);
    final selectedIds = ref.watch(adminSelectedIdsProvider);

    final islandsAsync = ref.watch(adminIslandsProvider);
    final deletedAsync = ref.watch(deletedIslandsProvider);
    final deletedCount = deletedAsync.asData?.value.length ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.sizeOf(context).width >= 700;

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
              title: Text(context.t.admin.islands),
              backgroundColor: isDark ? AppColors.darkBackground : null,
            ),
      floatingActionButton: (selectionMode || showDeleted)
          ? null
          : FloatingActionButton(
              onPressed: () => context.go('/admin/islands/new'),
              tooltip: context.t.admin.newItem,
              backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: showDeleted
          ? _buildDeletedBody(context, deletedAsync, isDark, isWide, searchQuery, selectionMode, selectedIds)
          : _buildActiveBody(context, islandsAsync, isDark, isWide, deletedCount, searchQuery, selectionMode, selectedIds),
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
                onRefresh: () async => ref.invalidate(deletedIslandsProvider),
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
    AsyncValue<List<Map<String, dynamic>>> islandsAsync,
    bool isDark,
    bool isWide,
    int deletedCount,
    String searchQuery,
    bool selectionMode,
    Set<String> selectedIds,
  ) {
    return islandsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${context.t.common.error}: $e')),
      data: (islands) {
        if (islands.isEmpty && deletedCount == 0) {
          return Center(child: Text(context.t.admin.noIslandsYet));
        }
        final filtered = _filter(islands, searchQuery);
        final padding = AdaptiveLayout.responsivePadding(context);
        return Column(
          children: [
            AdminListHeader(
              searchController: _searchController,
              deletedCount: deletedCount,
              countLabel: '${filtered.length} ${context.t.admin.islands.toLowerCase()}',
              padding: padding,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(adminIslandsProvider),
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

  Widget _buildGrid(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> islands, bool isDark, double padding, bool selectionMode, Set<String> selectedIds) {
    final width = MediaQuery.sizeOf(context).width;
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: adminGridDelegate(width),
      itemCount: islands.length,
      itemBuilder: (context, index) {
        final island = islands[index];
        final id = island['id'].toString();
        final isSelected = selectedIds.contains(id);
        final area = island['area_km2'];
        return AdminGridCard(
          title: island['name_en'] ?? '',
          subtitle: island['name_es'] ?? '',
          icon: Icons.landscape,
          isSelected: isSelected,
          selectionMode: selectionMode,
          isDark: isDark,
          onTap: selectionMode
              ? () => toggleSelection(ref, id)
              : () => context.go('/admin/islands/${island['id']}/edit'),
          onLongPress: selectionMode ? null : () => enterSelectionMode(ref, id),
          badge: area != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$area km\u00B2',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
                entityName: island['name_en'] ?? context.t.admin.unnamed,
                onConfirm: () async {
                  final service = ref.read(adminSupabaseServiceProvider);
                  await service.deleteIsland(island['id']);
                  ref.invalidate(adminIslandsProvider);
                  ref.invalidate(deletedIslandsProvider);
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

  Widget _buildList(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> islands, bool isDark, bool selectionMode, Set<String> selectedIds) {
    return ListView.builder(
      itemCount: islands.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final island = islands[index];
        final id = island['id'].toString();
        final isSelected = selectedIds.contains(id);
        final area = island['area_km2'];
        return AdminActiveListTile(
          title: island['name_en'] ?? '',
          subtitle: '${island['name_es'] ?? ''}${area != null ? ' \u00B7 $area km\u00B2' : ''}',
          icon: Icons.landscape,
          isSelected: isSelected,
          selectionMode: selectionMode,
          isDark: isDark,
          onTap: selectionMode
              ? () => toggleSelection(ref, id)
              : () => context.go('/admin/islands/${island['id']}/edit'),
          onLongPress: selectionMode ? null : () => enterSelectionMode(ref, id),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: context.t.common.delete,
            onPressed: () => AdminDeleteDialog.show(
              context,
              entityName: island['name_en'] ?? context.t.admin.unnamed,
              onConfirm: () async {
                final service = ref.read(adminSupabaseServiceProvider);
                await service.deleteIsland(island['id']);
                ref.invalidate(adminIslandsProvider);
                ref.invalidate(deletedIslandsProvider);
              },
            ),
          ),
        );
      },
    );
  }

  // --- Deleted (trash) grid and list builders ---

  Widget _buildDeletedGrid(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> islands, bool isDark, double padding, bool selectionMode, Set<String> selectedIds) {
    final width = MediaQuery.sizeOf(context).width;

    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: adminGridDelegate(width),
      itemCount: islands.length,
      itemBuilder: (context, index) {
        final island = islands[index];
        final id = island['id'].toString();
        final isSelected = selectedIds.contains(id);
        return AdminDeletedGridCard(
          title: island['name_en'] ?? '',
          subtitle: island['name_es'] ?? '',
          deletedAt: island['deleted_at']?.toString() ?? '',
          icon: Icons.landscape,
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
          onRestore: () => _restoreIsland(island),
          onPermanentDelete: () => _permanentlyDeleteIsland(island),
        );
      },
    );
  }

  Widget _buildDeletedList(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> islands, bool isDark, bool selectionMode, Set<String> selectedIds) {
    return ListView.builder(
      itemCount: islands.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final island = islands[index];
        final id = island['id'].toString();
        final isSelected = selectedIds.contains(id);
        return AdminDeletedListTile(
          title: island['name_en'] ?? '',
          subtitle: '${island['name_es'] ?? ''}${island['area_km2'] != null ? ' \u00B7 ${island['area_km2']} km\u00B2' : ''}',
          deletedAt: island['deleted_at']?.toString() ?? '',
          icon: Icons.landscape,
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
          onRestore: () => _restoreIsland(island),
          onPermanentDelete: () => _permanentlyDeleteIsland(island),
        );
      },
    );
  }
}
