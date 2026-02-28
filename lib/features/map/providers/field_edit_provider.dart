import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:latlong2/latlong.dart';

/// GPS recording profile — determines distance filter, iOS activity type hint
/// and RDP simplification tolerance when saving the track.
enum TrackingProfile {
  walking,
  cycling,
  boat,
  vehicle;

  String get labelEn => switch (this) {
    TrackingProfile.walking  => 'Walking / Hiking',
    TrackingProfile.cycling  => 'Cycling',
    TrackingProfile.boat     => 'Boat / Kayak',
    TrackingProfile.vehicle  => 'Vehicle',
  };

  IconData get icon => switch (this) {
    TrackingProfile.walking  => Icons.directions_walk,
    TrackingProfile.cycling  => Icons.directions_bike,
    TrackingProfile.boat     => Icons.directions_boat,
    TrackingProfile.vehicle  => Icons.directions_car,
  };

  /// Minimum movement (meters) before a new GPS point is recorded.
  int get distanceFilterMeters => switch (this) {
    TrackingProfile.walking  => 8,
    TrackingProfile.cycling  => 15,
    TrackingProfile.boat     => 20,
    TrackingProfile.vehicle  => 30,
  };

  /// Ramer-Douglas-Peucker tolerance (meters) applied when saving the track.
  double get rdpToleranceMeters => switch (this) {
    TrackingProfile.walking  => 5,
    TrackingProfile.cycling  => 10,
    TrackingProfile.boat     => 15,
    TrackingProfile.vehicle  => 20,
  };

  /// Approximate expected speed label shown in UI.
  String get speedHint => switch (this) {
    TrackingProfile.walking  => '3-5 km/h',
    TrackingProfile.cycling  => '15-25 km/h',
    TrackingProfile.boat     => '10-25 km/h',
    TrackingProfile.vehicle  => '40-80 km/h',
  };
}

/// Types of field editing operations
enum FieldEditMode {
  none,               // Not editing
  moveSitesDrag,      // All site markers are immediately draggable
  moveSiteManual,     // Moving a single visit site marker by dragging
  moveSiteGPS,        // Moving a visit site to current GPS location
  selectTrailForEdit, // Waiting for user to tap a trail to edit
  editTrailManual,    // Editing trail (drag points / move / rotate)
  editTrailGPS,       // Re-recording trail with GPS tracking
  createTrailManual,  // Creating new trail manually (tap map to add points)
  createTrailGPS,     // Creating new trail with GPS tracking
}

/// Sub-mode for trail editing — selected via toolbar toggle
enum TrailEditSubMode {
  points, // Drag individual trail points; tap map to add new ones
  move,   // Drag centroid handle to translate entire trail
  rotate, // Drag rotation handle to rotate trail around centroid
}

/// State for field editing operations
class FieldEditState {
  final FieldEditMode mode;
  final int? selectedSiteId;
  final int? selectedTrailId;
  final List<LatLng> recordingPoints;
  final bool isRecording;
  final DateTime? recordingStartTime;
  final bool hasUnsavedChanges;
  final TrackingProfile trackingProfile;
  final TrailEditSubMode trailEditSubMode;
  /// Points currently selected in Points sub-mode (tap to select, supports multi-select).
  final Set<int> selectedEditPoints;
  /// Undo stack: each entry is a snapshot of recordingPoints before a change.
  final List<List<LatLng>> undoStack;

  const FieldEditState({
    this.mode = FieldEditMode.none,
    this.selectedSiteId,
    this.selectedTrailId,
    this.recordingPoints = const [],
    this.isRecording = false,
    this.recordingStartTime,
    this.hasUnsavedChanges = false,
    this.trackingProfile = TrackingProfile.walking,
    this.trailEditSubMode = TrailEditSubMode.points,
    this.selectedEditPoints = const {},
    this.undoStack = const [],
  });

  FieldEditState copyWith({
    FieldEditMode? mode,
    int? selectedSiteId,
    int? selectedTrailId,
    List<LatLng>? recordingPoints,
    bool? isRecording,
    DateTime? recordingStartTime,
    bool? hasUnsavedChanges,
    TrackingProfile? trackingProfile,
    TrailEditSubMode? trailEditSubMode,
    Set<int>? selectedEditPoints,
    bool clearSelectedEditPoints = false,
    List<List<LatLng>>? undoStack,
  }) {
    return FieldEditState(
      mode: mode ?? this.mode,
      selectedSiteId: selectedSiteId ?? this.selectedSiteId,
      selectedTrailId: selectedTrailId ?? this.selectedTrailId,
      recordingPoints: recordingPoints ?? this.recordingPoints,
      isRecording: isRecording ?? this.isRecording,
      recordingStartTime: recordingStartTime ?? this.recordingStartTime,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      trackingProfile: trackingProfile ?? this.trackingProfile,
      trailEditSubMode: trailEditSubMode ?? this.trailEditSubMode,
      selectedEditPoints: clearSelectedEditPoints
          ? {}
          : (selectedEditPoints ?? this.selectedEditPoints),
      undoStack: undoStack ?? this.undoStack,
    );
  }

