import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import '../../../providers/admin_category_provider.dart';
import '../../../providers/admin_visit_site_provider.dart';

// ---------------------------------------------------------------------------
// Pantalla única para gestionar los 3 catálogos de clasificación de sitios
// Tabs: Tipos · Modalidades · Actividades
// ---------------------------------------------------------------------------

class AdminSiteCatalogsScreen extends ConsumerStatefulWidget {
  const AdminSiteCatalogsScreen({super.key});

  @override
  ConsumerState<AdminSiteCatalogsScreen> createState() => _AdminSiteCatalogsScreenState();
}

class _AdminSiteCatalogsScreenState extends ConsumerState<AdminSiteCatalogsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    (label: 'Tipos', icon: Icons.category_outlined, table: 'site_type_catalog'),
    (label: 'Modalidades', icon: Icons.directions_boat_outlined, table: 'site_modality_catalog'),
    (label: 'Actividades', icon: Icons.directions_run, table: 'site_activity_catalog'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clasificaciones de Sitios'),
        backgroundColor: isDark ? AppColors.darkBackground : null,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs
              .map((t) => Tab(icon: Icon(t.icon), text: t.label))
              .toList(),
          indicatorColor: isDark ? AppColors.primaryLight : AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CatalogTab(
            table: _tabs[0].table,
            provider: siteTypeCatalogProvider,
            emptyLabel: 'No hay tipos registrados',
          ),
          _CatalogTab(
            table: _tabs[1].table,
            provider: siteModalityCatalogProvider,
            emptyLabel: 'No hay modalidades registradas',
          ),
          _CatalogTab(
            table: _tabs[2].table,
            provider: siteActivityCatalogProvider,
            emptyLabel: 'No hay actividades registradas',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab reutilizable para un catálogo
// ---------------------------------------------------------------------------

class _CatalogTab extends ConsumerWidget {
  final String table;
  final FutureProvider<List<Map<String, dynamic>>> provider;
  final String emptyLabel;

  const _CatalogTab({
    required this.table,
    required this.provider,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dataAsync = ref.watch(provider);

    return Scaffold(
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 48,
                      color: isDark ? Colors.white24 : Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(emptyLabel,
                      style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(provider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: isDark
                        ? AppColors.primaryLight.withValues(alpha: 0.12)
                        : AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      (item['name'] as String? ?? '?')[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                  ),
                  title: Text(item['name'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar',
                        onPressed: () => _showEditDialog(context, ref, item),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: AppColors.error),
                        tooltip: 'Eliminar',
                        onPressed: () => _confirmDelete(context, ref, item),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        tooltip: 'Agregar',
        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    _showNameDialog(
      context: context,
      title: 'Nuevo elemento',
      confirmLabel: 'Agregar',
      onConfirm: (name) async {
        final service = ref.read(adminSupabaseServiceProvider);
        await service.createSiteCatalogEntry(table, name);
        ref.invalidate(provider);
      },
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> item) {
    _showNameDialog(
      context: context,
      title: 'Editar elemento',
      initialValue: item['name'] as String? ?? '',
      confirmLabel: 'Guardar',
      onConfirm: (name) async {
        final service = ref.read(adminSupabaseServiceProvider);
        await service.updateSiteCatalogEntry(table, item['id'].toString(), name);
        ref.invalidate(provider);
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Map<String, dynamic> item) async {
    final name = item['name'] as String? ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar elemento'),
        content: Text('¿Eliminar "$name"? Los sitios que lo tengan asignado perderán esta clasificación.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final service = ref.read(adminSupabaseServiceProvider);
    await service.deleteSiteCatalogEntry(table, item['id'].toString());
    ref.invalidate(provider);
  }

  void _showNameDialog({
    required BuildContext context,
    required String title,
    String initialValue = '',
    required String confirmLabel,
    required Future<void> Function(String name) onConfirm,
  }) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) async {
            if (value.trim().isEmpty) return;
            Navigator.pop(ctx);
            await onConfirm(value.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              await onConfirm(name);
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
