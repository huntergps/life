import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../providers/field_edit_provider.dart';

/// Builds the field editing layer (trail creation/editing with Points/Move/Rotate).
///
/// This is a stateful helper that needs mutable drag state. The parent
/// [_MapScreenState] passes the required state holders as parameters.
class FieldEditingLayerBuilder {
  /// Snapshot of points taken at drag start.
  List<LatLng>? preDragPoints;
  /// Centroid (move) or handle initial pos (rotate).
  LatLng? dragOrigin;
  /// Centroid used as rotation pivot.
  LatLng? rotateCentroid;
  /// Current position of the rotate handle.
  LatLng? rotateHandlePos;

  Widget build(WidgetRef ref) {
    final editState = ref.watch(fieldEditProvider);

    if (editState.mode != FieldEditMode.createTrailManual &&
        editState.mode != FieldEditMode.createTrailGPS &&
        editState.mode != FieldEditMode.editTrailManual &&
        editState.mode != FieldEditMode.editTrailGPS) {
      return const SizedBox.shrink();
    }

    final points = editState.recordingPoints;
    if (points.isEmpty) return const SizedBox.shrink();

    final polyline = PolylineLayer(polylines: [
      Polyline(
        points: points,
        color: Colors.orange,
        strokeWidth: 4.0,
        borderColor: Colors.white,
        borderStrokeWidth: 1.0,
      ),
    ]);

    switch (editState.trailEditSubMode) {
      case TrailEditSubMode.points:
        return Stack(children: [polyline, _buildDraggableTrailPoints(ref, points)]);
      case TrailEditSubMode.move:
        return Stack(children: [polyline, _buildTrailMoveHandle(ref, points)]);
      case TrailEditSubMode.rotate:
        return Stack(children: [polyline, _buildTrailRotateHandles(ref, points)]);
    }
  }

