import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Generates a PDF certificate on-device for checklist completion.
class CertificateGenerator {
  CertificateGenerator._();

  /// Generates and shows a print/share dialog for the certificate PDF.
  static Future<void> generateAndShare({
    required String userName,
    required int speciesCount,
    required DateTime completedAt,
    required String locale,
  }) async {
    final pdf = pw.Document();
    final isEs = locale == 'es';

    // Try to load the app logo
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/gwl_logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {}

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.amber, width: 3),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              // Logo
              if (logoImage != null)
                pw.Image(logoImage, width: 60, height: 60),
              pw.SizedBox(height: 16),

              // Title
              pw.Text(
                isEs ? 'CERTIFICADO DE LOGRO' : 'CERTIFICATE OF ACHIEVEMENT',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.amber800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                width: 200,
                height: 2,
                color: PdfColors.amber,
              ),
              pw.SizedBox(height: 24),

              // "This certifies that"
              pw.Text(
                isEs ? 'Esto certifica que' : 'This certifies that',
                style: const pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 12),

              // User name
              pw.Text(
                userName,
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
              pw.SizedBox(height: 12),

              // Description
              pw.Text(
                isEs
                    ? 'ha observado las $speciesCount especies iconicas\nde las Islas Galapagos'
                    : 'has observed all $speciesCount iconic species\nof the Galapagos Islands',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(
                  fontSize: 16,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 24),

              // Trophy icon (text-based since pdf package doesn't support emojis)
              pw.Container(
                width: 60,
                height: 60,
                decoration: const pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: PdfColors.amber100,
                ),
                child: pw.Center(
                  child: pw.Text(
                    '*',
                    style: pw.TextStyle(
                      fontSize: 36,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.amber800,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                isEs ? 'MAESTRO DE GALAPAGOS' : 'GALAPAGOS MASTER',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.amber800,
                ),
              ),
              pw.SizedBox(height: 24),

              // Date
              pw.Text(
                isEs
                    ? 'Completado el ${_formatDateEs(completedAt)}'
                    : 'Completed on ${_formatDateEn(completedAt)}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 32),

              // Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 150,
                        height: 1,
                        color: PdfColors.grey400,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'GalapagosTech',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'galapagos.tech',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Show print/share dialog
    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: isEs
          ? 'Certificado_Galapagos_Master.pdf'
          : 'Galapagos_Master_Certificate.pdf',
    );
  }

  static String _formatDateEn(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String _formatDateEs(DateTime dt) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${dt.day} de ${months[dt.month - 1]} de ${dt.year}';
  }
}
