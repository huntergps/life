import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../bootstrap.dart';
import '../../../core/services/app_logger.dart';

/// Model for a pending change
class PendingChange {
  final String id;
  final String type; // 'site', 'trail'
  final String action; // 'create', 'update', 'delete'
  final String name;
  final DateTime timestamp;

  PendingChange({
    required this.id,
    required this.type,
    required this.action,
    required this.name,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'action': action,
        'name': name,
        'timestamp': timestamp.toIso8601String(),
      };

  factory PendingChange.fromJson(Map<String, dynamic> json) => PendingChange(
        id: json['id'] as String,
        type: json['type'] as String,
        action: json['action'] as String,
        name: json['name'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

/// State for sync status
class SyncStatus {
  final List<PendingChange> pendingChanges;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final String? lastError;

  const SyncStatus({
    this.pendingChanges = const [],
    this.isSyncing = false,
    this.lastSyncTime,
    this.lastError,
  });

  SyncStatus copyWith({
    List<PendingChange>? pendingChanges,
    bool? isSyncing,
    DateTime? lastSyncTime,
    String? lastError,
  }) {
    return SyncStatus(
      pendingChanges: pendingChanges ?? this.pendingChanges,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastError: lastError ?? this.lastError,
    );
  }

  int get pendingCount => pendingChanges.length;
  bool get hasPendingChanges => pendingChanges.isNotEmpty;
}

/// Notifier for sync status
class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  static const _prefKey = 'pending_field_edits';

  SyncStatusNotifier() : super(const SyncStatus()) {
    _loadPendingChanges();
  }

  /// Load pending changes from SharedPreferences
  Future<void> _loadPendingChanges() async {
    try {
      final prefs = Bootstrap.prefs;
      final json = prefs.getString(_prefKey);

      if (json == null || json.isEmpty) {
        state = const SyncStatus();
        return;
      }

      final decoded = jsonDecode(json) as List;
      final changes = decoded
          .map((e) => PendingChange.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(pendingChanges: changes);
    } catch (e) {
      AppLogger.error('Error loading pending changes', e);
      state = const SyncStatus();
    }
  }

  /// Save pending changes to SharedPreferences
  Future<void> _savePendingChanges() async {
    try {
      final prefs = Bootstrap.prefs;
      final json = jsonEncode(
        state.pendingChanges.map((c) => c.toJson()).toList(),
      );
      await prefs.setString(_prefKey, json);
    } catch (e) {
      AppLogger.warning('Error saving pending changes', e);
    }
  }

  /// Add a pending change
  Future<void> addPendingChange({
    required String id,
    required String type,
    required String action,
    required String name,
  }) async {
    final change = PendingChange(
      id: id,
      type: type,
      action: action,
      name: name,
      timestamp: DateTime.now(),
    );

    final updated = [...state.pendingChanges, change];
    state = state.copyWith(pendingChanges: updated);
    await _savePendingChanges();
  }

  /// Remove a pending change (when synced)
  Future<void> removePendingChange(String id) async {
    final updated = state.pendingChanges.where((c) => c.id != id).toList();
    state = state.copyWith(pendingChanges: updated);
    await _savePendingChanges();
  }

  /// Clear all pending changes
  Future<void> clearAll() async {
    state = state.copyWith(pendingChanges: []);
    await _savePendingChanges();
  }

  /// Start syncing
  void startSyncing() {
    state = state.copyWith(isSyncing: true, lastError: null);
  }

  /// Complete sync successfully
  Future<void> completeSyncSuccess() async {
    state = state.copyWith(
      isSyncing: false,
      lastSyncTime: DateTime.now(),
      lastError: null,
    );
    // Clear all pending changes after successful sync
    await clearAll();
  }

  /// Complete sync with error
  void completeSyncError(String error) {
    state = state.copyWith(
      isSyncing: false,
      lastError: error,
    );
  }

  /// Manually trigger sync
  Future<void> triggerSync() async {
    if (state.isSyncing) return;

    startSyncing();

    try {
      // Wait a bit to simulate sync (Brick handles actual sync automatically)
      await Future.delayed(const Duration(seconds: 2));

      // In a real implementation, we would:
      // 1. Check internet connectivity
      // 2. Force Brick's offlineRequestQueue to process
      // 3. Wait for completion
      // For now, we just clear pending changes after delay
      await completeSyncSuccess();
    } catch (e) {
      completeSyncError(e.toString());
    }
  }
}

/// Global provider for sync status
final syncStatusProvider =
    StateNotifierProvider<SyncStatusNotifier, SyncStatus>((ref) {
  return SyncStatusNotifier();
});
