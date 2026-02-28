import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';

class AdminDeleteDialog extends StatelessWidget {
  final String entityName;
  final VoidCallback onConfirm;

  const AdminDeleteDialog({
    super.key,
    required this.entityName,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String entityName,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AdminDeleteDialog(
        entityName: entityName,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.common.delete),
      content: Text(t.admin.confirmDeleteNamed(name: entityName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(t.common.cancel),
        ),
        FilledButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(true);
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: Text(t.common.delete),
        ),
      ],
    );
  }
}
