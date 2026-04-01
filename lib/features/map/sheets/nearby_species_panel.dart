import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/models/visit_site.model.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import '../providers/map_provider.dart';

/// DraggableScrollableSheet showing species found near the user's location.
class NearbySpeciesPanel extends ConsumerWidget {
  final VisitSite site;
  final bool isEs;

  const NearbySpeciesPanel({super.key, required this.site, required this.isEs});

  Color _freqColor(String? freq) => switch (freq?.toLowerCase()) {
    'common'     => Colors.green.shade600,
    'occasional' => Colors.amber.shade700,
    'uncommon'   => Colors.amber.shade700,
    'rare'       => Colors.red.shade600,
    _            => Colors.grey,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speciesAsync = ref.watch(siteSpeciesProvider(site.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final siteName = isEs ? site.nameEs : site.nameEn ?? site.nameEs;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        siteName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: speciesAsync.when(
                  data: (species) => Text(
                    '${species.length} ${isEs ? 'especies en este sitio' : 'species at this site'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),
              const Divider(height: 1),
              // Species list
              Expanded(
                child: speciesAsync.when(
                  data: (species) {
                    if (species.isEmpty) {
                      return Center(
                        child: Text(
                          isEs ? 'Sin datos de especies' : 'No species data',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: species.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
                      itemBuilder: (context, i) {
                        final entry = species[i];
                        final sp = entry.species;
                        final freq = entry.frequency;
                        final name = isEs ? sp.commonNameEs : sp.commonNameEn;
                        final freqColor = _freqColor(freq);
                        return ListTile(
                          dense: true,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: sp.thumbnailUrl != null
                                ? Image.network(
                                    sp.thumbnailUrl!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _speciesIcon(sp),
                                  )
                                : _speciesIcon(sp),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            sp.scientificName,
                            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 11),
                          ),
                          trailing: freq != null
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: freqColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    freq[0].toUpperCase() + freq.substring(1),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: freqColor,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: Text(isEs ? 'Error al cargar' : 'Failed to load'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _speciesIcon(dynamic sp) {
    return Container(
      width: 40,
      height: 40,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: const Icon(Icons.pets, color: AppColors.primary, size: 20),
    );
  }
}
