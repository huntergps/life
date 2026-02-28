import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/features/badges/models/badge_definition.dart';

/// A celebratory dialog shown when the user earns a new badge.
class BadgeUnlockDialog extends StatelessWidget {
  final BadgeProgress badge;

  const BadgeUnlockDialog({super.key, required this.badge});

  /// Show the dialog for a single [BadgeProgress].
  static Future<void> show(BuildContext context, BadgeProgress badge) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => BadgeUnlockDialog(badge: badge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final badgeDef = badge.badge;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Congratulations title
          Text(
            t.badges.congratulations,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Badge icon in a colored circle
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: badgeDef.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: badgeDef.color.withValues(alpha: 0.4),
                width: 3,
              ),
            ),
            child: Icon(
              badgeDef.icon,
              size: 48,
              color: badgeDef.color,
            ),
          ),
          const SizedBox(height: 20),

          // "Badge Unlocked!" subtitle
          Text(
            t.badges.badgeUnlocked,
            style: theme.textTheme.titleMedium?.copyWith(
              color: badgeDef.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Badge name
          Text(
            badgeDef.name(t),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Badge description
          Text(
            badgeDef.description(t),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: badgeDef.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(t.common.ok),
          ),
        ),
      ],
    );
  }
}
