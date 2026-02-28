import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Shared state providers for admin list screens.
/// Eliminates setState boilerplate across category/island/visit_site/species lists.

/// Search query for filtering admin list items.
final adminSearchQueryProvider = StateProvider<String>((ref) => '');

/// Whether to show deleted (soft-deleted) items.
final adminShowDeletedProvider = StateProvider<bool>((ref) => false);

/// Whether multi-select mode is active (categories, islands, visit_sites).
final adminSelectionModeProvider = StateProvider<bool>((ref) => false);

/// Set of selected item IDs in multi-select mode.
final adminSelectedIdsProvider = StateProvider<Set<String>>((ref) => {});

/// Exits selection mode and clears selected IDs.
void exitSelectionMode(WidgetRef ref) {
  ref.read(adminSelectionModeProvider.notifier).state = false;
  ref.read(adminSelectedIdsProvider.notifier).state = {};
}

/// Toggles an item's selection. Exits selection mode if set becomes empty.
void toggleSelection(WidgetRef ref, String id) {
  final notifier = ref.read(adminSelectedIdsProvider.notifier);
  final current = {...notifier.state};
  if (current.contains(id)) {
    current.remove(id);
  } else {
    current.add(id);
  }
  notifier.state = current;
  if (current.isEmpty) {
    ref.read(adminSelectionModeProvider.notifier).state = false;
  }
}

/// Enters selection mode with the given item pre-selected.
void enterSelectionMode(WidgetRef ref, String id) {
  ref.read(adminSelectionModeProvider.notifier).state = true;
  ref.read(adminSelectedIdsProvider.notifier).state = {id};
}

/// Resets all admin list state (useful when navigating away).
void resetAdminListState(WidgetRef ref) {
  ref.read(adminSearchQueryProvider.notifier).state = '';
  ref.read(adminShowDeletedProvider.notifier).state = false;
  ref.read(adminSelectionModeProvider.notifier).state = false;
  ref.read(adminSelectedIdsProvider.notifier).state = {};
}
