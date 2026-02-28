import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/species_assets.dart';
import '../theme/app_colors.dart';
import '../services/species_cache_manager.dart';

class CachedSpeciesImage extends StatelessWidget {
  final String? imageUrl;
  final int? speciesId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? semanticLabel;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const CachedSpeciesImage({
    super.key,
    this.imageUrl,
    this.speciesId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final url = imageUrl;
    final Widget widget;

    if (url != null && url.isNotEmpty && url.startsWith('assets/')) {
      // Local asset image
      widget = Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(isDark),
      );
    } else if (url != null && url.isNotEmpty) {
      // Network image with offline-first caching
      widget = CachedNetworkImage(
        imageUrl: url,
        cacheManager: SpeciesCacheManager.instance, // ✅ Permanent offline cache
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        maxWidthDiskCache: memCacheWidth,
        maxHeightDiskCache: memCacheHeight,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: isDark ? AppColors.darkCard : Colors.grey.shade300,
          highlightColor: isDark ? AppColors.darkBorder : Colors.grey.shade100,
          child: Container(
            width: width,
            height: height,
            color: isDark ? AppColors.darkCard : Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => _assetFallbackOr(isDark),
      );
    } else {
      widget = _assetFallbackOr(isDark);
    }

    Widget result = widget;
    if (borderRadius != null) {
      result = ClipRRect(borderRadius: borderRadius!, child: result);
    }
    if (semanticLabel != null) {
      result = Semantics(label: semanticLabel, image: true, child: result);
    }
    return result;
  }

  /// Tries local asset as fallback, otherwise shows placeholder icon.
  Widget _assetFallbackOr(bool isDark) {
    if (speciesId != null) {
      final assetPath =
          SpeciesAssets.thumbnail(speciesId!) ?? SpeciesAssets.heroImage(speciesId!);
      if (assetPath != null) {
        return Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, _, _) => _placeholder(isDark),
        );
      }
    }
    return _placeholder(isDark);
  }

  Widget _placeholder(bool isDark) {
    return Container(
      width: width,
      height: height,
      color: isDark ? AppColors.darkCard : Colors.grey.shade200,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: isDark ? Colors.white24 : Colors.grey,
        size: 40,
      ),
    );
  }
}
