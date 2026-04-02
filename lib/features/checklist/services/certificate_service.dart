import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/features/checklist/services/certificate_generator.dart';

/// Service that generates a PDF certificate on-device and also
/// sends a request to the server for email delivery.
class CertificateService {
  CertificateService._();

  /// Generates and shows the PDF certificate immediately, then also
  /// saves the request to Supabase for email delivery later.
  static Future<void> requestCertificate({
    required int speciesCount,
    required BuildContext context,
  }) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final locale = LocaleSettings.currentLocale.languageCode;
    final userName = user.userMetadata?['display_name'] ??
        user.email?.split('@').first ??
        'Explorer';

    // Generate and show PDF immediately
    await CertificateGenerator.generateAndShare(
      userName: userName,
      speciesCount: speciesCount,
      completedAt: DateTime.now(),
      locale: locale,
    );

    // Also save to Supabase for email delivery
    try {
      await client.rpc('request_checklist_certificate', params: {
        'user_email': user.email ?? '',
        'user_name': userName,
        'species_count': speciesCount,
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Silently fail — the PDF was already shown to the user
    }
  }
}
