import 'dart:convert';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../bootstrap.dart';
import '../../../brick/models/trail.model.dart';
import '../../../brick/models/visit_site.model.dart';
import '../../../brick/repository.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/services/location/geo_utils.dart';

/// Service for offline field editing of sites and trails.
/// All changes are saved to SQLite first, then synced to Supabase when online.
class FieldEditService {
  static const _pendingTrailsKey = 'pending_trails_v1';

  final Repository _repository;
  final WidgetRef? _ref;

  FieldEditService({Repository? repository, WidgetRef? ref})
      : _repository = repository ?? Repository(),
        _ref = ref;

  // ============================================================================
  // VISIT SITE EDITING
  // ============================================================================

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

      AppLogger.info('Site $siteId location updated: ($newLatitude, $newLongitude)');
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

  // ============================================================================
  // TRAIL EDITING
  // ============================================================================

  /// Update trail coordinates (admin-only, updates Supabase directly).
  /// Returns updated Trail or null if not found.
  Future<Trail?> updateTrailCoordinates({
    required int trailId,
    required List<LatLng> newCoordinates,
    double rdpTolerance = 8,
  }) async {
    try {
      final trails = await _repository.get<Trail>(
        query: Query.where('id', trailId, limit1: true),
        policy: OfflineFirstGetPolicy.localOnly,
      );

      if (trails.isEmpty) {
        AppLogger.warning('Trail $trailId not found in local DB');
        return null;
      }

      final simplified = GeoUtils.simplifyTrack(newCoordinates, toleranceMeters: rdpTolerance);
      AppLogger.info('GPS points: ${newCoordinates.length} → simplified: ${simplified.length}');

      final coordsJson = jsonEncode(
        simplified.map((p) => [p.latitude, p.longitude]).toList(),
      );

      final distance = GeoUtils.calculateDistanceKm(simplified);

      await Supabase.instance.client
          .from('trails')
          .update({
            'coordinates': coordsJson,
            'distance_km': distance,
          })
          .eq('id', trailId);

      // Re-fetch via Brick to correctly update the existing SQLite row.
      final fresh = await _repository.get<Trail>(
        query: Query.where('id', trailId, limit1: true),
        policy: OfflineFirstGetPolicy.awaitRemote,
      );

      AppLogger.info('Trail $trailId coordinates updated (${simplified.length} pts, $distance km)');
      return fresh.isNotEmpty ? fresh.first : null;
    } catch (e, st) {
      AppLogger.error('Error updating trail coordinates', e, st);
      return null;
    }
  }

  /// Get a trail by ID — tries remote first; falls back to local SQLite when offline.
  Future<Trail?> getTrail(int trailId) async {
    final query = Query.where('id', trailId, limit1: true);
    try {
      final trails = await _repository.get<Trail>(
        query: query,
        policy: OfflineFirstGetPolicy.awaitRemote,
      );
      if (trails.isNotEmpty) return trails.first;
    } catch (_) {
      // Offline or network error — fall through to local cache.
    }
    final local = await _repository.get<Trail>(
      query: query,
      policy: OfflineFirstGetPolicy.localOnly,
    );
    return local.isNotEmpty ? local.first : null;
  }

  /// Update trail metadata (name, description, difficulty, estimated time).
  Future<bool> updateTrailMetadata({
    required int trailId,
    required String nameEn,
    required String nameEs,
    String? descriptionEn,
    String? descriptionEs,
    String? difficulty,
    int? estimatedMinutes,
  }) async {
    try {
      await Supabase.instance.client.from('trails').update({
        'name_en': nameEn,
        'name_es': nameEs,
        if (descriptionEn != null) 'description_en': descriptionEn,
        if (descriptionEs != null) 'description_es': descriptionEs,
        if (difficulty != null) 'difficulty': difficulty,
        if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      }).eq('id', trailId);
      await _repository.get<Trail>(
        query: Query.where('id', trailId, limit1: true),
        policy: OfflineFirstGetPolicy.awaitRemote,
      );
      return true;
    } catch (e, st) {
      AppLogger.error('Error updating trail metadata', e, st);
      return false;
    }
  }

  // ============================================================================
  // NEW TRAIL CREATION
  // ============================================================================

