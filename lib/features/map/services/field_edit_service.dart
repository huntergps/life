import 'dart:convert';
import 'dart:io';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../bootstrap.dart';
import '../../../brick/models/trail.model.dart';
import '../../../brick/models/visit_site.model.dart';
import '../../../brick/repository.dart';

/// Service for offline field editing of sites and trails
/// All changes are saved to SQLite first, then synced to Supabase when online
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

  /// Update the location of a visit site (offline-first)
  /// Returns updated VisitSite or null if not found
  Future<VisitSite?> updateVisitSiteLocation({
    required int siteId,
    required double newLatitude,
    required double newLongitude,
  }) async {
    try {
      // Get existing site from local DB
      final sites = await _repository.get<VisitSite>(
        query: Query.where('id', siteId, limit1: true),
        policy: OfflineFirstGetPolicy.localOnly, // Offline-first
      );

      if (sites.isEmpty) {
        print('⚠️ Site $siteId not found in local DB');
        return null;
      }

      final site = sites.first;

      // Create updated site with new coordinates
      final updated = VisitSite(
        id: site.id,
        islandId: site.islandId,
        nameEs: site.nameEs,
        nameEn: site.nameEn,
        latitude: newLatitude,  // ✅ New location
        longitude: newLongitude, // ✅ New location
        descriptionEs: site.descriptionEs,
        descriptionEn: site.descriptionEn,
        monitoringType: site.monitoringType,
      );

      // Update directly in Supabase (admin operation — bypass Brick queue).
      await Supabase.instance.client
          .from('visit_sites')
          .update({'latitude': newLatitude, 'longitude': newLongitude})
          .eq('id', siteId);

      // Write to local SQLite only — bypass offline queue to avoid stuck queue entries.
      await _repository.upsertSqlite<VisitSite>(updated);

      print('✅ Site $siteId location updated: ($newLatitude, $newLongitude)');
      return updated;
    } catch (e) {
      print('❌ Error updating site location: $e');
      return null;
    }
  }

  /// Get a visit site by ID
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

  /// Update trail coordinates (admin-only, updates Supabase directly)
  /// Returns updated Trail or null if not found
  Future<Trail?> updateTrailCoordinates({
    required int trailId,
    required List<LatLng> newCoordinates,
    double rdpTolerance = 8,
  }) async {
    try {
      // Get existing trail from local DB
      final trails = await _repository.get<Trail>(
        query: Query.where('id', trailId, limit1: true),
        policy: OfflineFirstGetPolicy.localOnly,
      );

      if (trails.isEmpty) {
        print('⚠️ Trail $trailId not found in local DB');
        return null;
      }

      final trail = trails.first;

      // Simplify before saving (Ramer-Douglas-Peucker).
      final simplified = _simplifyTrack(newCoordinates, toleranceMeters: rdpTolerance);
      print('📍 GPS points: ${newCoordinates.length} → simplified: ${simplified.length}');

      // Convert coordinates to JSON format: [[lat,lng],[lat,lng],...]
      final coordsJson = jsonEncode(
        simplified.map((p) => [p.latitude, p.longitude]).toList(),
      );

      // Calculate new distance
      final distance = _calculateDistance(simplified);

      // Update directly in Supabase (bypass Brick queue to avoid RLS failures
      // when the auth token expires between enqueue and replay).
      await Supabase.instance.client
          .from('trails')
          .update({
            'coordinates': coordsJson,
            'distance_km': distance,
          })
          .eq('id', trailId);

      // Re-fetch this trail from Supabase via Brick so it correctly updates the
      // existing SQLite row (awaitRemote maps by the unique `id` field, avoiding
      // the duplicate-row bug that upsertSqlite caused with anonymous objects).
      final fresh = await _repository.get<Trail>(
        query: Query.where('id', trailId, limit1: true),
        policy: OfflineFirstGetPolicy.awaitRemote,
      );

      print('✅ Trail $trailId coordinates updated (${simplified.length} pts, $distance km)');
      return fresh.isNotEmpty ? fresh.first : null;
    } catch (e) {
      print('❌ Error updating trail coordinates: $e');
      return null;
    }
  }

  /// Get a trail by ID — tries remote first so edits always start from the
  /// latest version; falls back to local SQLite when offline.
  Future<Trail?> getTrail(int trailId) async {
    final query = Query.where('id', trailId, limit1: true);
    try {
      final trails = await _repository.get<Trail>(
        query: query,
        policy: OfflineFirstGetPolicy.awaitRemote,
      );
      if (trails.isNotEmpty) return trails.first;
    } catch (_) {
      // Offline or network error — fall through to local cache
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
      // Sync local cache
      await _repository.get<Trail>(
        query: Query.where('id', trailId, limit1: true),
        policy: OfflineFirstGetPolicy.awaitRemote,
      );
      return true;
    } catch (e) {
      print('❌ Error updating trail metadata: $e');
      return false;
    }
  }

  /// Parse trail coordinates from JSON string
  List<LatLng> parseTrailCoordinates(String coordinatesJson) {
    try {
      final decoded = jsonDecode(coordinatesJson) as List;
      return decoded
          .map((c) => LatLng((c[0] as num).toDouble(), (c[1] as num).toDouble()))
          .toList();
    } catch (e) {
      print('⚠️ Error parsing trail coordinates: $e');
      return [];
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
  /// tell the user "saved offline, will sync later". Call [syncPendingTrails]
  /// when connectivity is restored to upload queued trails.
  ///
  /// Requires the user to be logged in (RLS enforces user_id = auth.uid()).
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
      print('⚠️ Cannot create trail with less than 2 points');
      return null;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      print('⚠️ User must be logged in to save a trail');
      return null;
    }

    // Simplify before saving.
    final simplified = _simplifyTrack(coordinates, toleranceMeters: rdpTolerance);
    print('📍 GPS points: ${coordinates.length} → simplified: ${simplified.length}');

    final coordsJson = jsonEncode(
      simplified.map((p) => [p.latitude, p.longitude]).toList(),
    );
    final distanceKm = _calculateDistance(simplified);
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
      // Insert directly to Supabase using the user's JWT so RLS passes.
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

      // Write to local SQLite only — bypass offline queue to avoid double-write.
      await _repository.upsertSqlite<Trail>(newTrail);

      print('✅ Trail "$nameEn" created (id=$realId, $distanceKm km, ${simplified.length} pts)');
      return newTrail;
    } catch (e) {
      if (_isNetworkError(e)) {
        // Device is offline — queue locally, sync when connectivity returns.
        await _savePendingTrail(payload);
        print('📤 Offline: trail "$nameEn" queued for later sync');
        // Return a sentinel trail (id = -1) so the UI can show "saved offline".
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
      print('❌ Error creating trail: $e');
      return null;
    }
  }

  // ============================================================================
  // PENDING TRAIL QUEUE (offline sync)
  // ============================================================================

  /// Saves [data] to the local pending-trails queue (SharedPreferences).
  Future<void> _savePendingTrail(Map<String, dynamic> data) async {
    try {
      final prefs = Bootstrap.prefs;
      final existing = prefs.getString(_pendingTrailsKey);
      final list = existing != null
          ? List<dynamic>.from(jsonDecode(existing) as List)
          : <dynamic>[];
      list.add({...data, '_queued_at': DateTime.now().toIso8601String()});
      await prefs.setString(_pendingTrailsKey, jsonEncode(list));
      print('📦 Pending trails: ${list.length} total');
    } catch (e) {
      print('❌ Error saving pending trail: $e');
    }
  }

  /// Uploads all locally queued (offline-saved) trails to Supabase.
  ///
  /// Call on app startup and whenever connectivity is restored.
  /// Successfully synced trails are written to local SQLite and removed from
  /// the queue. Trails that still fail remain queued for the next attempt.
  ///
  /// Returns the number of trails successfully synced.
  static Future<int> syncPendingTrails() async {
    int synced = 0;
    try {
      final prefs = Bootstrap.prefs;
      final existing = prefs.getString(_pendingTrailsKey);
      if (existing == null || existing.isEmpty) return 0;

      final list = List<dynamic>.from(jsonDecode(existing) as List);
      if (list.isEmpty) return 0;

      print('🔄 Syncing ${list.length} pending trail(s)…');
      final remaining = <dynamic>[];
      final repo = Repository();

      for (final item in list) {
        final data = Map<String, dynamic>.from(item as Map);
        data.remove('_queued_at'); // not a DB column
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
          print('✅ Pending trail synced (id=$realId, "${trail.nameEn}")');
        } catch (e) {
          print('⚠️ Could not sync pending trail "${data['name_en']}": $e — will retry');
          remaining.add({...data, '_queued_at': item['_queued_at']});
        }
      }

      await prefs.setString(_pendingTrailsKey, jsonEncode(remaining));
      if (synced > 0) {
        print('✅ Synced $synced pending trail(s), ${remaining.length} still queued');
      }
    } catch (e) {
      print('❌ syncPendingTrails error: $e');
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
    if (e is SocketException) return true;
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

  // ============================================================================
  // SYNC & UTILITIES
  // ============================================================================

  /// Check if there are pending changes to sync
  /// (This is handled automatically by Brick's offline queue)
  Future<bool> hasPendingChanges() async {
    // Brick's offlineRequestQueue automatically tracks pending changes
    // We could inspect the queue here if needed
    return false; // Placeholder - Brick handles this internally
  }

  /// Force sync pending changes to Supabase
  /// (Brick handles this automatically when online)
  Future<void> syncNow() async {
    // Brick's offlineRequestQueue syncs automatically when online
    // This is a no-op since Brick handles it
    print('🔄 Sync requested - Brick will sync automatically when online');
  }

  /// Simplifies a GPS track using the Ramer-Douglas-Peucker algorithm.
  ///
  /// Removes intermediate points that are within [toleranceMeters] of the
  /// straight line between their neighbours — preserving the shape of the
  /// route while drastically reducing point count (typically 70-85% reduction).
  ///
  /// [toleranceMeters] — 5 m keeps fine detail; 10 m is good for trails;
  /// 15-20 m is enough for boat/bike routes.
  List<LatLng> _simplifyTrack(List<LatLng> points, {double toleranceMeters = 8}) {
    if (points.length <= 2) return points;

    // Find the point with the maximum perpendicular distance from the
    // line formed by the first and last point.
    double maxDistance = 0;
    int maxIndex = 0;

    for (int i = 1; i < points.length - 1; i++) {
      final d = _perpendicularDistance(points[i], points.first, points.last);
      if (d > maxDistance) {
        maxDistance = d;
        maxIndex = i;
      }
    }

    if (maxDistance > toleranceMeters) {
      // Recursively simplify both halves.
      final left  = _simplifyTrack(points.sublist(0, maxIndex + 1), toleranceMeters: toleranceMeters);
      final right = _simplifyTrack(points.sublist(maxIndex),        toleranceMeters: toleranceMeters);
      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      // All intermediate points are within tolerance — keep only endpoints.
      return [points.first, points.last];
    }
  }

  /// Perpendicular distance (in metres) from [point] to the line [start]→[end].
  double _perpendicularDistance(LatLng point, LatLng start, LatLng end) {
    final dist = Distance();
    final lineLength = dist.distance(start, end);
    if (lineLength == 0) return dist.distance(point, start);

    // Project point onto the line using dot product in flat-earth approximation.
    final dx = end.longitude - start.longitude;
    final dy = end.latitude  - start.latitude;
    final t  = ((point.longitude - start.longitude) * dx +
                (point.latitude  - start.latitude)  * dy) /
               (dx * dx + dy * dy);
    final tClamped = t.clamp(0.0, 1.0);

    final closest = LatLng(
      start.latitude  + tClamped * dy,
      start.longitude + tClamped * dx,
    );
    return dist.distance(point, closest);
  }

  /// Calculate distance in km from a list of coordinates
  double _calculateDistance(List<LatLng> points) {
    if (points.length < 2) return 0;

    final distance = Distance();
    double totalMeters = 0;

    for (int i = 0; i < points.length - 1; i++) {
      totalMeters += distance.distance(points[i], points[i + 1]);
    }

    return totalMeters / 1000.0; // Convert to km
  }
}
