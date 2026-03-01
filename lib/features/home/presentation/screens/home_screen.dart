import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import 'package:galapagos_wildlife/core/widgets/cached_species_image.dart';
import '../widgets/category_grid.dart';
import '../../providers/home_provider.dart';
import 'package:galapagos_wildlife/core/widgets/species_card.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:galapagos_wildlife/features/species/providers/species_list_provider.dart';

// Search button shared across phone and tablet layouts
class _SearchButton extends StatelessWidget {
  const _SearchButton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      icon: Icon(
        Icons.search,
        color: isDark ? Colors.white70 : Colors.white,
      ),
      tooltip: context.t.search.title,
      onPressed: () => context.push('/search'),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= AppConstants.tabletBreakpoint;

    if (isTablet) {
      return _TabletHome(ref: ref);
    }
    return _PhoneHome(ref: ref);
  }
}

class _PhoneHome extends StatelessWidget {
  final WidgetRef ref;
  const _PhoneHome({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(categoriesProvider);
              ref.invalidate(featuredSpeciesProvider);
              ref.invalidate(allSpeciesProvider);
            },
            child: CustomScrollView(
              slivers: [
                // Hero section
                SliverToBoxAdapter(child: _WildlifeHero(ref: ref)),

            // Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.t.home.categories, style: Theme.of(context).textTheme.titleLarge),
                    TextButton(
                      onPressed: () => context.goNamed('species'),
                      child: Text(context.t.home.viewAll),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: CategoryGrid()),
            // Featured Species
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(context.t.home.featured, style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            SliverToBoxAdapter(child: _buildFeaturedSpecies(context, ref)),
            // Quick Links
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(context.t.home.quickLinks, style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            SliverToBoxAdapter(child: _buildQuickLinks(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
          // Search button floating over the hero area
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const _SearchButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSpecies(BuildContext context, WidgetRef ref) {
    final speciesAsync = ref.watch(featuredSpeciesProvider);
    final isEs = ref.watch(localeProvider.select((l) => l == 'es'));
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Responsive card width: ~45% of screen on phone, clamped to reasonable range
    final cardWidth = (screenWidth * 0.45).clamp(160.0, 240.0);
    return speciesAsync.when(
      data: (species) => SizedBox(
        height: 260,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: species.length,
          itemBuilder: (context, index) {
            final s = species[index];
            return SizedBox(
              key: ObjectKey(s.id),
              width: cardWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SpeciesCard(
                  commonName: isEs ? s.commonNameEs : s.commonNameEn,
                  scientificName: s.scientificName,
                  thumbnailUrl: s.thumbnailUrl ?? SpeciesAssets.thumbnail(s.id),
                  conservationStatus: s.conservationStatus,
                  isEndemic: s.isEndemic,
                  speciesId: s.id,
                  dietType: s.dietType,
                  activityPattern: s.activityPattern,
                  populationTrend: s.populationTrend,
                  expandImage: true,
                  onTap: () => context.goNamed('species-detail', pathParameters: {'id': '${s.id}'}),
                ),
              ),
            );
          },
        ),
      ),
      loading: () => const SizedBox(height: 260, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SizedBox(
        height: 100,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.t.common.error),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => ref.invalidate(featuredSpeciesProvider),
                child: Text(context.t.common.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _QuickLinkTile(
            icon: Icons.pets,
            title: context.t.home.discoverSpecies,
            subtitle: context.t.home.browseWildlife,
            isDark: isDark,
            onTap: () => context.goNamed('species'),
          ),
          _QuickLinkTile(
            icon: Icons.map,
            title: context.t.home.exploreMap,
            subtitle: context.t.home.findSites,
            isDark: isDark,
            onTap: () => context.goNamed('map'),
          ),
          _QuickLinkTile(
            icon: Icons.camera_alt,
            title: context.t.home.recentSightings,
            subtitle: context.t.home.logEncounters,
            isDark: isDark,
            onTap: () => context.goNamed('sightings'),
          ),
        ],
      ),
    );
  }
}

class _TabletHome extends StatelessWidget {
  final WidgetRef ref;
  const _TabletHome({required this.ref});

  @override
  Widget build(BuildContext context) {
    final speciesAsync = ref.watch(featuredSpeciesProvider);
    final isEs = ref.watch(localeProvider.select((l) => l == 'es'));
    String speciesName(dynamic s) => isEs ? s.commonNameEs : s.commonNameEn;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Row(
        children: [
          // Left panel - info
          Expanded(
            flex: 2,
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(categoriesProvider);
                ref.invalidate(featuredSpeciesProvider);
                ref.invalidate(allSpeciesProvider);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 60, 16, 32),
                children: [
                  Text(
                    'GALAPAGOS',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      letterSpacing: 6,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'WILDLIFE',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.accentOrange,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search entry point
                  InkWell(
                    onTap: () => context.push('/search'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkCard
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkBorder
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white38
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.t.search.hint,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white38
                                  : Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Categories
                  Text(context.t.home.categories, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const CategoryGrid(),
                  const SizedBox(height: 24),
                  // Featured species list
                  Text(context.t.home.featured, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  speciesAsync.when(
                    data: (species) => Column(
                      children: species.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedSpeciesImage(
                              imageUrl: s.thumbnailUrl ?? SpeciesAssets.thumbnail(s.id),
                              speciesId: s.id,
                              width: 56,
                              height: 56,
                            ),
                          ),
                          title: Text(speciesName(s)),
                          subtitle: Text(s.scientificName, style: const TextStyle(fontStyle: FontStyle.italic)),
                          onTap: () => context.goNamed('species-detail', pathParameters: {'id': '${s.id}'}),
                        ),
                      )).toList(),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.t.common.error),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () => ref.invalidate(featuredSpeciesProvider),
                          child: Text(context.t.common.retry),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right panel - hero image
          Expanded(
            flex: 3,
            child: speciesAsync.when(
              data: (species) {
                if (species.isEmpty) return const SizedBox.expand();
                final featured = species.first;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedSpeciesImage(
                      imageUrl: featured.heroImageUrl ?? SpeciesAssets.heroImage(featured.id) ?? SpeciesAssets.thumbnail(featured.id),
                      speciesId: featured.id,
                      fit: BoxFit.cover,
                      semanticLabel: context.t.species.featuredImageLabel(name: speciesName(featured)),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.darkBackground,
                            AppColors.darkBackground.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.15, 0.4],
                        ),
                      ),
                    ),
                    // Bottom gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.darkBackground.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3],
                        ),
                      ),
                    ),
                    // Species name overlay
                    Positioned(
                      left: 24,
                      bottom: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            speciesName(featured),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            featured.scientificName,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => Container(color: AppColors.darkSurface),
              error: (_, _) => Container(color: AppColors.darkSurface),
            ),
          ),
        ],
      ),
    );
  }
}

// Wildlife hero for phone - fullscreen PageView
class _WildlifeHero extends StatefulWidget {
  final WidgetRef ref;
  const _WildlifeHero({required this.ref});

  @override
  State<_WildlifeHero> createState() => _WildlifeHeroState();
}

class _WildlifeHeroState extends State<_WildlifeHero> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speciesAsync = widget.ref.watch(featuredSpeciesProvider);
    final isEs = widget.ref.watch(localeProvider.select((l) => l == 'es'));
    final screenHeight = MediaQuery.sizeOf(context).height;
    String speciesName(dynamic s) => isEs ? s.commonNameEs : s.commonNameEn;
    String? speciesDesc(dynamic s) => isEs ? (s.descriptionEs ?? s.descriptionEn) : s.descriptionEn;

    return speciesAsync.when(
      data: (species) {
        final featured = species.take(4).toList();
        if (featured.isEmpty) {
          return SizedBox(
            height: screenHeight * 0.55,
            child: _fallbackHero(context),
          );
        }
        return SizedBox(
          height: screenHeight * 0.55,
          child: Stack(
            children: [
              // PageView
              PageView.builder(
                controller: _pageController,
                itemCount: featured.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final s = featured[index];
                  final desc = speciesDesc(s);
                  return Semantics(
                    key: ObjectKey(s.id),
                    button: true,
                    child: GestureDetector(
                    onTap: () => context.goNamed('species-detail', pathParameters: {'id': '${s.id}'}),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedSpeciesImage(
                          imageUrl: s.heroImageUrl ?? SpeciesAssets.heroImage(s.id) ?? SpeciesAssets.thumbnail(s.id),
                          speciesId: s.id,
                          fit: BoxFit.cover,
                          semanticLabel: context.t.species.featuredImageLabel(name: speciesName(s)),
                        ),
                        // Dark gradient from bottom
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.darkBackground,
                                AppColors.darkBackground.withValues(alpha: 0.6),
                                Colors.transparent,
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.25, 0.55, 1.0],
                            ),
                          ),
                        ),
                        // Content overlay
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                speciesName(s).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.scientificName,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              if (desc != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  desc,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                                ),
                              ],
                              const SizedBox(height: 12),
                              // Quick facts row
                              _HeroFactsRow(species: s),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  );
                },
              ),
              // Page indicator
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentPage + 1} / ${featured.length}',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => SizedBox(
        height: screenHeight * 0.55,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => SizedBox(
        height: screenHeight * 0.55,
        child: _fallbackHero(context),
      ),
    );
  }

  Widget _fallbackHero(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Semantics(
          label: context.t.app.name,
          image: true,
          child: Image.asset(
            'assets/images/hero/flamingo_group_shore.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.darkBackground,
                AppColors.darkBackground.withValues(alpha: 0.6),
                Colors.transparent,
                Colors.transparent,
              ],
              stops: const [0.0, 0.25, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GALAPAGOS',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  letterSpacing: 6,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'WILDLIFE',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.accentOrange,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.t.app.subtitle,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroFactsRow extends StatelessWidget {
  final dynamic species;
  const _HeroFactsRow({required this.species});

  @override
  Widget build(BuildContext context) {
    final facts = <Widget>[];

    if (species.weightKg != null) {
      facts.add(_factChip('${species.weightKg} ${context.t.species.kg}', context.t.species.weight));
    }
    if (species.sizeCm != null) {
      facts.add(_factChip('${species.sizeCm} ${context.t.species.cm}', context.t.species.size));
    }
    if (species.populationEstimate != null) {
      facts.add(_factChip('~${species.populationEstimate}', context.t.species.population));
    }

    if (facts.isEmpty) return const SizedBox.shrink();

    return Row(
      children: facts
          .expand((w) => [w, const SizedBox(width: 12)])
          .toList()
        ..removeLast(),
    );
  }

  Widget _factChip(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDark
              ? AppColors.primaryLight.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(icon, color: isDark ? AppColors.primaryLight : Theme.of(context).colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle, style: TextStyle(color: isDark ? Colors.white54 : null)),
        trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white38 : null),
        onTap: onTap,
      ),
    );
  }
}
