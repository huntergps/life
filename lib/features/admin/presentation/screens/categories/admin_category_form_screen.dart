import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/utils/error_handler.dart';
import '../../../providers/admin_category_provider.dart';
import '../../widgets/admin_form_field.dart';
import '../../widgets/admin_form_scaffold.dart';

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
    for (final c in _controllers) {
      c.addListener(_markDirty);
    }
  }

  List<TextEditingController> get _controllers => [
        _slugController,
        _nameEsController,
        _nameEnController,
        _iconNameController,
        _sortOrderController,
      ];

  void _markDirty() {
    if (_initialized && !_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.removeListener(_markDirty);
      c.dispose();
    }
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
      if (isEditing) data['id'] = widget.categoryId;

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
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      final categoryAsync = ref.watch(adminCategoryProvider(widget.categoryId!));
      return categoryAsync.when(
        loading: () => const AdminFormLoadingScaffold(),
        error: (e, _) => AdminFormLoadingScaffold(error: e),
        data: (data) {
          if (data != null) _populateFields(data);
          return _buildForm(context);
        },
      );
    }

    if (!_initialized) _initialized = true;
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 600;

    return AdminFormScaffold(
      formKey: _formKey,
      isEditing: isEditing,
      entityLabel: context.t.admin.categories,
      hasUnsavedChanges: _hasUnsavedChanges,
      isLoading: _isLoading,
      onSave: _save,
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
    );
  }
}
