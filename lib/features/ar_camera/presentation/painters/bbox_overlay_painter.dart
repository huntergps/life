import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/features/ar_camera/providers/yolo_detection_provider.dart';

/// Draws YOLO bounding boxes over the camera preview.
///
/// Coordinate mapping:
///   - YOLO outputs normalized [0,1] bbox in model space (640×640).
///   - Camera preview is displayed via FittedBox(cover) with the preview's
///     width/height swapped for portrait.
///   - We map normalized → screen by accounting for the cover scale + offset.
class BboxOverlayPainter extends CustomPainter {
  final List<YoloDetection> detections;

  /// Camera native size from CameraController.value.previewSize (landscape).
  /// The preview is displayed with these swapped: display w = native h, display h = native w.
  final Size nativePreviewSize;

  const BboxOverlayPainter({
    required this.detections,
    required this.nativePreviewSize,
  });

  /// Deterministic per-class color using golden-ratio hue spacing.
  static Color classColor(int classId) {
    final hue = (classId * 47.0) % 360.0;
    return HSVColor.fromAHSV(1.0, hue, 0.85, 0.95).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty) return;

    // Camera displayed as portrait: displayW = nativeH, displayH = nativeW
    final displayW = nativePreviewSize.height;
    final displayH = nativePreviewSize.width;

    // BoxFit.cover scale & offset
    final scaleX = size.width / displayW;
    final scaleY = size.height / displayH;
    final scale  = math.max(scaleX, scaleY);
    final offsetX = (size.width  - displayW * scale) / 2;
    final offsetY = (size.height - displayH * scale) / 2;

    for (final det in detections) {
      final color = classColor(det.classId);
      final rect  = _toScreenRect(det.bbox, displayW, displayH, scale, offsetX, offsetY);

      _drawBox(canvas, rect, color, det.score);
      _drawLabel(canvas, rect, det.commonNameEn, det.score, color);
    }
  }

  Rect _toScreenRect(
    Rect norm,
    double displayW,
    double displayH,
    double scale,
    double offsetX,
    double offsetY,
  ) {
    final l = norm.left   * displayW * scale + offsetX;
    final t = norm.top    * displayH * scale + offsetY;
    final r = norm.right  * displayW * scale + offsetX;
    final b = norm.bottom * displayH * scale + offsetY;
    return Rect.fromLTRB(l, t, r, b);
  }

  void _drawBox(Canvas canvas, Rect rect, Color color, double score) {
    // Glow / fill
    canvas.drawRect(
      rect,
      Paint()
        ..color = color.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );

    // Border — solid cyan-ish with class color tint
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, borderPaint);

    // Corner accents (JARVIS style)
    const k = 12.0;
    final accentPaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // TL
    canvas.drawLine(rect.topLeft, rect.topLeft.translate(k, 0), accentPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft.translate(0, k), accentPaint);
    // TR
    canvas.drawLine(rect.topRight, rect.topRight.translate(-k, 0), accentPaint);
    canvas.drawLine(rect.topRight, rect.topRight.translate(0, k), accentPaint);
    // BL
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft.translate(k, 0), accentPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft.translate(0, -k), accentPaint);
    // BR
    canvas.drawLine(rect.bottomRight, rect.bottomRight.translate(-k, 0), accentPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight.translate(0, -k), accentPaint);
  }

  void _drawLabel(Canvas canvas, Rect rect, String name, double score, Color color) {
    final pct  = (score * 100).round();
    final text = '$name  $pct%';

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          shadows: [Shadow(color: Colors.black87, blurRadius: 2)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width + 40);

    const pad = 4.0;
    const height = 20.0;

    // Place label above box, clamped to canvas top
    double labelTop = rect.top - height - 2;
    if (labelTop < 0) labelTop = rect.top + 2;

    final bgRect = Rect.fromLTWH(
      rect.left - 1,
      labelTop,
      textPainter.width + pad * 2,
      height,
    );

    // Label background
    canvas.drawRect(
      bgRect,
      Paint()..color = color.withValues(alpha: 0.88),
    );

    textPainter.paint(
      canvas,
      Offset(bgRect.left + pad, labelTop + (height - textPainter.height) / 2),
    );
  }

  @override
  bool shouldRepaint(BboxOverlayPainter old) =>
      old.detections != detections ||
      old.nativePreviewSize != nativePreviewSize;
}
