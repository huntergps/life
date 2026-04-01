import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/features/species/shared/species_checklist_provider.dart';
import 'package:galapagos_wildlife/features/checklist/providers/suggested_species_provider.dart';

/// True when all 25 suggested species have been marked as seen.
final checklistCompleteProvider = Provider<bool>((ref) {
  final seen = ref.watch(userChecklistProvider).asData?.value ?? {};
  final suggested = ref.watch(suggestedSpeciesIdsProvider);
  return suggested.every((id) => seen.contains(id));
});

/// Convenience alias used by the checklist screen to trigger celebration.
/// The screen watches this and shows the dialog on transition to true.
final checklistJustCompletedProvider = Provider<bool>((ref) {
  return ref.watch(checklistCompleteProvider);
});
