import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class CertificateGenerator {
  CertificateGenerator._();

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
    String userType = 'tourist',
    String? affiliation,
  }) async {
    final isEs = locale == 'es';
    final cacheKey = '${userName}_${speciesCount}_${completedAt.toIso8601String()}_${locale}_${userType}_$affiliation';

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

    // Built-in fonts — no download, instant
    final bold = pw.Font.timesBold();
    final regular = pw.Font.times();
    final italic = pw.Font.timesItalic();
    final boldItalic = pw.Font.timesBoldItalic();

    final gold = PdfColor.fromHex('#B8860B');
    final lightGold = PdfColor.fromHex('#DAA520');
    final darkGreen = PdfColor.fromHex('#2E7D32');

    // Portrait A4 — fills the whole phone screen when viewing PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            color: PdfColors.white,
            child: pw.Stack(
              children: [
                // Gold double border
                pw.Positioned.fill(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.all(24),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: gold, width: 2),
                    ),
                  ),
                ),
                pw.Positioned.fill(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.all(30),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: lightGold, width: 0.5),
                    ),
                  ),
                ),
                // Corner ornaments
                ..._corners(gold),
                // Content
                pw.Positioned.fill(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.all(50),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        // Logo — large
                        if (logoImage != null)
                          pw.Image(logoImage, width: 80, height: 80),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'GALAPAGOS WILDLIFE',
                          style: pw.TextStyle(
                            font: bold, fontSize: 11,
                            letterSpacing: 4, color: darkGreen,
                          ),
                        ),
                        pw.SizedBox(height: 24),

                        // Divider
                        _divider(gold),
                        pw.SizedBox(height: 24),

                        // Title
                        pw.Text(
                          isEs ? 'CERTIFICADO' : 'CERTIFICATE',
                          style: pw.TextStyle(
                            font: bold, fontSize: 42,
                            color: gold, letterSpacing: 8,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          isEs ? 'DE EXPLORACION' : 'OF EXPLORATION',
                          style: pw.TextStyle(
                            font: regular, fontSize: 16,
                            color: lightGold, letterSpacing: 6,
                          ),
                        ),
                        pw.SizedBox(height: 30),

                        // "Awarded to"
                        pw.Text(
                          isEs ? 'Otorgado a' : 'Awarded to',
                          style: pw.TextStyle(
                            font: italic, fontSize: 14, color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 12),

                        // User name
                        pw.Text(
                          userName,
                          style: pw.TextStyle(
                            font: boldItalic, fontSize: 40,
                            color: PdfColor.fromHex('#1A1A1A'),
                          ),
                        ),
                        if (userType != 'tourist') ...[
                          pw.SizedBox(height: 4),
                          pw.Text(
                            _userTypeLabel(userType, isEs) +
                                (affiliation != null && affiliation.isNotEmpty
                                    ? ' — $affiliation'
                                    : ''),
                            style: pw.TextStyle(
                              font: italic, fontSize: 13,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                        pw.SizedBox(height: 8),
                        pw.Container(width: 280, height: 1, color: gold),
                        pw.SizedBox(height: 24),

                        // Description
                        pw.Text(
                          isEs
                              ? 'Por descubrir las $speciesCount especies'
                              : 'For discovering all $speciesCount species',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            font: regular, fontSize: 14, color: PdfColors.grey800,
                          ),
                        ),
                        pw.Text(
                          isEs
                              ? 'mas iconicas de las Islas Galapagos'
                              : 'most iconic of the Galapagos Islands',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            font: regular, fontSize: 14, color: PdfColors.grey800,
                          ),
                        ),
                        pw.SizedBox(height: 24),

                        // Badge pill
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                          decoration: pw.BoxDecoration(
                            color: gold,
                            borderRadius: pw.BorderRadius.circular(24),
                          ),
                          child: pw.Text(
                            isEs ? 'MAESTRO DE GALAPAGOS' : 'GALAPAGOS MASTER',
                            style: pw.TextStyle(
                              font: bold, fontSize: 14,
                              letterSpacing: 3, color: PdfColors.white,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 30),

                        // Divider
                        _divider(gold),
                        pw.SizedBox(height: 20),

                        // Date + location
                        pw.Text(
                          isEs
                              ? '${_formatDateEs(completedAt)}'
                              : '${_formatDateEn(completedAt)}',
                          style: pw.TextStyle(
                            font: regular, fontSize: 12, color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          isEs
                              ? 'Islas Galapagos, Ecuador'
                              : 'Galapagos Islands, Ecuador',
                          style: pw.TextStyle(
                            font: italic, fontSize: 11, color: PdfColors.grey500,
                          ),
                        ),
                        pw.SizedBox(height: 20),

                        // Footer — just the website
                        pw.Text(
                          'galapagos.tech',
                          style: pw.TextStyle(
                            font: regular, fontSize: 9, color: PdfColors.grey400,
                          ),
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
    final fileName = isEs ? 'Certificado_Galapagos.pdf' : 'Galapagos_Certificate.pdf';
    await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: fileName);
  }

  static pw.Widget _divider(PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Container(width: 80, height: 0.5, color: color),
        pw.SizedBox(width: 8),
        _dot(color, 4), pw.SizedBox(width: 5),
        _dot(color, 7), pw.SizedBox(width: 5),
        _dot(color, 4),
        pw.SizedBox(width: 8),
        pw.Container(width: 80, height: 0.5, color: color),
      ],
    );
  }

  static pw.Widget _dot(PdfColor c, double s) =>
      pw.Container(width: s, height: s, decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: c));

  static List<pw.Widget> _corners(PdfColor c) {
    const m = 27.0;
    const s = 20.0;
    const w = 1.5;
    return [
      pw.Positioned(top: m, left: m, child: pw.Container(width: s, height: w, color: c)),
      pw.Positioned(top: m, left: m, child: pw.Container(width: w, height: s, color: c)),
      pw.Positioned(top: m, right: m, child: pw.Container(width: s, height: w, color: c)),
      pw.Positioned(top: m, right: m, child: pw.Container(width: w, height: s, color: c)),
      pw.Positioned(bottom: m, left: m, child: pw.Container(width: s, height: w, color: c)),
      pw.Positioned(bottom: m, left: m, child: pw.Container(width: w, height: s, color: c)),
      pw.Positioned(bottom: m, right: m, child: pw.Container(width: s, height: w, color: c)),
      pw.Positioned(bottom: m, right: m, child: pw.Container(width: w, height: s, color: c)),
    ];
  }

  static String _formatDateEn(DateTime dt) {
    const m = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String _formatDateEs(DateTime dt) {
    const m = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
    return '${dt.day} de ${m[dt.month - 1]} de ${dt.year}';
  }

  static String _userTypeLabel(String type, bool isEs) {
    const labels = {
      'researcher': ('Researcher', 'Investigador/a'),
      'guide': ('Naturalist Guide', 'Guia naturalista'),
      'ranger': ('Park Ranger', 'Guardaparque'),
      'student': ('Student', 'Estudiante'),
    };
    final pair = labels[type];
    if (pair == null) return '';
    return isEs ? pair.$2 : pair.$1;
  }
}
