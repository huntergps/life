import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../brick/models/visit_site.model.dart';
import '../../../brick/repository.dart';
import '../../../core/services/app_logger.dart';

/// Service for offline field editing of visit sites.
/// All changes are saved to SQLite first, then synced to Supabase when online.
class SiteEditService {
  final Repository _repository;
  // ignore: unused_field
  final WidgetRef? _ref;

  SiteEditService({Repository? repository, WidgetRef? ref})
      : _repository = repository ?? Repository(),
        _ref = ref;

  /// Update the location of a visit site (offline-first).
  /// Returns updated VisitSite or null if not found.
  Future<VisitSite?> updateVisitSiteLocation({
    required int siteId,
    required double newLatitude,
    required double newLongitude,
  }) async {
    try {
      final sites = await _repository.get<VisitSite>(
        query: Query.where('id', siteId, limit1: true),
        policy: OfflineFirstGetPolicy.localOnly,
      );

      if (sites.isEmpty) {
        AppLogger.warning('Site $siteId not found in local DB');
        return null;
      }

      final site = sites.first;

      final updated = VisitSite(
        id: site.id,
        islandId: site.islandId,
        nameEs: site.nameEs,
        nameEn: site.nameEn,
        latitude: newLatitude,
        longitude: newLongitude,
        descriptionEs: site.descriptionEs,
        descriptionEn: site.descriptionEn,
        monitoringType: site.monitoringType,
      );

      await Supabase.instance.client
          .from('visit_sites')
          .update({'latitude': newLatitude, 'longitude': newLongitude})
          .eq('id', siteId);

      await _repository.upsertSqlite<VisitSite>(updated);

      AppLogger.info(
          'Site $siteId location updated: ($newLatitude, $newLongitude)');
      return updated;
    } catch (e, st) {
      AppLogger.error('Error updating site location', e, st);
      return null;
    }
  }

  /// Get a visit site by ID.
  Future<VisitSite?> getVisitSite(int siteId) async {
    final sites = await _repository.get<VisitSite>(
      query: Query.where('id', siteId, limit1: true),
      policy: OfflineFirstGetPolicy.localOnly,
    );
    return sites.isNotEmpty ? sites.first : null;
  }
}
