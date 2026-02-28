import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/brick/models/island.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/cached_species_image.dart';
import 'package:galapagos_wildlife/features/search/providers/global_search_provider.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:galapagos_wildlife/features/species/providers/species_list_provider.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Restore any existing query
    final existing = ref.read(searchQueryProvider);
    if (existing.isNotEmpty) {
      _controller.text = existing;
    }
    // Autofocus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    // Rebuild to update the clear button visibility
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = value.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider).toLowerCase();
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Clear query on exit
            ref.read(searchQueryProvider.notifier).state = '';
            context.pop();
          },
        ),
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onQueryChanged,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: context.t.search.hint,
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: context.t.common.clearSearch,
              onPressed: () {
                _controller.clear();
                ref.read(searchQueryProvider.notifier).state = '';
                setState(() {});
              },
            ),
        ],
      ),
      body: query.length < 2
          ? _buildInitialState(context, isDark)
          : _buildResults(context, query, locale, isDark),
    );
  }

  Widget _buildInitialState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            context.t.search.hint,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    String query,
    String locale,
    bool isDark,
  ) {
    final speciesAsync = ref.watch(allSpeciesProvider);
    final islandsAsync = ref.watch(allIslandsProvider);
    final sitesAsync = ref.watch(allVisitSitesProvider);

    // If any data is still loading, show a spinner
    if (speciesAsync.isLoading || islandsAsync.isLoading || sitesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Extract data (empty list on error)
    final allSpecies = speciesAsync.asData?.value ?? <Species>[];
    final allIslands = islandsAsync.asData?.value ?? <Island>[];
    final allSites = sitesAsync.asData?.value ?? <VisitSite>[];

    // Filter species
    final filteredSpecies = allSpecies.where((s) {
      return s.commonNameEn.toLowerCase().contains(query) ||
          s.commonNameEs.toLowerCase().contains(query) ||
          s.scientificName.toLowerCase().contains(query);
    }).toList();

    // Filter islands
    final filteredIslands = allIslands.where((i) {
      return i.nameEn.toLowerCase().contains(query) ||
          i.nameEs.toLowerCase().contains(query);
    }).toList();

    // Filter visit sites
    final filteredSites = allSites.where((vs) {
      return (vs.nameEn?.toLowerCase().contains(query) ?? false) ||
          vs.nameEs.toLowerCase().contains(query);
    }).toList();

    final hasResults =
        filteredSpecies.isNotEmpty || filteredIslands.isNotEmpty || filteredSites.isNotEmpty;

    if (!hasResults) {
      return _buildEmptyResults(context, isDark);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (filteredSpecies.isNotEmpty) ...[
          _SectionHeader(title: context.t.search.speciesSection),
          ...filteredSpecies.map(
            (s) => _SpeciesResultTile(
              species: s,
              locale: locale,
              isDark: isDark,
              onTap: () => context.push('/species/${s.id}'),
            ),
          ),
        ],
        if (filteredIslands.isNotEmpty) ...[
          _SectionHeader(title: context.t.search.islandsSection),
          ...filteredIslands.map(
            (i) => _IslandResultTile(
              island: i,
              locale: locale,
              isDark: isDark,
              onTap: () {
                if (i.latitude != null && i.longitude != null) {
                  context.push('/map?lat=${i.latitude}&lng=${i.longitude}&zoom=12');
                } else {
                  context.push('/map');
                }
              },
            ),
          ),
        ],
        if (filteredSites.isNotEmpty) ...[
          _SectionHeader(title: context.t.search.sitesSection),
          ...filteredSites.map(
            (vs) => _SiteResultTile(
              site: vs,
              locale: locale,
              isDark: isDark,
              onTap: () {
                if (vs.latitude != null && vs.longitude != null) {
                  context.push('/map?lat=${vs.latitude}&lng=${vs.longitude}&zoom=15');
                } else {
                  context.push('/map');
                }
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyResults(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            context.t.search.noResults,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t.search.noResultsSubtitle,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Section header ---

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primaryLight,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

// --- Species result tile ---

class _SpeciesResultTile extends StatelessWidget {
  final Species species;
  final String locale;
  final bool isDark;
  final VoidCallback onTap;

  const _SpeciesResultTile({
    required this.species,
    required this.locale,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = locale == 'es' ? species.commonNameEs : species.commonNameEn;
    final imageUrl = species.thumbnailUrl ?? SpeciesAssets.thumbnail(species.id);

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedSpeciesImage(
          imageUrl: imageUrl,
          speciesId: species.id,
          width: 48,
          height: 48,
        ),
      ),
      title: Text(name),
      subtitle: Text(
        species.scientificName,
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.white38 : Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

// --- Island result tile ---

class _IslandResultTile extends StatelessWidget {
  final Island island;
  final String locale;
  final bool isDark;
  final VoidCallback onTap;

  const _IslandResultTile({
    required this.island,
    required this.locale,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = locale == 'es' ? island.nameEs : island.nameEn;
    final hasCoords = island.latitude != null && island.longitude != null;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isDark
            ? AppColors.primaryLight.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.landscape,
          color: isDark ? AppColors.primaryLight : AppColors.primary,
        ),
      ),
      title: Text(name),
      subtitle: island.areaKm2 != null
          ? Text('${island.areaKm2} km\u00B2')
          : null,
      trailing: Icon(
        hasCoords ? Icons.map_outlined : Icons.chevron_right,
        color: isDark ? Colors.white38 : Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

// --- Visit site result tile ---

class _SiteResultTile extends StatelessWidget {
  final VisitSite site;
  final String locale;
  final bool isDark;
  final VoidCallback onTap;

  const _SiteResultTile({
    required this.site,
    required this.locale,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = locale == 'es' ? site.nameEs : (site.nameEn ?? site.nameEs);
    final hasCoords = site.latitude != null && site.longitude != null;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isDark
            ? AppColors.primaryLight.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.place,
          color: isDark ? AppColors.primaryLight : AppColors.primary,
        ),
      ),
      title: Text(name),
      subtitle: site.monitoringType != null ? Text(site.monitoringType!) : null,
      trailing: Icon(
        hasCoords ? Icons.map_outlined : Icons.chevron_right,
        color: isDark ? Colors.white38 : Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
