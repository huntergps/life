import 'dart:math';
import 'package:flutter/material.dart';

/// Celebration overlay with firework bursts, falling confetti, and star sparkles.
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
  late final List<_FireworkBurst> _bursts;
  late final List<_ConfettiParticle> _confetti;
  late final List<_SparkleParticle> _sparkles;
  final _rng = Random();

  static const _burstColors = [
    Color(0xFFFFD700), // gold
    Color(0xFFFF4444), // red
    Color(0xFF4488FF), // blue
    Color(0xFF44DD44), // green
    Color(0xFFFF44FF), // magenta
    Color(0xFF44FFFF), // cyan
  ];

  static const _confettiColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Color(0xFFFFD700),
    Colors.pink,
    Colors.teal,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();

    // Generate 4 firework bursts staggered over the first second
    _bursts = List.generate(4, (i) {
      final color = _burstColors[_rng.nextInt(_burstColors.length)];
      final launchX = 0.15 + _rng.nextDouble() * 0.7; // 15%-85% of screen width
      final targetY = 0.15 + _rng.nextDouble() * 0.25; // explode in upper quarter
      final delay = i * 0.05 + _rng.nextDouble() * 0.05; // stagger 0-0.2 normalized
      return _FireworkBurst(
        originX: launchX + (_rng.nextDouble() - 0.5) * 0.1,
        targetX: launchX,
        targetY: targetY,
        launchDelay: delay, // normalized time (0..1 of total 5s)
        launchDuration: 0.08, // ~400ms to reach target
        color: color,
        particles: List.generate(30, (_) => _FireworkParticle.random(_rng)),
      );
    });

    // Generate 60 confetti particles (larger, more varied)
    _confetti = List.generate(60, (_) => _ConfettiParticle.random(_rng));

    // Generate 25 sparkle particles
    _sparkles = List.generate(25, (_) => _SparkleParticle.random(_rng));

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
        painter: _CelebrationPainter(
          bursts: _bursts,
          confetti: _confetti,
          sparkles: _sparkles,
          progress: _controller.value,
          confettiColors: _confettiColors,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// ── Firework Burst ──

class _FireworkBurst {
  final double originX;
  final double targetX;
  final double targetY;
  final double launchDelay; // normalized 0..1
  final double launchDuration; // normalized 0..1
  final Color color;
  final List<_FireworkParticle> particles;

  const _FireworkBurst({
    required this.originX,
    required this.targetX,
    required this.targetY,
    required this.launchDelay,
    required this.launchDuration,
    required this.color,
    required this.particles,
  });
}

class _FireworkParticle {
  final double angle; // radians
  final double speed; // 0..1 multiplier
  final double size;
  final double decay; // how fast it fades

  const _FireworkParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.decay,
  });

  factory _FireworkParticle.random(Random rng) {
    return _FireworkParticle(
      angle: rng.nextDouble() * 2 * pi,
      speed: 0.4 + rng.nextDouble() * 0.6,
      size: 2.0 + rng.nextDouble() * 3.0,
      decay: 0.6 + rng.nextDouble() * 0.4,
    );
  }
}

// ── Confetti Particle ──

enum _ConfettiShape { circle, rectangle, star }

class _ConfettiParticle {
  final double x;
  final double startY;
  final double drift;
  final double speed;
  final double size;
  final int colorIndex;
  final _ConfettiShape shape;
  final double rotationSpeed;
  final double entryDelay; // normalized 0..1, confetti starts after fireworks

  const _ConfettiParticle({
    required this.x,
    required this.startY,
    required this.drift,
    required this.speed,
    required this.size,
    required this.colorIndex,
    required this.shape,
    required this.rotationSpeed,
    required this.entryDelay,
  });

  factory _ConfettiParticle.random(Random rng) {
    final shapes = _ConfettiShape.values;
    return _ConfettiParticle(
      x: rng.nextDouble(),
      startY: -rng.nextDouble() * 0.3,
      drift: (rng.nextDouble() - 0.5) * 0.18,
      speed: 0.5 + rng.nextDouble() * 0.7,
      size: 5 + rng.nextDouble() * 8, // larger particles
      colorIndex: rng.nextInt(10),
      shape: shapes[rng.nextInt(shapes.length)],
      rotationSpeed: 2 + rng.nextDouble() * 6,
      entryDelay: 0.15 + rng.nextDouble() * 0.15, // start 15-30% into animation
    );
  }
}

// ── Sparkle Particle ──

class _SparkleParticle {
  final double x;
  final double y;
  final double phaseOffset; // for sin-based twinkle
  final double frequency;
  final double size;

  const _SparkleParticle({
    required this.x,
    required this.y,
    required this.phaseOffset,
    required this.frequency,
    required this.size,
  });

  factory _SparkleParticle.random(Random rng) {
    return _SparkleParticle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      phaseOffset: rng.nextDouble() * 2 * pi,
      frequency: 3 + rng.nextDouble() * 5,
      size: 1.5 + rng.nextDouble() * 2.5,
    );
  }
}

// ── Combined Painter ──

class _CelebrationPainter extends CustomPainter {
  final List<_FireworkBurst> bursts;
  final List<_ConfettiParticle> confetti;
  final List<_SparkleParticle> sparkles;
  final double progress; // 0..1
  final List<Color> confettiColors;

