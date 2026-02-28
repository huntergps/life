import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/search_bar_widget.dart';
import '../../providers/admin_list_state_providers.dart';

// ---------------------------------------------------------------------------
// A. AdminListHeader — Filter chips + search bar
// ---------------------------------------------------------------------------

/// Reusable header section for admin list screens.
///
/// Contains: search bar, active/trash filter chips, and item-count label.
class AdminListHeader extends ConsumerWidget {
  /// Controller for the search text field.
  final TextEditingController searchController;

  /// Number of items currently in trash (shown as badge on Trash chip).
  final int deletedCount;

  /// Label shown below the chips (e.g. "5 categories" or "3 in trash").
  final String countLabel;

  /// Horizontal padding applied around the header contents.
  final double padding;

  const AdminListHeader({
    super.key,
    required this.searchController,
    required this.deletedCount,
    required this.countLabel,
    required this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showDeleted = ref.watch(adminShowDeletedProvider);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.fromLTRB(padding, 8, padding, 0),
          child: SearchBarWidget(
            hintText: context.t.admin.search,
            controller: searchController,
            onChanged: (value) =>
                ref.read(adminSearchQueryProvider.notifier).state = value,
            onClear: () {
              ref.read(adminSearchQueryProvider.notifier).state = '';
              searchController.clear();
            },
          ),
        ),

        // Active / Trash filter chips
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            children: [
              FilterChip(
                label: Text(context.t.admin.active),
                selected: !showDeleted,
                onSelected: (_) {
                  ref.read(adminShowDeletedProvider.notifier).state = false;
                  ref.read(adminSelectedIdsProvider.notifier).state = {};
                  ref.read(adminSelectionModeProvider.notifier).state = false;
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(
                  '${context.t.admin.trash}${deletedCount > 0 ? ' ($deletedCount)' : ''}',
                ),
                selected: showDeleted,
                onSelected: (_) {
                  ref.read(adminShowDeletedProvider.notifier).state = true;
                  ref.read(adminSelectedIdsProvider.notifier).state = {};
                  ref.read(adminSelectionModeProvider.notifier).state = false;
                },
                avatar: const Icon(Icons.delete_outline, size: 18),
              ),
            ],
          ),
        ),

        // Count label
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              countLabel,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// B. AdminGridCard — Generic card for active items in grid view
// ---------------------------------------------------------------------------

/// A reusable grid card for active admin entity items.
///
/// Shows an icon, optional badge widget, title, subtitle, selection checkbox
/// overlay, and an optional trailing action (e.g. delete button).
class AdminGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isDark;

  /// Optional badge widget shown in the top-right corner (e.g. sort order, area).
  final Widget? badge;

  /// Optional trailing widget shown at bottom-right when NOT in selection mode
  /// (e.g. a small delete icon button).
  final Widget? trailing;

  const AdminGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.selectionMode,
    required this.onTap,
    this.onLongPress,
    required this.isDark,
    this.badge,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        color: isDark ? AppColors.darkCard : null,
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isSelected
              ? BorderSide(color: accentColor, width: 2)
              : isDark
                  ? const BorderSide(color: AppColors.darkBorder, width: 0.5)
                  : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(10),
          hoverColor: accentColor.withValues(alpha: 0.05),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 22, color: accentColor),
                        const Spacer(),
                        ?badge,
                      ],
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey[600],
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (!selectionMode && trailing != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: trailing!,
                      ),
                  ],
                ),
              ),
              if (selectionMode)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => onTap(),
                    activeColor: accentColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// C. AdminDeletedGridCard — Card for deleted/trash items in grid view
// ---------------------------------------------------------------------------

