import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../providers/field_edit_provider.dart';
import '../../providers/trail_provider.dart';
import '../../services/field_edit_service.dart';

/// Panel for GPS trail recording
/// Shows real-time stats and auto-captures GPS points
class TrailRecordingPanel extends ConsumerStatefulWidget {
  /// Island currently selected on the map — stored on the saved trail so it
  /// appears in the correct island group in the sidebar.
  final int? islandId;

  const TrailRecordingPanel({super.key, this.islandId});

  @override
  ConsumerState<TrailRecordingPanel> createState() =>
      _TrailRecordingPanelState();
}

class _TrailRecordingPanelState extends ConsumerState<TrailRecordingPanel> {
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(fieldEditProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Only show if in a trail creation/editing mode
    final isManualMode = editState.mode == FieldEditMode.createTrailManual ||
        editState.mode == FieldEditMode.editTrailManual;
    final isGPSMode = editState.mode == FieldEditMode.createTrailGPS ||
        editState.mode == FieldEditMode.editTrailGPS;

    if (!isManualMode && !isGPSMode) {
      return const SizedBox.shrink();
    }

    final distanceKm = editState.recordedDistance / 1000;
    final duration = editState.recordingDuration;
    final points = editState.recordingPoints.length;

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.grey[900] : Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isManualMode
                          ? Colors.green.withValues(alpha: 0.2)
                          : (editState.isRecording
                              ? Colors.red.withValues(alpha: 0.2)
                              : Colors.orange.withValues(alpha: 0.2)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isManualMode
                          ? Icons.touch_app
                          : (editState.isRecording
                              ? Icons.fiber_manual_record
                              : Icons.pause),
                      color: isManualMode
                          ? Colors.green
                          : (editState.isRecording ? Colors.red : Colors.orange),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          editState.mode == FieldEditMode.editTrailManual
                              ? 'Editing Trail (Draw)'
                              : isManualMode
                              ? 'Creating Trail (Draw)'
                              : (editState.mode == FieldEditMode.editTrailGPS
                                  ? (editState.isRecording
                                      ? 'Re-recording Trail...'
                                      : 'Re-recording Paused')
                                  : (editState.isRecording
                                      ? 'Recording New Trail...'
                                      : 'Recording Paused')),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          isManualMode
                              ? '$points points added'
                              : _formatDuration(duration),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Profile selector (GPS mode only)
              if (isGPSMode) _buildProfileSelector(editState, isDark),

              const SizedBox(height: 12),

              // Stats (GPS mode only, once recording has points)
              if (isGPSMode && points > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      icon: Icons.straighten,
                      label: 'Distance',
                      value: '${distanceKm.toStringAsFixed(2)} km',
                      isDark: isDark,
                    ),
                    _buildStat(
                      icon: Icons.location_on,
                      label: 'Points',
                      value: points.toString(),
                      isDark: isDark,
                    ),
                    _buildStat(
                      icon: Icons.speed,
                      label: 'Avg Speed',
                      value: _calculateSpeed(distanceKm, duration),
                      isDark: isDark,
                    ),
                  ],
                ),

