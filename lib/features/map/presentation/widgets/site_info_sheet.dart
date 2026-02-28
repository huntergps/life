import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/brick/models/island.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/cached_species_image.dart';
import '../../providers/map_provider.dart';

// ---------------------------------------------------------------------------
// SiteInfoSheet — ficha completa de un sitio de visita
// ---------------------------------------------------------------------------

class SiteInfoSheet extends ConsumerWidget {
  final VisitSite site;
  final List<Island> islands;

  const SiteInfoSheet({
    super.key,
    required this.site,
    required this.islands,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEs = LocaleSettings.currentLocale == AppLocale.es;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    final speciesAsync = ref.watch(siteSpeciesProvider(site.id));
    final classAsync = ref.watch(siteClassificationsProvider(site.id));

    final name = isEs ? site.nameEs : (site.nameEn ?? site.nameEs);
    final description = isEs
        ? (site.descriptionEs ?? site.descriptionEn)
        : (site.descriptionEn ?? site.descriptionEs);
    final islandName = site.islandId != null
        ? islands
            .where((i) => i.id == site.islandId)
            .map((i) => isEs ? i.nameEs : (i.nameEn ?? i.nameEs))
            .firstOrNull
        : null;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.94,
      builder: (ctx, scrollController) => Column(
        children: [
          // ── drag handle ──
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── scrollable body ──
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              children: [
                // ── Name + monitoring type ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(name, style: tt.headlineSmall),
                    ),
                    if (site.monitoringType != null) ...[
                      const SizedBox(width: 8),
                      _MonitoringChip(type: site.monitoringType!, isDark: isDark),
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                // ── Quick info chips ──
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (islandName != null)
                      _InfoChip(icon: Icons.landscape, label: islandName, isDark: isDark),
                    if (site.difficulty != null)
                      _DifficultyChip(difficulty: site.difficulty!, isDark: isDark),
                    if (site.capacity != null)
                      _InfoChip(
                        icon: Icons.people_outline,
                        label: '${site.capacity} ${isEs ? 'pers.' : 'cap.'}',
                        isDark: isDark,
                      ),
                    if (site.abbreviation != null)
                      _InfoChip(icon: Icons.tag, label: site.abbreviation!, isDark: isDark),
                    if (site.latitude != null && site.longitude != null)
                      _InfoChip(
                        icon: Icons.my_location,
                        label: '${site.latitude!.toStringAsFixed(5)}, ${site.longitude!.toStringAsFixed(5)}',
                        isDark: isDark,
                      ),
                  ],
                ),

                // ── Description ──
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(description, style: tt.bodyMedium),
                ],

                // ── Atractivo principal ──
                if (site.attractionEs != null && site.attractionEs!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SectionTitle(isEs ? 'Atractivo principal' : 'Main attraction'),
                  const SizedBox(height: 6),
                  Text(
                    site.attractionEs!,
                    style: tt.bodyMedium?.copyWith(
                      color: isDark ? Colors.amber[300] : Colors.orange[800],
                    ),
                  ),
                ],

                // ── Zonificación ──
                if (site.conservationZone != null || site.publicUseZone != null) ...[
                  const SizedBox(height: 16),
                  _SectionTitle(isEs ? 'Zonificación' : 'Zoning'),
                  const SizedBox(height: 6),
                  if (site.conservationZone != null)
                    _DetailRow(
                      icon: Icons.eco_outlined,
                      label: isEs ? 'Zona de conservación' : 'Conservation zone',
                      value: site.conservationZone!,
                      isDark: isDark,
                    ),
                  if (site.publicUseZone != null)
                    _DetailRow(
                      icon: Icons.people_outline,
                      label: isEs ? 'Zona de uso público' : 'Public use zone',
                      value: site.publicUseZone!,
                      isDark: isDark,
                    ),
                ],

                // ── Clasificaciones (Tipos / Modalidades / Actividades) ──
                classAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (cls) {
                    final types = cls['types'] ?? [];
                    final modalities = cls['modalities'] ?? [];
                    final activities = cls['activities'] ?? [];
                    if (types.isEmpty && modalities.isEmpty && activities.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        if (types.isNotEmpty) ...[
                          _SectionTitle(isEs ? 'Tipos de sitio' : 'Site types'),
                          const SizedBox(height: 6),
                          _TagWrap(tags: types, isDark: isDark),
                          const SizedBox(height: 10),
                        ],
                        if (modalities.isNotEmpty) ...[
                          _SectionTitle(isEs ? 'Modalidades de acceso' : 'Access modalities'),
                          const SizedBox(height: 6),
                          _TagWrap(tags: modalities, isDark: isDark),
                          const SizedBox(height: 10),
                        ],
                        if (activities.isNotEmpty) ...[
                          _SectionTitle(isEs ? 'Actividades' : 'Activities'),
                          const SizedBox(height: 6),
                          _TagWrap(tags: activities, isDark: isDark),
                        ],
                      ],
                    );
                  },
                ),

                // ── Especies en este sitio ──
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 4),
                _SectionTitle(isEs ? 'Especies en este sitio' : 'Species at this site'),
                const SizedBox(height: 8),

                speciesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (list) {
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          isEs ? 'No hay especies registradas aún' : 'No species recorded yet',
                          style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                        ),
                      );
                    }
                    return Column(
                      children: list.map((item) {
                        final sName = isEs
                            ? item.species.commonNameEs
                            : item.species.commonNameEn;
                        final imageUrl = item.species.thumbnailUrl ??
                            SpeciesAssets.thumbnail(item.species.id);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedSpeciesImage(
                              imageUrl: imageUrl,
                              speciesId: item.species.id,
                              width: 52,
                              height: 52,
                            ),
                          ),
                          title: Text(sName),
                          subtitle: Text(
                            item.species.scientificName,
                            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                          ),
                          trailing: item.frequency != null
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.frequency!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            Navigator.of(ctx).pop();
                            context.push('/species/${item.species.id}');
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryLight,
          ),
    );
  }
}

class _MonitoringChip extends StatelessWidget {
  final String type;
  final bool isDark;
  const _MonitoringChip({required this.type, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isMarine = type == 'MARINO';
    final color = isMarine ? Colors.blue : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isMarine ? Icons.water : Icons.terrain, size: 14,
              color: isDark ? color.withValues(alpha: 0.9) : color),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? color.withValues(alpha: 0.9) : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String difficulty;
  final bool isDark;
  const _DifficultyChip({required this.difficulty, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'fácil':
        color = Colors.green;
        label = LocaleSettings.currentLocale == AppLocale.es ? 'Fácil' : 'Easy';
      case 'hard':
      case 'difícil':
        color = Colors.red;
        label = LocaleSettings.currentLocale == AppLocale.es ? 'Difícil' : 'Hard';
      default:
        color = Colors.orange;
        label = LocaleSettings.currentLocale == AppLocale.es ? 'Moderado' : 'Moderate';
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.show_chart, size: 15,
            color: isDark ? color.withValues(alpha: 0.85) : color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? color.withValues(alpha: 0.85) : color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _InfoChip({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16,
              color: isDark ? Colors.white38 : Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagWrap extends StatelessWidget {
  final List<String> tags;
  final bool isDark;
  const _TagWrap({required this.tags, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primaryLight.withValues(alpha: 0.12)
                : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppColors.primaryLight.withValues(alpha: 0.3)
                  : AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
            ),
          ),
        );
      }).toList(),
    );
  }
}
