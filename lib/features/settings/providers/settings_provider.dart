import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';

final localeProvider = NotifierProvider<LocaleNotifier, String>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<String> {
  @override
  String build() {
    final saved = Bootstrap.prefs.getString('locale');
    if (saved != null) {
      Future.microtask(() => LocaleSettings.setLocaleRaw(saved));
      return saved;
    }
    // First launch: detect device language
    final deviceLocale = ui.PlatformDispatcher.instance.locale.languageCode;
    final detected = deviceLocale.startsWith('es') ? 'es' : 'en';
    Future.microtask(() {
      LocaleSettings.setLocaleRaw(detected);
      Bootstrap.prefs.setString('locale', detected);
    });
    return detected;
  }

  Future<void> setLocale(String locale) async {
    state = locale;
    await LocaleSettings.setLocaleRaw(locale);
    await Bootstrap.prefs.setString('locale', locale);
  }
}

// ── Photo ID daily usage counter ────────────────────────────────────────────

const _photoIdCountKey = 'photo_id_count';
const _photoIdDateKey = 'photo_id_date';
const kFreePhotoIdLimit = 3;

/// Returns how many Photo ID uses remain today for free users.
int remainingFreePhotoIds() {
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final savedDate = Bootstrap.prefs.getString(_photoIdDateKey) ?? '';
  if (savedDate != today) return kFreePhotoIdLimit;
  final count = Bootstrap.prefs.getInt(_photoIdCountKey) ?? 0;
  return (kFreePhotoIdLimit - count).clamp(0, kFreePhotoIdLimit);
}

/// Records one Photo ID use. Returns false if limit reached.
Future<bool> usePhotoId() async {
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final savedDate = Bootstrap.prefs.getString(_photoIdDateKey) ?? '';
  int count;
  if (savedDate != today) {
    count = 0;
    await Bootstrap.prefs.setString(_photoIdDateKey, today);
  } else {
    count = Bootstrap.prefs.getInt(_photoIdCountKey) ?? 0;
  }
  if (count >= kFreePhotoIdLimit) return false;
  await Bootstrap.prefs.setInt(_photoIdCountKey, count + 1);
  return true;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final mode = Bootstrap.prefs.getString('theme_mode') ?? 'dark';
    return switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final modeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await Bootstrap.prefs.setString('theme_mode', modeStr);
  }
}

/// Persists the last visited route so the app can restore it on cold start.
final lastRouteProvider = NotifierProvider<LastRouteNotifier, String>(LastRouteNotifier.new);

class LastRouteNotifier extends Notifier<String> {
  @override
  String build() {
    return Bootstrap.prefs.getString('last_route') ?? '/';
  }

  Future<void> save(String route) async {
    state = route;
    await Bootstrap.prefs.setString('last_route', route);
  }
}

/// Tracks when data was last synced with the server.
final lastSyncedProvider = NotifierProvider<LastSyncedNotifier, DateTime?>(LastSyncedNotifier.new);

class LastSyncedNotifier extends Notifier<DateTime?> {
  static const _key = 'last_synced';

  @override
  DateTime? build() {
    final ms = Bootstrap.prefs.getInt(_key);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  Future<void> recordSync() async {
    final now = DateTime.now();
    state = now;
    await Bootstrap.prefs.setInt(_key, now.millisecondsSinceEpoch);
  }
}

/// Persists the collapsed state of the NavigationRail.
final navCollapsedProvider = NotifierProvider<NavCollapsedNotifier, bool>(NavCollapsedNotifier.new);

class NavCollapsedNotifier extends Notifier<bool> {
  @override
  bool build() {
    return Bootstrap.prefs.getBool('nav_collapsed') ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    await Bootstrap.prefs.setBool('nav_collapsed', state);
  }

  Future<void> set(bool collapsed) async {
    state = collapsed;
    await Bootstrap.prefs.setBool('nav_collapsed', collapsed);
  }
}

/// Controls whether badge unlock dialogs are shown.
final badgeNotificationsProvider =
    NotifierProvider<BadgeNotificationsNotifier, bool>(BadgeNotificationsNotifier.new);

class BadgeNotificationsNotifier extends Notifier<bool> {
  static const _key = 'badge_notifications';

  @override
  bool build() => Bootstrap.prefs.getBool(_key) ?? true;

  Future<void> toggle() async {
    state = !state;
    await Bootstrap.prefs.setBool(_key, state);
  }
}

/// Controls whether sighting reminder notifications are shown.
final sightingRemindersProvider =
    NotifierProvider<SightingRemindersNotifier, bool>(SightingRemindersNotifier.new);

class SightingRemindersNotifier extends Notifier<bool> {
  static const _key = 'sighting_reminders';

  @override
  bool build() => Bootstrap.prefs.getBool(_key) ?? true;

  Future<void> toggle() async {
    state = !state;
    await Bootstrap.prefs.setBool(_key, state);
  }
}

/// Controls whether sync status notifications are shown.
final syncNotificationsProvider =
    NotifierProvider<SyncNotificationsNotifier, bool>(SyncNotificationsNotifier.new);

class SyncNotificationsNotifier extends Notifier<bool> {
  static const _key = 'sync_notifications';

  @override
  bool build() => Bootstrap.prefs.getBool(_key) ?? false;

  Future<void> toggle() async {
    state = !state;
    await Bootstrap.prefs.setBool(_key, state);
  }
}

/// Global text scale factor (0.8 – 1.5). Persisted locally.
final textScaleProvider = NotifierProvider<TextScaleNotifier, double>(TextScaleNotifier.new);

class TextScaleNotifier extends Notifier<double> {
  static const _key = 'text_scale';
  static const double minScale = 0.8;
  static const double maxScale = 1.5;

  @override
  double build() => Bootstrap.prefs.getDouble(_key) ?? 1.0;

  Future<void> setScale(double scale) async {
    final clamped = scale.clamp(minScale, maxScale);
    state = clamped;
    await Bootstrap.prefs.setDouble(_key, clamped);
  }
}