  /// Create a new trail from GPS recording.
  ///
  /// **Online**: Inserts directly to Supabase (user's JWT → RLS passes), then
  /// writes to local SQLite via [upsertSqlite]. Returns the saved [Trail].
  ///
  /// **Offline**: Saves the trail data to a local pending queue
  /// (SharedPreferences). Returns a sentinel `Trail(id: -1)` so callers can
  /// show "saved offline, will sync later". Call [syncPendingTrails] when
  /// connectivity is restored to upload queued trails.
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
  }) async {
    if (coordinates.length < 2) {
      AppLogger.warning('Cannot create trail with less than 2 points');
      return null;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      AppLogger.warning('User must be logged in to save a trail');
      return null;
    }

    final simplified = GeoUtils.simplifyTrack(coordinates, toleranceMeters: rdpTolerance);
    AppLogger.info('GPS points: ${coordinates.length} → simplified: ${simplified.length}');

    final coordsJson = jsonEncode(
      simplified.map((p) => [p.latitude, p.longitude]).toList(),
    );
    final distanceKm = GeoUtils.calculateDistanceKm(simplified);
    final estimatedMinutes = ((distanceKm / 3.0) * 60).round();
    final diff = difficulty ?? 'moderate';

    final payload = <String, dynamic>{
      'name_en': nameEn,
      'name_es': nameEs,
      if (descriptionEn != null) 'description_en': descriptionEn,
      if (descriptionEs != null) 'description_es': descriptionEs,
      if (islandId != null) 'island_id': islandId,
      if (visitSiteId != null) 'visit_site_id': visitSiteId,
      'difficulty': diff,
      'distance_km': distanceKm,
      'estimated_minutes': estimatedMinutes,
      'coordinates': coordsJson,
      'user_id': userId,
    };

    try {
      final response = await Supabase.instance.client
          .from('trails')
          .insert(payload)
          .select('id')
          .single();

      final realId = response['id'] as int;

      final newTrail = Trail(
        id: realId,
        nameEn: nameEn,
        nameEs: nameEs,
        descriptionEn: descriptionEn,
        descriptionEs: descriptionEs,
        islandId: islandId,
        visitSiteId: visitSiteId,
        difficulty: diff,
        distanceKm: distanceKm,
        estimatedMinutes: estimatedMinutes,
        coordinates: coordsJson,
        userId: userId,
      );

      await _repository.upsertSqlite<Trail>(newTrail);

      AppLogger.info('Trail "$nameEn" created (id=$realId, $distanceKm km, ${simplified.length} pts)');
      return newTrail;
    } catch (e) {
      if (_isNetworkError(e)) {
        await _savePendingTrail(payload);
        AppLogger.info('Offline: trail "$nameEn" queued for later sync');
        return Trail(
          id: -1,
          nameEn: nameEn,
          nameEs: nameEs,
          descriptionEn: descriptionEn,
          descriptionEs: descriptionEs,
          islandId: islandId,
          visitSiteId: visitSiteId,
          difficulty: diff,
          distanceKm: distanceKm,
          estimatedMinutes: estimatedMinutes,
          coordinates: coordsJson,
          userId: userId,
        );
      }
      AppLogger.error('Error creating trail', e);
      return null;
    }
  }

  // ============================================================================
  // PENDING TRAIL QUEUE (offline sync)
  // ============================================================================

  Future<void> _savePendingTrail(Map<String, dynamic> data) async {
    try {
      final prefs = Bootstrap.prefs;
      final existing = prefs.getString(_pendingTrailsKey);
      final list = existing != null
          ? List<dynamic>.from(jsonDecode(existing) as List)
          : <dynamic>[];
      list.add({...data, '_queued_at': DateTime.now().toIso8601String()});
      await prefs.setString(_pendingTrailsKey, jsonEncode(list));
      AppLogger.info('Pending trails: ${list.length} total');
    } catch (e, st) {
      AppLogger.error('Error saving pending trail', e, st);
    }
  }

  /// Uploads all locally queued trails to Supabase.
  ///
  /// Call on app startup and whenever connectivity is restored.
  /// Returns the number of trails successfully synced.
  static Future<int> syncPendingTrails() async {
    int synced = 0;
    try {
      final prefs = Bootstrap.prefs;
      final existing = prefs.getString(_pendingTrailsKey);
      if (existing == null || existing.isEmpty) return 0;

      final list = List<dynamic>.from(jsonDecode(existing) as List);
      if (list.isEmpty) return 0;

      AppLogger.info('Syncing ${list.length} pending trail(s)…');
      final remaining = <dynamic>[];
      final repo = Repository();

      for (final item in list) {
        final data = Map<String, dynamic>.from(item as Map);
        data.remove('_queued_at');
        try {
          final response = await Supabase.instance.client
              .from('trails')
              .insert(data)
              .select('id')
              .single();

          final realId = response['id'] as int;
          final trail = Trail(
            id: realId,
            nameEn: data['name_en'] as String,
            nameEs: data['name_es'] as String,
            descriptionEn: data['description_en'] as String?,
            descriptionEs: data['description_es'] as String?,
            islandId: data['island_id'] as int?,
            visitSiteId: data['visit_site_id'] as int?,
            difficulty: data['difficulty'] as String?,
            distanceKm: (data['distance_km'] as num?)?.toDouble(),
            estimatedMinutes: data['estimated_minutes'] as int?,
            coordinates: data['coordinates'] as String? ?? '[]',
            userId: data['user_id'] as String?,
          );
          await repo.upsertSqlite<Trail>(trail);
          synced++;
          AppLogger.info('Pending trail synced (id=$realId, "${trail.nameEn}")');
        } catch (e) {
          AppLogger.warning('Could not sync pending trail "${data['name_en']}": $e — will retry');
          remaining.add({...data, '_queued_at': item['_queued_at']});
        }
      }

      await prefs.setString(_pendingTrailsKey, jsonEncode(remaining));
      if (synced > 0) {
        AppLogger.info('Synced $synced pending trail(s), ${remaining.length} still queued');
      }
    } catch (e, st) {
      AppLogger.error('syncPendingTrails error', e, st);
    }
    return synced;
  }

  /// Returns the number of trails currently waiting to be synced.
  static int pendingTrailCount() {
    try {
      final existing = Bootstrap.prefs.getString(_pendingTrailsKey);
      if (existing == null || existing.isEmpty) return 0;
      return (jsonDecode(existing) as List).length;
    } catch (_) {
      return 0;
    }
  }

  /// Returns true if the error looks like a network-connectivity failure.
  static bool _isNetworkError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('socketexception') ||
        msg.contains('failed host lookup') ||
        msg.contains('network is unreachable') ||
        msg.contains('no address associated with hostname') ||
        msg.contains('clientexception') ||
        msg.contains('network request failed') ||
        msg.contains('connection refused') ||
        msg.contains('connection timed out');
  }
}
