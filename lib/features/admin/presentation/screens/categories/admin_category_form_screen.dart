import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/utils/error_handler.dart';
import '../../../providers/admin_category_provider.dart';
import '../../widgets/admin_form_field.dart';

class AdminCategoryFormScreen extends ConsumerStatefulWidget {
  final int? categoryId;

  const AdminCategoryFormScreen({super.key, this.categoryId});

  @override
  ConsumerState<AdminCategoryFormScreen> createState() => _AdminCategoryFormScreenState();
}

class _AdminCategoryFormScreenState extends ConsumerState<AdminCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _slugController = TextEditingController();
  final _nameEsController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _iconNameController = TextEditingController();
  final _sortOrderController = TextEditingController(text: '0');
  bool _isLoading = false;
  bool _initialized = false;
  bool _hasUnsavedChanges = false;

  bool get isEditing => widget.categoryId != null;

  @override
  void initState() {
    super.initState();
    _slugController.addListener(_onFieldChanged);
    _nameEsController.addListener(_onFieldChanged);
    _nameEnController.addListener(_onFieldChanged);
    _iconNameController.addListener(_onFieldChanged);
    _sortOrderController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (_initialized && !_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  @override
  void dispose() {
    _slugController.removeListener(_onFieldChanged);
    _nameEsController.removeListener(_onFieldChanged);
    _nameEnController.removeListener(_onFieldChanged);
    _iconNameController.removeListener(_onFieldChanged);
    _sortOrderController.removeListener(_onFieldChanged);
    _slugController.dispose();
    _nameEsController.dispose();
    _nameEnController.dispose();
    _iconNameController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  void _populateFields(Map<String, dynamic> data) {
    if (_initialized) return;
    _initialized = true;
    _slugController.text = data['slug'] ?? '';
    _nameEsController.text = data['name_es'] ?? '';
    _nameEnController.text = data['name_en'] ?? '';
    _iconNameController.text = data['icon_name'] ?? '';
    _sortOrderController.text = '${data['sort_order'] ?? 0}';
    // Reset after population so initial load doesn't trigger unsaved changes
    _hasUnsavedChanges = false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{
        'slug': _slugController.text.trim(),
        'name_es': _nameEsController.text.trim(),
        'name_en': _nameEnController.text.trim(),
        'icon_name': _iconNameController.text.trim().isEmpty
            ? null
            : _iconNameController.text.trim(),
        'sort_order': int.tryParse(_sortOrderController.text) ?? 0,
      };

      if (isEditing) {
        data['id'] = widget.categoryId;
      }

      final service = ref.read(adminSupabaseServiceProvider);
      await service.upsertCategory(data);
      ref.invalidate(adminCategoriesProvider);

      if (mounted) {
        setState(() => _hasUnsavedChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? context.t.admin.categoryUpdated : context.t.admin.categoryCreated)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isEditing) {
      final categoryAsync = ref.watch(adminCategoryProvider(widget.categoryId!));
      return categoryAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: Text(context.t.admin.editItem)),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(title: Text(context.t.admin.editItem)),
          body: Center(child: Text('${context.t.common.error}: $e')),
        ),
        data: (data) {
          if (data != null) _populateFields(data);
          return _buildForm(context, isDark);
        },
      );
    }

    // For new items, mark as initialized so listeners can track changes
    if (!_initialized) {
      _initialized = true;
    }

    return _buildForm(context, isDark);
  }

  Widget _buildForm(BuildContext context, bool isDark) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(context.t.admin.unsavedChangesTitle),
              content: Text(context.t.admin.unsavedChangesMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(context.t.common.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: Text(context.t.admin.discard),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? '${context.t.admin.editItem} ${context.t.admin.categories}' : '${context.t.admin.newItem} ${context.t.admin.categories}'),
          backgroundColor: isDark ? AppColors.darkBackground : null,
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.check),
                tooltip: context.t.common.save,
                onPressed: _save,
              ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Form(
              key: _formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      AdminBilingualField(
                        label: context.t.admin.name,
                        controllerEs: _nameEsController,
                        controllerEn: _nameEnController,
                        required: true,
                        sideBySide: isWide,
                      ),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AdminFormField(
                                label: context.t.admin.slug,
                                controller: _slugController,
                                required: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AdminFormField(
                                label: context.t.admin.iconName,
                                controller: _iconNameController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 120,
                              child: AdminFormField(
                                label: context.t.admin.sortOrder,
                                controller: _sortOrderController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        AdminFormField(
                          label: context.t.admin.slug,
                          controller: _slugController,
                          required: true,
                        ),
                        AdminFormField(
                          label: context.t.admin.iconName,
                          controller: _iconNameController,
                        ),
                        AdminFormField(
                          label: context.t.admin.sortOrder,
                          controller: _sortOrderController,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
