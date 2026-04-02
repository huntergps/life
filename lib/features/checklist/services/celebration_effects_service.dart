import 'package:flutter/services.dart';

/// Provides haptic feedback for celebration moments in the checklist.
class CelebrationEffectsService {
  /// Light haptic when a species is marked as seen.
  static Future<void> celebrateCheckmark() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium haptic for every-5 milestone.
  static Future<void> celebrateMilestone() async {
    await HapticFeedback.mediumImpact();
  }

  /// Triple heavy haptic burst for 100% completion.
  static Future<void> celebrateCompletion() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.heavyImpact();
  }
}
