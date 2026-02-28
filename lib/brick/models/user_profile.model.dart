import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'profiles'),
)
class UserProfile extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true, name: 'id')
  final String id;

  @Supabase(name: 'display_name')
  final String? displayName;

  final String? bio;

  @Supabase(name: 'birth_date')
  final DateTime? birthDate;

  final String? country;

  @Supabase(name: 'country_code')
  final String? countryCode;

  @Supabase(name: 'avatar_url')
  final String? avatarUrl;

  @Supabase(name: 'created_at')
  final DateTime? createdAt;

  @Supabase(name: 'updated_at')
  final DateTime? updatedAt;

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
