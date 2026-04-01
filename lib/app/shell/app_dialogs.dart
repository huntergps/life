import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/app/router/router_keys.dart';
import 'package:galapagos_wildlife/features/badges/models/badge_definition.dart';
import 'package:galapagos_wildlife/features/badges/providers/badge_notification_provider.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:galapagos_wildlife/features/badges/presentation/widgets/badge_unlock_dialog.dart';
import 'package:galapagos_wildlife/features/profile/providers/celebration_events_provider.dart';
import 'package:galapagos_wildlife/features/profile/presentation/widgets/birthday_dialog.dart';

/// Invisible widget that listens for badge-unlock and birthday events and
/// shows the appropriate celebratory dialogs on top of the app.
///
/// Place this as a wrapper around the router child so that listeners are
/// active whenever the main app is visible.
class AppDialogs extends ConsumerStatefulWidget {
  final Widget child;

  const AppDialogs({super.key, required this.child});

  @override
  ConsumerState<AppDialogs> createState() => _AppDialogsState();
}

class _AppDialogsState extends ConsumerState<AppDialogs> {
  /// Shows one dialog per newly unlocked badge, sequentially.
  Future<void> _showBadgeDialogs(
    BuildContext navContext,
    List<BadgeProgress> badges,
  ) async {
    for (final badge in badges) {
      if (!mounted) return;
      await BadgeUnlockDialog.show(navContext, badge);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check for birthday and show dialog
    ref.listen<bool>(
      isBirthdayTodayProvider,
      (_, next) {
        if (!next) return;
        final navContext = rootNavigatorKey.currentContext;
        if (navContext == null) return;
        BirthdayDialog.show(navContext);
      },
    );

    // Listen for newly unlocked badges and show celebratory dialog
    ref.listen<AsyncValue<List<BadgeProgress>>>(
      newlyUnlockedBadgesProvider,
      (_, next) {
        final badges = next.asData?.value;
        if (badges == null || badges.isEmpty) return;

        // Check if badge notifications are enabled
        final badgeNotificationsEnabled = ref.read(badgeNotificationsProvider);

        // Use rootNavigatorKey so the dialog appears above the whole app
        final navContext = rootNavigatorKey.currentContext;
        if (navContext == null) return;

        // Show one dialog per new badge, sequentially (only if enabled)
        if (badgeNotificationsEnabled) {
          _showBadgeDialogs(navContext, badges);
        }

        // Persist so they are not shown again (regardless of notification pref)
        markBadgesAsSeen(badges);
      },
    );

    return widget.child;
  }
}
