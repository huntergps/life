import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter/foundation.dart';
import 'package:galapagos_wildlife/brick/repository.dart';
import 'package:galapagos_wildlife/brick/models/category.model.dart' as brick;
import 'package:galapagos_wildlife/brick/models/island.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/species_image.model.dart';
import 'package:galapagos_wildlife/brick/models/species_site.model.dart';
import 'package:galapagos_wildlife/brick/models/trail.model.dart';
import 'seed_data_service.dart';
import 'image_preload_service.dart';

class InitialSyncService {
  final Repository _repo;

  InitialSyncService(this._repo);

  /// Check if initial sync has been completed by checking local data.
  Future<bool> isSyncComplete() async {
    try {
      final species = await _repo.get<Species>(
        policy: OfflineFirstGetPolicy.localOnly,
      );
      return species.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Perform full sync of all reference data from Supabase to local SQLite.
  /// Calls [onProgress] with (step, totalSteps, tableName).
  Future<void> syncAll({
    void Function(int step, int total, String table)? onProgress,
  }) async {
    const tables = [
      'Categories',
      'Islands',
      'Visit Sites',
      'Species',
      'Species Sites',
      'Species Images',
      'Trails',
    ];
    final total = tables.length;

    try {
      // 1. Categories
      onProgress?.call(1, total, tables[0]);
      await _repo.get<brick.Category>(
        policy: OfflineFirstGetPolicy.awaitRemote,
      );

      // 2. Islands
      onProgress?.call(2, total, tables[1]);
      await _repo.get<Island>(
        policy: OfflineFirstGetPolicy.awaitRemote,
      );

      // 3. Visit Sites
      onProgress?.call(3, total, tables[2]);
      await _repo.get<VisitSite>(
        policy: OfflineFirstGetPolicy.awaitRemote,
      );

      // 4. Species
      onProgress?.call(4, total, tables[3]);
      await _repo.get<Species>(
        policy: OfflineFirstGetPolicy.awaitRemote,
      );

      // 5. Species-Sites relationships
      onProgress?.call(5, total, tables[4]);
      await _repo.get<SpeciesSite>(
        policy: OfflineFirstGetPolicy.awaitRemote,
      );

      // 6. Species Images
      onProgress?.call(6, total, tables[5]);
      await _repo.get<SpeciesImage>(
        policy: OfflineFirstGetPolicy.awaitRemote,
      );

      // 7. Trails (admin-created routes visible to all users)
      onProgress?.call(7, total, tables[6]);
      await _repo.get<Trail>(
        policy: OfflineFirstGetPolicy.awaitRemote,
      );

      debugPrint('Initial sync complete: all tables cached locally');
    } catch (e) {
      debugPrint('Initial sync failed: $e');
      rethrow;
    }
  }

  /// Pre-download species images into the HTTP cache so they're available
  /// offline after the initial sync.
  /// Calls [onProgress] with (current, total) for each image downloaded.
  Future<void> precacheImages({
    void Function(int current, int total)? onProgress,
  }) async {
    final imageService = ImagePreloadService(_repo);
    await imageService.preloadAllSpeciesImages(onProgress: onProgress);
  }

  /// Seed local database with bundled data as offline fallback.
  Future<void> seedLocalData({
    void Function(int step, int total, String table)? onProgress,
  }) async {
    final seedService = SeedDataService();
    await seedService.seed(onProgress: onProgress);
  }
}
