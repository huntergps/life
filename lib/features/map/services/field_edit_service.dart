import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../brick/models/trail.model.dart';
import '../../../brick/models/visit_site.model.dart';
import '../../../brick/repository.dart';
import 'site_edit_service.dart';
import 'trail_edit_service.dart';

export 'site_edit_service.dart' show SiteEditService;
export 'trail_edit_service.dart' show TrailEditService;

/// Thin facade that composes [SiteEditService] and [TrailEditService].
/// Existing callers continue to work without changes.
class FieldEditService {
  final SiteEditService site;
  final TrailEditService trail;

  FieldEditService({Repository? repository, WidgetRef? ref})
      : site = SiteEditService(repository: repository, ref: ref),
        trail = TrailEditService(repository: repository, ref: ref);

  // ── Visit Site delegation ────────────────────────────────────────────────

  Future<VisitSite?> updateVisitSiteLocation({
    required int siteId,
    required double newLatitude,
    required double newLongitude,
  }) =>
      site.updateVisitSiteLocation(
        siteId: siteId,
        newLatitude: newLatitude,
        newLongitude: newLongitude,
      );

  Future<VisitSite?> getVisitSite(int siteId) => site.getVisitSite(siteId);

  // ── Trail delegation ─────────────────────────────────────────────────────

  Future<Trail?> updateTrailCoordinates({
    required int trailId,
    required List<LatLng> newCoordinates,
    double rdpTolerance = 8,
  }) =>
      trail.updateTrailCoordinates(
        trailId: trailId,
        newCoordinates: newCoordinates,
        rdpTolerance: rdpTolerance,
      );

  Future<Trail?> getTrail(int trailId) => trail.getTrail(trailId);

  Future<bool> updateTrailMetadata({
    required int trailId,
    required String nameEn,
    required String nameEs,
    String? descriptionEn,
    String? descriptionEs,
    String? difficulty,
    int? estimatedMinutes,
  }) =>
      trail.updateTrailMetadata(
        trailId: trailId,
        nameEn: nameEn,
        nameEs: nameEs,
        descriptionEn: descriptionEn,
        descriptionEs: descriptionEs,
        difficulty: difficulty,
        estimatedMinutes: estimatedMinutes,
      );

  Future<Trail?> createNewTrail({
    required String nameEn,
    required String nameEs,
    required List<LatLng> coordinates,
    String? descriptionEn,
    String? descriptionEs,
    int? islandId,
    int? visitSiteId,
    String? difficulty,
    double rdpTolerance = 8,
  }) =>
      trail.createNewTrail(
        nameEn: nameEn,
        nameEs: nameEs,
        coordinates: coordinates,
        descriptionEn: descriptionEn,
        descriptionEs: descriptionEs,
        islandId: islandId,
        visitSiteId: visitSiteId,
        difficulty: difficulty,
        rdpTolerance: rdpTolerance,
      );

  // ── Static delegation ────────────────────────────────────────────────────

  static Future<int> syncPendingTrails() => TrailEditService.syncPendingTrails();

  static int pendingTrailCount() => TrailEditService.pendingTrailCount();
}
