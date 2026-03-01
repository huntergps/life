import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import 'package:galapagos_wildlife/core/widgets/error_state_widget.dart';
import '../../providers/admin_category_provider.dart';
import '../widgets/admin_entity_tile.dart';

// ── Dashboard tile counts ──

final _dashboardCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(adminSupabaseServiceProvider);
  final results = await Future.wait([
    service.getActiveCount('species'),
    service.getActiveCount('categories'),
    service.getActiveCount('islands'),
    service.getActiveCount('visit_sites'),
    service.getTaxonomyCount(),
    service.getCount('species_sites'),
    service.getCount('site_type_catalog'),
    service.getCount('site_modality_catalog'),
    service.getCount('site_activity_catalog'),
    service.getCount('profiles'),
  ]);
  return {
    'species': results[0],
    'categories': results[1],
    'islands': results[2],
    'visit_sites': results[3],
    'taxonomy': results[4],
    'species_sites': results[5],
    'site_catalogs': results[6] + results[7] + results[8],
    'users': results[9],
  };
});

// ── Dashboard statistics ──

class DashboardStats {
  final List<Map<String, dynamic>> speciesByCategory;
  final int orphanVisitSites;
  final int speciesWithoutImages;

  const DashboardStats({
    required this.speciesByCategory,
    required this.orphanVisitSites,
    required this.speciesWithoutImages,
  });
}

final _dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final service = ref.watch(adminSupabaseServiceProvider);
  final results = await Future.wait([
    service.getSpeciesCountByCategory(),
    service.getOrphanVisitSitesCount(),
    service.getSpeciesWithoutImagesCount(),
  ]);
  return DashboardStats(
    speciesByCategory: results[0] as List<Map<String, dynamic>>,
    orphanVisitSites: results[1] as int,
    speciesWithoutImages: results[2] as int,
  );
});

