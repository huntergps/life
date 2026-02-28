import 'dart:math';
import 'package:flutter/material.dart';

/// Floating heart bubbles animation triggered on favorite toggle.
/// - [reverse]: true = red hearts fall downward (mirror of the rising effect)
/// - [compact]: true = smaller effect for use on grid cards
class HeartBubbleOverlay extends StatefulWidget {
  final VoidCallback? onComplete;
  final bool reverse;
  final bool compact;
  const HeartBubbleOverlay({
    super.key,
    this.onComplete,
    this.reverse = false,
    this.compact = false,
  });

  @override
  State<HeartBubbleOverlay> createState() => _HeartBubbleOverlayState();
}

class _HeartBubbleOverlayState extends State<HeartBubbleOverlay>
    with TickerProviderStateMixin {
  final _random = Random();
  final List<_HeartParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _spawnHearts();
  }

  void _spawnHearts() {
    final count = widget.compact ? 5 : 12;
    final stagger = widget.compact ? 40 : 80;

    for (var i = 0; i < count; i++) {
      final delay = Duration(milliseconds: i * stagger);
      Future.delayed(delay, () {
        if (!mounted) return;

        final baseDuration = widget.compact
            ? 400 + _random.nextInt(300)
            : 1200 + _random.nextInt(800);

        final spread = widget.compact ? 50.0 : 120.0;
        final baseSize = widget.compact
            ? 8.0 + _random.nextDouble() * 8
            : 14.0 + _random.nextDouble() * 18;

        final controller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: baseDuration),
        );
        final particle = _HeartParticle(
          controller: controller,
          dx: (_random.nextDouble() - 0.5) * spread,
          size: baseSize,
          opacity: 0.5 + _random.nextDouble() * 0.5,
        );
        setState(() => _particles.add(particle));
        controller.forward().then((_) {
          if (mounted) {
            controller.dispose();
            setState(() => _particles.remove(particle));
            if (_particles.isEmpty) widget.onComplete?.call();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    for (final p in _particles) {
      p.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.compact ? 80.0 : 160.0;
    final h = widget.compact ? 150.0 : 300.0;
    final centerX = w / 2;

    return IgnorePointer(
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          clipBehavior: Clip.none,
          children: _particles.map((p) {
            return AnimatedBuilder(
              animation: p.controller,
              builder: (context, child) {
                final t = p.controller.value;
                final travel = widget.compact ? 100.0 : 250.0;
                final x = p.dx * sin(t * pi);
                final opacity = p.opacity * (1 - t);
                final scale = 1.0 - (t * 0.3);

                if (widget.reverse) {
                  // Falling hearts — mirror of rising effect
                  final y = t * travel;
                  return Positioned(
                    top: 0,
                    left: centerX + x,
                    child: Transform.translate(
                      offset: Offset(0, y),
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity.clamp(0.0, 1.0),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.redAccent.withValues(
                              alpha: opacity.clamp(0.0, 1.0),
                            ),
                            size: p.size,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // Rising hearts (add-to-favorites)
                final y = -t * travel;
                return Positioned(
                  bottom: 0,
                  left: centerX + x,
                  child: Transform.translate(
                    offset: Offset(0, y),
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.redAccent.withValues(
                            alpha: opacity.clamp(0.0, 1.0),
                          ),
                          size: p.size,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _HeartParticle {
  final AnimationController controller;
  final double dx;
  final double size;
  final double opacity;

  _HeartParticle({
    required this.controller,
    required this.dx,
    required this.size,
    required this.opacity,
  });
}
