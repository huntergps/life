import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import '../../providers/favorites_provider.dart';
import 'package:galapagos_wildlife/core/widgets/species_list_card.dart';
import 'package:galapagos_wildlife/core/widgets/empty_state.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: Text(context.t.favorites.title)),
        body: EmptyState(
          icon: Icons.favorite_outline,
          title: context.t.favorites.loginRequired,
          subtitle: context.t.auth.signInSubtitle,
          action: ElevatedButton(
            onPressed: () => context.pushNamed('login'),
            child: Text(context.t.auth.signIn),
          ),
        ),
      );
    }

    final speciesAsync = ref.watch(favoriteSpeciesProvider);
    final crossAxisCount = AdaptiveLayout.gridColumns(context);
    final padding = AdaptiveLayout.responsivePadding(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.t.favorites.title)),
      body: AdaptiveLayout.constrainedContent(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(favoriteSpeciesProvider);
          },
          child: speciesAsync.when(
            data: (species) {
              if (species.isEmpty) {
                return ListView(
                  children: [
                    EmptyState(
                      icon: Icons.favorite_outline,
                      title: context.t.favorites.empty,
                      subtitle: context.t.favorites.emptySubtitle,
                    ),
                  ],
                );
              }
              // Phone → single-column ListView, tablet/desktop → GridView
              if (crossAxisCount == 1) {
                return ListView.builder(
                  padding: EdgeInsets.all(padding * 0.75),
                  itemCount: species.length,
                  itemBuilder: (context, index) {
                    final s = species[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SpeciesListCard(
                        commonName: s.commonNameEn,
                        scientificName: s.scientificName,
                        thumbnailUrl: s.thumbnailUrl ?? SpeciesAssets.thumbnail(s.id),
                        conservationStatus: s.conservationStatus,
                        isEndemic: s.isEndemic,
                        speciesId: s.id,
                        dietType: s.dietType,
                        activityPattern: s.activityPattern,
                        populationTrend: s.populationTrend,
                        onTap: () => context.goNamed('species-detail', pathParameters: {'id': '${s.id}'}),
                      ),
                    );
                  },
                );
              }
              return GridView.builder(
                padding: EdgeInsets.all(padding * 0.75),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: species.length,
                itemBuilder: (context, index) {
                  final s = species[index];
                  return SpeciesListCard(
                    commonName: s.commonNameEn,
                    scientificName: s.scientificName,
                    thumbnailUrl: s.thumbnailUrl ?? SpeciesAssets.thumbnail(s.id),
                    conservationStatus: s.conservationStatus,
                    isEndemic: s.isEndemic,
                    speciesId: s.id,
                    dietType: s.dietType,
                    activityPattern: s.activityPattern,
                    populationTrend: s.populationTrend,
                    onTap: () => context.goNamed('species-detail', pathParameters: {'id': '${s.id}'}),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ListView(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 32),
                      Text(context.t.common.error),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(favoriteSpeciesProvider),
                        child: Text(context.t.common.retry),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