  /// Sub-mode Points: every trail point is a DragMarker.
  Widget _buildDraggableTrailPoints(WidgetRef ref, List<LatLng> points) {
    final notifier = ref.read(fieldEditProvider.notifier);
    final selectedSet = ref.watch(
        fieldEditProvider.select((s) => s.selectedEditPoints));
    final dragMarkers = List.generate(points.length, (i) {
      final isFirst = i == 0;
      final isLast = i == points.length - 1;
      final isSelected = selectedSet.contains(i);
      final baseColor = isFirst ? Colors.green : (isLast ? Colors.red : Colors.orange);
      return DragMarker(
        point: points[i],
        size: const Size(36, 36),
        builder: (context, latLng, isDragging) => Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue.shade600
                : (isDragging ? baseColor.withValues(alpha: 0.7) : baseColor),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.blue.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)]
                : isDragging
                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8)]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 3)],
          ),
          child: Center(
            child: Text(
              '${i + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        onTap: (_) => notifier.selectEditPoint(i),
        onDragStart: (details, latLng) {
          preDragPoints = [...ref.read(fieldEditProvider).recordingPoints];
          notifier.pushUndoState();
        },
        onDragEnd: (details, latLng) {
          final preDrag = preDragPoints;
          preDragPoints = null;
          if (preDrag == null || i >= preDrag.length) return;

          final sel = ref.read(fieldEditProvider).selectedEditPoints;
          if (sel.length > 1 && sel.contains(i)) {
            final deltaLat = latLng.latitude  - preDrag[i].latitude;
            final deltaLng = latLng.longitude - preDrag[i].longitude;
            final updated = List<LatLng>.from(preDrag);
            for (final idx in sel) {
              if (idx < updated.length) {
                updated[idx] = LatLng(
                  updated[idx].latitude  + deltaLat,
                  updated[idx].longitude + deltaLng,
                );
              }
            }
            notifier.setRecordingPoints(updated);
          } else {
            notifier.updateRecordingPoint(i, latLng);
          }
        },
        onLongPress: (_) {
          notifier.pushUndoState();
          final current = List<LatLng>.from(
            ref.read(fieldEditProvider).recordingPoints,
          );
          if (i >= 0 && i < current.length && current.length > 2) {
            current.removeAt(i);
            notifier.setRecordingPoints(current);
          }
          notifier.clearSelection();
        },
      );
    });
    return DragMarkers(markers: dragMarkers);
  }

  /// Sub-mode Move: a single handle at the centroid translates the entire trail.
  Widget _buildTrailMoveHandle(WidgetRef ref, List<LatLng> points) {
    final centroid = _computeCentroid(points);
    final notifier = ref.read(fieldEditProvider.notifier);

    return DragMarkers(markers: [
      DragMarker(
        point: centroid,
        size: const Size(64, 64),
        builder: (context, latLng, isDragging) => Container(
          decoration: BoxDecoration(
            color: isDragging ? Colors.blue.shade800 : Colors.blue.shade600,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: isDragging ? 0.6 : 0.3),
                blurRadius: isDragging ? 20 : 10,
                spreadRadius: isDragging ? 6 : 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.open_with, color: Colors.white, size: isDragging ? 26 : 24),
              Text(
                'MOVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDragging ? 8 : 7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        onDragStart: (details, latLng) {
          preDragPoints = [...ref.read(fieldEditProvider).recordingPoints];
          dragOrigin = latLng;
        },
        onDragUpdate: (details, latLng) {
          final base = preDragPoints;
          final origin = dragOrigin;
          if (base == null || origin == null) return;
          notifier.translatePoints(base, latLng.latitude - origin.latitude,
              latLng.longitude - origin.longitude);
        },
        onDragEnd: (details, latLng) {
          final base = preDragPoints;
          final origin = dragOrigin;
          if (base != null && origin != null) {
            notifier.translatePoints(base, latLng.latitude - origin.latitude,
                latLng.longitude - origin.longitude);
          }
          preDragPoints = null;
          dragOrigin = null;
        },
      ),
    ]);
  }

  /// Sub-mode Rotate: centroid anchor + draggable rotation handle.
  Widget _buildTrailRotateHandles(WidgetRef ref, List<LatLng> points) {
    final centroid = _computeCentroid(points);
    final notifier = ref.read(fieldEditProvider.notifier);

    double maxDist = 0;
    for (final p in points) {
      final d = math.sqrt(math.pow(p.latitude - centroid.latitude, 2) +
          math.pow(p.longitude - centroid.longitude, 2));
      if (d > maxDist) maxDist = d;
    }
    final handleDist = math.max(maxDist * 1.5, 0.004);
    final handleInitial = LatLng(centroid.latitude, centroid.longitude + handleDist);
    final handlePoint = rotateHandlePos ?? handleInitial;

    return Stack(
      children: [
        // Arm line from centroid to handle
        PolylineLayer(polylines: [
          Polyline(
            points: [centroid, handlePoint],
            color: Colors.purple.withValues(alpha: 0.7),
            strokeWidth: 2.0,
          ),
        ]),
        // Static centroid anchor
        MarkerLayer(markers: [
          Marker(
            point: centroid,
            width: 32,
            height: 32,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade700,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.my_location, color: Colors.white, size: 16),
            ),
          ),
        ]),
        // Rotation handle (draggable)
        DragMarkers(markers: [
          DragMarker(
            point: handlePoint,
            size: const Size(56, 56),
            builder: (context, latLng, isDragging) => Container(
              decoration: BoxDecoration(
                color: isDragging
                    ? Colors.deepPurple.shade700
                    : Colors.purple.shade500,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: isDragging ? 0.6 : 0.3),
                    blurRadius: isDragging ? 20 : 10,
                    spreadRadius: isDragging ? 6 : 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rotate_right, color: Colors.white, size: isDragging ? 22 : 20),
                  Text(
                    'ROTATE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDragging ? 7 : 6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            onDragStart: (details, latLng) {
              preDragPoints = [...ref.read(fieldEditProvider).recordingPoints];
              dragOrigin    = latLng;
              rotateCentroid = _computeCentroid(preDragPoints!);
              rotateHandlePos = latLng;
            },
            onDragUpdate: (details, latLng) {
              rotateHandlePos = latLng;
              final base   = preDragPoints;
              final origin = dragOrigin;
              final pivot  = rotateCentroid;
              if (base == null || origin == null || pivot == null) return;
              final angle = _angleBetween(pivot, origin, latLng);
              notifier.rotatePoints(base, pivot, angle);
            },
            onDragEnd: (details, latLng) {
              rotateHandlePos = latLng;
              final base   = preDragPoints;
              final origin = dragOrigin;
              final pivot  = rotateCentroid;
              if (base != null && origin != null && pivot != null) {
                final angle = _angleBetween(pivot, origin, latLng);
                notifier.rotatePoints(base, pivot, angle);
              }
              preDragPoints  = null;
              dragOrigin     = null;
              rotateCentroid = null;
            },
          ),
        ]),
      ],
    );
  }

  // ─── Geometry helpers ──────────────────────────────────────────────────

  LatLng _computeCentroid(List<LatLng> points) {
    final lat = points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final lng = points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
    return LatLng(lat, lng);
  }

  double _angleBetween(LatLng pivot, LatLng from, LatLng to) {
    final a1 = math.atan2(from.latitude - pivot.latitude, from.longitude - pivot.longitude);
    final a2 = math.atan2(to.latitude - pivot.latitude, to.longitude - pivot.longitude);
    return a2 - a1;
  }
}
