import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';

/// Reusable scaffold for admin create/edit forms.
///
/// Handles:
/// - PopScope + unsaved-changes confirmation dialog
/// - AppBar with bilingual edit/create title and loading/save button
/// - LayoutBuilder → Form → Center → ConstrainedBox → ListView wrapper
class AdminFormScaffold extends StatelessWidget {
  const AdminFormScaffold({
    super.key,
    required this.formKey,
    required this.isEditing,
    required this.entityLabel,
    required this.hasUnsavedChanges,
    required this.isLoading,
    required this.onSave,
    required this.children,
  });

  final GlobalKey<FormState> formKey;
  final bool isEditing;

  /// Localised entity label shown in the AppBar title, e.g. "Categoría".
  final String entityLabel;

  final bool hasUnsavedChanges;
  final bool isLoading;
  final VoidCallback onSave;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showUnsavedDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing
              ? '${t.admin.editItem} $entityLabel'
              : '${t.admin.newItem} $entityLabel'),
          backgroundColor: isDark ? AppColors.darkBackground : null,
          actions: [
            if (isLoading)
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
                tooltip: t.common.save,
                onPressed: onSave,
              ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Form(
              key: formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: children,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showUnsavedDialog(BuildContext context) {
    final t = context.t;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.admin.unsavedChangesTitle),
        content: Text(t.admin.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(t.admin.discard),
          ),
        ],
      ),
    );
  }
}

/// Shown while an entity is being loaded for editing.
class AdminFormLoadingScaffold extends StatelessWidget {
  const AdminFormLoadingScaffold({super.key, this.error});
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.admin.editItem)),
      body: error != null
          ? Center(child: Text('${t.common.error}: $error'))
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
