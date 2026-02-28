import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/widgets/heart_bubble_overlay.dart';
import 'package:galapagos_wildlife/features/favorites/providers/favorites_provider.dart';

/// Reusable animated heart button for toggling species favorites.
/// Use [iconSize] to control the heart size (default 20 for cards, 32 for detail).
/// Set [showBackground] to true to show a dark circle behind the icon (for cards).
class FavoriteHeartButton extends ConsumerStatefulWidget {
  final int speciesId;
  final double iconSize;
  final bool showBackground;
  final bool compact;

  const FavoriteHeartButton({
    super.key,
    required this.speciesId,
    this.iconSize = 20,
    this.showBackground = true,
    this.compact = true,
  });

  @override
  ConsumerState<FavoriteHeartButton> createState() =>
      _FavoriteHeartButtonState();
}

class _FavoriteHeartButtonState extends ConsumerState<FavoriteHeartButton>
    with SingleTickerProviderStateMixin {
  bool _showHearts = false;
  bool _reverseHearts = false;
  int _heartKey = 0;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    if (!isLoggedIn) return const SizedBox.shrink();

    final isFavorite = ref.watch(isSpeciesFavoriteProvider(widget.speciesId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final heartIcon = Icon(
      isFavorite ? Icons.favorite : Icons.favorite_border,
      color: isFavorite
          ? Colors.red
          : isDark
              ? Colors.white
              : Colors.grey.shade700,
      size: widget.iconSize,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ScaleTransition(
          scale: _scaleAnim,
          child: GestureDetector(
            onTap: () => _onTap(isFavorite),
            child: widget.showBackground
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: heartIcon,
                  )
                : Padding(
                    padding: const EdgeInsets.all(8),
                    child: heartIcon,
                  ),
          ),
        ),
        if (_showHearts)
          Positioned(
            right: widget.compact ? -24 : -60,
            bottom: _reverseHearts ? null : 0,
            top: _reverseHearts ? 0 : null,
            child: HeartBubbleOverlay(
              key: ValueKey(_heartKey),
              reverse: _reverseHearts,
              compact: widget.compact,
              onComplete: () {
                if (mounted) setState(() => _showHearts = false);
              },
            ),
          ),
      ],
    );
  }

  Future<void> _onTap(bool isFavorite) async {
    try {
      final wasFavorite = isFavorite;
      await toggleFavorite(ref, widget.speciesId);
      if (mounted) {
        _scaleCtrl.forward(from: 0);
        setState(() {
          _heartKey++; // Force new HeartBubbleOverlay instance
          _showHearts = true;
          _reverseHearts = wasFavorite;
        });
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.common.error)),
        );
      }
    }
  }
}