  bool get isEditing => mode != FieldEditMode.none;

  /// Total distance of recorded trail in meters
  double get recordedDistance {
    if (recordingPoints.length < 2) return 0;

    final distance = Distance();
    double totalMeters = 0;

    for (int i = 0; i < recordingPoints.length - 1; i++) {
      totalMeters += distance.distance(recordingPoints[i], recordingPoints[i + 1]);
    }

    return totalMeters;
  }

  /// Duration of recording session
  Duration get recordingDuration {
    if (recordingStartTime == null) return Duration.zero;
    return DateTime.now().difference(recordingStartTime!);
  }
}

/// Provider for field editing state
class FieldEditNotifier extends StateNotifier<FieldEditState> {
  FieldEditNotifier() : super(const FieldEditState());

  /// Activate "Move Sites Drag" mode — all site markers are immediately draggable
  void startMovingSitesDrag() {
    state = state.copyWith(
      mode: FieldEditMode.moveSitesDrag,
      selectedSiteId: null,
      selectedTrailId: null,
    );
  }

  /// Activate "Move Site Manually" mode (drag a single pre-selected marker)
  void startMovingSiteManual(int siteId) {
    state = state.copyWith(
      mode: FieldEditMode.moveSiteManual,
      selectedSiteId: siteId,
      selectedTrailId: null,
    );
  }

  /// Activate "Move Site to GPS" mode (use current location)
  void startMovingSiteGPS(int siteId) {
    state = state.copyWith(
      mode: FieldEditMode.moveSiteGPS,
      selectedSiteId: siteId,
      selectedTrailId: null,
    );
  }

  /// Activate "Select Trail for Edit" mode — waiting for user to tap a trail
  void startSelectingTrailForEdit() {
    state = state.copyWith(
      mode: FieldEditMode.selectTrailForEdit,
      selectedTrailId: null,
      selectedSiteId: null,
      recordingPoints: [],
    );
  }

  /// Activate "Edit Trail Manually" mode (tap map to add points)
  void startEditingTrailManual(int trailId) {
    state = state.copyWith(
      mode: FieldEditMode.editTrailManual,
      selectedTrailId: trailId,
      selectedSiteId: null,
    );
  }

  /// Activate "Edit Trail with GPS" mode (re-record by walking)
  void startEditingTrailGPS(int trailId) {
    state = state.copyWith(
      mode: FieldEditMode.editTrailGPS,
      selectedTrailId: trailId,
      isRecording: true,
      recordingStartTime: DateTime.now(),
      recordingPoints: [], // Will be populated as user walks
      selectedSiteId: null,
    );
  }

  /// Change the GPS tracking profile (can be set before or after starting).
  void setTrackingProfile(TrackingProfile profile) {
    state = state.copyWith(trackingProfile: profile);
  }

  /// Start GPS recording for new trail
  void startRecordingGPS() {
    state = state.copyWith(
      mode: FieldEditMode.createTrailGPS,
      isRecording: true,
      recordingStartTime: DateTime.now(),
      recordingPoints: [],
      selectedSiteId: null,
      selectedTrailId: null,
    );
  }

  /// Start manual creation of new trail (tap map to add points)
  void startCreatingManual() {
    state = state.copyWith(
      mode: FieldEditMode.createTrailManual,
      isRecording: false,
      recordingPoints: [],
      selectedSiteId: null,
      selectedTrailId: null,
    );
  }

  /// Switch the trail-edit sub-mode (points / move / rotate)
  void setTrailEditSubMode(TrailEditSubMode subMode) {
    state = state.copyWith(trailEditSubMode: subMode, clearSelectedEditPoints: true);
  }

  // ── Selection ──────────────────────────────────────────────────────────────

  /// Toggle a point's membership in the selection set.
  void selectEditPoint(int index) {
    final newSet = Set<int>.from(state.selectedEditPoints);
    if (newSet.contains(index)) {
      newSet.remove(index);
    } else {
      newSet.add(index);
    }
    state = state.copyWith(selectedEditPoints: newSet);
  }

  /// Clear all selected points.
  void clearSelection() {
    if (state.selectedEditPoints.isEmpty) return;
    state = state.copyWith(clearSelectedEditPoints: true);
  }

