import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/cached_species_image.dart';
import 'package:galapagos_wildlife/core/widgets/fullscreen_gallery.dart';
import 'package:galapagos_wildlife/features/species/providers/species_detail_provider.dart';

/// Compact horizontal thumbnail strip for gallery images.
///
/// On phone: use [GalleryCarousel.asSliver] inside a CustomScrollView.
/// On tablet: use [GalleryCarousel.asOverlay] positioned over the hero panel.
class GalleryCarousel extends ConsumerStatefulWidget {
  final int speciesId;
  final bool asOverlay;
  final int? activeIndex;

  const GalleryCarousel({
    super.key,
    required this.speciesId,
    this.asOverlay = false,
    this.activeIndex,
  });

  /// Creates a SliverToBoxAdapter version for phone layout.
  static Widget asSliver({required int speciesId}) {
    return SliverToBoxAdapter(
      child: GalleryCarousel(speciesId: speciesId),
    );
  }

  /// Creates an overlay version for tablet layout (positioned at bottom).
  static Widget asTabletOverlay({
    required int speciesId,
    int? activeIndex,
  }) {
    return GalleryCarousel(
      speciesId: speciesId,
      asOverlay: true,
      activeIndex: activeIndex,
    );
  }

  @override
  ConsumerState<GalleryCarousel> createState() => _GalleryCarouselState();
}

class _GalleryCarouselState extends ConsumerState<GalleryCarousel> {
  final ScrollController _scrollController = ScrollController();

  /// Thumbnail height: 80px for tablet overlay, 72px for phone.
  double get _thumbHeight => widget.asOverlay ? 80.0 : 72.0;

  /// Thumbnail width at 16:9 ratio.
  double get _thumbWidth => _thumbHeight * 16 / 9;

  /// Horizontal padding for each thumbnail item (right margin).
  static const double _thumbSpacing = 6.0;

  @override
  void didUpdateWidget(covariant GalleryCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeIndex != oldWidget.activeIndex &&
        widget.activeIndex != null) {
      _scrollToActiveIndex(widget.activeIndex!);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scrolls the thumbnail list to center the active thumbnail.
  void _scrollToActiveIndex(int index) {
    if (!_scrollController.hasClients) return;

    final horizontalPadding = widget.asOverlay ? 12.0 : 16.0;
    final itemExtent = _thumbWidth + _thumbSpacing;
    final viewportWidth = _scrollController.position.viewportDimension;
    final maxScroll = _scrollController.position.maxScrollExtent;

    // Target offset: center the active thumbnail in the viewport.
    final targetOffset =
        (horizontalPadding + (index * itemExtent) + (_thumbWidth / 2)) -
            (viewportWidth / 2);
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(speciesImagesProvider(widget.speciesId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return imagesAsync.when(
      data: (images) {
        List<String> urls;
        List<String> thumbUrls;
        List<bool> isAssetList;
        if (images.isEmpty) {
          final localGallery = SpeciesAssets.gallery(widget.speciesId);
          if (localGallery.isEmpty) return const SizedBox.shrink();
          urls = localGallery;
          thumbUrls = localGallery;
          isAssetList = List.filled(localGallery.length, true);
        } else {
          urls = images.map((i) => i.imageUrl).toList();
          thumbUrls =
              images.map((i) => i.thumbnailUrl ?? i.imageUrl).toList();
          isAssetList = List.filled(images.length, false);
        }

        final totalCount = urls.length;
        final activeIdx = widget.activeIndex;

        final content = SizedBox(
          height: _thumbHeight,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: widget.asOverlay ? 12 : 16,
            ),
            itemCount: totalCount,
            itemBuilder: (context, index) {
              final isActive = activeIdx != null && activeIdx == index;
              final hasActiveHighlight = activeIdx != null;

              // Determine border and opacity based on active state.
              final double borderWidth;
              final Color borderColor;
              final double opacity;

              if (hasActiveHighlight) {
                if (isActive) {
                  borderWidth = 2.0;
                  borderColor = Colors.white;
                  opacity = 1.0;
                } else {
                  borderWidth = 1.0;
                  borderColor = widget.asOverlay
                      ? Colors.white.withValues(alpha: 0.2)
                      : (isDark
                          ? AppColors.darkBorder
                          : Colors.grey.shade300);
                  opacity = 0.6;
                }
              } else {
                borderWidth = 1.5;
                borderColor = widget.asOverlay
                    ? Colors.white.withValues(alpha: 0.3)
                    : (isDark
                        ? AppColors.darkBorder
                        : Colors.grey.shade300);
                opacity = 1.0;
              }

              return Semantics(
                label: context.t.species.galleryImageLabel(
                  index: '${index + 1}',
                  total: '$totalCount',
                ),
                image: true,
                child: GestureDetector(
                  onTap: () => FullscreenGallery.open(
                    context,
                    imageUrls: urls,
                    isAsset: isAssetList,
                    initialIndex: index,
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: const EdgeInsets.only(right: _thumbSpacing),
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: borderColor,
                              width: borderWidth,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: isAssetList[index]
                                ? Image.asset(
                                    thumbUrls[index],
                                    width: _thumbWidth,
                                    height: _thumbHeight,
                                    fit: BoxFit.cover,
                                    cacheWidth: 400,
                                    cacheHeight: 225,
                                  )
                                : CachedSpeciesImage(
                                    imageUrl: thumbUrls[index],
                                    speciesId: widget.speciesId,
                                    width: _thumbWidth,
                                    height: _thumbHeight,
                                    memCacheWidth: 400,
                                    memCacheHeight: 225,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );

        if (widget.asOverlay) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.only(bottom: 12, top: 16),
            child: totalCount >= 2
                ? Stack(
                    children: [
                      content,
                      // Photo count badge at top-left of the strip.
                      Positioned(
                        left: 12,
                        top: 0,
                        child: _PhotoCountBadge(count: totalCount),
                      ),
                    ],
                  )
                : content,
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: content,
        );
      },
      loading: () => SizedBox(
        height: _thumbHeight,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// Small pill badge showing a camera icon and the total photo count.
class _PhotoCountBadge extends StatelessWidget {
  final int count;

  const _PhotoCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.camera_alt,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
