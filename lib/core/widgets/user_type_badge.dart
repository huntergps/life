import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';

class UserTypeBadge extends StatelessWidget {
  final String userType;
  final String? affiliation;
  final bool compact; // true = icon only, false = icon + text

  const UserTypeBadge({
    super.key,
    required this.userType,
    this.affiliation,
    this.compact = false,
  });

  static const _config = {
    'researcher': (icon: Icons.biotech, color: Colors.blue, labelEn: 'Researcher', labelEs: 'Investigador/a'),
    'guide': (icon: Icons.hiking, color: Colors.green, labelEn: 'Naturalist Guide', labelEs: 'Guia naturalista'),
    'ranger': (icon: Icons.security, color: Colors.orange, labelEn: 'Park Ranger', labelEs: 'Guardaparque'),
    'student': (icon: Icons.menu_book, color: Colors.purple, labelEn: 'Student', labelEs: 'Estudiante'),
  };

  @override
  Widget build(BuildContext context) {
    if (userType == 'tourist') return const SizedBox.shrink();

    final config = _config[userType];
    if (config == null) return const SizedBox.shrink();

    final isEs = LocaleSettings.currentLocale == AppLocale.es;
    final label = isEs ? config.labelEs : config.labelEn;

    if (compact) {
      return Tooltip(
        message: affiliation != null ? '$label — $affiliation' : label,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: config.color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(config.icon, size: 16, color: config.color),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              affiliation != null ? '$label — $affiliation' : label,
              style: TextStyle(fontSize: 12, color: config.color, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
