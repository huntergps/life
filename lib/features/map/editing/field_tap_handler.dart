import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../providers/field_edit_provider.dart';
import '../services/field_edit_service.dart';
import '../utils/route_utils.dart';
import '../layers/field_editing_layer.dart';

/// Handles map tap events during field editing and trail loading.
///
/// Extracted from [_MapScreenState] to reduce the size of map_screen.dart.
class FieldTapHandler {
  FieldTapHandler({
    required this.ref,
    required this.fieldEditBuilder,
    required this.showSnackBar,
    required this.onResetRotateHandle,
  });

  final WidgetRef ref;
  final FieldEditingLayerBuilder fieldEditBuilder;
  final void Function(String) showSnackBar;
  final VoidCallback onResetRotateHandle;

  /// Handles a tap on the map surface during trail point editing.
  void handleMapTap(LatLng point) {
    final editState = ref.read(fieldEditProvider);
    if ((editState.mode == FieldEditMode.createTrailManual ||
            editState.mode == FieldEditMode.editTrailManual) &&
        editState.trailEditSubMode == TrailEditSubMode.points) {
      final notifier = ref.read(fieldEditProvider.notifier);
      notifier.clearSelection();
      notifier.pushUndoState();
      final pts = editState.recordingPoints;

      if (pts.length < 2) {
        notifier.addRecordingPoint(point);
      } else {
        final result = distanceToPolyline(point, pts);
        final atStart = haversineDistance(result.nearest, pts.first) < 1.0;
        final atEnd   = haversineDistance(result.nearest, pts.last)  < 1.0;

        final int insertIdx;
        if (atEnd) {
          insertIdx = pts.length;
        } else if (atStart) {
          insertIdx = 0;
        } else {
          insertIdx = result.segmentIndex + 1;
        }

        final newPts = List<LatLng>.from(pts)..insert(insertIdx, point);
        notifier.setRecordingPoints(newPts);
      }
      notifier.markUnsaved();
    }
  }

  /// Loads a trail by [trailId] into the field editor for manual editing.
  Future<void> loadTrailForEditing(int trailId) async {
    showSnackBar('Loading trail...');
    onResetRotateHandle();
    try {
      final service = FieldEditService(ref: ref);
      final trail = await service.getTrail(trailId);
      if (trail == null) { showSnackBar('Trail not found (id $trailId)'); return; }
      final coords = parseTrailCoordinates(trail.coordinates);
      if (coords.isEmpty) { showSnackBar('Trail has no coordinates'); return; }
      final editNotifier = ref.read(fieldEditProvider.notifier);
      editNotifier.startEditingTrailManual(trailId);
      editNotifier.loadPoints(coords);
      showSnackBar('Trail loaded -- use Points / Move / Rotate to edit');
    } catch (e) {
      showSnackBar('Error loading trail: $e');
    }
  }
}
