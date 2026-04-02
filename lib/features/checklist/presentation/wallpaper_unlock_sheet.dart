import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

/// Data class for a wallpaper entry.
class _WallpaperItem {
  const _WallpaperItem({required this.title, required this.imageUrl});
  final String title;
  final String imageUrl;
}

class WallpaperUnlockSheet extends StatefulWidget {
  const WallpaperUnlockSheet({super.key});

  @override
  State<WallpaperUnlockSheet> createState() => _WallpaperUnlockSheetState();
}

class _WallpaperUnlockSheetState extends State<WallpaperUnlockSheet> {
  late Future<List<_WallpaperItem>> _wallpapersFuture;
  final Set<String> _downloading = {};

  // Fallback wallpapers when no admin-uploaded ones exist.
  static const _defaultWallpapers = [
    _WallpaperItem(
      title: 'Marine Iguana',
      imageUrl:
          'https://vojbznerffkemxqlwapf.supabase.co/storage/v1/object/public/species-images/1/gallery_0_marine_iguana_closeup.jpeg',
    ),
    _WallpaperItem(
      title: 'Blue-footed Booby',
      imageUrl:
          'https://vojbznerffkemxqlwapf.supabase.co/storage/v1/object/public/species-images/5/gallery_0_blue_footed_booby_standing.jpg',
    ),
    _WallpaperItem(
      title: 'Giant Tortoise',
      imageUrl:
          'https://vojbznerffkemxqlwapf.supabase.co/storage/v1/object/public/species-images/3/gallery_0_giant_tortoise_pair.jpg',
    ),
    _WallpaperItem(
      title: 'Galapagos Penguin',
      imageUrl:
          'https://vojbznerffkemxqlwapf.supabase.co/storage/v1/object/public/species-images/8/gallery_0_penguin_swimming.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _wallpapersFuture = _fetchWallpapers();
  }

  Future<List<_WallpaperItem>> _fetchWallpapers() async {
    try {
      final response = await Supabase.instance.client
          .from('wallpapers')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      final rows = response as List;
      if (rows.isEmpty) return _defaultWallpapers;
      return rows
          .map(
            (r) => _WallpaperItem(
              title: r['title'] as String,
              imageUrl: r['image_url'] as String,
            ),
          )
          .toList();
    } catch (_) {
      return _defaultWallpapers;
    }
  }

  Future<void> _downloadWallpaper(String url, String title) async {
    if (_downloading.contains(url)) return;
    setState(() => _downloading.add(url));
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download failed')),
          );
        }
        return;
      }
      final tempDir = await getTemporaryDirectory();
      final safeName = title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      final file = File('${tempDir.path}/$safeName.jpg');
      await file.writeAsBytes(response.bodyBytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading.remove(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEs = LocaleSettings.currentLocale == AppLocale.es;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, controller) => FutureBuilder<List<_WallpaperItem>>(
        future: _wallpapersFuture,
        builder: (context, snapshot) {
          final wallpapers = snapshot.data ?? _defaultWallpapers;
          final isLoading =
              snapshot.connectionState == ConnectionState.waiting;

          return ListView(
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
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ...wallpapers.map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: CachedNetworkImage(
                              imageUrl: w.imageUrl,
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
                          // Title overlay at bottom-left
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
                                w.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Download button at bottom-right
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: FilledButton.icon(
                              onPressed: _downloading.contains(w.imageUrl)
                                  ? null
                                  : () => _downloadWallpaper(
                                        w.imageUrl,
                                        w.title,
                                      ),
                              icon: _downloading.contains(w.imageUrl)
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.download, size: 16),
                              label: Text(
                                _downloading.contains(w.imageUrl)
                                    ? (isEs ? 'Guardando...' : 'Saving...')
                                    : (isEs ? 'Guardar' : 'Save'),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.black54,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
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
          );
        },
      ),
    );
  }
}
