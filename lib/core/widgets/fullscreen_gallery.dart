import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cached_species_image.dart';

/// Fullscreen image gallery with swipe navigation, zoom, auto-advance,
/// and a thumbnail strip at the bottom.
class FullscreenGallery extends StatefulWidget {
  final List<String> imageUrls;
  final List<bool> isAsset;
  final int initialIndex;
  final String? heroTag;

  const FullscreenGallery({
    super.key,
    required this.imageUrls,
    required this.isAsset,
    this.initialIndex = 0,
    this.heroTag,
  });

  static void open(
    BuildContext context, {
    required List<String> imageUrls,
    required List<bool> isAsset,
    int initialIndex = 0,
    String? heroTag,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullscreenGallery(
            imageUrls: imageUrls,
            isAsset: isAsset,
            initialIndex: initialIndex,
            heroTag: heroTag,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<FullscreenGallery>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late ScrollController _thumbScrollController;
  late int _currentIndex;

  // Auto-advance
  static const _autoAdvanceDuration = Duration(seconds: 30);
  bool _isPlaying = true;
  Timer? _autoAdvanceTimer;
  late AnimationController _progressController;

  // Thumbnail dimensions
  static const _thumbHeight = 56.0;
  static const _thumbWidth = _thumbHeight * 16 / 9; // ~99.5
  static const _thumbSpacing = 6.0;
  static const _thumbBorderActive = 2.0;

  // Double-tap zoom
  late TransformationController _transformationController;
  TapDownDetails? _doubleTapDetails;
  late AnimationController _zoomAnimController;
  Animation<Matrix4>? _zoomAnimation;

  // Swipe down to close
  double _dragOffset = 0;
  bool _isDraggingDown = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _thumbScrollController = ScrollController();
    _progressController = AnimationController(
      vsync: this,
      duration: _autoAdvanceDuration,
    );
    _transformationController = TransformationController();
    _zoomAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        if (_zoomAnimation != null) {
          _transformationController.value = _zoomAnimation!.value;
        }
      });
    if (widget.imageUrls.length > 1) {
      _startAutoAdvance();
    } else {
      _isPlaying = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollThumbToIndex(_currentIndex, animate: false);
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _progressController.dispose();
    _pageController.dispose();
    _thumbScrollController.dispose();
    _transformationController.dispose();
    _zoomAnimController.dispose();
    super.dispose();
  }

  void _toggleAutoAdvance() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startAutoAdvance();
      } else {
        _stopAutoAdvance();
      }
    });
  }

  void _startAutoAdvance() {
    _progressController.forward(from: 0);
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(_autoAdvanceDuration, (_) {
      _advanceToNext();
    });
  }

  void _stopAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
    _progressController.stop();
    _progressController.value = 0;
  }

  void _advanceToNext() {
    final nextIndex = _currentIndex + 1 < widget.imageUrls.length
        ? _currentIndex + 1
        : 0;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    _progressController.forward(from: 0);
  }

  void _onManualNavigation() {
    if (_isPlaying) {
      _autoAdvanceTimer?.cancel();
      _progressController.forward(from: 0);
      _autoAdvanceTimer = Timer.periodic(_autoAdvanceDuration, (_) {
        _advanceToNext();
      });
    }
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _onManualNavigation();
  }

  void _scrollThumbToIndex(int index, {bool animate = true}) {
    if (!_thumbScrollController.hasClients) return;
    final itemExtent = _thumbWidth + _thumbSpacing;
    final viewportWidth = _thumbScrollController.position.viewportDimension;
    final targetOffset = (index * itemExtent) - (viewportWidth / 2) + (itemExtent / 2);
    final clampedOffset = targetOffset.clamp(
      0.0,
      _thumbScrollController.position.maxScrollExtent,
    );
    if (animate) {
      _thumbScrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _thumbScrollController.jumpTo(clampedOffset);
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    _zoomAnimController.reset();
    _zoomAnimation = null;
  }

  bool get _isZoomed {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    return scale > 1.05;
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_isZoomed) {
      final begin = _transformationController.value;
      final end = Matrix4.identity();
      _zoomAnimation = Matrix4Tween(begin: begin, end: end).animate(
        CurvedAnimation(parent: _zoomAnimController, curve: Curves.easeOut),
      );
      _zoomAnimController.forward(from: 0);
    } else {
      final position = _doubleTapDetails!.localPosition;
      const scale = 2.5;
      final x = -position.dx * (scale - 1);
      final y = -position.dy * (scale - 1);
      final zoomed = Matrix4.identity()
        ..translateByDouble(x, y, 0.0, 1.0)
        ..scaleByDouble(scale, scale, 1.0, 1.0);
      final begin = _transformationController.value;
      _zoomAnimation = Matrix4Tween(begin: begin, end: zoomed).animate(
        CurvedAnimation(parent: _zoomAnimController, curve: Curves.easeOut),
      );
      _zoomAnimController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final showThumbs = widget.imageUrls.length > 1;
    final thumbOverlayHeight = showThumbs
        ? _thumbHeight + 20 + bottomPadding + (_isPlaying ? 3 : 0)
        : 0.0;

    final clampedDrag = _dragOffset.clamp(0.0, 300.0);
    final dragOpacity = (1 - _dragOffset / 400).clamp(0.5, 1.0);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          if (_currentIndex > 0) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            _onManualNavigation();
          }
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          if (_currentIndex < widget.imageUrls.length - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            _onManualNavigation();
          }
        },
        const SingleActivator(LogicalKeyboardKey.space): _toggleAutoAdvance,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onVerticalDragUpdate: _isZoomed
                ? null
                : (details) {
                    if (details.delta.dy > 0 || _isDraggingDown) {
                      setState(() {
                        _isDraggingDown = true;
                        _dragOffset += details.delta.dy;
                        if (_dragOffset < 0) _dragOffset = 0;
                      });
                    }
                  },
            onVerticalDragEnd: _isZoomed
                ? null
                : (details) {
                    if (_dragOffset > 100) {
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        _dragOffset = 0;
                        _isDraggingDown = false;
                      });
                    }
                  },
            onVerticalDragCancel: _isZoomed
                ? null
                : () {
                    setState(() {
                      _dragOffset = 0;
                      _isDraggingDown = false;
                    });
                  },
            child: Opacity(
              opacity: dragOpacity,
              child: Transform.translate(
                offset: Offset(0, clampedDrag),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.imageUrls.length,
                        physics: _isDraggingDown
                            ? const NeverScrollableScrollPhysics()
                            : null,
                        onPageChanged: (i) {
                          setState(() => _currentIndex = i);
                          _scrollThumbToIndex(i);
                          _onManualNavigation();
                          _resetZoom();
                        },
                        itemBuilder: (context, index) {
                          final imageWidget = widget.isAsset[index]
                              ? Image.asset(
                                  widget.imageUrls[index],
                                  fit: BoxFit.contain,
                                )
                              : CachedSpeciesImage(
                                  imageUrl: widget.imageUrls[index],
                                  fit: BoxFit.contain,
                                );

                          final isCurrentPage = index == _currentIndex;
                          final useHero = widget.heroTag != null && isCurrentPage;

                          Widget content = Center(child: imageWidget);
                          if (useHero) {
                            content = Center(
                              child: Hero(
                                tag: widget.heroTag!,
                                child: imageWidget,
                              ),
                            );
                          }

                          return Semantics(
                            label: '${index + 1} / ${widget.imageUrls.length}',
                            image: true,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              onDoubleTapDown: isCurrentPage
                                  ? _handleDoubleTapDown
                                  : null,
                              onDoubleTap:
                                  isCurrentPage ? _handleDoubleTap : null,
                              child: InteractiveViewer(
                                transformationController: isCurrentPage
                                    ? _transformationController
                                    : null,
                                minScale: 0.5,
                                maxScale: 4.0,
                                child: content,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    if (showThumbs)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.85),
                                Colors.black.withValues(alpha: 0.6),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.7, 1.0],
                            ),
                          ),
                          padding: EdgeInsets.only(
                            top: 20,
                            bottom: bottomPadding + (_isPlaying ? 6 : 8),
                          ),
                          child: SizedBox(
                            height: _thumbHeight,
                            child: ListView.builder(
                              controller: _thumbScrollController,
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: widget.imageUrls.length,
                              itemBuilder: (context, index) {
                                final isSelected = index == _currentIndex;
                                return Semantics(
                                  label: 'Thumbnail ${index + 1}',
                                  button: true,
                                  child: GestureDetector(
                                    onTap: () => _goToPage(index),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(
                                          right: _thumbSpacing),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white24,
                                          width: isSelected
                                              ? _thumbBorderActive
                                              : 1,
                                        ),
                                      ),
                                      child: AnimatedOpacity(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        opacity: isSelected ? 1.0 : 0.5,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: widget.isAsset[index]
                                              ? Image.asset(
                                                  widget.imageUrls[index],
                                                  width: _thumbWidth,
                                                  height: _thumbHeight,
                                                  fit: BoxFit.cover,
                                                )
                                              : CachedSpeciesImage(
                                                  imageUrl:
                                                      widget.imageUrls[index],
                                                  width: _thumbWidth,
                                                  height: _thumbHeight,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                    if (_isPlaying)
                      Positioned(
                        bottom: bottomPadding,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, _) {
                            return LinearProgressIndicator(
                              value: _progressController.value,
                              backgroundColor: Colors.white10,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white38),
                              minHeight: 3,
                            );
                          },
                        ),
                      ),

                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 28),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black45,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),

                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.imageUrls.length > 1)
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: 18,
                                    icon: Icon(
                                      _isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white70,
                                    ),
                                    onPressed: _toggleAutoAdvance,
                                  ),
                                ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '${_currentIndex + 1} / ${widget.imageUrls.length}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (widget.imageUrls.length > 1) ...[
                      if (_currentIndex > 0)
                        Positioned(
                          left: 16,
                          top: 0,
                          bottom: thumbOverlayHeight,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(Icons.chevron_left,
                                  color: Colors.white70, size: 40),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black38,
                              ),
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                                _onManualNavigation();
                              },
                            ),
                          ),
                        ),
                      if (_currentIndex < widget.imageUrls.length - 1)
                        Positioned(
                          right: 16,
                          top: 0,
                          bottom: thumbOverlayHeight,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(Icons.chevron_right,
                                  color: Colors.white70, size: 40),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black38,
                              ),
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                                _onManualNavigation();
                              },
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
