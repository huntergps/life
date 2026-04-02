import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/features/species/shared/species_checklist_provider.dart';
import 'package:galapagos_wildlife/features/checklist/providers/suggested_species_provider.dart';

/// Trip statistics computed from the user's checklist data.
class ChecklistStats {
  final int totalSpecies;
  final int seenCount;
  final int daysToComplete;
  final DateTime? firstSeenDate;
  final DateTime? lastSeenDate;

  const ChecklistStats({
    required this.totalSpecies,
    required this.seenCount,
    this.daysToComplete = 0,
    this.firstSeenDate,
    this.lastSeenDate,
  });

  bool get isComplete => totalSpecies > 0 && seenCount >= totalSpecies;
}

/// Provides trip statistics based on the user's checklist progress.
final checklistStatsProvider = Provider<ChecklistStats>((ref) {
  final myList = ref.watch(checklistSpeciesProvider).asData?.value ?? [];
  final seenSet = ref.watch(userChecklistProvider).asData?.value ?? {};

  // We need the notifier to access entry metadata (seenAt dates)
  final notifier = ref.read(userChecklistProvider.notifier);

  final seenIds = myList.where((id) => seenSet.contains(id)).toList();

  // Collect all seen_at dates
  final dates = <DateTime>[];
  for (final id in seenIds) {
    final entry = notifier.entryFor(id);
    if (entry?.seenAt != null) dates.add(entry!.seenAt!);
  }
  dates.sort();

  final firstDate = dates.isNotEmpty ? dates.first : null;
  final lastDate = dates.isNotEmpty ? dates.last : null;
  final days = (firstDate != null && lastDate != null)
      ? lastDate.difference(firstDate).inDays + 1
      : 0;

  return ChecklistStats(
    totalSpecies: myList.length,
    seenCount: seenIds.length,
    daysToComplete: days,
    firstSeenDate: firstDate,
    lastSeenDate: lastDate,
  );
});
