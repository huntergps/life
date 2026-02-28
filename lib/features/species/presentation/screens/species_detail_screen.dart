import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/widgets/conservation_badge.dart';
import 'package:galapagos_wildlife/core/widgets/image_carousel.dart';
import 'package:galapagos_wildlife/core/widgets/favorite_heart_button.dart';
import 'package:galapagos_wildlife/core/widgets/error_state_widget.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';
import '../../providers/species_detail_provider.dart';
import '../widgets/quick_facts_row.dart';
import '../widgets/taxonomy_tree.dart';
import '../widgets/gallery_carousel.dart';

class SpeciesDetailScreen extends ConsumerWidget {
  final int speciesId;
  const SpeciesDetailScreen({super.key, required this.speciesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speciesAsync = ref.watch(speciesDetailProvider(speciesId));
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= AppConstants.tabletBreakpoint;

    final locale = ref.watch(localeProvider);

    return Scaffold(
      body: speciesAsync.when(
        data: (species) {
          if (species == null) {
            return Center(child: Text(context.t.species.notFound));
          }

          final heroUrl = species.heroImageUrl
              ?? SpeciesAssets.heroImage(speciesId)
              ?? SpeciesAssets.thumbnail(speciesId);

          if (isTablet) {
            return _TabletDetail(species: species, speciesId: speciesId, ref: ref, heroUrl: heroUrl, locale: locale);
          }
          return _PhoneDetail(species: species, speciesId: speciesId, ref: ref, heroUrl: heroUrl, locale: locale);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => ErrorStateWidget(
          error: e,
          stackTrace: st,
          onRetry: () => ref.invalidate(speciesDetailProvider(speciesId)),
        ),
      ),
    );
  }
}

class _PhoneDetail extends StatelessWidget {
  final dynamic species;
  final int speciesId;
  final WidgetRef ref;
  final String? heroUrl;
  final String locale;

  const _PhoneDetail({required this.species, required this.speciesId, required this.ref, this.heroUrl, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build combined image list (hero + gallery)
    final imagesAsync = ref.watch(speciesImagesProvider(speciesId));
    final galleryData = imagesAsync.asData?.value;
    final allUrls = <String>[];
    final allIsAsset = <bool>[];
    if (heroUrl != null) {
      allUrls.add(heroUrl!);
      allIsAsset.add(SpeciesAssets.heroImage(speciesId) == heroUrl ||
          SpeciesAssets.thumbnail(speciesId) == heroUrl);
    }
    if (galleryData != null && galleryData.isNotEmpty) {
      for (final img in galleryData) {
        if (!allUrls.contains(img.imageUrl)) {
          allUrls.add(img.imageUrl);
          allIsAsset.add(false);
        }
      }
    } else {
      for (final path in SpeciesAssets.gallery(speciesId)) {
        if (!allUrls.contains(path)) {
          allUrls.add(path);
          allIsAsset.add(true);
        }
      }
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          backgroundColor: isDark ? AppColors.darkBackground : null,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                ImageCarousel(
                  imageUrls: allUrls,
                  isAsset: allIsAsset,
                  height: 400,
                  showPhotoBadge: false,
                  speciesId: speciesId, // ✅ Enable offline fallback
                ),
                if (isDark)
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.darkBackground,
                            AppColors.darkBackground.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3, 0.6],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            _ShareButton(species: species, locale: locale),
            FavoriteHeartButton(speciesId: speciesId, iconSize: 32, showBackground: false, compact: false),
          ],
        ),
        // Gallery carousel below hero
        GalleryCarousel.asSliver(speciesId: speciesId),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _DetailContent(
              species: species,
              locale: locale,
              showCommonName: true,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// Shared content widget used by both phone and tablet layouts
class _DetailContent extends ConsumerWidget {
  final dynamic species;
  final String locale;
  final bool showCommonName;

  const _DetailContent({
    required this.species,
    required this.locale,
    this.showCommonName = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoggedIn = ref.watch(isAuthenticatedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Common name (only for phone layout)
        if (showCommonName) ...[
          Text(
            locale == 'es' ? species.commonNameEs : species.commonNameEn,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
        ],
        // Scientific name (more prominent)
        Text(
          species.scientificName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontStyle: FontStyle.italic,
            color: isDark ? Colors.white.withValues(alpha: 0.87) : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        // Badges in same row (conservation status + endemic)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (species.conservationStatus != null)
              ConservationBadge(status: species.conservationStatus!),
            if (species.isEndemic)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryLight.withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: isDark
                      ? Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3))
                      : null,
                ),
                child: Text(
                  context.t.species.endemic,
                  style: TextStyle(
                    color: isDark ? AppColors.primaryLight : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        // Taxonomy tree
        if (species.taxonomyClass != null) ...[
          TaxonomyTree(species: species),
          const SizedBox(height: 20),
        ],
        // Quick facts chips
        QuickFactsRow(species: species),
        const SizedBox(height: 20),
        // Description
        ..._localizedSection(
          context,
          label: context.t.species.description,
          en: species.descriptionEn,
          es: species.descriptionEs,
          locale: locale,
        ),
        // Habitat
        ..._localizedSection(
          context,
          label: context.t.species.habitat,
          en: species.habitatEn,
          es: species.habitatEs,
          locale: locale,
        ),

        // Extended information (only for logged-in users)
        if (isLoggedIn) ..._buildExtendedInfo(context, isDark)
        else ..._buildLoginPrompt(context, isDark),
      ],
    );
  }

  List<Widget> _buildExtendedInfo(BuildContext context, bool isDark) {
    final emptyColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;
    final emptyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: emptyColor,
      fontStyle: FontStyle.italic,
    );
    final emptyLabel = locale == 'es' ? 'Sin información' : 'No information';

    Widget emptyValue() => Text(emptyLabel, style: emptyStyle);

    final widgets = <Widget>[];

    // Behavior section — always visible
    widgets.add(Text(
      locale == 'es' ? 'Comportamiento' : 'Behavior',
      style: Theme.of(context).textTheme.titleLarge,
    ));
    widgets.add(const SizedBox(height: 8));
    final behaviorInfo = <String>[];
    if (species.dietType != null) {
      behaviorInfo.add('${locale == 'es' ? 'Dieta' : 'Diet'}: ${_formatEnumValue(species.dietType!)}');
    }
    if (species.activityPattern != null) {
      behaviorInfo.add('${locale == 'es' ? 'Actividad' : 'Activity'}: ${_formatEnumValue(species.activityPattern!)}');
    }
    if (species.socialStructure != null) {
      behaviorInfo.add('${locale == 'es' ? 'Social' : 'Social'}: ${_formatEnumValue(species.socialStructure!)}');
    }
    if (species.primaryFoodSources != null && species.primaryFoodSources!.isNotEmpty) {
      behaviorInfo.add('${locale == 'es' ? 'Alimentación' : 'Food'}: ${species.primaryFoodSources!.join(', ')}');
    }
    widgets.add(behaviorInfo.isEmpty
        ? emptyValue()
        : Text(behaviorInfo.join(' • '), style: Theme.of(context).textTheme.bodyMedium));
    widgets.add(const SizedBox(height: 20));

    // Reproduction section — always visible
    widgets.add(Text(
      locale == 'es' ? 'Reproducción' : 'Reproduction',
      style: Theme.of(context).textTheme.titleLarge,
    ));
    widgets.add(const SizedBox(height: 8));
    final reproInfo = <String>[];
    if (species.breedingSeason != null) {
      reproInfo.add('${locale == 'es' ? 'Temporada' : 'Season'}: ${species.breedingSeason}');
    }
    if (species.clutchSize != null) {
      reproInfo.add('${locale == 'es' ? 'Tamaño de puesta' : 'Clutch size'}: ${species.clutchSize}');
    }
    if (species.reproductiveFrequency != null) {
      reproInfo.add('${locale == 'es' ? 'Frecuencia' : 'Frequency'}: ${species.reproductiveFrequency}');
    }
    widgets.add(reproInfo.isEmpty
        ? emptyValue()
        : Text(reproInfo.join(' • '), style: Theme.of(context).textTheme.bodyMedium));
    widgets.add(const SizedBox(height: 20));

    // Distinguishing features — always visible
    widgets.add(Text(
      locale == 'es' ? 'Características Distintivas' : 'Distinguishing Features',
      style: Theme.of(context).textTheme.titleLarge,
    ));
    widgets.add(const SizedBox(height: 8));
    final features = locale == 'es'
        ? (species.distinguishingFeaturesEs ?? species.distinguishingFeaturesEn)
        : species.distinguishingFeaturesEn;
    widgets.add((features == null || features.isEmpty)
        ? emptyValue()
        : Text(features, style: Theme.of(context).textTheme.bodyMedium));
    if (species.sexualDimorphism != null && species.sexualDimorphism!.isNotEmpty) {
      widgets.add(const SizedBox(height: 8));
      widgets.add(Text(
        '${locale == 'es' ? 'Dimorfismo sexual' : 'Sexual dimorphism'}: ${species.sexualDimorphism}',
        style: Theme.of(context).textTheme.bodyMedium,
      ));
    }
    widgets.add(const SizedBox(height: 20));

    return widgets;
  }

  List<Widget> _buildLoginPrompt(BuildContext context, bool isDark) {
    return [
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.primaryLight.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.primaryLight.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lock_outline,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locale == 'es'
                        ? 'Información Detallada'
                        : 'Detailed Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    locale == 'es'
                        ? 'Inicia sesión para acceder a información extendida sobre comportamiento, reproducción, características y más.'
                        : 'Sign in to access extended information about behavior, reproduction, features and more.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
    ];
  }

  String _formatEnumValue(String value) {
    return value.split('_').map((word) =>
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  List<Widget> _localizedSection(
    BuildContext context, {
    required String label,
    String? en,
    String? es,
    required String locale,
  }) {
    final text = locale == 'es' ? (es ?? en) : en;
    if (text == null) return [];
    return [
      Text(label, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(text, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 20),
    ];
  }
}

class _TabletDetail extends StatelessWidget {
  final dynamic species;
  final int speciesId;
  final WidgetRef ref;
  final String? heroUrl;
  final String locale;

  const _TabletDetail({required this.species, required this.speciesId, required this.ref, this.heroUrl, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build combined image list (hero + gallery)
    final imagesAsync = ref.watch(speciesImagesProvider(speciesId));
    final galleryData = imagesAsync.asData?.value;
    final allUrls = <String>[];
    final allIsAsset = <bool>[];
    if (heroUrl != null) {
      allUrls.add(heroUrl!);
      allIsAsset.add(SpeciesAssets.heroImage(speciesId) == heroUrl ||
          SpeciesAssets.thumbnail(speciesId) == heroUrl);
    }
    if (galleryData != null && galleryData.isNotEmpty) {
      for (final img in galleryData) {
        if (!allUrls.contains(img.imageUrl)) {
          allUrls.add(img.imageUrl);
          allIsAsset.add(false);
        }
      }
    } else {
      for (final path in SpeciesAssets.gallery(speciesId)) {
        if (!allUrls.contains(path)) {
          allUrls.add(path);
          allIsAsset.add(true);
        }
      }
    }

    return Row(
      children: [
        // Left panel - info (fixed max width so only the image expands)
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Scaffold(
            appBar: AppBar(
              title: Text(locale == 'es' ? species.commonNameEs : species.commonNameEn),
              actions: [
                _ShareButton(species: species, locale: locale),
                FavoriteHeartButton(speciesId: speciesId, iconSize: 32, showBackground: false, compact: false),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _DetailContent(
                  species: species,
                  locale: locale,
                  showCommonName: false,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        // Right panel - hero image (takes all remaining space)
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ImageCarousel(
                imageUrls: allUrls,
                isAsset: allIsAsset,
                height: MediaQuery.sizeOf(context).height,
                showPageIndicator: false,
                showPhotoBadge: false,
                speciesId: speciesId, // ✅ Enable offline fallback
              ),
              if (isDark)
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.darkBackground.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.2],
                      ),
                    ),
                  ),
                ),
              // Gallery carousel overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GalleryCarousel.asTabletOverlay(speciesId: speciesId),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  final dynamic species;
  final String locale;

  const _ShareButton({required this.species, required this.locale});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share),
      tooltip: context.t.share.species,
      onPressed: () {
        final isEs = locale == 'es';
        final name = isEs ? species.commonNameEs : species.commonNameEn;
        final text = context.t.share.shareText(
          name: name,
          scientificName: species.scientificName,
        );
        final details = StringBuffer(text);
        if (species.conservationStatus != null) {
          details.write(
              '\n\u{1F539} ${context.t.species.conservationStatus}: ${species.conservationStatus}');
        }
        if (species.isEndemic) {
          details.write('\n\u{1F539} ${context.t.species.endemic}');
        }
        details.write('\n\ngalapagos://species/${species.id}');
        final box = context.findRenderObject() as RenderBox?;
        SharePlus.instance.share(ShareParams(
          text: details.toString(),
          sharePositionOrigin: box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : Rect.zero,
        ));
      },
    );
  }
}

