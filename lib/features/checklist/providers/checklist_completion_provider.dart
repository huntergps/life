import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/features/species/shared/species_checklist_provider.dart';
import 'suggested_species_provider.dart';

/// True when ALL species in the user's custom checklist have been seen.
final checklistCompleteProvider = Provider<bool>((ref) {
  final seen = ref.watch(userChecklistProvider).asData?.value ?? {};
  final myList = ref.watch(checklistSpeciesProvider).asData?.value ?? [];
  if (myList.isEmpty) return false;
  return myList.every((id) => seen.contains(id));
});

/// Convenience alias used by the checklist screen to trigger celebration.
/// The screen watches this and shows the dialog on transition to true.
final checklistJustCompletedProvider = Provider<bool>((ref) {
  return ref.watch(checklistCompleteProvider);
});
