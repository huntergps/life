import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/bootstrap.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';

/// A celebratory dialog shown on the user's birthday.
///
/// Uses [SharedPreferences] via [Bootstrap.prefs] to ensure the dialog is
/// only shown once per calendar day.
class BirthdayDialog extends StatelessWidget {
  const BirthdayDialog({super.key});

  static const _prefsKey = 'birthday_dialog_shown_date';

  /// Shows the birthday dialog if it hasn't been shown today.
  ///
  /// Checks [SharedPreferences] for the key `birthday_dialog_shown_date`.
  /// If the stored value matches today's date (yyyy-MM-dd), the dialog is
  /// skipped. Otherwise, it is shown and the date is persisted.
  static Future<void> show(BuildContext context) async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final lastShown = Bootstrap.prefs.getString(_prefsKey);
    if (lastShown == todayStr) return;

    await Bootstrap.prefs.setString(_prefsKey, todayStr);

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const BirthdayDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: const _BirthdayDialogContent(),
    );
  }
}

/// The inner content of the birthday dialog, using a [StatefulWidget] so we
/// can run a repeating scale animation on the festive icons.
class _BirthdayDialogContent extends StatefulWidget {
  const _BirthdayDialogContent();

  @override
  State<_BirthdayDialogContent> createState() =>
      _BirthdayDialogContentState();
}

class _BirthdayDialogContentState extends State<_BirthdayDialogContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cake icon inside a circular gradient container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.secondary.withValues(alpha: 0.8),
                  AppColors.primary.withValues(alpha: 0.9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.cake,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            t.auth.happyBirthday,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Message
          Text(
            t.auth.happyBirthdayMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Row of animated festive icons
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedIcon(
                    Icons.star,
                    Colors.amber,
                    _scaleAnimation.value,
                  ),
                  const SizedBox(width: 16),
                  _buildAnimatedIcon(
                    Icons.cake,
                    AppColors.secondary,
                    // Slightly offset phase by inverting the scale
                    2.0 - _scaleAnimation.value,
                  ),
                  const SizedBox(width: 16),
                  _buildAnimatedIcon(
                    Icons.celebration,
                    AppColors.primary,
                    _scaleAnimation.value,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Dismiss button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
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
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, Color color, double scale) {
    return Transform.scale(
      scale: scale,
      child: Icon(icon, size: 28, color: color),
    );
  }
}
