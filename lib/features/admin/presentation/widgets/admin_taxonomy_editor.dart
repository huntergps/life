import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import '../../providers/admin_taxonomy_provider.dart';
import 'admin_delete_dialog.dart';

/// Expandable tree editor for the 4-level taxonomy hierarchy:
/// Class > Order > Family > Genus.
class AdminTaxonomyEditor extends ConsumerStatefulWidget {
  const AdminTaxonomyEditor({super.key});

  @override
  ConsumerState<AdminTaxonomyEditor> createState() => _AdminTaxonomyEditorState();
}

class _AdminTaxonomyEditorState extends ConsumerState<AdminTaxonomyEditor> {
  // Level border colors
  static const _classBorderColor = Color(0xFF2E7D32); // green
  static const _orderBorderColor = Color(0xFF1565C0); // blue
  static const _familyBorderColor = Color(0xFFE65100); // orange
  static const _genusBorderColor = Color(0xFF6A1B9A); // purple

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final classesAsync = ref.watch(taxonomyClassesProvider);

    return Card(
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
          child: Text('${context.t.common.error}: $e', style: TextStyle(color: AppColors.error)),
        ),
        data: (classes) => _buildClassLevel(context, isDark, classes),
      ),
    );
  }

  // ── Level 1: Classes ──

  Widget _buildClassLevel(BuildContext context, bool isDark, List<Map<String, dynamic>> classes) {
    if (classes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.category_outlined, size: 48, color: isDark ? Colors.white24 : Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              context.t.admin.noTaxonomyClasses,
              style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[500]),
            ),
            const SizedBox(height: 16),
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
        ...classes.map((cls) => _ClassTile(
          key: ValueKey('class-${cls['id']}'),
          classData: cls,
          isDark: isDark,
          onEdit: () => _onEditItem(
            context: context,
            label: context.t.species.classLabel,
            currentName: cls['name'] as String,
            onSave: (newName) async {
              await updateTaxonomyClass(cls['id'] as int, newName);
              ref.invalidate(taxonomyClassesProvider);
            },
          ),
          onDelete: () => _onDeleteItem(
            context: context,
            name: cls['name'] as String,
            warningChildren: true,
            onConfirm: () async {
              await deleteTaxonomyClass(cls['id'] as int);
              ref.invalidate(taxonomyClassesProvider);
            },
          ),
        )),
        _addButton(
          context: context,
          isDark: isDark,
          label: context.t.species.classLabel,
          color: _classBorderColor,
          onAdd: () => _onAddClass(context),
        ),
      ],
    );
  }

  Future<void> _onAddClass(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorLabel = context.t.common.error;
    final name = await _showNameDialog(context, '${context.t.admin.newItem} ${context.t.species.classLabel}');
    if (name == null) return;
    try {
      await createTaxonomyClass(name);
      ref.invalidate(taxonomyClassesProvider);
      ref.invalidate(taxonomyClassCountProvider);
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(errorLabel), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // ── Shared helpers ──

  Future<void> _onEditItem({
    required BuildContext context,
    required String label,
    required String currentName,
    required Future<void> Function(String) onSave,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final savedText = context.t.admin.saved;
    final errorLabel = context.t.common.error;
    final newName = await _showNameDialog(context, '${context.t.common.edit} $label', initialValue: currentName);
    if (newName == null || newName == currentName) return;
    try {
      await onSave(newName);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(savedText)),
        );
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(errorLabel), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _onDeleteItem({
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

  Future<void> _showDeleteWithChildrenDialog(BuildContext context, String name, VoidCallback onConfirm) {
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
                color: AppColors.error.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
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

  Future<String?> _showNameDialog(BuildContext context, String title, {String? initialValue}) async {
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.t.common.cancel)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                '${context.t.common.add} $label',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
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
// Level 1 tile: Taxonomy Class
// ══════════════════════════════════════════════════════════════════

class _ClassTile extends ConsumerWidget {
  final Map<String, dynamic> classData;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClassTile({
    super.key,
    required this.classData,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classId = classData['id'] as int;
    final className = classData['name'] as String;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: _AdminTaxonomyEditorState._classBorderColor,
            width: 3,
          ),
        ),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.category, color: isDark ? AppColors.primaryLight : AppColors.primary, size: 22),
        title: Text(
          className,
          style: TextStyle(
            color: isDark ? Colors.white : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${classData['kingdom'] ?? 'Animalia'} > ${classData['phylum'] ?? 'Chordata'}',
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.grey[500],
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionButton(Icons.edit_outlined, isDark ? AppColors.primaryLight : AppColors.primary, onEdit),
            _actionButton(Icons.delete_outline, AppColors.error, onDelete),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, color: isDark ? Colors.white38 : Colors.grey),
          ],
        ),
        childrenPadding: const EdgeInsets.only(left: 16),
        children: [
          _OrderList(classId: classId, isDark: isDark),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Level 2: Orders within a class
// ══════════════════════════════════════════════════════════════════

class _OrderList extends ConsumerWidget {
  final int classId;
  final bool isDark;

  const _OrderList({required this.classId, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(taxonomyOrdersProvider(classId));
    final parentState = context.findAncestorStateOfType<_AdminTaxonomyEditorState>()!;

    return ordersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text('${context.t.common.error}: $e', style: TextStyle(color: AppColors.error, fontSize: 12)),
      ),
      data: (orders) {
        if (orders.isEmpty) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  context.t.admin.noOrdersInClass,
                  style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.grey[400],
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              parentState._addButton(
                context: context,
                isDark: isDark,
                label: context.t.species.order,
                color: _AdminTaxonomyEditorState._orderBorderColor,
                onAdd: () => _onAddOrder(context, ref, parentState),
              ),
              const SizedBox(height: 8),
            ],
          );
        }
        return Column(
          children: [
            ...orders.map((order) => _OrderTile(
              key: ValueKey('order-${order['id']}'),
              orderData: order,
              isDark: isDark,
              onEdit: () => parentState._onEditItem(
                context: context,
                label: context.t.species.order,
                currentName: order['name'] as String,
                onSave: (newName) async {
                  await updateTaxonomyOrder(order['id'] as int, newName);
                  ref.invalidate(taxonomyOrdersProvider(classId));
                },
              ),
              onDelete: () => parentState._onDeleteItem(
                context: context,
                name: order['name'] as String,
                warningChildren: true,
                onConfirm: () async {
                  await deleteTaxonomyOrder(order['id'] as int);
                  ref.invalidate(taxonomyOrdersProvider(classId));
                  ref.invalidate(taxonomyOrderCountProvider);
                },
              ),
            )),
            parentState._addButton(
              context: context,
              isDark: isDark,
              label: context.t.species.order,
              color: _AdminTaxonomyEditorState._orderBorderColor,
              onAdd: () => _onAddOrder(context, ref, parentState),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Future<void> _onAddOrder(BuildContext context, WidgetRef ref, _AdminTaxonomyEditorState parentState) async {
    final name = await parentState._showNameDialog(context, '${context.t.admin.newItem} ${context.t.species.order}');
    if (name == null) return;
    try {
      await createTaxonomyOrder(name, classId);
      ref.invalidate(taxonomyOrdersProvider(classId));
      ref.invalidate(taxonomyOrderCountProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.common.error), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// Level 2 tile: Taxonomy Order
// ══════════════════════════════════════════════════════════════════

class _OrderTile extends ConsumerWidget {
  final Map<String, dynamic> orderData;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OrderTile({
    super.key,
    required this.orderData,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderId = orderData['id'] as int;
    final orderName = orderData['name'] as String;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: _AdminTaxonomyEditorState._orderBorderColor,
            width: 3,
          ),
        ),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.format_list_numbered, color: _AdminTaxonomyEditorState._orderBorderColor, size: 20),
        title: Text(
          orderName,
          style: TextStyle(
            color: isDark ? Colors.white : null,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionButton(Icons.edit_outlined, isDark ? AppColors.primaryLight : AppColors.primary, onEdit),
            _actionButton(Icons.delete_outline, AppColors.error, onDelete),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, color: isDark ? Colors.white38 : Colors.grey, size: 20),
          ],
        ),
        childrenPadding: const EdgeInsets.only(left: 16),
        children: [
          _FamilyList(orderId: orderId, isDark: isDark),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Level 3: Families within an order
// ══════════════════════════════════════════════════════════════════

class _FamilyList extends ConsumerWidget {
  final int orderId;
  final bool isDark;

  const _FamilyList({required this.orderId, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familiesAsync = ref.watch(taxonomyFamiliesProvider(orderId));
    final parentState = context.findAncestorStateOfType<_AdminTaxonomyEditorState>()!;

    return familiesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text('${context.t.common.error}: $e', style: TextStyle(color: AppColors.error, fontSize: 12)),
      ),
      data: (families) {
        if (families.isEmpty) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  context.t.admin.noFamiliesInOrder,
                  style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.grey[400],
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              parentState._addButton(
                context: context,
                isDark: isDark,
                label: context.t.species.family,
                color: _AdminTaxonomyEditorState._familyBorderColor,
                onAdd: () => _onAddFamily(context, ref, parentState),
              ),
              const SizedBox(height: 8),
            ],
          );
        }
        return Column(
          children: [
            ...families.map((family) => _FamilyTile(
              key: ValueKey('family-${family['id']}'),
              familyData: family,
              isDark: isDark,
              onEdit: () => parentState._onEditItem(
                context: context,
                label: context.t.species.family,
                currentName: family['name'] as String,
                onSave: (newName) async {
                  await updateTaxonomyFamily(family['id'] as int, newName);
                  ref.invalidate(taxonomyFamiliesProvider(orderId));
                },
              ),
              onDelete: () => parentState._onDeleteItem(
                context: context,
                name: family['name'] as String,
                warningChildren: true,
                onConfirm: () async {
                  await deleteTaxonomyFamily(family['id'] as int);
                  ref.invalidate(taxonomyFamiliesProvider(orderId));
                  ref.invalidate(taxonomyFamilyCountProvider);
                },
              ),
            )),
            parentState._addButton(
              context: context,
              isDark: isDark,
              label: context.t.species.family,
              color: _AdminTaxonomyEditorState._familyBorderColor,
              onAdd: () => _onAddFamily(context, ref, parentState),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Future<void> _onAddFamily(BuildContext context, WidgetRef ref, _AdminTaxonomyEditorState parentState) async {
    final name = await parentState._showNameDialog(context, '${context.t.admin.newItem} ${context.t.species.family}');
    if (name == null) return;
    try {
      await createTaxonomyFamily(name, orderId);
      ref.invalidate(taxonomyFamiliesProvider(orderId));
      ref.invalidate(taxonomyFamilyCountProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.common.error), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// Level 3 tile: Taxonomy Family
// ══════════════════════════════════════════════════════════════════

class _FamilyTile extends ConsumerWidget {
  final Map<String, dynamic> familyData;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FamilyTile({
    super.key,
    required this.familyData,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyId = familyData['id'] as int;
    final familyName = familyData['name'] as String;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: _AdminTaxonomyEditorState._familyBorderColor,
            width: 3,
          ),
        ),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.family_restroom, color: _AdminTaxonomyEditorState._familyBorderColor, size: 20),
        title: Text(
          familyName,
          style: TextStyle(
            color: isDark ? Colors.white : null,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionButton(Icons.edit_outlined, isDark ? AppColors.primaryLight : AppColors.primary, onEdit),
            _actionButton(Icons.delete_outline, AppColors.error, onDelete),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, color: isDark ? Colors.white38 : Colors.grey, size: 20),
          ],
        ),
        childrenPadding: const EdgeInsets.only(left: 16),
        children: [
          _GenusList(familyId: familyId, isDark: isDark),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Level 4: Genera within a family
// ══════════════════════════════════════════════════════════════════

class _GenusList extends ConsumerWidget {
  final int familyId;
  final bool isDark;

  const _GenusList({required this.familyId, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generaAsync = ref.watch(taxonomyGeneraProvider(familyId));
    final parentState = context.findAncestorStateOfType<_AdminTaxonomyEditorState>()!;

    return generaAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text('${context.t.common.error}: $e', style: TextStyle(color: AppColors.error, fontSize: 12)),
      ),
      data: (genera) {
        if (genera.isEmpty) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  context.t.admin.noGeneraInFamily,
                  style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.grey[400],
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              parentState._addButton(
                context: context,
                isDark: isDark,
                label: context.t.species.genus,
                color: _AdminTaxonomyEditorState._genusBorderColor,
                onAdd: () => _onAddGenus(context, ref, parentState),
              ),
              const SizedBox(height: 8),
            ],
          );
        }
        return Column(
          children: [
            ...genera.map((genus) => _GenusTile(
              key: ValueKey('genus-${genus['id']}'),
              genusData: genus,
              isDark: isDark,
              onEdit: () => parentState._onEditItem(
                context: context,
                label: context.t.species.genus,
                currentName: genus['name'] as String,
                onSave: (newName) async {
                  await updateTaxonomyGenus(genus['id'] as int, newName);
                  ref.invalidate(taxonomyGeneraProvider(familyId));
                },
              ),
              onDelete: () => parentState._onDeleteItem(
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
              color: _AdminTaxonomyEditorState._genusBorderColor,
              onAdd: () => _onAddGenus(context, ref, parentState),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Future<void> _onAddGenus(BuildContext context, WidgetRef ref, _AdminTaxonomyEditorState parentState) async {
    final name = await parentState._showNameDialog(context, '${context.t.admin.newItem} ${context.t.species.genus}');
    if (name == null) return;
    try {
      await createTaxonomyGenus(name, familyId);
      ref.invalidate(taxonomyGeneraProvider(familyId));
      ref.invalidate(taxonomyGenusCountProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.common.error), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// Level 4 tile: Taxonomy Genus (leaf node — ListTile, not expandable)
// ══════════════════════════════════════════════════════════════════

class _GenusTile extends StatelessWidget {
  final Map<String, dynamic> genusData;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GenusTile({
    super.key,
    required this.genusData,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final genusName = genusData['name'] as String;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: _AdminTaxonomyEditorState._genusBorderColor,
            width: 3,
          ),
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(Icons.eco, color: _AdminTaxonomyEditorState._genusBorderColor, size: 18),
        title: Text(
          genusName,
          style: TextStyle(
            color: isDark ? Colors.white : null,
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionButton(Icons.edit_outlined, isDark ? AppColors.primaryLight : AppColors.primary, onEdit),
            _actionButton(Icons.delete_outline, AppColors.error, onDelete),
          ],
        ),
      ),
    );
  }
}

// ── Shared small icon button ──

Widget _actionButton(IconData icon, Color color, VoidCallback onPressed) {
  return SizedBox(
    width: 32,
    height: 32,
    child: IconButton(
      icon: Icon(icon, size: 16, color: color),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: 16,
    ),
  );
}
