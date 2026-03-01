import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import '../../providers/admin_taxonomy_provider.dart';
import 'admin_delete_dialog.dart';

/// Taxonomy tree selector for the species form.
///
/// Displays an expandable 4-level hierarchy (Class > Order > Family > Genus)
/// where the user can SELECT a genus (leaf node) and also add/edit/delete
/// items at every level. The currently selected genus is highlighted and
/// its ancestors are auto-expanded on first build.
class AdminTaxonomySelector extends ConsumerStatefulWidget {
  final int? selectedGenusId;
  final ValueChanged<int> onGenusSelected;

  const AdminTaxonomySelector({
    super.key,
    this.selectedGenusId,
    required this.onGenusSelected,
  });

  @override
  ConsumerState<AdminTaxonomySelector> createState() =>
      AdminTaxonomySelectorState();
}

class AdminTaxonomySelectorState
    extends ConsumerState<AdminTaxonomySelector> {
  // Level border colors (same palette as AdminTaxonomyEditor)
  static const _classBorderColor = Color(0xFF2E7D32); // green
  static const _orderBorderColor = Color(0xFF1565C0); // blue
  static const _familyBorderColor = Color(0xFFE65100); // orange
  static const _genusBorderColor = Color(0xFF6A1B9A); // purple

  /// IDs that should start expanded (resolved from selectedGenusId).
  final Set<int> _expandedClassIds = {};
  final Set<int> _expandedOrderIds = {};
  final Set<int> _expandedFamilyIds = {};

  /// Resolved breadcrumb path: className > orderName > familyName > genusName
  String? _breadcrumbClass;
  String? _breadcrumbOrder;
  String? _breadcrumbFamily;
  String? _breadcrumbGenus;

  bool _resolvedInitial = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedGenusId != null) {
      _resolveAndExpand(widget.selectedGenusId!);
    }
  }

  @override
  void didUpdateWidget(covariant AdminTaxonomySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedGenusId != oldWidget.selectedGenusId &&
        widget.selectedGenusId != null &&
        !_resolvedInitial) {
      _resolveAndExpand(widget.selectedGenusId!);
    }
  }

  /// Resolve genus_id to its ancestor IDs so we can auto-expand the tree.
  Future<void> _resolveAndExpand(int genusId) async {
    try {
      final path = await ref.read(taxonomyPathProvider(genusId).future);
      final classId = path['classId'] as int;
      final orderId = path['orderId'] as int;
      final familyId = path['familyId'] as int;
      final genus = path['genus'] as Map<String, dynamic>;
      final family = path['family'] as Map<String, dynamic>;
      final order = path['order'] as Map<String, dynamic>;
      final taxClass = path['class'] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _expandedClassIds.add(classId);
          _expandedOrderIds.add(orderId);
          _expandedFamilyIds.add(familyId);
          _breadcrumbClass = taxClass['name'] as String?;
          _breadcrumbOrder = order['name'] as String?;
          _breadcrumbFamily = family['name'] as String?;
          _breadcrumbGenus = genus['name'] as String?;
          _resolvedInitial = true;
        });
      }
    } catch (e) {
      AppLogger.warning('Taxonomy initial resolution failed (genus may be deleted)', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final classesAsync = ref.watch(taxonomyClassesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb bar
        if (_breadcrumbGenus != null) _buildBreadcrumbs(context, isDark),
        // Tree
        Card(
          color: isDark ? AppColors.darkCard : null,
          elevation: isDark ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isDark
                ? const BorderSide(color: AppColors.darkBorder, width: 0.5)
                : BorderSide.none,
          ),
          child: classesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child:
                  Text('${context.t.common.error}: $e', style: TextStyle(color: AppColors.error)),
            ),
            data: (classes) => _buildClassLevel(context, isDark, classes),
          ),
        ),
      ],
    );
  }

  // ── Breadcrumbs ──

  Widget _buildBreadcrumbs(BuildContext context, bool isDark) {
    final parts = <String>[
      ?_breadcrumbClass,
      ?_breadcrumbOrder,
      ?_breadcrumbFamily,
      ?_breadcrumbGenus,
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.primaryLight : AppColors.primary)
            .withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isDark ? AppColors.primaryLight : AppColors.primary)
              .withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle,
              size: 16,
              color: isDark ? AppColors.primaryLight : AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              parts.join('  >  '),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Level 1: Classes ──

  Widget _buildClassLevel(
      BuildContext context, bool isDark, List<Map<String, dynamic>> classes) {
    if (classes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.category_outlined,
                size: 40, color: isDark ? Colors.white24 : Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              context.t.admin.noTaxonomyClasses,
              style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey[500],
                  fontSize: 13),
            ),
            const SizedBox(height: 12),
            _addButton(
              context: context,
              isDark: isDark,
              label: context.t.species.classLabel,
              color: _classBorderColor,
              onAdd: () => _onAddClass(context),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...classes.map((cls) => _SelectorClassTile(
              key: ValueKey('sel-class-${cls['id']}'),
              classData: cls,
              isDark: isDark,
              selectedGenusId: widget.selectedGenusId,
              initiallyExpanded:
                  _expandedClassIds.contains(cls['id'] as int),
              expandedOrderIds: _expandedOrderIds,
              expandedFamilyIds: _expandedFamilyIds,
              onGenusSelected: _onGenusSelected,
              parentState: this,
            )),
        _addButton(
          context: context,
          isDark: isDark,
          label: context.t.species.classLabel,
          color: _classBorderColor,
          onAdd: () => _onAddClass(context),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  void _onGenusSelected(int genusId, String genusName, String familyName,
      String orderName, String className) {
    setState(() {
      _breadcrumbClass = className;
      _breadcrumbOrder = orderName;
      _breadcrumbFamily = familyName;
      _breadcrumbGenus = genusName;
    });
    widget.onGenusSelected(genusId);
  }

  // ── CRUD helpers ──

  Future<void> _onAddClass(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorLabel = context.t.common.error;
    final name = await _showNameDialog(
        context, '${context.t.admin.newItem} ${context.t.species.classLabel}');
    if (name == null) return;
    try {
      await createTaxonomyClass(name);
      ref.invalidate(taxonomyClassesProvider);
      ref.invalidate(taxonomyClassCountProvider);
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
              content: Text('$errorLabel: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> onEditItem({
    required BuildContext context,
    required String label,
    required String currentName,
    required Future<void> Function(String) onSave,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final savedText = context.t.admin.saved;
    final errorLabel = context.t.common.error;
    final newName = await _showNameDialog(
        context, '${context.t.common.edit} $label',
        initialValue: currentName);
    if (newName == null || newName == currentName) return;
    try {
      await onSave(newName);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(savedText)),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
              content: Text('$errorLabel: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void onDeleteItem({
    required BuildContext context,
    required String name,
    required VoidCallback onConfirm,
    bool warningChildren = false,
  }) {
    if (warningChildren) {
      _showDeleteWithChildrenDialog(context, name, onConfirm);
    } else {
      AdminDeleteDialog.show(
        context,
        entityName: name,
        onConfirm: onConfirm,
      );
    }
  }

  Future<void> _showDeleteWithChildrenDialog(
      BuildContext context, String name, VoidCallback onConfirm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.common.delete),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.admin.confirmDeleteNamed(name: name)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    AppColors.error.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.t.admin.deleteChildrenWarning,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.t.common.cancel),
          ),
          FilledButton(
            onPressed: () {
              onConfirm();
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(context.t.common.delete),
          ),
        ],
      ),
    );
  }

  Future<String?> _showNameDialog(BuildContext context, String title,
      {String? initialValue}) async {
    final controller = TextEditingController(text: initialValue ?? '');
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: context.t.admin.name,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (text) {
            final trimmed = text.trim();
            if (trimmed.isNotEmpty) Navigator.pop(ctx, trimmed);
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.t.common.cancel)),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.pop(ctx, text);
            },
            child: Text(context.t.common.save),
          ),
        ],
      ),
    );
  }

  Widget _addButton({
    required BuildContext context,
    required bool isDark,
    required String label,
    required Color color,
    required VoidCallback onAdd,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                '${context.t.common.add} $label',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Level 1 tile: Taxonomy Class (selector variant)
// ══════════════════════════════════════════════════════════════════

class _SelectorClassTile extends ConsumerStatefulWidget {
  final Map<String, dynamic> classData;
  final bool isDark;
  final int? selectedGenusId;
  final bool initiallyExpanded;
  final Set<int> expandedOrderIds;
  final Set<int> expandedFamilyIds;
  final void Function(
          int genusId, String genus, String family, String order, String cls)
      onGenusSelected;
  final AdminTaxonomySelectorState parentState;

  const _SelectorClassTile({
    super.key,
    required this.classData,
    required this.isDark,
    required this.selectedGenusId,
    required this.initiallyExpanded,
    required this.expandedOrderIds,
    required this.expandedFamilyIds,
    required this.onGenusSelected,
    required this.parentState,
  });

  @override
  ConsumerState<_SelectorClassTile> createState() =>
      _SelectorClassTileState();
}

class _SelectorClassTileState extends ConsumerState<_SelectorClassTile> {
  @override
  Widget build(BuildContext context) {
    final classId = widget.classData['id'] as int;
    final className = widget.classData['name'] as String;
    final isDark = widget.isDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AdminTaxonomySelectorState._classBorderColor,
            width: 3,
          ),
        ),
      ),
      child: ExpansionTile(
        key: PageStorageKey('sel-class-$classId'),
        initiallyExpanded: widget.initiallyExpanded,
        leading: Icon(Icons.category,
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            size: 20),
        title: Text(
          className,
          style: TextStyle(
            color: isDark ? Colors.white : null,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _selectorActionButton(
                Icons.edit_outlined,
                isDark ? AppColors.primaryLight : AppColors.primary,
                () => widget.parentState.onEditItem(
                      context: context,
                      label: context.t.species.classLabel,
                      currentName: className,
                      onSave: (newName) async {
                        await updateTaxonomyClass(classId, newName);
                        ref.invalidate(taxonomyClassesProvider);
                      },
                    )),
            _selectorActionButton(
                Icons.delete_outline,
                AppColors.error,
                () => widget.parentState.onDeleteItem(
                      context: context,
                      name: className,
                      warningChildren: true,
                      onConfirm: () async {
                        await deleteTaxonomyClass(classId);
                        ref.invalidate(taxonomyClassesProvider);
                      },
                    )),
            const SizedBox(width: 2),
            Icon(Icons.expand_more,
                color: isDark ? Colors.white38 : Colors.grey, size: 18),
          ],
        ),
        childrenPadding: const EdgeInsets.only(left: 12),
        children: [
          _SelectorOrderList(
            classId: classId,
            className: className,
            isDark: isDark,
            selectedGenusId: widget.selectedGenusId,
            expandedOrderIds: widget.expandedOrderIds,
            expandedFamilyIds: widget.expandedFamilyIds,
            onGenusSelected: widget.onGenusSelected,
            parentState: widget.parentState,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Level 2: Orders within a class (selector variant)
// ══════════════════════════════════════════════════════════════════

class _SelectorOrderList extends ConsumerWidget {
  final int classId;
  final String className;
  final bool isDark;
  final int? selectedGenusId;
  final Set<int> expandedOrderIds;
  final Set<int> expandedFamilyIds;
  final void Function(
          int genusId, String genus, String family, String order, String cls)
      onGenusSelected;
  final AdminTaxonomySelectorState parentState;

  const _SelectorOrderList({
    required this.classId,
    required this.className,
    required this.isDark,
    required this.selectedGenusId,
    required this.expandedOrderIds,
    required this.expandedFamilyIds,
    required this.onGenusSelected,
    required this.parentState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(taxonomyOrdersProvider(classId));

    return ordersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(12),
        child: Center(
            child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text('${context.t.common.error}: $e',
            style: TextStyle(color: AppColors.error, fontSize: 12)),
      ),
      data: (orders) {
        if (orders.isEmpty) {
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Text(
                  context.t.admin.noOrdersInClass,
                  style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.grey[400],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              parentState._addButton(
                context: context,
                isDark: isDark,
                label: context.t.species.order,
                color: AdminTaxonomySelectorState._orderBorderColor,
                onAdd: () => _onAddOrder(context, ref),
              ),
              const SizedBox(height: 6),
            ],
          );
        }
        return Column(
          children: [
            ...orders.map((order) => _SelectorOrderTile(
                  key: ValueKey('sel-order-${order['id']}'),
                  orderData: order,
                  className: className,
                  isDark: isDark,
                  selectedGenusId: selectedGenusId,
                  initiallyExpanded:
                      expandedOrderIds.contains(order['id'] as int),
                  expandedFamilyIds: expandedFamilyIds,
                  onGenusSelected: onGenusSelected,
                  parentState: parentState,
                )),
            parentState._addButton(
              context: context,
              isDark: isDark,
              label: context.t.species.order,
              color: AdminTaxonomySelectorState._orderBorderColor,
              onAdd: () => _onAddOrder(context, ref),
            ),
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }

  Future<void> _onAddOrder(BuildContext context, WidgetRef ref) async {
    final name = await parentState._showNameDialog(
        context, '${context.t.admin.newItem} ${context.t.species.order}');
    if (name == null) return;
    try {
      await createTaxonomyOrder(name, classId);
      ref.invalidate(taxonomyOrdersProvider(classId));
      ref.invalidate(taxonomyOrderCountProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${context.t.common.error}: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// Level 2 tile: Order (selector variant)
// ══════════════════════════════════════════════════════════════════

class _SelectorOrderTile extends ConsumerWidget {
  final Map<String, dynamic> orderData;
  final String className;
  final bool isDark;
  final int? selectedGenusId;
  final bool initiallyExpanded;
  final Set<int> expandedFamilyIds;
  final void Function(
          int genusId, String genus, String family, String order, String cls)
      onGenusSelected;
  final AdminTaxonomySelectorState parentState;

  const _SelectorOrderTile({
    super.key,
    required this.orderData,
    required this.className,
    required this.isDark,
    required this.selectedGenusId,
    required this.initiallyExpanded,
    required this.expandedFamilyIds,
    required this.onGenusSelected,
    required this.parentState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderId = orderData['id'] as int;
    final orderName = orderData['name'] as String;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AdminTaxonomySelectorState._orderBorderColor,
            width: 3,
          ),
        ),
      ),
      child: ExpansionTile(
        key: PageStorageKey('sel-order-$orderId'),
        initiallyExpanded: initiallyExpanded,
        leading: Icon(Icons.format_list_numbered,
            color: AdminTaxonomySelectorState._orderBorderColor, size: 18),
        title: Text(
          orderName,
          style: TextStyle(
            color: isDark ? Colors.white : null,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _selectorActionButton(
                Icons.edit_outlined,
                isDark ? AppColors.primaryLight : AppColors.primary,
                () => parentState.onEditItem(
                      context: context,
                      label: context.t.species.order,
                      currentName: orderName,
                      onSave: (newName) async {
                        await updateTaxonomyOrder(orderId, newName);
                        ref.invalidate(taxonomyOrdersProvider(
                            orderData['class_id'] as int));
                      },
                    )),
            _selectorActionButton(
                Icons.delete_outline,
                AppColors.error,
                () => parentState.onDeleteItem(
                      context: context,
                      name: orderName,
                      warningChildren: true,
                      onConfirm: () async {
                        await deleteTaxonomyOrder(orderId);
                        ref.invalidate(taxonomyOrdersProvider(
                            orderData['class_id'] as int));
                        ref.invalidate(taxonomyOrderCountProvider);
                      },
                    )),
            const SizedBox(width: 2),
            Icon(Icons.expand_more,
                color: isDark ? Colors.white38 : Colors.grey, size: 16),
          ],
        ),
        childrenPadding: const EdgeInsets.only(left: 12),
        children: [
          _SelectorFamilyList(
            orderId: orderId,
            orderName: orderName,
            className: className,
            isDark: isDark,
            selectedGenusId: selectedGenusId,
            expandedFamilyIds: expandedFamilyIds,
            onGenusSelected: onGenusSelected,
            parentState: parentState,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Level 3: Families within an order (selector variant)
// ══════════════════════════════════════════════════════════════════

class _SelectorFamilyList extends ConsumerWidget {
  final int orderId;
  final String orderName;
  final String className;
  final bool isDark;
  final int? selectedGenusId;
  final Set<int> expandedFamilyIds;
  final void Function(
          int genusId, String genus, String family, String order, String cls)
      onGenusSelected;
  final AdminTaxonomySelectorState parentState;

  const _SelectorFamilyList({
    required this.orderId,
    required this.orderName,
    required this.className,
    required this.isDark,
    required this.selectedGenusId,
    required this.expandedFamilyIds,
    required this.onGenusSelected,
    required this.parentState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familiesAsync = ref.watch(taxonomyFamiliesProvider(orderId));

    return familiesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(12),
        child: Center(
            child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text('${context.t.common.error}: $e',
            style: TextStyle(color: AppColors.error, fontSize: 12)),
      ),
      data: (families) {
        if (families.isEmpty) {
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Text(
                  context.t.admin.noFamiliesInOrder,
                  style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.grey[400],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              parentState._addButton(
                context: context,
                isDark: isDark,
                label: context.t.species.family,
                color: AdminTaxonomySelectorState._familyBorderColor,
                onAdd: () => _onAddFamily(context, ref),
              ),
              const SizedBox(height: 6),
            ],
          );
        }
        return Column(
          children: [
            ...families.map((family) => _SelectorFamilyTile(
                  key: ValueKey('sel-family-${family['id']}'),
                  familyData: family,
                  orderName: orderName,
                  className: className,
                  isDark: isDark,
                  selectedGenusId: selectedGenusId,
                  initiallyExpanded:
                      expandedFamilyIds.contains(family['id'] as int),
                  onGenusSelected: onGenusSelected,
                  parentState: parentState,
                )),
            parentState._addButton(
              context: context,
              isDark: isDark,
              label: context.t.species.family,
              color: AdminTaxonomySelectorState._familyBorderColor,
              onAdd: () => _onAddFamily(context, ref),
            ),
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }

  Future<void> _onAddFamily(BuildContext context, WidgetRef ref) async {
    final name = await parentState._showNameDialog(
        context, '${context.t.admin.newItem} ${context.t.species.family}');
    if (name == null) return;
    try {
      await createTaxonomyFamily(name, orderId);
      ref.invalidate(taxonomyFamiliesProvider(orderId));
      ref.invalidate(taxonomyFamilyCountProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${context.t.common.error}: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// Level 3 tile: Family (selector variant)
// ══════════════════════════════════════════════════════════════════

class _SelectorFamilyTile extends ConsumerWidget {
  final Map<String, dynamic> familyData;
  final String orderName;
  final String className;
  final bool isDark;
  final int? selectedGenusId;
  final bool initiallyExpanded;
  final void Function(
          int genusId, String genus, String family, String order, String cls)
      onGenusSelected;
  final AdminTaxonomySelectorState parentState;

  const _SelectorFamilyTile({
    super.key,
    required this.familyData,
    required this.orderName,
    required this.className,
    required this.isDark,
    required this.selectedGenusId,
    required this.initiallyExpanded,
    required this.onGenusSelected,
    required this.parentState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyId = familyData['id'] as int;
    final familyName = familyData['name'] as String;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AdminTaxonomySelectorState._familyBorderColor,
            width: 3,
          ),
        ),
      ),
      child: ExpansionTile(
        key: PageStorageKey('sel-family-$familyId'),
        initiallyExpanded: initiallyExpanded,
        leading: Icon(Icons.family_restroom,
            color: AdminTaxonomySelectorState._familyBorderColor, size: 18),
        title: Text(
          familyName,
          style: TextStyle(
            color: isDark ? Colors.white : null,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _selectorActionButton(
                Icons.edit_outlined,
                isDark ? AppColors.primaryLight : AppColors.primary,
                () => parentState.onEditItem(
                      context: context,
                      label: context.t.species.family,
                      currentName: familyName,
                      onSave: (newName) async {
                        await updateTaxonomyFamily(familyId, newName);
                        ref.invalidate(taxonomyFamiliesProvider(
                            familyData['order_id'] as int));
                      },
                    )),
            _selectorActionButton(
                Icons.delete_outline,
                AppColors.error,
                () => parentState.onDeleteItem(
                      context: context,
                      name: familyName,
                      warningChildren: true,
                      onConfirm: () async {
                        await deleteTaxonomyFamily(familyId);
                        ref.invalidate(taxonomyFamiliesProvider(
                            familyData['order_id'] as int));
                        ref.invalidate(taxonomyFamilyCountProvider);
                      },
                    )),
            const SizedBox(width: 2),
            Icon(Icons.expand_more,
                color: isDark ? Colors.white38 : Colors.grey, size: 16),
          ],
        ),
        childrenPadding: const EdgeInsets.only(left: 12),
        children: [
          _SelectorGenusList(
            familyId: familyId,
            familyName: familyName,
            orderName: orderName,
            className: className,
            isDark: isDark,
            selectedGenusId: selectedGenusId,
            onGenusSelected: onGenusSelected,
            parentState: parentState,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Level 4: Genera within a family (selector variant)
// ══════════════════════════════════════════════════════════════════

class _SelectorGenusList extends ConsumerWidget {
  final int familyId;
  final String familyName;
  final String orderName;
  final String className;
  final bool isDark;
  final int? selectedGenusId;
  final void Function(
          int genusId, String genus, String family, String order, String cls)
      onGenusSelected;
  final AdminTaxonomySelectorState parentState;

  const _SelectorGenusList({
    required this.familyId,
    required this.familyName,
    required this.orderName,
    required this.className,
    required this.isDark,
    required this.selectedGenusId,
    required this.onGenusSelected,
    required this.parentState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generaAsync = ref.watch(taxonomyGeneraProvider(familyId));

    return generaAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(12),
        child: Center(
            child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text('${context.t.common.error}: $e',
            style: TextStyle(color: AppColors.error, fontSize: 12)),
      ),
      data: (genera) {
        if (genera.isEmpty) {
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Text(
                  context.t.admin.noGeneraInFamily,
                  style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.grey[400],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              parentState._addButton(
                context: context,
                isDark: isDark,
                label: context.t.species.genus,
                color: AdminTaxonomySelectorState._genusBorderColor,
                onAdd: () => _onAddGenus(context, ref),
              ),
              const SizedBox(height: 6),
            ],
          );
        }
        return Column(
          children: [
            ...genera.map((genus) => _SelectorGenusTile(
                  key: ValueKey('sel-genus-${genus['id']}'),
                  genusData: genus,
                  isDark: isDark,
                  isSelected: selectedGenusId == (genus['id'] as int),
                  onTap: () => onGenusSelected(
                    genus['id'] as int,
                    genus['name'] as String,
                    familyName,
                    orderName,
                    className,
                  ),
                  onEdit: () => parentState.onEditItem(
                    context: context,
                    label: context.t.species.genus,
                    currentName: genus['name'] as String,
                    onSave: (newName) async {
                      await updateTaxonomyGenus(
                          genus['id'] as int, newName);
                      ref.invalidate(taxonomyGeneraProvider(familyId));
                    },
                  ),
                  onDelete: () => parentState.onDeleteItem(
                    context: context,
                    name: genus['name'] as String,
                    warningChildren: false,
                    onConfirm: () async {
                      await deleteTaxonomyGenus(genus['id'] as int);
                      ref.invalidate(taxonomyGeneraProvider(familyId));
                      ref.invalidate(taxonomyGenusCountProvider);
                    },
                  ),
                )),
            parentState._addButton(
              context: context,
              isDark: isDark,
              label: context.t.species.genus,
              color: AdminTaxonomySelectorState._genusBorderColor,
              onAdd: () => _onAddGenus(context, ref),
            ),
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }

  Future<void> _onAddGenus(BuildContext context, WidgetRef ref) async {
    final name = await parentState._showNameDialog(
        context, '${context.t.admin.newItem} ${context.t.species.genus}');
    if (name == null) return;
    try {
      await createTaxonomyGenus(name, familyId);
      ref.invalidate(taxonomyGeneraProvider(familyId));
      ref.invalidate(taxonomyGenusCountProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${context.t.common.error}: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// Level 4 tile: Genus leaf node with SELECTION support
// ══════════════════════════════════════════════════════════════════

class _SelectorGenusTile extends StatelessWidget {
  final Map<String, dynamic> genusData;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SelectorGenusTile({
    super.key,
    required this.genusData,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final genusName = genusData['name'] as String;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withValues(alpha: isDark ? 0.18 : 0.1)
            : null,
        border: Border(
          left: BorderSide(
            color: isSelected
                ? primaryColor
                : AdminTaxonomySelectorState._genusBorderColor,
            width: 3,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: ListTile(
        dense: true,
        onTap: onTap,
        leading: isSelected
            ? Icon(Icons.check_circle, color: primaryColor, size: 18)
            : Icon(Icons.eco,
                color: AdminTaxonomySelectorState._genusBorderColor, size: 16),
        title: Text(
          genusName,
          style: TextStyle(
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.white : null),
            fontStyle: FontStyle.italic,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _selectorActionButton(
                Icons.edit_outlined,
                isDark ? AppColors.primaryLight : AppColors.primary,
                onEdit),
            _selectorActionButton(
                Icons.delete_outline, AppColors.error, onDelete),
          ],
        ),
      ),
    );
  }
}

// ── Shared small icon button for selector ──

Widget _selectorActionButton(
    IconData icon, Color color, VoidCallback onPressed) {
  return SizedBox(
    width: 28,
    height: 28,
    child: IconButton(
      icon: Icon(icon, size: 14, color: color),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: 14,
    ),
  );
}
