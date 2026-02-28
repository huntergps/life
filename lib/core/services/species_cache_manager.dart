import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom cache manager for species images with permanent offline-first caching
class SpeciesCacheManager {
  static const key = 'speciesImageCache';

  static CacheManager? _instance;

  /// Get the singleton cache manager instance
  static CacheManager get instance {
    _instance ??= CacheManager(
      Config(
        key,
        // Cache for 90 days (3 months)
        stalePeriod: const Duration(days: 90),
        // Keep up to 500 images (plenty for all species)
        maxNrOfCacheObjects: 500,
        // Use FileService with offline-first behavior
        repo: JsonCacheInfoRepository(databaseName: key),
        fileService: HttpFileService(),
      ),
    );
    return _instance!;
  }
}
