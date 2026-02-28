import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/features/profile/providers/celebration_events_provider.dart';

/// Lightweight decoration overlay for active celebration events.
///
/// Wraps a [child] widget in a [Stack] and positions a small themed
/// icon/decoration on the top-right corner based on the active overlay type.
class CelebrationOverlay extends ConsumerWidget {
  final Widget child;

  const CelebrationOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayType = ref.watch(activeOverlayTypeProvider);
    final activeCelebrations = ref.watch(activeCelebrationsProvider);

    if (overlayType == null || activeCelebrations.isEmpty) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -6,
          right: -6,
          child: _buildDecoration(overlayType, activeCelebrations.first),
        ),
      ],
    );
  }

  Widget _buildDecoration(String type, dynamic event) {
    return switch (type) {
      'hat' => _HatDecoration(),
      'fireworks' => _FireworksDecoration(),
      'badge' => _BadgeDecoration(event: event),
      'frame' => _FrameDecoration(),
      _ => const SizedBox.shrink(),
    };
  }
}

// ---------------------------------------------------------------------------
// Hat decoration — small red Santa-hat style icon
// ---------------------------------------------------------------------------

class _HatDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(
        Icons.celebration,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fireworks decoration — sparkle icon with subtle pulse
// ---------------------------------------------------------------------------

class _FireworksDecoration extends StatefulWidget {
  @override
  State<_FireworksDecoration> createState() => _FireworksDecorationState();
}

class _FireworksDecorationState extends State<_FireworksDecoration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.scale(
          scale: _controller.value,
          child: Icon(
            Icons.auto_awesome,
            size: 20,
            color: Colors.amber.shade600,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Badge decoration — small circle with event icon
// ---------------------------------------------------------------------------

class _BadgeDecoration extends StatelessWidget {
  final dynamic event;

  const _BadgeDecoration({required this.event});

  @override
  Widget build(BuildContext context) {
    final iconName = (event.iconName as String?) ?? 'celebration';
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Icon(
        _mapIconName(iconName),
        size: 14,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Frame decoration — subtle glow dot on the corner
// ---------------------------------------------------------------------------

class _FrameDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.6),
            Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Icon(
        Icons.star,
        size: 12,
        color: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Icon name mapping — converts DB string names to Flutter IconData
// ---------------------------------------------------------------------------

IconData _mapIconName(String name) {
  return switch (name) {
    'celebration' => Icons.celebration,
    'park' => Icons.park,
    'favorite' => Icons.favorite,
    'water' => Icons.water,
    'public' => Icons.public,
    'flag' => Icons.flag,
    'eco' => Icons.eco,
    'nightlight' => Icons.nightlight,
    'local_florist' => Icons.local_florist,
    'restaurant' => Icons.restaurant,
    'ac_unit' => Icons.ac_unit,
    _ => Icons.celebration,
  };
}
