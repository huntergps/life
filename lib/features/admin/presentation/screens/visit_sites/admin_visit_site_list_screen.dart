import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import '../../../providers/admin_visit_site_provider.dart';
import '../../../providers/admin_category_provider.dart';
import '../../../providers/admin_list_state_providers.dart';
import '../../widgets/admin_delete_dialog.dart';
import '../../widgets/admin_list_helpers.dart';

class AdminVisitSiteListScreen extends ConsumerStatefulWidget {
  const AdminVisitSiteListScreen({super.key});

  @override
  ConsumerState<AdminVisitSiteListScreen> createState() => _AdminVisitSiteListScreenState();
}

class _AdminVisitSiteListScreenState extends ConsumerState<AdminVisitSiteListScreen> {
  final _searchController = TextEditingController();
  // null = all statuses
  String? _statusFilter;

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
        await service.permanentlyDeleteVisitSite(int.parse(id));
      } else {
        await service.deleteVisitSite(int.parse(id));
      }
    }
    ref.invalidate(adminVisitSitesProvider);
    ref.invalidate(deletedVisitSitesProvider);
    exitSelectionMode(ref);
  }

  Future<void> _restoreVisitSite(Map<String, dynamic> site) async {
    final service = ref.read(adminSupabaseServiceProvider);
    await service.restoreVisitSite(site['id'] as int);
    ref.invalidate(adminVisitSitesProvider);
    ref.invalidate(deletedVisitSitesProvider);
  }

  Future<void> _permanentlyDeleteVisitSite(Map<String, dynamic> site) async {
    final confirmed = await showAdminDeleteConfirmation(
      context,
      name: site['name_en'] ?? context.t.admin.unnamed,
      permanent: true,
    );
    if (!confirmed) return;

    final service = ref.read(adminSupabaseServiceProvider);
    await service.permanentlyDeleteVisitSite(site['id'] as int);
    ref.invalidate(adminVisitSitesProvider);
    ref.invalidate(deletedVisitSitesProvider);
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> items, String query) {
    var result = items;
    // Status filter
    if (_statusFilter != null) {
      result = result.where((item) => item['status'] == _statusFilter).toList();
    }
    // Text search
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((item) {
        return (item['name_es']?.toString().toLowerCase() ?? '').contains(q) ||
            (item['name_en']?.toString().toLowerCase() ?? '').contains(q);
      }).toList();
    }
    return result;
  }

  Widget _buildStatusFilterChips(bool isDark, List<Map<String, dynamic>> allItems) {
    final counts = <String?, int>{
      null: allItems.length,
      'active': allItems.where((s) => s['status'] == 'active').length,
      'inactive': allItems.where((s) => s['status'] == 'inactive').length,
      'monitoring': allItems.where((s) => s['status'] == 'monitoring').length,
    };
    final chips = [
      (null, 'Todos', Colors.grey),
      ('active', 'Activos', Colors.green),
      ('inactive', 'Inactivos', Colors.orange),
      ('monitoring', 'Monitoreo', Colors.blue),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: chips.map((chip) {
          final (value, label, color) = chip;
          final isSelected = _statusFilter == value;
          final count = counts[value] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('$label ($count)'),
              selected: isSelected,
              onSelected: (_) => setState(() => _statusFilter = value),
              selectedColor: color.withValues(alpha: isDark ? 0.3 : 0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? (isDark ? color.withValues(alpha: 0.9) : color)
                    : (isDark ? Colors.white70 : Colors.grey[700]),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              checkmarkColor: isDark ? color.withValues(alpha: 0.9) : color,
              backgroundColor: isDark ? AppColors.darkCard : null,
              side: BorderSide(
                color: isSelected ? color : (isDark ? AppColors.darkBorder : Colors.grey[300]!),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(adminSearchQueryProvider);
    final selectionMode = ref.watch(adminSelectionModeProvider);
    final showDeleted = ref.watch(adminShowDeletedProvider);
    final selectedIds = ref.watch(adminSelectedIdsProvider);

    final sitesAsync = ref.watch(adminVisitSitesProvider);
    final deletedAsync = ref.watch(deletedVisitSitesProvider);
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
              title: Text(context.t.admin.visitSites),
              backgroundColor: isDark ? AppColors.darkBackground : null,
            ),
      floatingActionButton: (selectionMode || showDeleted)
          ? null
          : FloatingActionButton(
              onPressed: () => context.go('/admin/visit-sites/new'),
              tooltip: context.t.admin.newItem,
              backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: showDeleted
          ? _buildDeletedBody(context, deletedAsync, isDark, isWide, searchQuery, selectionMode, selectedIds)
          : _buildActiveBody(context, sitesAsync, isDark, isWide, deletedCount, searchQuery, selectionMode, selectedIds),
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
                onRefresh: () async => ref.invalidate(deletedVisitSitesProvider),
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
    AsyncValue<List<Map<String, dynamic>>> sitesAsync,
    bool isDark,
    bool isWide,
    int deletedCount,
    String searchQuery,
    bool selectionMode,
    Set<String> selectedIds,
  ) {
    return sitesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${context.t.common.error}: $e')),
      data: (sites) {
        if (sites.isEmpty && deletedCount == 0) {
          return Center(child: Text(context.t.admin.noVisitSitesYet));
        }
        final filtered = _filter(sites, searchQuery);
        final padding = AdaptiveLayout.responsivePadding(context);
        return Column(
          children: [
            AdminListHeader(
              searchController: _searchController,
              deletedCount: deletedCount,
              countLabel: '${filtered.length} ${context.t.admin.visitSites.toLowerCase()}',
              padding: padding,
            ),
            _buildStatusFilterChips(isDark, sites),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(adminVisitSitesProvider),
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

  /// Returns the status badge color for a given status string.
  Color _statusColor(String? status) => switch (status) {
        'active' => Colors.green,
        'inactive' => Colors.orange,
        _ => Colors.blueGrey,
      };

  /// Returns the display label for a given status string.
  String _statusLabel(String? status) => switch (status) {
        'active' => 'ACTIVO',
        'inactive' => 'INACTIVO',
        _ => 'MONITOREO',
      };

  Widget _buildGrid(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> sites, bool isDark, double padding, bool selectionMode, Set<String> selectedIds) {
    final width = MediaQuery.sizeOf(context).width;

    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: adminGridDelegate(width),
      itemCount: sites.length,
      itemBuilder: (context, index) {
        final site = sites[index];
        final id = site['id'].toString();
        final isSelected = selectedIds.contains(id);
        final status = site['status'] as String?;
        final monitoringType = site['monitoring_type'] as String?;
        final statusColor = _statusColor(status);
        return AdminGridCard(
          title: site['name_es'] ?? site['name_en'] ?? '',
          subtitle: site['name_en'] ?? '',
          icon: Icons.place,
          isSelected: isSelected,
          selectionMode: selectionMode,
          isDark: isDark,
          onTap: selectionMode
              ? () => toggleSelection(ref, id)
              : () => context.go('/admin/visit-sites/${site['id']}/edit'),
          onLongPress: selectionMode ? null : () => enterSelectionMode(ref, id),
          badge: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: isDark ? 0.25 : 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 0.8),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isDark ? statusColor.withValues(alpha: 0.9) : statusColor,
                  ),
                ),
              ),
              // Monitoring type icon (if available)
              if (monitoringType != null) ...[
                const SizedBox(width: 4),
                Icon(
                  monitoringType == 'MARINO' ? Icons.water : Icons.terrain,
                  size: 11,
                  color: (monitoringType == 'MARINO' ? Colors.blue[600] : Colors.teal[600])!
                      .withValues(alpha: 0.8),
                ),
              ],
            ],
          ),
          trailing: SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              icon: Icon(Icons.delete_outline, size: 14, color: AppColors.error),
              tooltip: context.t.common.delete,
              onPressed: () => AdminDeleteDialog.show(
                context,
                entityName: site['name_en'] ?? context.t.admin.unnamed,
                onConfirm: () async {
                  final service = ref.read(adminSupabaseServiceProvider);
                  await service.deleteVisitSite(site['id']);
                  ref.invalidate(adminVisitSitesProvider);
                  ref.invalidate(deletedVisitSitesProvider);
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

  Widget _buildList(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> sites, bool isDark, bool selectionMode, Set<String> selectedIds) {
    return ListView.builder(
      itemCount: sites.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final site = sites[index];
        final id = site['id'].toString();
        final isSelected = selectedIds.contains(id);
        final status = site['status'] as String?;
        final statusColor = _statusColor(status);
        final statusLabel = _statusLabel(status);
        final monType = site['monitoring_type'] as String?;
        final subtitleParts = [
          if (site['name_en'] != null && (site['name_en'] as String).isNotEmpty) site['name_en'] as String,
          if (monType != null) monType,
        ];
        return AdminActiveListTile(
          title: site['name_es'] ?? site['name_en'] ?? '',
          subtitle: subtitleParts.isEmpty ? statusLabel : subtitleParts.join(' · '),
          subtitleLeading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 0.8),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          icon: Icons.place,
          isSelected: isSelected,
          selectionMode: selectionMode,
          isDark: isDark,
          onTap: selectionMode
              ? () => toggleSelection(ref, id)
              : () => context.go('/admin/visit-sites/${site['id']}/edit'),
          onLongPress: selectionMode ? null : () => enterSelectionMode(ref, id),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: context.t.common.delete,
            onPressed: () => AdminDeleteDialog.show(
              context,
              entityName: site['name_en'] ?? context.t.admin.unnamed,
              onConfirm: () async {
                final service = ref.read(adminSupabaseServiceProvider);
                await service.deleteVisitSite(site['id']);
                ref.invalidate(adminVisitSitesProvider);
                ref.invalidate(deletedVisitSitesProvider);
              },
            ),
          ),
        );
      },
    );
  }

  // --- Deleted (trash) grid and list builders ---

  Widget _buildDeletedGrid(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> sites, bool isDark, double padding, bool selectionMode, Set<String> selectedIds) {
    final width = MediaQuery.sizeOf(context).width;

    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: adminGridDelegate(width),
      itemCount: sites.length,
      itemBuilder: (context, index) {
        final site = sites[index];
        final id = site['id'].toString();
        final isSelected = selectedIds.contains(id);
        return AdminDeletedGridCard(
          title: site['name_en'] ?? '',
          subtitle: site['name_es'] ?? '',
          deletedAt: site['deleted_at']?.toString() ?? '',
          icon: Icons.place,
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
          onRestore: () => _restoreVisitSite(site),
          onPermanentDelete: () => _permanentlyDeleteVisitSite(site),
        );
      },
    );
  }

  Widget _buildDeletedList(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> sites, bool isDark, bool selectionMode, Set<String> selectedIds) {
    return ListView.builder(
      itemCount: sites.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final site = sites[index];
        final id = site['id'].toString();
        final isSelected = selectedIds.contains(id);
        return AdminDeletedListTile(
          title: site['name_es'] ?? site['name_en'] ?? '',
          subtitle: '${site['name_en'] ?? ''}${site['monitoring_type'] != null ? ' · ${site['monitoring_type']}' : ''}',
          deletedAt: site['deleted_at']?.toString() ?? '',
          icon: Icons.place,
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
          onRestore: () => _restoreVisitSite(site),
          onPermanentDelete: () => _permanentlyDeleteVisitSite(site),
        );
      },
    );
  }
}
