import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/features/profile/providers/profile_provider.dart';
import 'package:galapagos_wildlife/brick/models/user_profile.model.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class CelebrationEvent {
  final int id;
  final String nameEn;
  final String nameEs;
  final String? descriptionEn;
  final String? descriptionEs;
  final int eventMonth;
  final int eventDay;
  final String? countryCode;
  final String iconName;
  final String overlayType;
  final bool isActive;

  const CelebrationEvent({
    required this.id,
    required this.nameEn,
    required this.nameEs,
    this.descriptionEn,
    this.descriptionEs,
    required this.eventMonth,
    required this.eventDay,
    this.countryCode,
    required this.iconName,
    required this.overlayType,
    required this.isActive,
  });

  factory CelebrationEvent.fromJson(Map<String, dynamic> json) {
    return CelebrationEvent(
      id: json['id'] as int,
      nameEn: json['name_en'] as String,
      nameEs: json['name_es'] as String,
      descriptionEn: json['description_en'] as String?,
      descriptionEs: json['description_es'] as String?,
      eventMonth: json['event_month'] as int,
      eventDay: json['event_day'] as int,
      countryCode: json['country_code'] as String?,
      iconName: json['icon_name'] as String,
      overlayType: json['overlay_type'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  /// Returns the localised name based on the current language.
  String name(bool isEs) => isEs ? nameEs : nameEn;

  /// Returns the localised description based on the current language.
  String? description(bool isEs) => isEs ? descriptionEs : descriptionEn;
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Fetches all active celebration events from the `celebration_events` table.
final celebrationEventsProvider =
    FutureProvider<List<CelebrationEvent>>((ref) async {
  final data = await Supabase.instance.client
      .from('celebration_events')
      .select()
      .eq('is_active', true);

  return (data as List<dynamic>)
      .map((row) => CelebrationEvent.fromJson(row as Map<String, dynamic>))
      .toList();
});

/// Returns the list of celebration events that are active **today**, filtered
/// by relevance:
///   - Worldwide events (countryCode == null)
///   - Galapagos-specific events (countryCode == 'GAL') -- always shown
///   - Events matching the user's country code
///
/// Also includes a synthetic birthday event when today is the user's birthday.
final activeCelebrationsProvider = Provider<List<CelebrationEvent>>((ref) {
  final eventsAsync = ref.watch(celebrationEventsProvider);
  final profileAsync = ref.watch(userProfileProvider);

  final events = eventsAsync.asData?.value ?? [];
  final profile = profileAsync.asData?.value;
  final userCountry = profile?.countryCode;

  final now = DateTime.now();
  final todayMonth = now.month;
  final todayDay = now.day;

  // Filter events matching today's date and applicable scope.
  final active = events.where((e) {
    if (e.eventMonth != todayMonth || e.eventDay != todayDay) return false;

    // Worldwide events always match.
    if (e.countryCode == null) return true;

    // Galapagos-specific events always shown (this is a Galapagos app).
    if (e.countryCode == 'GAL') return true;

    // Match against the user's country code.
    if (userCountry != null && e.countryCode == userCountry) return true;

    return false;
  }).toList();

  // If today is the user's birthday, add a synthetic birthday event.
  final isBirthday = ref.watch(isBirthdayTodayProvider);
  if (isBirthday) {
    active.add(
      CelebrationEvent(
        id: -1,
        nameEn: 'Happy Birthday!',
        nameEs: 'Feliz Cumpleanos!',
        descriptionEn: 'Wishing you a wonderful birthday!',
        descriptionEs: 'Te deseamos un maravilloso cumpleanos!',
        eventMonth: todayMonth,
        eventDay: todayDay,
        iconName: 'cake',
        overlayType: 'hat',
        isActive: true,
      ),
    );
  }

  return active;
});

/// Whether today is the current user's birthday.
final isBirthdayTodayProvider = Provider<bool>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  final profile = profileAsync.asData?.value;
  if (profile == null) return false;
  return profile.isBirthdayToday;
});

/// Returns the overlay type of the highest-priority active celebration.
///
/// Priority order: hat > fireworks > frame > badge.
/// If it's the user's birthday, 'hat' is always returned.
final activeOverlayTypeProvider = Provider<String?>((ref) {
  final isBirthday = ref.watch(isBirthdayTodayProvider);
  if (isBirthday) return 'hat';

  final celebrations = ref.watch(activeCelebrationsProvider);
  if (celebrations.isEmpty) return null;

  const priorityOrder = ['hat', 'fireworks', 'frame', 'badge'];

  for (final type in priorityOrder) {
    if (celebrations.any((e) => e.overlayType == type)) {
      return type;
    }
  }

  // If none of the known types match, return the first event's overlay type.
  return celebrations.first.overlayType;
});
