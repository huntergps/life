import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';

/// Visual taxonomy tree with connecting lines and progressive indentation.
class TaxonomyTree extends StatelessWidget {
  final dynamic species;
  const TaxonomyTree({super.key, required this.species});

  @override
  Widget build(BuildContext context) {
    final t = context.t.species;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final entries = <MapEntry<String, String?>>[
      MapEntry(t.kingdom, species.taxonomyKingdom),
      MapEntry(t.phylum, species.taxonomyPhylum),
      MapEntry(t.classLabel, species.taxonomyClass),
      MapEntry(t.order, species.taxonomyOrder),
      MapEntry(t.family, species.taxonomyFamily),
      MapEntry(t.genus, species.taxonomyGenus),
    ].where((e) => e.value != null).toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.taxonomy, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < entries.length; i++)
                _TaxonomyNode(
                  label: entries[i].key,
                  value: entries[i].value!,
                  indent: i,
                  isLast: i == entries.length - 1,
                  isDark: isDark,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaxonomyNode extends StatelessWidget {
  final String label;
  final String value;
  final int indent;
  final bool isLast;
  final bool isDark;

  const _TaxonomyNode({
    required this.label,
    required this.value,
    required this.indent,
    required this.isLast,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = isDark ? AppColors.darkBorder : Colors.grey.shade300;
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final leftPad = indent * 20.0;
    final dotSize = isLast ? 10.0 : 7.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: CustomPaint(
        painter: _TreeLinePainter(
          indent: indent,
          isLast: isLast,
          lineColor: lineColor,
          dotColor: isLast ? accentColor : lineColor,
          dotSize: dotSize,
          leftPad: leftPad,
        ),
        child: Padding(
          padding: EdgeInsets.only(left: leftPad + 22),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: isLast ? FontWeight.bold : FontWeight.w600,
                    fontSize: isLast ? 14 : 13,
                    color: isLast
                        ? accentColor
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TreeLinePainter extends CustomPainter {
  final int indent;
  final bool isLast;
  final Color lineColor;
  final Color dotColor;
  final double dotSize;
  final double leftPad;

  _TreeLinePainter({
    required this.indent,
    required this.isLast,
    required this.lineColor,
    required this.dotColor,
    required this.dotSize,
    required this.leftPad,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;

    // Draw vertical lines for ancestor levels
    for (var i = 0; i < indent; i++) {
      final x = i * 20.0 + 10;
      // Draw full vertical line for non-last ancestors
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    if (indent > 0) {
      final parentX = (indent - 1) * 20.0 + 10;
      final nodeX = leftPad + 10;
      // Vertical from top to center at parent column
      // (already drawn by ancestor loop above if not last, but need connector)
      // Horizontal from parent column to dot
      canvas.drawLine(
        Offset(parentX, centerY),
        Offset(nodeX - dotSize / 2 - 2, centerY),
        paint,
      );
    }

    // Draw the dot
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(leftPad + 10, centerY),
      dotSize / 2,
      dotPaint,
    );

    // Vertical line below dot (if not last)
    if (!isLast) {
      canvas.drawLine(
        Offset(leftPad + 10, centerY + dotSize / 2 + 1),
        Offset(leftPad + 10, size.height),
        paint,
      );
    }

    // Vertical line above dot (if indent > 0, already handled by ancestor loop)
    // But if it's a new indentation level, draw from top to dot
    if (indent > 0) {
      // This is handled by the ancestor loop drawing vertical lines
    } else if (!isLast) {
      // Root node: just draw from dot down
      // Already handled above
    }
  }

  @override
  bool shouldRepaint(covariant _TreeLinePainter oldDelegate) =>
      indent != oldDelegate.indent ||
      isLast != oldDelegate.isLast ||
      lineColor != oldDelegate.lineColor;
}
