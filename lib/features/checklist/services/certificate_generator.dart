import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CertificateGenerator {
  CertificateGenerator._();

  /// Cached PDF bytes — regenerate only if data changes.
  static List<int>? _cachedPdf;
  static String? _cachedKey;

  static void invalidateCache() {
    _cachedPdf = null;
    _cachedKey = null;
  }

  static Future<void> generateAndShare({
    required String userName,
    required int speciesCount,
    required DateTime completedAt,
    required String locale,
  }) async {
    final isEs = locale == 'es';
    final cacheKey = '${userName}_${speciesCount}_${completedAt.toIso8601String()}_$locale';

    // Use cached PDF if available
    if (_cachedPdf != null && _cachedKey == cacheKey) {
      await _sharePdf(_cachedPdf!, isEs);
      return;
    }

    final pdf = pw.Document();

    // Load logo
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/gwl_logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {}

    // Use built-in fonts (no network download = instant)
    final bold = pw.Font.timesBold();
    final regular = pw.Font.times();
    final italic = pw.Font.timesItalic();
    final boldItalic = pw.Font.timesBoldItalic();

    final gold = PdfColor.fromHex('#C5922E');
    final darkGreen = PdfColor.fromHex('#1B5E20');
    final ocean = PdfColor.fromHex('#0D47A1');
    final cream = PdfColor.fromHex('#FFFDE7');
    final darkText = PdfColor.fromHex('#1A1A1A');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          final w = PdfPageFormat.a4.landscape.width;
          final h = PdfPageFormat.a4.landscape.height;

          return pw.Container(
            width: w,
            height: h,
            decoration: pw.BoxDecoration(color: cream),
            child: pw.Stack(
              children: [
                // Top colored band
                pw.Positioned(
                  top: 0, left: 0, right: 0,
                  child: pw.Container(
                    height: 45,
                    decoration: pw.BoxDecoration(
                      gradient: pw.LinearGradient(
                        colors: [darkGreen, ocean],
                      ),
                    ),
                  ),
                ),
                // Bottom colored band
                pw.Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: pw.Container(
                    height: 35,
                    decoration: pw.BoxDecoration(
                      gradient: pw.LinearGradient(
                        colors: [ocean, darkGreen],
                      ),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'galapagos.tech',
                        style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.white),
                      ),
                    ),
                  ),
                ),
                // Gold border frame
                pw.Positioned.fill(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.fromLTRB(25, 55, 25, 45),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: gold, width: 2),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Inner content
                pw.Positioned.fill(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.fromLTRB(45, 60, 45, 55),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        // Logo + app name row
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            if (logoImage != null)
                              pw.Image(logoImage, width: 36, height: 36),
                            if (logoImage != null) pw.SizedBox(width: 10),
                            pw.Text(
                              'GALAPAGOS WILDLIFE',
                              style: pw.TextStyle(
                                font: bold, fontSize: 11,
                                letterSpacing: 3, color: darkGreen,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 14),

                        // Title
                        pw.Text(
                          isEs ? 'CERTIFICADO' : 'CERTIFICATE',
                          style: pw.TextStyle(
                            font: bold, fontSize: 38,
                            color: gold, letterSpacing: 6,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          isEs ? 'DE EXPLORACION' : 'OF EXPLORATION',
                          style: pw.TextStyle(
                            font: regular, fontSize: 14,
                            color: gold, letterSpacing: 4,
                          ),
                        ),
                        pw.SizedBox(height: 14),

                        // Divider
                        _wavyDivider(gold),
                        pw.SizedBox(height: 14),

                        // "Awarded to"
                        pw.Text(
                          isEs ? 'Otorgado a' : 'Awarded to',
                          style: pw.TextStyle(
                            font: italic, fontSize: 12, color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 6),

                        // User name — big and bold
                        pw.Text(
                          userName,
                          style: pw.TextStyle(
                            font: boldItalic, fontSize: 36, color: darkText,
                          ),
                        ),

                        pw.SizedBox(height: 6),
                        pw.Container(width: 250, height: 1, color: gold),
                        pw.SizedBox(height: 14),

                        // Fun description
                        pw.Text(
                          isEs
                              ? 'Por descubrir las $speciesCount especies mas iconicas'
                              : 'For discovering all $speciesCount most iconic species',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            font: regular, fontSize: 13, color: PdfColors.grey800,
                          ),
                        ),
                        pw.Text(
                          isEs
                              ? 'de las Islas Galapagos'
                              : 'of the Galapagos Islands',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            font: bold, fontSize: 14, color: darkGreen,
                          ),
                        ),
                        pw.SizedBox(height: 14),

                        // Badge
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: pw.BoxDecoration(
                            color: gold,
                            borderRadius: pw.BorderRadius.circular(20),
                          ),
                          child: pw.Text(
                            isEs ? 'MAESTRO DE GALAPAGOS' : 'GALAPAGOS MASTER',
                            style: pw.TextStyle(
                              font: bold, fontSize: 13,
                              letterSpacing: 2, color: PdfColors.white,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 14),

                        // Divider
                        _wavyDivider(gold),
                        pw.SizedBox(height: 10),

                        // Date + location
                        pw.Text(
                          isEs
                              ? '${_formatDateEs(completedAt)}  |  Islas Galapagos, Ecuador'
                              : '${_formatDateEn(completedAt)}  |  Galapagos Islands, Ecuador',
                          style: pw.TextStyle(
                            font: regular, fontSize: 10, color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 16),

                        // Footer
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                          children: [
                            _footerBlock(bold, regular, 'GalapagosTech', isEs ? 'Organizador' : 'Organizer', gold),
                            _footerBlock(bold, regular, isEs ? 'Verificado' : 'Verified', isEs ? 'Certificado digital' : 'Digital certificate', gold),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();
    _cachedPdf = bytes;
    _cachedKey = cacheKey;

    await _sharePdf(bytes, isEs);
  }

  static Future<void> _sharePdf(List<int> bytes, bool isEs) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = isEs ? 'Certificado_Galapagos.pdf' : 'Galapagos_Certificate.pdf';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
  }

  static pw.Widget _wavyDivider(PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Container(width: 60, height: 0.5, color: color),
        pw.SizedBox(width: 6),
        _dot(color, 4), pw.SizedBox(width: 4),
        _dot(color, 6), pw.SizedBox(width: 4),
        _dot(color, 8), pw.SizedBox(width: 4),
        _dot(color, 6), pw.SizedBox(width: 4),
        _dot(color, 4),
        pw.SizedBox(width: 6),
        pw.Container(width: 60, height: 0.5, color: color),
      ],
    );
  }

  static pw.Widget _dot(PdfColor color, double size) {
    return pw.Container(
      width: size, height: size,
      decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: color),
    );
  }

  static pw.Widget _footerBlock(pw.Font bold, pw.Font regular, String title, String subtitle, PdfColor lineColor) {
    return pw.Column(
      children: [
        pw.Container(width: 120, height: 0.5, color: lineColor),
        pw.SizedBox(height: 4),
        pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.grey800)),
        pw.Text(subtitle, style: pw.TextStyle(font: regular, fontSize: 7, color: PdfColors.grey500)),
      ],
    );
  }

  static String _formatDateEn(DateTime dt) {
    const m = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String _formatDateEs(DateTime dt) {
    const m = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
    return '${dt.day} de ${m[dt.month - 1]} de ${dt.year}';
  }
}
