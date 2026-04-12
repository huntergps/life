import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';

/// Available Gemma 4 Edge models.
enum GemmaModelTier {
  e2b, // 2B params, ~2.5 GB, 4GB+ RAM — most devices
  e4b, // 4B params, ~4.3 GB, 8GB+ RAM — high-end only
}

class GemmaModelInfo {
  final GemmaModelTier tier;
  final String label;
  final String sizeLabel;
  final String url;
  final String fileName;
  final int minRamGB;
  final int approximateSizeBytes;

  const GemmaModelInfo({
    required this.tier,
    required this.label,
    required this.sizeLabel,
    required this.url,
    required this.fileName,
    required this.minRamGB,
    required this.approximateSizeBytes,
  });
}

class GemmaModelConfig {
  static const _selectedTierKey = 'gemma_selected_tier';

  static const e2b = GemmaModelInfo(
    tier: GemmaModelTier.e2b,
    label: 'Gemma 4 E2B',
    sizeLabel: '2.5 GB',
    url: 'https://life-api.galapagos.tech/models/gemma-4-E2B-it.litertlm',
    fileName: 'gemma-4-E2B-it.litertlm',
    minRamGB: 4,
    approximateSizeBytes: 2500000000,
  );

  static const e4b = GemmaModelInfo(
    tier: GemmaModelTier.e4b,
    label: 'Gemma 4 E4B',
    sizeLabel: '4.3 GB',
    url: 'https://life-api.galapagos.tech/models/gemma-4-E4B-it.litertlm',
    fileName: 'gemma-4-E4B-it.litertlm',
    minRamGB: 8,
    approximateSizeBytes: 4300000000,
  );

  /// All available models.
  static const models = [e2b, e4b];

  /// Detect device RAM and recommend the best model.
  static GemmaModelInfo get recommended {
    if (kIsWeb) return e2b;

    final ramGB = _estimateDeviceRamGB();
    if (ramGB >= 8) return e4b;
    return e2b;
  }

  /// Get the user's selected model (or recommended default).
  static GemmaModelInfo get selected {
    final saved = Bootstrap.prefs.getString(_selectedTierKey);
    if (saved == 'e4b') return e4b;
    if (saved == 'e2b') return e2b;
    return recommended;
  }

  /// Save user's model selection.
  static Future<void> selectTier(GemmaModelTier tier) async {
    await Bootstrap.prefs.setString(_selectedTierKey, tier.name);
  }

  /// Whether the device can run E4B (high-end).
  static bool get canRunE4B => _estimateDeviceRamGB() >= 6;

  /// Whether a non-default model is selected.
  static bool get isCustomSelection {
    final saved = Bootstrap.prefs.getString(_selectedTierKey);
    return saved != null && saved != recommended.tier.name;
  }

  /// Estimate device RAM in GB.
  /// iOS doesn't expose RAM directly, so we use heuristics.
  static int _estimateDeviceRamGB() {
    if (kIsWeb) return 4;

    try {
      if (Platform.isIOS || Platform.isMacOS) {
        // iOS heuristic: ProcessInfo.processInfo.physicalMemory
        // not available in Dart — use device model heuristics
        // iPhone 15 Pro/Max: 8GB, iPhone 15/14: 6GB, iPhone 12/13: 4GB
        // For safety, assume 6GB for iOS (most modern iPhones)
        return 6;
      }

      if (Platform.isAndroid) {
        // On Android we could read /proc/meminfo but that requires
        // platform channel. Use conservative estimate.
        return 6;
      }
    } catch (_) {}

    return 4; // default conservative
  }

  /// Human-readable device tier description.
  static String get deviceTierLabel {
    final ram = _estimateDeviceRamGB();
    if (ram >= 8) return 'High-end';
    if (ram >= 6) return 'Mid-range';
    return 'Standard';
  }
}
