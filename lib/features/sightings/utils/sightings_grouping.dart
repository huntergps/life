import 'package:galapagos_wildlife/brick/models/sighting.model.dart';

/// Groups sightings by "yyyy-MM" key (year-month), ordered newest first.
///
/// Returns a [LinkedHashMap]-ordered map where each key is a "yyyy-MM" string
/// and each value is the list of sightings in that month, in the order they
/// were provided.
Map<String, List<Sighting>> groupSightingsByMonth(List<Sighting> sightings) {
  final grouped = <String, List<Sighting>>{};
  for (final s in sightings) {
    final date = s.observedAt ?? DateTime(1970);
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    grouped.putIfAbsent(key, () => []).add(s);
  }
  // Sort keys newest first
  final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
  return {for (final k in sortedKeys) k: grouped[k]!};
}

/// Parses a "yyyy-MM" key back to a [DateTime] representing the first of that month.
DateTime monthKeyToDateTime(String key) {
  final parts = key.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]));
}
