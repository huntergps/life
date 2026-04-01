import 'package:flutter/services.dart';

/// A parsed label entry from the TFLite labels file.
class LabelEntry {
  final String scientific;
  final String en;
  final String es;
  const LabelEntry(this.scientific, this.en, this.es);
}

/// Parses TFLite label files in the format: `scientific|en|es` (one per line).
class LabelParser {
  const LabelParser._();

  /// Asset path for the labels file.
  static const labelsAsset = 'assets/ml/labels.txt';

  /// Load and parse labels from the bundled asset.
  static Future<List<LabelEntry>> loadFromAsset() async {
    final raw = await rootBundle.loadString(labelsAsset);
    return parse(raw);
  }

  /// Parse a raw multi-line label string into [LabelEntry] objects.
  static List<LabelEntry> parse(String raw) {
    return raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) {
          final parts = l.split('|');
          if (parts.length >= 3) return LabelEntry(parts[0], parts[1], parts[2]);
          if (parts.length == 2) return LabelEntry(parts[0], parts[1], parts[1]);
          return LabelEntry(l, l, l);
        })
        .toList();
  }

  /// Extract the set of scientific names (lowercase) from the labels asset.
  /// Used by species cards to show the "AI" badge.
  static Future<Set<String>> loadRecognizedNames() async {
    try {
      final raw = await rootBundle.loadString(labelsAsset);
      return raw
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .map((l) => l.split('|').first.toLowerCase())
          .toSet();
    } catch (_) {
      return {};
    }
  }
}