// ── Screen ──

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(_dashboardCountsProvider);
    final statsAsync = ref.watch(_dashboardStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.admin.panel),
        backgroundColor: isDark ? AppColors.darkBackground : null,
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: context.t.admin.backToHome,
          onPressed: () => context.go('/'),
        ),
      ),
      body: countsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(
          error: e,
          onRetry: () {
            ref.invalidate(_dashboardCountsProvider);
            ref.invalidate(_dashboardStatsProvider);
          },
        ),
        data: (counts) {
          final crossAxisCount = AdaptiveLayout.gridColumns(context);
          final padding = AdaptiveLayout.responsivePadding(context);
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(_dashboardCountsProvider);
              ref.invalidate(_dashboardStatsProvider);
            },
            child: AdaptiveLayout.constrainedContent(
              child: ListView(
                padding: EdgeInsets.all(padding),
                children: [
                  // ── Entity Grid Tiles ──
                  GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      AdminEntityTile(
                        title: context.t.admin.species,
                        subtitle: context.t.admin.manageContent,
                        icon: Icons.pets,
                        count: counts['species'],
                        onTap: () => context.go('/admin/species'),
                      ),
                      AdminEntityTile(
                        title: context.t.admin.categories,
                        subtitle: context.t.admin.manageCategories,
                        icon: Icons.category,
                        count: counts['categories'],
                        onTap: () => context.go('/admin/categories'),
                      ),
                      AdminEntityTile(
                        title: context.t.admin.islands,
                        subtitle: context.t.admin.manageIslands,
                        icon: Icons.landscape,
                        count: counts['islands'],
                        onTap: () => context.go('/admin/islands'),
                      ),
                      AdminEntityTile(
                        title: context.t.admin.visitSites,
                        subtitle: context.t.admin.manageSites,
                        icon: Icons.place,
                        count: counts['visit_sites'],
                        onTap: () => context.go('/admin/visit-sites'),
                      ),
                      AdminEntityTile(
                        title: context.t.species.taxonomy,
                        subtitle: context.t.admin.taxonomySubtitle,
                        icon: Icons.account_tree,
                        count: counts['taxonomy'],
                        onTap: () => context.go('/admin/taxonomy'),
                      ),
                      AdminEntityTile(
                        title: context.t.admin.speciesSites,
                        subtitle: context.t.admin.manageRelationships,
                        icon: Icons.link,
                        count: counts['species_sites'],
                        onTap: () => context.go('/admin/species-sites'),
                      ),
                      AdminEntityTile(
                        title: context.t.admin.siteCatalogs,
                        subtitle: context.t.admin.manageCatalogs,
                        icon: Icons.label_outline,
                        count: counts['site_catalogs'],
                        onTap: () => context.go('/admin/site-catalogs'),
                      ),
                      AdminEntityTile(
                        title: context.t.admin.users,
                        subtitle: context.t.admin.manageUsers,
                        icon: Icons.people_outline,
                        count: counts['users'],
                        onTap: () => context.go('/admin/users'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Statistics Section ──
                  _StatisticsSection(statsAsync: statsAsync, isDark: isDark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Statistics Section Widget ──

class _StatisticsSection extends StatelessWidget {
  final AsyncValue<DashboardStats> statsAsync;
  final bool isDark;

  const _StatisticsSection({
    required this.statsAsync,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 24,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              context.t.admin.statistics,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Divider(
          color: isDark ? AppColors.darkBorder : Colors.grey[300],
        ),
        const SizedBox(height: 16),

        statsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Card(
            color: isDark ? AppColors.darkCard : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.t.admin.errorLoadingStats(error: e.toString()))),
                ],
              ),
            ),
          ),
          data: (stats) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Species per Category card
              _SpeciesPerCategoryCard(
                data: stats.speciesByCategory,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              // Coverage stats card
              _CoverageStatsCard(
                orphanSites: stats.orphanVisitSites,
                speciesWithoutImages: stats.speciesWithoutImages,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Species per Category Card ──

class _SpeciesPerCategoryCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final bool isDark;

  const _SpeciesPerCategoryCard({
    required this.data,
    required this.isDark,
  });

  static const _barColors = [
    AppColors.primary,
    AppColors.primaryLight,
    AppColors.secondary,
    AppColors.statusNT,
    AppColors.statusVU,
    AppColors.statusEN,
    AppColors.statusLC,
    AppColors.statusCR,
  ];

  @override
  Widget build(BuildContext context) {
    final maxCount = data.isEmpty
        ? 1
        : data.map((d) => d['count'] as int).reduce((a, b) => a > b ? a : b);

    return Card(
      color: isDark ? AppColors.darkCard : null,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark
            ? const BorderSide(color: AppColors.darkBorder, width: 0.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.donut_small_rounded,
                  size: 20,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.t.admin.speciesByCategory,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (data.isEmpty)
              Text(
                context.t.admin.noData,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
              )
            else
              ...data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final count = item['count'] as int;
                final name = item['name_es'] as String;
                final barColor = _barColors[index % _barColors.length];
                final fraction = maxCount > 0 ? count / maxCount : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white70 : Colors.grey[800],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$count',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            height: 8,
                            width: constraints.maxWidth * fraction,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ── Coverage Stats Card ──

class _CoverageStatsCard extends StatelessWidget {
  final int orphanSites;
  final int speciesWithoutImages;
  final bool isDark;

  const _CoverageStatsCard({
    required this.orphanSites,
    required this.speciesWithoutImages,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark ? AppColors.darkCard : null,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark
            ? const BorderSide(color: AppColors.darkBorder, width: 0.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.checklist_rounded,
                  size: 20,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.t.admin.dataCoverage,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CoverageRow(
              icon: Icons.location_off_outlined,
              label: context.t.admin.sitesWithoutSpecies,
              count: orphanSites,
              isDark: isDark,
              isWarning: orphanSites > 0,
            ),
            const SizedBox(height: 12),
            _CoverageRow(
              icon: Icons.image_not_supported_outlined,
              label: context.t.admin.speciesWithoutImages,
              count: speciesWithoutImages,
              isDark: isDark,
              isWarning: speciesWithoutImages > 0,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverageRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool isDark;
  final bool isWarning;

  const _CoverageRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.isDark,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final warningColor = isWarning ? AppColors.secondary : AppColors.statusLC;
    final countBgColor = isWarning
        ? AppColors.secondary.withValues(alpha: 0.15)
        : AppColors.statusLC.withValues(alpha: 0.15);

    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: isWarning
              ? (isDark ? AppColors.secondary : AppColors.secondary)
              : (isDark ? AppColors.primaryLight : AppColors.statusLC),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.grey[800],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: countBgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: warningColor,
            ),
          ),
        ),
      ],
    );
  }
}
