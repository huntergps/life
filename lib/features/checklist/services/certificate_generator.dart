import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class CertificateGenerator {
  CertificateGenerator._();

  static Future<void> generateAndShare({
    required String userName,
    required int speciesCount,
    required DateTime completedAt,
    required String locale,
  }) async {
    final pdf = pw.Document();
    final isEs = locale == 'es';

    // Load logo
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/gwl_logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {}

    // Load fonts for better typography
    final boldFont = await PdfGoogleFonts.playfairDisplayBold();
    final regularFont = await PdfGoogleFonts.latoRegular();
    final lightFont = await PdfGoogleFonts.latoLight();
    final italicFont = await PdfGoogleFonts.latoItalic();
    final nameFont = await PdfGoogleFonts.greatVibesRegular();

    final gold = PdfColor.fromHex('#B8860B');
    final darkGold = PdfColor.fromHex('#8B6914');
    final lightGold = PdfColor.fromHex('#DAA520');
    final cream = PdfColor.fromHex('#FFF8E7');
    final darkText = PdfColor.fromHex('#2C2C2C');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (context) => pw.Container(
          width: double.infinity,
          height: double.infinity,
          decoration: pw.BoxDecoration(color: cream),
          child: pw.Stack(
            children: [
              // Outer decorative border
              pw.Positioned.fill(
                child: pw.Container(
                  margin: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: gold, width: 3),
                  ),
                ),
              ),
              // Inner decorative border
              pw.Positioned.fill(
                child: pw.Container(
                  margin: const pw.EdgeInsets.all(28),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: lightGold, width: 1),
                  ),
                ),
              ),
              // Corner ornaments (simple L-shapes)
              ..._cornerOrnaments(gold),
              // Main content
              pw.Positioned.fill(
                child: pw.Container(
                  margin: const pw.EdgeInsets.all(50),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      // Logo
                      if (logoImage != null)
                        pw.Image(logoImage, width: 50, height: 50),
                      pw.SizedBox(height: 8),
                      // App name
                      pw.Text(
                        'GALAPAGOS WILDLIFE',
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 10,
                          letterSpacing: 4,
                          color: gold,
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      // Decorative line
                      _ornamentalDivider(gold, lightGold),
                      pw.SizedBox(height: 16),
                      // Title
                      pw.Text(
                        isEs ? 'Certificado de Logro' : 'Certificate of Achievement',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 36,
                          color: darkGold,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      // Subtitle
                      pw.Text(
                        isEs ? 'Esto certifica que' : 'This is to certify that',
                        style: pw.TextStyle(
                          font: italicFont,
                          fontSize: 13,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      // User name (elegant script font)
                      pw.Text(
                        userName,
                        style: pw.TextStyle(
                          font: nameFont,
                          fontSize: 48,
                          color: darkText,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      // Thin line under name
                      pw.Container(width: 300, height: 0.5, color: gold),
                      pw.SizedBox(height: 14),
                      // Description
                      pw.Text(
                        isEs
                            ? 'ha observado exitosamente las $speciesCount especies iconicas'
                            : 'has successfully observed all $speciesCount iconic species',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 14,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.Text(
                        isEs
                            ? 'de las Islas Galapagos, Patrimonio Natural de la Humanidad'
                            : 'of the Galapagos Islands, UNESCO World Heritage Site',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 14,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      // Badge
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: gold, width: 1.5),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          isEs ? 'MAESTRO DE GALAPAGOS' : 'GALAPAGOS MASTER',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 16,
                            letterSpacing: 3,
                            color: darkGold,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      // Decorative line
                      _ornamentalDivider(gold, lightGold),
                      pw.SizedBox(height: 16),
                      // Date
                      pw.Text(
                        isEs
                            ? '${_formatDateEs(completedAt)}  ·  Islas Galapagos, Ecuador'
                            : '${_formatDateEn(completedAt)}  ·  Galapagos Islands, Ecuador',
                        style: pw.TextStyle(
                          font: lightFont,
                          fontSize: 11,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 24),
                      // Footer with signature lines
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          _signatureLine(
                            font: lightFont,
                            label: 'GalapagosTech',
                            color: gold,
                          ),
                          pw.Column(
                            children: [
                              pw.Text(
                                'galapagos.tech',
                                style: pw.TextStyle(
                                  font: lightFont,
                                  fontSize: 9,
                                  color: PdfColors.grey500,
                                ),
                              ),
                            ],
                          ),
                          _signatureLine(
                            font: lightFont,
                            label: isEs ? 'Verificado digitalmente' : 'Digitally verified',
                            color: gold,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: isEs
          ? 'Certificado_Galapagos_Master.pdf'
          : 'Galapagos_Master_Certificate.pdf',
    );
  }

  static pw.Widget _ornamentalDivider(PdfColor gold, PdfColor lightGold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Container(width: 80, height: 0.5, color: lightGold),
        pw.SizedBox(width: 8),
        pw.Container(
          width: 8, height: 8,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: gold, width: 1),
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Container(
          width: 12, height: 12,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            color: gold,
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Container(
          width: 8, height: 8,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: gold, width: 1),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Container(width: 80, height: 0.5, color: lightGold),
      ],
    );
  }

  static pw.Widget _signatureLine({
    required pw.Font font,
    required String label,
    required PdfColor color,
  }) {
    return pw.Column(
      children: [
        pw.Container(width: 140, height: 0.5, color: color),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static List<pw.Widget> _cornerOrnaments(PdfColor color) {
    const m = 24.0;
    const s = 30.0;
    const w = 2.0;
    return [
      // Top-left
      pw.Positioned(top: m, left: m, child: pw.Container(width: s, height: w, color: color)),
      pw.Positioned(top: m, left: m, child: pw.Container(width: w, height: s, color: color)),
      // Top-right
      pw.Positioned(top: m, right: m, child: pw.Container(width: s, height: w, color: color)),
      pw.Positioned(top: m, right: m, child: pw.Container(width: w, height: s, color: color)),
      // Bottom-left
      pw.Positioned(bottom: m, left: m, child: pw.Container(width: s, height: w, color: color)),
      pw.Positioned(bottom: m, left: m, child: pw.Container(width: w, height: s, color: color)),
      // Bottom-right
      pw.Positioned(bottom: m, right: m, child: pw.Container(width: s, height: w, color: color)),
      pw.Positioned(bottom: m, right: m, child: pw.Container(width: w, height: s, color: color)),
    ];
  }

  static String _formatDateEn(DateTime dt) {
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String _formatDateEs(DateTime dt) {
    const months = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
    return '${dt.day} de ${months[dt.month - 1]} de ${dt.year}';
  }
}
