import 'dart:async';

import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/core/widgets/cached_species_image.dart';
import 'package:galapagos_wildlife/core/widgets/fullscreen_gallery.dart';

/// A reusable swipeable image carousel with page indicators, photo count badge,
/// optional auto-play, and tap-to-fullscreen support.
///
/// Used in the species detail screen to replace the static hero image with a
/// swipeable PageView so users can browse all photos inline.
class ImageCarousel extends StatefulWidget {
  /// URLs for each image (network URLs or asset paths).
  final List<String> imageUrls;

  /// Whether each corresponding URL is a local asset (`true`) or network
  /// image (`false`).
  final List<bool> isAsset;

  /// Fixed height of the carousel. Typical values: ~280 for phone,
  /// full height for tablet.
  final double height;

  /// Optional border radius applied to the carousel container.
  final BorderRadius? borderRadius;

  /// If `true`, draws a dark gradient at the bottom of each image for
  /// readability when text or controls are placed below.
  final bool showOverlayGradient;

  /// If `true`, shows a page indicator at the bottom-center:
  /// - Dots (Instagram-style) when there are <= 5 images.
  /// - A "2 / 8" text counter when there are > 5 images.
  final bool showPageIndicator;

  /// If `true`, shows a photo count badge (camera icon + count) at the
  /// top-right. Set to `false` when the carousel is inside a SliverAppBar
  /// whose actions would overlap.
  final bool showPhotoBadge;

  /// If `true`, automatically cycles through images every
  /// [autoPlayInterval]. Disabled by default.
  final bool autoPlay;

  /// Duration between auto-play page transitions.
  final Duration autoPlayInterval;

  /// Species ID for offline fallback to local assets
  final int? speciesId;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    required this.isAsset,
    this.height = 280,
    this.borderRadius,
    this.showOverlayGradient = false,
    this.showPageIndicator = true,
    this.showPhotoBadge = true,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.speciesId,
  }) : assert(imageUrls.length == isAsset.length,
            'imageUrls and isAsset must have the same length');

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    if (widget.autoPlay && widget.imageUrls.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void didUpdateWidget(covariant ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset if the image list changed.
    if (widget.imageUrls.length != oldWidget.imageUrls.length) {
      _currentPage = 0;
      _pageController.jumpToPage(0);
    }
    // Handle auto-play toggling.
    if (widget.autoPlay && !oldWidget.autoPlay && widget.imageUrls.length > 1) {
      _startAutoPlay();
    } else if (!widget.autoPlay && oldWidget.autoPlay) {
      _stopAutoPlay();
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Auto-play
  // ---------------------------------------------------------------------------

  void _startAutoPlay() {
    _stopAutoPlay();
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted) return;
      final nextPage = _currentPage + 1 < widget.imageUrls.length
          ? _currentPage + 1
          : 0;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  // ---------------------------------------------------------------------------
  // Tap handler
  // ---------------------------------------------------------------------------

  void _onImageTap() {
    FullscreenGallery.open(
      context,
      imageUrls: widget.imageUrls,
      isAsset: widget.isAsset,
      initialIndex: _currentPage,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final imageCount = widget.imageUrls.length;

    // Edge case: no images at all.
    if (imageCount == 0) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
            size: 48,
          ),
        ),
      );
    }

    Widget carousel = SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // --- PageView ---
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: imageCount,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                // Reset auto-play timer on manual swipe.
                if (widget.autoPlay && imageCount > 1) {
                  _startAutoPlay();
                }
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: _onImageTap,
                  child: widget.isAsset[index]
                      ? Image.asset(
                          widget.imageUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: widget.height,
                          cacheWidth: 1280,
                          cacheHeight: 720,
                        )
                      : CachedSpeciesImage(
                          imageUrl: widget.imageUrls[index],
                          speciesId: widget.speciesId, // ✅ Now has offline fallback!
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: widget.height,
                          memCacheWidth: 1280,
                          memCacheHeight: 720,
                        ),
                );
              },
            ),
          ),

          // --- Dark bottom gradient ---
          if (widget.showOverlayGradient)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: widget.height * 0.35,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // --- Photo count badge (top-right) ---
          if (widget.showPhotoBadge && imageCount > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$imageCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // --- Page indicator (bottom-center) ---
          if (widget.showPageIndicator && imageCount > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: imageCount <= 5
                    ? _buildDotIndicator(imageCount)
                    : _buildCounterIndicator(imageCount),
              ),
            ),
        ],
      ),
    );

    // Apply border radius clipping if provided.
    if (widget.borderRadius != null) {
      carousel = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: carousel,
      );
    }

    return carousel;
  }

  // ---------------------------------------------------------------------------
  // Indicator widgets
  // ---------------------------------------------------------------------------

  /// Instagram-style dot indicators for <= 5 images.
  Widget _buildDotIndicator(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 8,
            height: 8,
            margin: EdgeInsets.only(right: index < count - 1 ? 6 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
            ),
          );
        }),
      ),
    );
  }

  /// "2 / 8" text counter for > 5 images.
  Widget _buildCounterIndicator(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${_currentPage + 1} / $count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
