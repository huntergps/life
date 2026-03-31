import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class UserProfile extends OfflineFirstWithSupabaseModel {
  final String id;

  final String? displayName;

  final String? bio;

  final DateTime? birthDate;

  final String? country;

  final String? countryCode;

  final String? avatarUrl;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  @override
  Object? get primaryKey => id;

  UserProfile({
    required this.id,
    this.displayName,
    this.bio,
    this.birthDate,
    this.country,
    this.countryCode,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });
}

/// Extension methods for UserProfile
extension UserProfileExtension on UserProfile {
  bool get isBirthdayToday {
    if (birthDate == null) return false;
    final now = DateTime.now();
    return birthDate!.month == now.month && birthDate!.day == now.day;
  }
}