              // Tip
              if (points < 2)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isManualMode
                                ? 'Tap on the map to add trail points.'
                                : 'Start walking the trail. GPS will record your path automatically.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.blue[200] : Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Control Buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  // Pause/Resume Button (GPS mode only)
                  if (isGPSMode) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (editState.isRecording) {
                            ref.read(fieldEditProvider.notifier).pauseRecording();
                          } else {
                            ref.read(fieldEditProvider.notifier).resumeRecording();
                          }
                        },
                        icon: Icon(
                          editState.isRecording ? Icons.pause : Icons.play_arrow,
                          size: 18,
                        ),
                        label: Text(editState.isRecording ? 'Pause' : 'Resume'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              editState.isRecording ? Colors.orange : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  // Save Button (disabled if less than 2 points)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: points < 2 ? null : () => _showSaveDialog(editState),
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Cancel Button
                  IconButton(
                    onPressed: _showCancelDialog,
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: 'Cancel',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show dialog to save trail — create new or update existing
  void _showSaveDialog(FieldEditState editState) {
    final isEditing = editState.mode == FieldEditMode.editTrailManual;

    if (isEditing) {
      // Editing: just confirm overwrite (no name needed)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Save Trail Changes'),
          content: Text(
            'This will update the trail path with ${editState.recordingPoints.length} points '
            '(${(editState.recordedDistance / 1000).toStringAsFixed(2)} km).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await _updateTrail(
                  trailId: editState.selectedTrailId!,
                  coordinates: editState.recordingPoints,
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ),
      );
    } else {
      // Creating new: ask for name
      final nameController = TextEditingController();
      final descController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Save Trail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Trail Name (English)',
                  hintText: 'e.g., Tortuga Bay Trail',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Trail details...',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a trail name')),
                  );
                  return;
                }
                Navigator.pop(context);
                await _createTrail(
                  nameEn: name,
                  nameEs: name,
                  descriptionEn: descController.text.trim().isNotEmpty
                      ? descController.text.trim()
                      : null,
                  coordinates: editState.recordingPoints,
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ),
      );
    }
  }

  /// Create a new trail in the database
  Future<void> _createTrail({
    required String nameEn,
    required String nameEs,
    String? descriptionEn,
    required List<LatLng> coordinates,
  }) async {
    if (coordinates.length < 2) {
      _showError('Trail must have at least 2 points');
      return;
    }
    try {
      final profile = ref.read(fieldEditProvider).trackingProfile;
      final service = FieldEditService(ref: ref);
      final trail = await service.createNewTrail(
        nameEn: nameEn,
        nameEs: nameEs,
        descriptionEn: descriptionEn,
        descriptionEs: descriptionEn,
        coordinates: coordinates,
        difficulty: 'moderate',
        rdpTolerance: profile.rdpToleranceMeters,
        islandId: widget.islandId,
      );
      if (trail != null) {
        if (mounted) {
          final isOffline = trail.id == -1;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isOffline
                    ? 'Ruta guardada sin conexión — se enviará al servidor cuando haya internet.'
                    : 'Ruta "$nameEn" guardada.',
              ),
              backgroundColor: isOffline ? Colors.orange : Colors.green,
              duration: Duration(seconds: isOffline ? 5 : 3),
            ),
          );
        }
        ref.read(fieldEditProvider.notifier).exitEditMode();
        ref.invalidate(trailsProvider);
      } else {
        _showError('Failed to save trail');
      }
    } catch (e) {
      _showError('Error saving trail: $e');
    }
  }

  /// Update coordinates of an existing trail
  Future<void> _updateTrail({
    required int trailId,
    required List<LatLng> coordinates,
  }) async {
    if (coordinates.length < 2) {
      _showError('Trail must have at least 2 points');
      return;
    }
    try {
      final profile = ref.read(fieldEditProvider).trackingProfile;
      final service = FieldEditService(ref: ref);
      final updated = await service.updateTrailCoordinates(
        trailId: trailId,
        newCoordinates: coordinates,
        rdpTolerance: profile.rdpToleranceMeters,
      );
      if (updated != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trail updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
        ref.read(fieldEditProvider.notifier).exitEditMode();
        ref.invalidate(trailsProvider);
      } else {
        _showError('Failed to update trail');
      }
    } catch (e) {
      _showError('Error updating trail: $e');
    }
  }

  /// Show cancel confirmation dialog
  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Recording?'),
        content: const Text(
          'Are you sure you want to cancel? All recorded points will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Continue'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(fieldEditProvider.notifier).cancel();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  /// Profile selector row — compact chips for each [TrackingProfile].
  Widget _buildProfileSelector(FieldEditState editState, bool isDark) {
    final selected = editState.trackingProfile;
    // Once recording has points, show only a compact badge (no change allowed)
    if (editState.isRecording && editState.recordingPoints.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(selected.icon, size: 14, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            selected.labelEn,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity type',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: TrackingProfile.values.map((profile) {
            final isSelected = profile == selected;
            return GestureDetector(
              onTap: () =>
                  ref.read(fieldEditProvider.notifier).setTrackingProfile(profile),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.orange
                      : (isDark ? Colors.grey[800] : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      profile.icon,
                      size: 14,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[300] : Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profile.labelEn,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.grey[300] : Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.orange),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _calculateSpeed(double km, Duration duration) {
    if (duration.inSeconds == 0 || km == 0) return '0.0 km/h';
    final hours = duration.inSeconds / 3600.0;
    final speed = km / hours;
    return '${speed.toStringAsFixed(1)} km/h';
  }
}