  /// Delete all currently selected points (keeps at least 2).
  void removeSelectedPoints() {
    if (state.selectedEditPoints.isEmpty) return;
    final current = List<LatLng>.from(state.recordingPoints);
    final sorted = state.selectedEditPoints.toList()..sort((a, b) => b.compareTo(a));
    for (final idx in sorted) {
      if (idx >= 0 && idx < current.length && current.length > 2) {
        current.removeAt(idx);
      }
    }
    state = state.copyWith(
      recordingPoints: current,
      hasUnsavedChanges: true,
      clearSelectedEditPoints: true,
    );
  }

  // ── Undo ───────────────────────────────────────────────────────────────────

  /// Save the current points to the undo stack before a modification.
  void pushUndoState() {
    final stack = [...state.undoStack, List<LatLng>.from(state.recordingPoints)];
    if (stack.length > 20) stack.removeAt(0); // cap at 20 entries
    state = state.copyWith(undoStack: stack);
  }

  /// Restore the previous points state.
  void undo() {
    if (state.undoStack.isEmpty) return;
    final stack = [...state.undoStack];
    final previous = stack.removeLast();
    state = state.copyWith(
      recordingPoints: previous,
      undoStack: stack,
      clearSelectedEditPoints: true,
      hasUnsavedChanges: stack.isNotEmpty,
    );
  }

  /// Replace a single recording point (used when dragging an individual point)
  void updateRecordingPoint(int index, LatLng newPoint) {
    if (index < 0 || index >= state.recordingPoints.length) return;
    final updated = [...state.recordingPoints];
    updated[index] = newPoint;
    state = state.copyWith(recordingPoints: updated, hasUnsavedChanges: true);
  }

  /// Replace the entire recording points list (used during move / rotate drags)
  void setRecordingPoints(List<LatLng> points) {
    state = state.copyWith(recordingPoints: points, hasUnsavedChanges: true);
  }

  /// Translate all recording points by [dLat, dLng] starting from [basePoints]
  void translatePoints(List<LatLng> basePoints, double dLat, double dLng) {
    final updated = basePoints
        .map((p) => LatLng(p.latitude + dLat, p.longitude + dLng))
        .toList();
    state = state.copyWith(recordingPoints: updated, hasUnsavedChanges: true);
  }

  /// Rotate all recording points around [centroid] by [angleRad] radians,
  /// starting from [basePoints] (so each call is idempotent given the same base).
  void rotatePoints(List<LatLng> basePoints, LatLng centroid, double angleRad) {
    final cos = math.cos(angleRad);
    final sin = math.sin(angleRad);
    final updated = basePoints.map((p) {
      final dx = p.longitude - centroid.longitude;
      final dy = p.latitude - centroid.latitude;
      return LatLng(
        centroid.latitude + dy * cos - dx * sin,
        centroid.longitude + dx * cos + dy * sin,
      );
    }).toList();
    state = state.copyWith(recordingPoints: updated, hasUnsavedChanges: true);
  }

  /// Add point to recording (GPS or manual tap)
  void addRecordingPoint(LatLng point) {
    // Allow in manual tap modes OR when GPS recording is active
    final isManualMode = state.mode == FieldEditMode.createTrailManual ||
        state.mode == FieldEditMode.editTrailManual;
    if (!state.isRecording && !isManualMode) return;

    final updated = [...state.recordingPoints, point];
    state = state.copyWith(
      recordingPoints: updated,
      hasUnsavedChanges: true,
    );
  }

  /// Pause GPS recording
  void pauseRecording() {
    state = state.copyWith(isRecording: false);
  }

  /// Resume GPS recording
  void resumeRecording() {
    if (state.mode != FieldEditMode.createTrailGPS &&
        state.mode != FieldEditMode.editTrailGPS) return;
    state = state.copyWith(isRecording: true);
  }

  /// Load initial points without marking as unsaved.
  /// Use this when loading an existing trail for editing so the save button
  /// does not appear until the user actually modifies something.
  void loadPoints(List<LatLng> points) {
    state = state.copyWith(recordingPoints: points, hasUnsavedChanges: false);
  }

  /// Mark that changes were made
  void markUnsaved() {
    state = state.copyWith(hasUnsavedChanges: true);
  }

  /// Clear unsaved changes flag (after successful save)
  void clearUnsaved() {
    state = state.copyWith(hasUnsavedChanges: false);
  }

  /// Cancel editing and reset state
  void cancel() {
    state = const FieldEditState();
  }

  /// Exit edit mode after saving
  void exitEditMode() {
    state = const FieldEditState();
  }
}

/// Global provider instance
final fieldEditProvider = StateNotifierProvider<FieldEditNotifier, FieldEditState>((ref) {
  return FieldEditNotifier();
});