  _CelebrationPainter({
    required this.bursts,
    required this.confetti,
    required this.sparkles,
    required this.progress,
    required this.confettiColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintSparkles(canvas, size);
    _paintFireworks(canvas, size);
    _paintConfetti(canvas, size);
  }

  void _paintFireworks(Canvas canvas, Size size) {
    for (final burst in bursts) {
      final burstStart = burst.launchDelay;
      final burstLaunchEnd = burstStart + burst.launchDuration;

      // Launch trail phase
      if (progress >= burstStart && progress < burstLaunchEnd) {
        final launchT =
            ((progress - burstStart) / burst.launchDuration).clamp(0.0, 1.0);
        final trailX = burst.originX +
            (burst.targetX - burst.originX) * launchT;
        final trailY = 1.0 + (burst.targetY - 1.0) * launchT;

        final trailPaint = Paint()
          ..color = burst.color.withValues(alpha: 0.9)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(trailX * size.width, trailY * size.height),
          3.0,
          trailPaint,
        );

        // Small trailing dots
        for (int i = 1; i <= 3; i++) {
          final tt = (launchT - i * 0.15).clamp(0.0, 1.0);
          final tx = burst.originX +
              (burst.targetX - burst.originX) * tt;
          final ty = 1.0 + (burst.targetY - 1.0) * tt;
          final dotPaint = Paint()
            ..color = burst.color.withValues(alpha: 0.3 / i)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            Offset(tx * size.width, ty * size.height),
            2.0 / i,
            dotPaint,
          );
        }
      }

      // Explosion phase
      if (progress >= burstLaunchEnd) {
        final explosionT =
            ((progress - burstLaunchEnd) / 0.4).clamp(0.0, 1.0); // 2s explosion
        final gravity = explosionT * explosionT * 0.15; // gravity pull

        for (final p in burst.particles) {
          final spread = explosionT * p.speed * 0.18;
          final px = burst.targetX + cos(p.angle) * spread;
          final py = burst.targetY + sin(p.angle) * spread + gravity;

          if (px < -0.05 || px > 1.05 || py < -0.05 || py > 1.1) continue;

          final fade = (1.0 - explosionT * p.decay).clamp(0.0, 1.0);
          if (fade <= 0) continue;

          final paint = Paint()
            ..color = burst.color.withValues(alpha: fade)
            ..style = PaintingStyle.fill;

          canvas.drawCircle(
            Offset(px * size.width, py * size.height),
            p.size * (1.0 - explosionT * 0.5), // shrink over time
            paint,
          );

          // Glow effect for larger particles
          if (p.size > 3.5 && fade > 0.3) {
            final glowPaint = Paint()
              ..color = burst.color.withValues(alpha: fade * 0.2)
              ..style = PaintingStyle.fill
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
            canvas.drawCircle(
              Offset(px * size.width, py * size.height),
              p.size * 2,
              glowPaint,
            );
          }
        }
      }
    }
  }

  void _paintConfetti(Canvas canvas, Size size) {
    for (final p in confetti) {
      // Confetti starts after its entry delay
      if (progress < p.entryDelay) continue;

      final localProgress =
          ((progress - p.entryDelay) / (1.0 - p.entryDelay)).clamp(0.0, 1.0);
      final t = (localProgress * p.speed).clamp(0.0, 1.0);
      final y = p.startY + t * 1.3;
      if (y < -0.1 || y > 1.1) continue;

      final x = p.x + sin(localProgress * p.rotationSpeed * pi) * p.drift;
      final opacity = (1.0 - (t * 0.5)).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = confettiColors[p.colorIndex].withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      final px = x * size.width;
      final py = y * size.height;

      switch (p.shape) {
        case _ConfettiShape.circle:
          canvas.drawCircle(Offset(px, py), p.size / 2, paint);
        case _ConfettiShape.rectangle:
          canvas.save();
          canvas.translate(px, py);
          canvas.rotate(localProgress * p.rotationSpeed);
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.45,
            ),
            paint,
          );
          canvas.restore();
        case _ConfettiShape.star:
          _drawStar(canvas, Offset(px, py), p.size * 0.6, paint,
              localProgress * p.rotationSpeed);
      }
    }
  }

  void _drawStar(
      Canvas canvas, Offset center, double radius, Paint paint, double rotation) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final path = Path();
    const points = 5;
    final outerR = radius;
    final innerR = radius * 0.4;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * pi / points) - pi / 2;
      final x = cos(angle) * r;
      final y = sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _paintSparkles(Canvas canvas, Size size) {
    for (final s in sparkles) {
      // Twinkle using sin wave
      final twinkle =
          ((sin(progress * s.frequency * 2 * pi + s.phaseOffset) + 1) / 2)
              .clamp(0.0, 1.0);

      // Fade out in last 20% of animation
      final fadeOut = progress > 0.8
          ? ((1.0 - progress) / 0.2).clamp(0.0, 1.0)
          : 1.0;
      final alpha = twinkle * fadeOut;
      if (alpha < 0.05) continue;

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.9)
        ..style = PaintingStyle.fill;

      final px = s.x * size.width;
      final py = s.y * size.height;
      final r = s.size * (0.5 + twinkle * 0.5);

      // Four-point sparkle shape
      final path = Path();
      path.moveTo(px, py - r * 1.5);
      path.lineTo(px + r * 0.3, py);
      path.lineTo(px, py + r * 1.5);
      path.lineTo(px - r * 0.3, py);
      path.close();

      path.moveTo(px - r * 1.5, py);
      path.lineTo(px, py + r * 0.3);
      path.lineTo(px + r * 1.5, py);
      path.lineTo(px, py - r * 0.3);
      path.close();

      canvas.drawPath(path, paint);

      // Center glow
      if (alpha > 0.3) {
        final glowPaint = Paint()
          ..color = Colors.white.withValues(alpha: alpha * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(px, py), r, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_CelebrationPainter old) => old.progress != progress;
}
