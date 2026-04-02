import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/features/checklist/services/certificate_generator.dart';

class CertificateService {
  CertificateService._();

  static Future<void> requestCertificate({
    required int speciesCount,
    required BuildContext context,
  }) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final locale = LocaleSettings.currentLocale.languageCode;

    // Get display name — try profile table first, then auth metadata, then email
    String userName = 'Explorer';
    try {
      final profile = await client
          .from('profiles')
          .select('display_name')
          .eq('id', user.id)
          .maybeSingle();
      final profileName = profile?['display_name'] as String?;
      if (profileName != null && profileName.trim().isNotEmpty) {
        userName = profileName.trim();
      } else {
        // Fallback to auth metadata
        final metaName = user.userMetadata?['display_name'] as String?;
        if (metaName != null && metaName.trim().isNotEmpty) {
          userName = metaName.trim();
        } else {
          // Last resort: email prefix
          userName = user.email?.split('@').first ?? 'Explorer';
        }
      }
    } catch (_) {
      userName = user.email?.split('@').first ?? 'Explorer';
    }

    // Invalidate cache so new name is used
    CertificateGenerator.invalidateCache();

    await CertificateGenerator.generateAndShare(
      userName: userName,
      speciesCount: speciesCount,
      completedAt: DateTime.now(),
      locale: locale,
    );

    // Save to Supabase for email delivery
    try {
      await client.rpc('request_checklist_certificate', params: {
        'user_email': user.email ?? '',
        'user_name': userName,
        'species_count': speciesCount,
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }
}
