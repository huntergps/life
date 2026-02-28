import 'dart:async';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:galapagos_wildlife/brick/repository.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/species_image.model.dart';
import 'package:galapagos_wildlife/core/services/species_cache_manager.dart';

/// Service to preload all species images into the HTTP cache for offline use.
/// Downloads thumbnails only to save storage space.
class ImagePreloadService {
  final Repository _repo;

  ImagePreloadService(this._repo);

  /// Preload all species thumbnails and gallery thumbnails.
  /// Calls [onProgress] with (current, total) for each image downloaded.
  /// Returns the number of successfully downloaded images.
  Future<int> preloadAllSpeciesImages({
    void Function(int current, int total)? onProgress,
  }) async {
    try {
      // Get all species and images from local cache
      final species = await _repo.get<Species>(
        policy: OfflineFirstGetPolicy.localOnly,
      );
      final images = await _repo.get<SpeciesImage>(
        policy: OfflineFirstGetPolicy.localOnly,
      );

      // Collect all thumbnail URLs
      final urls = <String>[];

      // Add species thumbnails
      for (final s in species) {
        if (s.thumbnailUrl != null && s.thumbnailUrl!.isNotEmpty) {
          urls.add(s.thumbnailUrl!);
        }
      }

      // Add gallery thumbnails (prefer card_thumbnail, fallback to thumbnail, fallback to full image)
      for (final img in images) {
        if (img.cardThumbnailUrl != null && img.cardThumbnailUrl!.isNotEmpty) {
          urls.add(img.cardThumbnailUrl!);
        } else if (img.thumbnailUrl != null && img.thumbnailUrl!.isNotEmpty) {
          urls.add(img.thumbnailUrl!);
        } else if (img.imageUrl.isNotEmpty) {
          urls.add(img.imageUrl);
        }
      }

      // Remove duplicates
      final uniqueUrls = urls.toSet().toList();
      final total = uniqueUrls.length;

      debugPrint('Starting image preload: $total unique URLs');

      int successCount = 0;
      int failureCount = 0;

      // Download images sequentially with progress callbacks
      for (int i = 0; i < uniqueUrls.length; i++) {
        final url = uniqueUrls[i];
        onProgress?.call(i + 1, total);

        try {
          // Preload image into cache
          await _precacheImage(url);
          successCount++;

          if (kDebugMode && (i + 1) % 10 == 0) {
            debugPrint('Preloaded $successCount/$total images...');
          }
        } catch (e) {
          failureCount++;
          debugPrint('Failed to preload image $url: $e');
          // Continue with next image
        }
      }

      debugPrint(
        'Image preload complete: $successCount succeeded, $failureCount failed out of $total',
      );

      return successCount;
    } catch (e) {
      debugPrint('Image preload service error: $e');
      rethrow;
    }
  }

  /// Preload a single image URL into the cache.
  Future<void> _precacheImage(String url) async {
    final completer = Completer<void>();
    final provider = CachedNetworkImageProvider(
      url,
      cacheManager: SpeciesCacheManager.instance, // ✅ Use permanent cache
    );
    final stream = provider.resolve(ImageConfiguration.empty);

    final listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (dynamic error, StackTrace? stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    );

    stream.addListener(listener);

    try {
      await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Image download timeout', const Duration(seconds: 30));
        },
      );
    } finally {
      stream.removeListener(listener);
    }
  }

  /// Estimate total download size in MB (rough estimate: 50KB per thumbnail).
  Future<double> estimateDownloadSize() async {
    try {
      final species = await _repo.get<Species>(
        policy: OfflineFirstGetPolicy.localOnly,
      );
      final images = await _repo.get<SpeciesImage>(
        policy: OfflineFirstGetPolicy.localOnly,
      );

      final totalImages = species.length + images.length;
      // Rough estimate: 50KB per thumbnail
      return (totalImages * 50) / 1024; // MB
    } catch (_) {
      return 0.0;
    }
  }

  /// Check if images are likely already cached by attempting to load one.
  Future<bool> areImagesCached() async {
    try {
      final species = await _repo.get<Species>(
        policy: OfflineFirstGetPolicy.localOnly,
      );

      if (species.isEmpty || species.first.thumbnailUrl == null) {
        return false;
      }

      // Try to resolve one image quickly to check cache
      final provider = CachedNetworkImageProvider(species.first.thumbnailUrl!);
      final completer = Completer<bool>();

      final stream = provider.resolve(ImageConfiguration.empty);
      final listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (!completer.isCompleted) {
            // If it loads synchronously, it was cached
            completer.complete(synchronousCall);
          }
        },
        onError: (dynamic error, StackTrace? stackTrace) {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );

      stream.addListener(listener);

      try {
        final result = await completer.future.timeout(
          const Duration(seconds: 2),
          onTimeout: () => false,
        );
        stream.removeListener(listener);
        return result;
      } catch (_) {
        stream.removeListener(listener);
        return false;
      }
    } catch (_) {
      return false;
    }
  }
}
