import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/features/checklist/services/certificate_generator.dart';

const _certIssuedKey = 'certificate_issued';
const _certNameKey = 'certificate_name';
const _certCountKey = 'certificate_count';
const _certDateKey = 'certificate_date';

class CertificateService {
  CertificateService._();

  /// Whether this user has already been issued a certificate.
  static bool get isIssued => Bootstrap.prefs.getBool(_certIssuedKey) ?? false;

  /// Cached certificate data for re-download.
  static String? get issuedName => Bootstrap.prefs.getString(_certNameKey);
  static int? get issuedCount => Bootstrap.prefs.getInt(_certCountKey);
  static DateTime? get issuedDate {
    final ms = Bootstrap.prefs.getInt(_certDateKey);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  /// Check with Supabase if certificate was already issued.
  static Future<bool> checkIssuedRemote() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;
    try {
      final result = await Supabase.instance.client.rpc('has_checklist_certificate');
      final issued = result == true;
      if (issued) {
        await Bootstrap.prefs.setBool(_certIssuedKey, true);
      }
      return issued;
    } catch (_) {
      return isIssued;
    }
  }

  /// Issue a NEW certificate (first time only). Returns false if already issued.
  static Future<bool> issueCertificate({
    required int speciesCount,
    required BuildContext context,
  }) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Check local cache first
    if (isIssued) return false;

    final locale = LocaleSettings.currentLocale.languageCode;
    final userName = await _resolveUserName(client, user);
    final profileData = await _resolveProfileData(client, user);

    // Try to register in Supabase (returns false if already exists)
    try {
      final result = await client.rpc('request_checklist_certificate', params: {
        'user_email': user.email ?? '',
        'user_name': userName,
        'species_count': speciesCount,
        'completed_at': DateTime.now().toIso8601String(),
      });
      if (result == false) {
        // Already issued server-side
        await Bootstrap.prefs.setBool(_certIssuedKey, true);
        return false;
      }
    } catch (_) {}

    // Save locally
    final now = DateTime.now();
    await Bootstrap.prefs.setBool(_certIssuedKey, true);
    await Bootstrap.prefs.setString(_certNameKey, userName);
    await Bootstrap.prefs.setInt(_certCountKey, speciesCount);
    await Bootstrap.prefs.setInt(_certDateKey, now.millisecondsSinceEpoch);

    // Generate and share PDF
    await CertificateGenerator.generateAndShare(
      userName: userName,
      speciesCount: speciesCount,
      completedAt: now,
      locale: locale,
      userType: profileData.$1,
      affiliation: profileData.$2,
    );
    return true;
  }

  /// Re-download an already issued certificate.
  static Future<void> downloadExisting({required BuildContext context}) async {
    final locale = LocaleSettings.currentLocale.languageCode;
    final userName = issuedName ?? 'Explorer';
    final count = issuedCount ?? 17;
    final date = issuedDate ?? DateTime.now();

    await CertificateGenerator.generateAndShare(
      userName: userName,
      speciesCount: count,
      completedAt: date,
      locale: locale,
    );
  }

  static Future<(String, String?)> _resolveProfileData(
      SupabaseClient client, User user) async {
    try {
      final profile = await client
          .from('profiles')
          .select('user_type, affiliation')
          .eq('id', user.id)
          .maybeSingle();
      return (
        (profile?['user_type'] as String?) ?? 'tourist',
        profile?['affiliation'] as String?,
      );
    } catch (_) {
      return ('tourist', null);
    }
  }

  static Future<String> _resolveUserName(SupabaseClient client, User user) async {
    try {
      final profile = await client
          .from('profiles')
          .select('display_name')
          .eq('id', user.id)
          .maybeSingle();
      final name = profile?['display_name'] as String?;
      if (name != null && name.trim().isNotEmpty) return name.trim();
    } catch (_) {}
    final meta = user.userMetadata?['display_name'] as String?;
    if (meta != null && meta.trim().isNotEmpty) return meta.trim();
    return user.email?.split('@').first ?? 'Explorer';
  }
}
