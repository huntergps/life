import 'dart:math';
import 'package:flutter/material.dart';

/// Lightweight confetti particle effect with ~50 colored shapes falling from the top.
/// Runs for approximately 5 seconds, then calls [onComplete].
class ConfettiOverlay extends StatefulWidget {
  final VoidCallback? onComplete;
  const ConfettiOverlay({super.key, this.onComplete});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;
  final _random = Random();

  static const _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Color(0xFFFFD700), // gold
    Colors.pink,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _particles = List.generate(50, (_) => _ConfettiParticle.random(_random));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )
      ..addListener(() => setState(() {}))
      ..forward().then((_) {
        widget.onComplete?.call();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(
          particles: _particles,
          progress: _controller.value,
          colors: _colors,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ConfettiParticle {
  /// Horizontal position 0..1 across the screen.
  final double x;

  /// Vertical start offset 0..1 (allows staggered entry).
  final double startY;

  /// Horizontal drift amplitude.
  final double drift;

  /// Fall speed multiplier (1.0 = normal).
  final double speed;

  /// Size of the particle.
  final double size;

  /// Index into the color palette.
  final int colorIndex;

  /// True = circle, false = small rectangle.
  final bool isCircle;

  /// Rotation speed for rectangles.
  final double rotationSpeed;

  const _ConfettiParticle({
    required this.x,
    required this.startY,
    required this.drift,
    required this.speed,
    required this.size,
    required this.colorIndex,
    required this.isCircle,
    required this.rotationSpeed,
  });

  factory _ConfettiParticle.random(Random rng) {
    return _ConfettiParticle(
      x: rng.nextDouble(),
      startY: -rng.nextDouble() * 0.3, // start above screen
      drift: (rng.nextDouble() - 0.5) * 0.15,
      speed: 0.6 + rng.nextDouble() * 0.8,
      size: 4 + rng.nextDouble() * 6,
      colorIndex: rng.nextInt(9),
      isCircle: rng.nextBool(),
      rotationSpeed: 2 + rng.nextDouble() * 6,
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  final List<Color> colors;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed).clamp(0.0, 1.0);
      final y = p.startY + t * 1.3; // fall past bottom
      if (y < -0.1 || y > 1.1) continue;

      final x = p.x + sin(progress * p.rotationSpeed * pi) * p.drift;
      final opacity = (1.0 - (t * 0.6)).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = colors[p.colorIndex].withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      final px = x * size.width;
      final py = y * size.height;

      if (p.isCircle) {
        canvas.drawCircle(Offset(px, py), p.size / 2, paint);
      } else {
        canvas.save();
        canvas.translate(px, py);
        canvas.rotate(progress * p.rotationSpeed);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.5,
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
