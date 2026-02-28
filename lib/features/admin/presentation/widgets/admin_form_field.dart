import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';

class AdminFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool required;

  const AdminFormField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator ?? (required
            ? (v) => (v == null || v.isEmpty) ? context.t.admin.required : null
            : null),
        style: TextStyle(color: isDark ? Colors.white : null),
        decoration: InputDecoration(
          labelText: '$label${required ? ' *' : ''}',
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : null,
          ),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : Colors.grey[300]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? AppColors.primaryLight : AppColors.primary,
              width: 2,
            ),
          ),
          filled: isDark,
          fillColor: isDark ? AppColors.darkSurface : null,
        ),
      ),
    );
  }
}

class AdminBilingualField extends StatelessWidget {
  final String label;
  final TextEditingController controllerEs;
  final TextEditingController controllerEn;
  final int maxLines;
  final bool required;
  final bool sideBySide;

  const AdminBilingualField({
    super.key,
    required this.label,
    required this.controllerEs,
    required this.controllerEn,
    this.maxLines = 1,
    this.required = false,
    this.sideBySide = false,
  });

  @override
  Widget build(BuildContext context) {
    final esField = AdminFormField(
      label: '$label (ES)',
      controller: controllerEs,
      maxLines: maxLines,
      required: required,
    );
    final enField = AdminFormField(
      label: '$label (EN)',
      controller: controllerEn,
      maxLines: maxLines,
      required: required,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (sideBySide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: esField),
              const SizedBox(width: 16),
              Expanded(child: enField),
            ],
          )
        else ...[
          esField,
          enField,
        ],
      ],
    );
  }
}
