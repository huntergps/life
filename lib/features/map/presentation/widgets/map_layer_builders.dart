import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:galapagos_wildlife/brick/models/trail.model.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import '../../providers/field_edit_provider.dart';
import '../../utils/route_utils.dart';

// ---------------------------------------------------------------------------
// Difficulty colour / label helpers (shared by trail layers)
// ---------------------------------------------------------------------------

Color trailDifficultyColor(String? difficulty) {
  switch (difficulty?.toLowerCase()) {
    case 'easy':
      return Colors.green;
    case 'moderate':
      return Colors.orange;
    case 'hard':
      return Colors.red;
    default:
      return Colors.green;
  }
}

String trailDifficultyLabel(BuildContext context, String? difficulty) {
  switch (difficulty?.toLowerCase()) {
    case 'easy':
      return context.t.map.difficultyEasy;
    case 'moderate':
      return context.t.map.difficultyModerate;
    case 'hard':
      return context.t.map.difficultyHard;
    default:
      return context.t.map.difficultyEasy;
  }
}

// ---------------------------------------------------------------------------
// MapLayerBuilders — static helpers for building flutter_map layers.
//
// These are pure / near-pure functions that transform data into
// flutter_map Widget layers (MarkerLayer, PolylineLayer, etc.).
// They accept all state they need as parameters so they can live outside
// the _MapScreenState class.
// ---------------------------------------------------------------------------

class MapLayerBuilders {
  MapLayerBuilders._(); // prevent instantiation

  // -------------------------------------------------------------------------
  // Trail polylines layer
  // -------------------------------------------------------------------------

  /// Builds a [PolylineLayer] for all trails.
  ///
  /// [editingTrailId] and [isEditing] are forwarded from the field-edit
  /// provider so the currently-edited trail is hidden (its live orange
  /// overlay is rendered by the field-edit layer instead).
  static Widget buildTrailPolylinesLayer({
    required AsyncValue<List<Trail>> trailsAsync,
    required int? editingTrailId,
    required bool isEditing,
  }) {
    return trailsAsync.when(
      data: (trails) {
        final polylines = <Polyline>[];
        for (final trail in trails) {
          // Skip the trail that is currently being edited
          if (isEditing && trail.id == editingTrailId) {
            continue;
          }

          final coords = parseTrailCoordinates(trail.coordinates);
          if (coords.length < 2) continue;

          polylines.add(
            Polyline(
              points: coords,
              color: trailDifficultyColor(trail.difficulty),
              strokeWidth: 4,
              borderColor: Colors.white,
              borderStrokeWidth: 1,
            ),
          );
        }
        return PolylineLayer(polylines: polylines);
      },
      loading: () => PolylineLayer(polylines: <Polyline>[]),
      error: (_, _) => PolylineLayer(polylines: <Polyline>[]),
    );
  }

  // -------------------------------------------------------------------------
  // Trail midpoint markers layer
  // -------------------------------------------------------------------------

  /// Builds small circular [MarkerLayer] at each trail's midpoint.
  ///
  /// In normal mode tapping opens the trail info sheet ([onShowTrailInfo]).
  /// In [isSelectingForEdit] mode the markers turn orange and tapping
  /// triggers [onSelectTrailForEdit] instead.
  static Widget buildTrailMarkers({
    required BuildContext context,
    required AsyncValue<List<Trail>> trailsAsync,
    required bool isEs,
    required bool isSelectingForEdit,
    required void Function(Trail trail) onShowTrailInfo,
    required void Function(int trailId) onSelectTrailForEdit,
  }) {
    return trailsAsync.when(
      data: (trails) {
        final markers = <Marker>[];
        for (final trail in trails) {
          final coords = parseTrailCoordinates(trail.coordinates);
          if (coords.length < 2) continue;

          final midPoint = coords[coords.length ~/ 2];
          final trailName = isEs ? trail.nameEs : trail.nameEn;
          // Highlight markers orange when in selection mode
          final color = isSelectingForEdit
              ? Colors.orange
              : trailDifficultyColor(trail.difficulty);

          // Larger tap target and pulsing shadow in selection mode
          final markerSize = isSelectingForEdit ? 48.0 : 36.0;
          final iconSize = isSelectingForEdit ? 24.0 : 18.0;
          markers.add(
            Marker(
              point: midPoint,
              width: markerSize,
              height: markerSize,
              child: Semantics(
                button: true,
                label: context.t.map.trailLabel(name: trailName),
                child: GestureDetector(
                  onTap: () {
                    if (isSelectingForEdit) {
                      onSelectTrailForEdit(trail.id);
                    } else {
                      onShowTrailInfo(trail);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: isSelectingForEdit ? 3 : 2,
                      ),
                      boxShadow: isSelectingForEdit
                          ? [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.6),
                                blurRadius: 12,
                                spreadRadius: 3,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isSelectingForEdit ? Icons.edit : Icons.route,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return MarkerLayer(markers: markers);
      },
      loading: () => const MarkerLayer(markers: []),
      error: (_, _) => const MarkerLayer(markers: []),
    );
  }

  // -------------------------------------------------------------------------
  // Sightings layer
  // -------------------------------------------------------------------------

  /// Builds a [MarkerLayer] for wildlife sightings.
  ///
  /// [isWithinViewport] should be the caller's viewport-culling function.
  /// [onSightingTap] is called when the user taps a sighting marker.
  static Widget buildSightingsLayer({
    required BuildContext context,
    required bool isEs,
    required AsyncValue<dynamic> sightingsAsync,
    required AsyncValue<dynamic> speciesLookupAsync,
    required bool Function(double? lat, double? lng) isWithinViewport,
    required void Function(dynamic sighting, dynamic species) onSightingTap,
  }) {
    final speciesMap =
        speciesLookupAsync.asData?.value as Map<int, dynamic>?;
    return sightingsAsync.when(
      data: (sightings) => MarkerLayer(
        markers: (sightings as List)
            .where((s) => s.latitude != null && s.longitude != null)
            .where((s) => isWithinViewport(s.latitude as double?, s.longitude as double?))
            .map((sighting) {
              final species = speciesMap?[sighting.speciesId];
              final speciesName = species != null
                  ? (isEs ? species.commonNameEs : species.commonNameEn)
                  : '?';
              return Marker(
                point: LatLng(
                  (sighting.latitude as num).toDouble(),
                  (sighting.longitude as num).toDouble(),
                ),
                width: 30,
                height: 30,
                child: Semantics(
                  button: true,
                  label: context.t.map.sightingLabel(species: speciesName),
                  child: GestureDetector(
                    onTap: () => onSightingTap(sighting, species),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withValues(alpha: 0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList()
            .cast<Marker>(),
      ),
      loading: () => const MarkerLayer(markers: []),
      error: (_, _) => const MarkerLayer(markers: []),
    );
  }
}

// ---------------------------------------------------------------------------
// Extension on WidgetRef to extract field-edit values needed by layer builders
// ---------------------------------------------------------------------------

extension MapLayerBuildersRef on WidgetRef {
  /// Reads the trail ID currently being edited from [fieldEditProvider].
  int? get editingTrailId =>
      watch(fieldEditProvider.select((s) => s.selectedTrailId));

  /// Whether the map is currently in manual trail-edit mode.
  bool get isEditingTrailManual => watch(
      fieldEditProvider.select((s) => s.mode == FieldEditMode.editTrailManual));

  /// Whether the map is in "select trail for edit" mode.
  bool get isSelectingTrailForEdit => watch(
      fieldEditProvider.select((s) => s.mode == FieldEditMode.selectTrailForEdit));
}
