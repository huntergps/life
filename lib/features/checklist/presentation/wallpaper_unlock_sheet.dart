import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Shows unlockable wallpapers as a reward for completing the checklist.
Future<void> showWallpaperUnlockSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const WallpaperUnlockSheet(),
  );
}

class WallpaperUnlockSheet extends StatelessWidget {
  const WallpaperUnlockSheet({super.key});

  // Use species hero images as wallpapers
  static const _wallpapers = [
    {
      'title': 'Marine Iguana',
      'url':
          'https://vojbznerffkemxqlwapf.supabase.co/storage/v1/object/public/species-images/species/1/hero.jpg',
    },
    {
      'title': 'Blue-footed Booby',
      'url':
          'https://vojbznerffkemxqlwapf.supabase.co/storage/v1/object/public/species-images/species/5/hero.jpg',
    },
    {
      'title': 'Giant Tortoise',
      'url':
          'https://vojbznerffkemxqlwapf.supabase.co/storage/v1/object/public/species-images/species/3/hero.jpg',
    },
    {
      'title': 'Galapagos Penguin',
      'url':
          'https://vojbznerffkemxqlwapf.supabase.co/storage/v1/object/public/species-images/species/8/hero.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isEs = LocaleSettings.currentLocale == AppLocale.es;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_open, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                isEs
                    ? 'Fondos de pantalla desbloqueados'
                    : 'Wallpapers Unlocked',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isEs
                ? 'Descarga fondos exclusivos de Galapagos'
                : 'Download exclusive Galapagos wallpapers',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ..._wallpapers.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: w['url']!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: Colors.grey,
                          child: const Center(
                            child: Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
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
                        child: Text(
                          w['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
