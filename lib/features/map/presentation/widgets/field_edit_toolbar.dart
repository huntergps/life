import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../admin/providers/admin_auth_provider.dart';
import '../../providers/field_edit_provider.dart';
import '../../providers/trail_provider.dart';
import '../../services/field_edit_service.dart';

/// Floating toolbar for field editing operations
/// ONLY visible to admin users
class FieldEditToolbar extends ConsumerWidget {
  const FieldEditToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check admin status
    final isAdminAsync = ref.watch(isAdminProvider);
    final isAdmin = isAdminAsync.asData?.value ?? false;

    final editState = ref.watch(fieldEditProvider);
    final editNotifier = ref.read(fieldEditProvider.notifier);

    // Non-admin users: only show the editing toolbar when actively editing
    // their own trail (entered via the Edit button in the trail info sheet).
    if (!isAdmin) {
      if (editState.mode != FieldEditMode.editTrailManual) {
        return const SizedBox.shrink();
      }
      return _buildEditToolbar(context, ref, isDark, editState, editNotifier);
    }

    // If not in edit mode, show FAB to enter edit mode (admin only)
    if (!editState.isEditing) {
      return _buildEditModeFAB(context, isDark, editNotifier);
    }

    // In edit mode - show toolbar with options
    return _buildEditToolbar(context, ref, isDark, editState, editNotifier);
  }

  /// FAB to activate edit mode
  Widget _buildEditModeFAB(
    BuildContext context,
    bool isDark,
    FieldEditNotifier editNotifier,
  ) {
    return Positioned(
      left: 16,
      bottom: 90,
      child: FloatingActionButton.extended(
        onPressed: () => _showEditModeMenu(context, editNotifier),
        icon: const Icon(Icons.edit_location_alt),
        label: const Text('Field Edit'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  /// Show menu to choose edit mode
  void _showEditModeMenu(BuildContext context, FieldEditNotifier editNotifier) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Field Editing Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: const Text('Move Visit Site'),
              subtitle: const Text('Correct site location'),
              onTap: () {
                Navigator.pop(context);
                _showMoveSiteOptions(context, editNotifier);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_road, color: Colors.purple),
              title: const Text('Edit Trail'),
              subtitle: const Text('Correct trail path'),
              onTap: () {
                Navigator.pop(context);
                _showEditTrailOptions(context, editNotifier);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_location_alt, color: Colors.green),
              title: const Text('Create New Trail'),
              subtitle: const Text('Draw on map or GPS tracking'),
              onTap: () {
                Navigator.pop(context);
                _showCreateTrailOptions(context, editNotifier);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Show options for moving a site
  void _showMoveSiteOptions(BuildContext context, FieldEditNotifier editNotifier) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'How to Move Site?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.open_with, color: Colors.blue),
              title: const Text('Drag on Map'),
              subtitle: const Text('All markers become draggable — drag any to its correct position'),
              onTap: () {
                Navigator.pop(context);
                editNotifier.startMovingSitesDrag();
                _showToast(context, 'Drag any site marker to move it');
              },
            ),
            ListTile(
              leading: const Icon(Icons.my_location, color: Colors.green),
              title: const Text('Use Current GPS Location'),
              subtitle: const Text('Tap a site marker to move it to your current position'),
              onTap: () {
                Navigator.pop(context);
                _showToast(context, 'Tap a site marker to move it to your current location');
                // Mode will be activated when user taps a marker
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Show options for editing a trail
  void _showEditTrailOptions(BuildContext context, FieldEditNotifier editNotifier) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'How to Edit Trail?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.purple),
              title: const Text('Edit on Map'),
              subtitle: const Text('Tap a trail, then add/remove points'),
              onTap: () {
                Navigator.pop(context);
                editNotifier.startSelectingTrailForEdit();
                _showToast(context, 'Tap a trail to start editing');
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_walk, color: Colors.orange),
              title: const Text('Walk & Record GPS'),
              subtitle: const Text('Re-record trail by walking the route'),
              onTap: () {
                Navigator.pop(context);
                _showToast(context, 'Tap a trail, then start walking to re-record');
                // Mode will be activated when user taps a trail
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Show options for creating a new trail
  void _showCreateTrailOptions(BuildContext context, FieldEditNotifier editNotifier) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'How to Create Trail?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.touch_app, color: Colors.blue),
              title: const Text('Draw on Map'),
              subtitle: const Text('Tap map to add points, drag to adjust'),
              onTap: () {
                Navigator.pop(context);
                editNotifier.startCreatingManual();
                _showToast(context, 'Tap on map to add trail points');
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_walk, color: Colors.green),
              title: const Text('Walk & Record GPS'),
              subtitle: const Text('GPS tracking while walking the route'),
              onTap: () {
                Navigator.pop(context);
                editNotifier.startRecordingGPS();
                _showToast(context, '🚶 Start walking - GPS will track your path');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Toolbar when in edit mode
  Widget _buildEditToolbar(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    FieldEditState state,
    FieldEditNotifier editNotifier,
  ) {
    final isTrailMode = state.mode == FieldEditMode.editTrailManual ||
        state.mode == FieldEditMode.createTrailManual ||
        state.mode == FieldEditMode.editTrailGPS ||
        state.mode == FieldEditMode.createTrailGPS;
    final isGpsMode = state.mode == FieldEditMode.createTrailGPS ||
        state.mode == FieldEditMode.editTrailGPS;

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.grey[900] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top row: icon + title + controls + cancel/save ──
              Row(
                children: [
                  Icon(_getModeIcon(state.mode), color: Colors.orange, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getModeTitle(state.mode),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        if (isTrailMode && state.recordingPoints.isNotEmpty)
                          Text(
                            '${state.recordingPoints.length} pts • ${(state.recordedDistance / 1000).toStringAsFixed(2)} km',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // GPS pause/stop controls
                  if (isGpsMode) ...[
                    IconButton(
                      icon: Icon(state.isRecording ? Icons.pause : Icons.play_arrow),
                      onPressed: () => state.isRecording
                          ? editNotifier.pauseRecording()
                          : editNotifier.resumeRecording(),
                      color: Colors.orange,
                      iconSize: 22,
                      tooltip: state.isRecording ? 'Pause' : 'Resume',
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: () {
                        if (state.mode == FieldEditMode.createTrailGPS) {
                          _showSaveRecordingDialog(context, ref, state, editNotifier);
                        } else {
                          _showSaveEditedTrailDialog(context, ref, state, editNotifier);
                        }
                      },
                      color: Colors.green,
                      iconSize: 22,
                      tooltip: 'Stop & Save',
                    ),
                  ],
                  // Edit trail info (name, description, difficulty)
                  if (state.mode == FieldEditMode.editTrailManual &&
                      state.selectedTrailId != null)
                    IconButton(
                      icon: const Icon(Icons.edit_note),
                      onPressed: () => _showEditTrailInfoDialog(
                          context, ref, state.selectedTrailId!),
                      color: Colors.blue,
                      iconSize: 22,
                      tooltip: 'Edit info',
                    ),
                  // Undo
                  if (state.undoStack.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.undo),
                      onPressed: () => editNotifier.undo(),
                      color: Colors.orange,
                      iconSize: 22,
                      tooltip: 'Undo',
                    ),
                  // Cancel
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _confirmCancel(context, state, editNotifier),
                    color: Colors.red,
                    iconSize: 22,
                    tooltip: 'Cancel',
                  ),
                  // Save button visibility:
                  // • editTrailManual → always show when trail is loaded
                  //   (save is harmless if no changes; not showing it is confusing)
                  // • createTrailManual → only when user has added points (hasUnsavedChanges)
                  // • site modes → only after at least one drag saved (hasUnsavedChanges)
                  if ((state.mode == FieldEditMode.editTrailManual &&
                          state.recordingPoints.isNotEmpty) ||
                      ((state.mode == FieldEditMode.moveSiteManual ||
                              state.mode == FieldEditMode.moveSitesDrag ||
                              state.mode == FieldEditMode.moveSiteGPS ||
                              state.mode == FieldEditMode.createTrailManual) &&
                          state.hasUnsavedChanges))
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => _confirmSave(context, ref, state, editNotifier),
                      color: Colors.green,
                      iconSize: 22,
                      tooltip: 'Save',
                    ),
                ],
              ),

              // ── Trail sub-mode toggle row (only for trail modes, not GPS recording) ──
              if (isTrailMode && !isGpsMode && state.recordingPoints.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    _SubModeButton(
                      icon: Icons.grain,
                      label: 'Points',
                      active: state.trailEditSubMode == TrailEditSubMode.points,
                      onTap: () => editNotifier.setTrailEditSubMode(TrailEditSubMode.points),
                    ),
                    const SizedBox(width: 8),
                    _SubModeButton(
                      icon: Icons.open_with,
                      label: 'Move',
                      active: state.trailEditSubMode == TrailEditSubMode.move,
                      onTap: () => editNotifier.setTrailEditSubMode(TrailEditSubMode.move),
                    ),
                    const SizedBox(width: 8),
                    _SubModeButton(
                      icon: Icons.rotate_right,
                      label: 'Rotate',
                      active: state.trailEditSubMode == TrailEditSubMode.rotate,
                      onTap: () => editNotifier.setTrailEditSubMode(TrailEditSubMode.rotate),
                    ),
                    if (state.trailEditSubMode == TrailEditSubMode.points) ...[
                      const Spacer(),
                      if (state.selectedEditPoints.isNotEmpty) ...[
                        // Delete selected points button
                        GestureDetector(
                          onTap: () => editNotifier.removeSelectedPoints(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.delete_outline, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  state.selectedEditPoints.length == 1
                                      ? 'Borrar punto ${state.selectedEditPoints.first + 1}'
                                      : 'Borrar ${state.selectedEditPoints.length} puntos',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Toca punto(s) • arrastrar mueve selección',
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                      ],
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getModeIcon(FieldEditMode mode) {
    switch (mode) {
      case FieldEditMode.moveSitesDrag:
        return Icons.open_with;
      case FieldEditMode.moveSiteManual:
      case FieldEditMode.moveSiteGPS:
        return Icons.location_on;
      case FieldEditMode.selectTrailForEdit:
        return Icons.touch_app;
      case FieldEditMode.editTrailManual:
      case FieldEditMode.editTrailGPS:
        return Icons.edit_road;
      case FieldEditMode.createTrailManual:
      case FieldEditMode.createTrailGPS:
        return Icons.add_location_alt;
      case FieldEditMode.none:
        return Icons.edit_off;
    }
  }

  String _getModeTitle(FieldEditMode mode) {
    switch (mode) {
      case FieldEditMode.moveSitesDrag:
        return 'Moving Sites — drag any marker';
      case FieldEditMode.moveSiteManual:
        return 'Moving Site (Drag)';
      case FieldEditMode.moveSiteGPS:
        return 'Moving Site (GPS)';
      case FieldEditMode.selectTrailForEdit:
        return 'Tap a trail to edit';
      case FieldEditMode.editTrailManual:
        return 'Editing Trail';
      case FieldEditMode.editTrailGPS:
        return 'Recording Trail (GPS)';
      case FieldEditMode.createTrailManual:
        return 'Creating Trail';
      case FieldEditMode.createTrailGPS:
        return 'Recording New Trail (GPS)';
      case FieldEditMode.none:
        return 'Field Edit';
    }
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _confirmCancel(
    BuildContext context,
    FieldEditState state,
    FieldEditNotifier editNotifier,
  ) {
    if (!state.hasUnsavedChanges) {
      editNotifier.cancel();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              editNotifier.cancel();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _confirmSave(
    BuildContext context,
    WidgetRef ref,
    FieldEditState state,
    FieldEditNotifier editNotifier,
  ) {
    // Trail creation: need to collect names first
    if (state.mode == FieldEditMode.createTrailManual) {
      _showSaveRecordingDialog(context, ref, state, editNotifier);
      return;
    }
    // Trail editing: show confirmation + actually save
    if (state.mode == FieldEditMode.editTrailManual) {
      _showSaveEditedTrailDialog(context, ref, state, editNotifier);
      return;
    }
    // Site modes: saves happen immediately on drag end — just exit
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Done Editing?'),
        content: const Text('Site positions have been saved to the server.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Editing'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              editNotifier.exitEditMode();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showSaveRecordingDialog(
    BuildContext context,
    WidgetRef ref,
    FieldEditState state,
    FieldEditNotifier editNotifier,
  ) {
    if (state.recordingPoints.length < 2) {
      _showToast(context, 'Need at least 2 points to save trail');
      return;
    }

    // Pause GPS recording while the dialog is shown
    editNotifier.pauseRecording();

    final nameEnController = TextEditingController();
    final nameEsController = TextEditingController();
    // Capture points snapshot so dialog remains valid after state changes
    final points = List<LatLng>.from(state.recordingPoints);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save New Trail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameEnController,
              decoration: const InputDecoration(
                labelText: 'Trail Name (English)',
                hintText: 'e.g., Tortuga Bay Trail',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameEsController,
              decoration: const InputDecoration(
                labelText: 'Trail Name (Spanish)',
                hintText: 'e.g., Sendero Bahía Tortuga',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Points: ${points.length}\n'
              'Distance: ${(state.recordedDistance / 1000).toStringAsFixed(2)} km\n'
              'Duration: ${state.recordingDuration.inMinutes} min',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              editNotifier.resumeRecording();
            },
            child: const Text('Continue Recording'),
          ),
          FilledButton(
            onPressed: () async {
              final nameEn = nameEnController.text.trim();
              final nameEs = nameEsController.text.trim();
              if (nameEn.isEmpty || nameEs.isEmpty) {
                _showToast(context, 'Please enter trail names in both languages');
                return;
              }

              Navigator.pop(context);

              final service = FieldEditService(ref: ref);
              final trail = await service.createNewTrail(
                nameEn: nameEn,
                nameEs: nameEs,
                coordinates: points,
              );

              if (!context.mounted) return;
              if (trail != null) {
                editNotifier.exitEditMode();
                ref.invalidate(trailsProvider);
                if (trail.id == -1) {
                  _showToast(context, '📤 Ruta guardada sin conexión — se sincronizará luego');
                } else {
                  _showToast(context, '✅ Trail saved');
                }
              } else {
                _showToast(context, '❌ Failed to save trail — check connection');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditTrailInfoDialog(
    BuildContext context,
    WidgetRef ref,
    int trailId,
  ) async {
    // Load current trail data
    final service = FieldEditService(ref: ref);
    final trail = await service.getTrail(trailId);
    if (!context.mounted || trail == null) return;

    final nameEsCtrl = TextEditingController(text: trail.nameEs);
    final nameEnCtrl = TextEditingController(text: trail.nameEn);
    final descEsCtrl = TextEditingController(text: trail.descriptionEs ?? '');
    final descEnCtrl = TextEditingController(text: trail.descriptionEn ?? '');
    final minutesCtrl = TextEditingController(
        text: trail.estimatedMinutes?.toString() ?? '');
    String? difficulty = trail.difficulty;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Editar información del sendero'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameEsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre (ES) *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameEnCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre (EN)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descEsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (ES)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descEnCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (EN)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: difficulty,
                  decoration: const InputDecoration(
                    labelText: 'Dificultad',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'easy',     child: Text('Fácil')),
                    DropdownMenuItem(value: 'moderate', child: Text('Moderado')),
                    DropdownMenuItem(value: 'hard',     child: Text('Difícil')),
                  ],
                  onChanged: (v) => setDialogState(() => difficulty = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: minutesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tiempo estimado (minutos)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final nameEs = nameEsCtrl.text.trim();
                if (nameEs.isEmpty) return;
                Navigator.pop(ctx);
                final ok = await service.updateTrailMetadata(
                  trailId: trailId,
                  nameEn: nameEnCtrl.text.trim().isEmpty
                      ? nameEs
                      : nameEnCtrl.text.trim(),
                  nameEs: nameEs,
                  descriptionEs: descEsCtrl.text.trim().isEmpty
                      ? null
                      : descEsCtrl.text.trim(),
                  descriptionEn: descEnCtrl.text.trim().isEmpty
                      ? null
                      : descEnCtrl.text.trim(),
                  difficulty: difficulty,
                  estimatedMinutes: int.tryParse(minutesCtrl.text.trim()),
                );
                if (!context.mounted) return;
                ref.invalidate(trailsProvider);
                _showToast(
                  context,
                  ok ? '✅ Sendero actualizado' : '❌ Error al guardar',
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    nameEsCtrl.dispose();
    nameEnCtrl.dispose();
    descEsCtrl.dispose();
    descEnCtrl.dispose();
    minutesCtrl.dispose();
  }

  void _showSaveEditedTrailDialog(
    BuildContext context,
    WidgetRef ref,
    FieldEditState state,
    FieldEditNotifier editNotifier,
  ) {
    if (state.recordingPoints.length < 2) {
      _showToast(context, 'Need at least 2 points to save trail');
      return;
    }

    // Pause GPS recording while the dialog is shown
    editNotifier.pauseRecording();

    final trailId = state.selectedTrailId;
    // Capture points snapshot so dialog remains valid after state changes
    final points = List<LatLng>.from(state.recordingPoints);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Trail Changes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This will replace the existing trail path with the edited coordinates.',
            ),
            const SizedBox(height: 16),
            Text(
              'Points: ${points.length}\n'
              'Distance: ${(state.recordedDistance / 1000).toStringAsFixed(2)} km',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              editNotifier.resumeRecording();
            },
            child: const Text('Continue Editing'),
          ),
          FilledButton(
            onPressed: () async {
              if (trailId == null) {
                _showToast(context, '❌ No trail selected');
                return;
              }

              Navigator.pop(context);

              final service = FieldEditService(ref: ref);
              final updated = await service.updateTrailCoordinates(
                trailId: trailId,
                newCoordinates: points,
              );

              if (!context.mounted) return;
              if (updated != null) {
                editNotifier.exitEditMode();
                ref.invalidate(trailsProvider);
                _showToast(context, '✅ Trail updated');
              } else {
                _showToast(context, '❌ Failed to update trail — check connection');
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

// ── Sub-mode toggle button ────────────────────────────────────────────────────

class _SubModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SubModeButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.deepOrange : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active ? Colors.deepOrange : Colors.grey.shade400,
            width: active ? 0 : 1,
          ),
          boxShadow: active
              ? [BoxShadow(color: Colors.deepOrange.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: active ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
