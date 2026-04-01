import 'package:supabase_flutter/supabase_flutter.dart';

/// Service that sends a certificate request to the server.
///
/// The actual PDF generation and email sending happens server-side via
/// a Supabase RPC (or Edge Function). This is the Flutter client code only.
class CertificateService {
  CertificateService._();

  /// Requests a digital certificate to be sent to the user's email.
  static Future<void> requestCertificate() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await client.rpc('request_checklist_certificate', params: {
      'user_email': user.email,
      'user_name': user.userMetadata?['display_name'] ??
          user.email?.split('@').first ??
          'Explorer',
      'completed_at': DateTime.now().toIso8601String(),
    });
  }
}
