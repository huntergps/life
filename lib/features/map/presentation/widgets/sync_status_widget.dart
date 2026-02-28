import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/sync_status_provider.dart';

/// Widget to show sync status in settings
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.sync,
                  color: syncStatus.isSyncing ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Offline Sync Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (syncStatus.lastSyncTime != null)
                        Text(
                          'Last sync: ${_formatTime(syncStatus.lastSyncTime!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                // Badge
                if (syncStatus.hasPendingChanges)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${syncStatus.pendingCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Pending changes list
            if (syncStatus.hasPendingChanges) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Pending Changes (${syncStatus.pendingCount})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ...syncStatus.pendingChanges.map((change) => ListTile(
                    dense: true,
                    leading: Icon(
                      _getIconForType(change.type),
                      size: 20,
                      color: _getColorForAction(change.action),
                    ),
                    title: Text(
                      change.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      '${_getActionLabel(change.action)} ${change.type} • ${_formatTime(change.timestamp)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.pending,
                      size: 16,
                      color: Colors.orange,
                    ),
                  )),
              const SizedBox(height: 8),
            ],

            // Status message
            if (syncStatus.isSyncing)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    const Text('Syncing changes...'),
                  ],
                ),
              )
            else if (syncStatus.lastError != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sync failed: ${syncStatus.lastError}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )
            else if (!syncStatus.hasPendingChanges && syncStatus.lastSyncTime != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    const Text('All changes synced'),
                  ],
                ),
              )
            else if (!syncStatus.hasPendingChanges)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[800]
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_done, size: 20),
                    SizedBox(width: 12),
                    Text('No pending changes'),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Sync button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: syncStatus.isSyncing
                    ? null
                    : () => ref.read(syncStatusProvider.notifier).triggerSync(),
                icon: const Icon(Icons.sync),
                label: Text(
                  syncStatus.isSyncing ? 'Syncing...' : 'Sync Now',
                ),
              ),
            ),

            // Info text
            const SizedBox(height: 8),
            Text(
              'Changes are automatically synced when internet is available. You can also manually trigger sync above.',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'site':
        return Icons.location_on;
      case 'trail':
        return Icons.route;
      default:
        return Icons.edit;
    }
  }

  Color _getColorForAction(String action) {
    switch (action) {
      case 'create':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getActionLabel(String action) {
    switch (action) {
      case 'create':
        return 'Created';
      case 'update':
        return 'Updated';
      case 'delete':
        return 'Deleted';
      default:
        return action;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(time);
    }
  }
}