/// A reusable grid card for deleted (trashed) admin entity items.
///
/// Shows a dimmed card with icon, "Deleted" badge, title, subtitle,
/// deleted date, and restore/permanent-delete action buttons.
class AdminDeletedGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String deletedAt;
  final IconData icon;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isDark;

  /// Called when the restore button is pressed.
  final VoidCallback? onRestore;

  /// Called when the permanent-delete button is pressed.
  final VoidCallback? onPermanentDelete;

  const AdminDeletedGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.deletedAt,
    required this.icon,
    required this.isSelected,
    required this.selectionMode,
    required this.onTap,
    this.onLongPress,
    required this.isDark,
    this.onRestore,
    this.onPermanentDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Opacity(
      opacity: 0.6,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          color: isDark ? AppColors.darkCard : null,
          elevation: isDark ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isSelected
                ? BorderSide(color: accentColor, width: 2)
                : isDark
                    ? const BorderSide(
                        color: AppColors.darkBorder, width: 0.5)
                    : BorderSide.none,
          ),
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(10),
            hoverColor: accentColor.withValues(alpha: 0.05),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 22, color: accentColor),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              context.t.admin.deletedLabel,
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        title,
                        style: TextStyle(
                          color: isDark ? Colors.white : null,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey[600],
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (deletedAt.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            deletedAt.length >= 10
                                ? deletedAt.substring(0, 10)
                                : deletedAt,
                            style: TextStyle(
                              fontSize: 9,
                              color: isDark ? Colors.white38 : Colors.grey,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (!selectionMode)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (onRestore != null)
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: IconButton(
                                  icon: Icon(Icons.restore_from_trash,
                                      size: 14, color: AppColors.primaryLight),
                                  tooltip: context.t.admin.restore,
                                  onPressed: onRestore,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            if (onRestore != null && onPermanentDelete != null)
                              const SizedBox(width: 8),
                            if (onPermanentDelete != null)
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: IconButton(
                                  icon: Icon(Icons.delete_forever,
                                      size: 14, color: AppColors.error),
                                  tooltip: context.t.admin.deletePermanently,
                                  onPressed: onPermanentDelete,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (selectionMode)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => onTap(),
                      activeColor: accentColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// D. showAdminDeleteConfirmation — Shared delete confirmation dialog
// ---------------------------------------------------------------------------

/// Shows a delete confirmation dialog. Returns `true` if the user confirmed.
///
/// - For a single named item, pass [name].
/// - For batch deletion, pass [count].
/// - Set [permanent] to `true` for permanent deletion wording.
Future<bool> showAdminDeleteConfirmation(
  BuildContext context, {
  String? name,
  bool permanent = false,
  int? count,
}) async {
  final String title;
  final String content;

  if (count != null && count > 0) {
    // Batch delete
    title = permanent
        ? context.t.admin.deletePermanently
        : context.t.admin.confirmDeleteTitle;
    content = permanent
        ? context.t.admin
            .confirmDeletePermanentlyCount(count: count.toString())
        : context.t.admin.confirmDeleteCount(count: count.toString());
  } else {
    // Single item
    title = permanent
        ? context.t.admin.deletePermanently
        : context.t.admin.confirmDeleteTitle;
    content = permanent
        ? context.t.admin
            .confirmDeletePermanently(name: name ?? context.t.admin.unnamed)
        : context.t.admin
            .confirmDeleteNamed(name: name ?? context.t.admin.unnamed);
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(context.t.common.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            permanent
                ? context.t.admin.deletePermanently
                : context.t.common.delete,
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );

  return confirmed == true;
}

// ---------------------------------------------------------------------------
// E. AdminSelectionAppBar — AppBar shown during multi-selection mode
// ---------------------------------------------------------------------------

/// An [AppBar] displayed when multi-selection mode is active.
///
/// Shows the count of selected items, a close button, and a delete action.
class AdminSelectionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Number of currently selected items.
  final int selectedCount;

  /// Whether viewing trash (changes delete icon to delete_forever).
  final bool showDeleted;

  /// Called when the delete/permanent-delete action is pressed.
  final VoidCallback onDelete;

  /// Called when the close (cancel selection) button is pressed.
  final VoidCallback onClose;

  final bool isDark;

  const AdminSelectionAppBar({
    super.key,
    required this.selectedCount,
    required this.showDeleted,
    required this.onDelete,
    required this.onClose,
    required this.isDark,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onClose,
      ),
      title: Text(
        context.t.admin.itemsSelected(count: selectedCount.toString()),
      ),
      backgroundColor: isDark ? AppColors.darkBackground : null,
      actions: [
        IconButton(
          icon: Icon(
            showDeleted ? Icons.delete_forever : Icons.delete,
            color: AppColors.error,
          ),
          tooltip: showDeleted
              ? context.t.admin.deletePermanently
              : context.t.common.delete,
          onPressed: onDelete,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// F. AdminEmptyTrash — Placeholder shown when the trash is empty
// ---------------------------------------------------------------------------

/// A centered empty-state widget for empty trash views.
class AdminEmptyTrash extends StatelessWidget {
  final bool isDark;

  const AdminEmptyTrash({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline,
              size: 64, color: isDark ? Colors.white24 : Colors.grey),
          const SizedBox(height: 16),
          Text(
            context.t.admin.emptyTrash,
            style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// G. adminGridDelegate — Shared grid delegate builder
// ---------------------------------------------------------------------------

/// Returns a consistent grid delegate based on screen width.
SliverGridDelegateWithFixedCrossAxisCount adminGridDelegate(double width) {
  final crossAxisCount = width >= 1200 ? 5 : (width >= 900 ? 4 : 3);
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: crossAxisCount,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 1.3,
  );
}

// ---------------------------------------------------------------------------
// H. AdminDeletedListTile — List tile for deleted items
// ---------------------------------------------------------------------------

/// A reusable list tile card for deleted (trashed) admin items.
class AdminDeletedListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String deletedAt;
  final IconData icon;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isDark;
  final VoidCallback? onRestore;
  final VoidCallback? onPermanentDelete;

  const AdminDeletedListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.deletedAt,
    required this.icon,
    required this.isSelected,
    required this.selectionMode,
    required this.onTap,
    this.onLongPress,
    required this.isDark,
    this.onRestore,
    this.onPermanentDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Opacity(
      opacity: 0.6,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: isDark ? AppColors.darkCard : null,
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isSelected
              ? BorderSide(color: accentColor, width: 2)
              : isDark
                  ? const BorderSide(color: AppColors.darkBorder, width: 0.5)
                  : BorderSide.none,
        ),
        child: ListTile(
          leading: selectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap(),
                  activeColor: accentColor,
                )
              : CircleAvatar(
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  child: Icon(icon, color: AppColors.error),
                ),
          title: Text(
            title,
            style: TextStyle(color: isDark ? Colors.white : null),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: TextStyle(color: isDark ? Colors.white54 : null),
              ),
              if (deletedAt.isNotEmpty)
                Text(
                  context.t.admin.deletedOn(
                    date: deletedAt.length >= 10
                        ? deletedAt.substring(0, 10)
                        : deletedAt,
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.error.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
          trailing: selectionMode
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onRestore != null)
                      IconButton(
                        icon: Icon(Icons.restore_from_trash,
                            color: AppColors.primaryLight),
                        tooltip: context.t.admin.restore,
                        onPressed: onRestore,
                      ),
                    if (onPermanentDelete != null)
                      IconButton(
                        icon:
                            Icon(Icons.delete_forever, color: AppColors.error),
                        tooltip: context.t.admin.deletePermanently,
                        onPressed: onPermanentDelete,
                      ),
                  ],
                ),
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// I. AdminActiveListTile — List tile for active items
// ---------------------------------------------------------------------------

/// A reusable list tile card for active admin items.
class AdminActiveListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isDark;

  /// Optional trailing widget shown when NOT in selection mode.
  final Widget? trailing;

  /// Optional widget shown inline before the subtitle text (e.g. a status badge).
  final Widget? subtitleLeading;

  const AdminActiveListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.selectionMode,
    required this.onTap,
    this.onLongPress,
    required this.isDark,
    this.trailing,
    this.subtitleLeading,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    final subtitleWidget = subtitleLeading != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              subtitleLeading!,
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : null,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        : Text(
            subtitle,
            style: TextStyle(color: isDark ? Colors.white54 : null),
          );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isDark ? AppColors.darkCard : null,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: accentColor, width: 2)
            : isDark
                ? const BorderSide(color: AppColors.darkBorder, width: 0.5)
                : BorderSide.none,
      ),
      child: ListTile(
        leading: selectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => onTap(),
                activeColor: accentColor,
              )
            : CircleAvatar(
                backgroundColor: accentColor.withValues(alpha: 0.1),
                child: Icon(icon, color: accentColor),
              ),
        title: Text(
          title,
          style: TextStyle(color: isDark ? Colors.white : null),
        ),
        subtitle: subtitleWidget,
        trailing: selectionMode ? null : trailing,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
