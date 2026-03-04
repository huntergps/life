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
import 'package:galapagos_wildlife/brick/models/species_threat.model.dart';
import 'package:galapagos_wildlife/brick/models/species_reference.model.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';
import 'package:galapagos_wildlife/features/species/providers/species_checklist_provider.dart';
import 'package:galapagos_wildlife/features/admin/providers/admin_auth_provider.dart';
import 'package:galapagos_wildlife/features/editorial/presentation/sheets/field_proposal_sheet.dart';
import 'package:galapagos_wildlife/features/editorial/services/proposal_service.dart';
import '../../providers/species_detail_provider.dart';
import '../../providers/species_sounds_provider.dart';
import '../widgets/quick_facts_row.dart';
import '../widgets/taxonomy_tree.dart';
import '../widgets/gallery_carousel.dart';
import '../widgets/species_sound_player.dart';
import 'package:go_router/go_router.dart';

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
            Consumer(builder: (context, ref, _) {
              final isSeen = ref.watch(isSpeciesSeenProvider(speciesId));
              final isLoggedIn = ref.watch(isAuthenticatedProvider);
              if (!isLoggedIn) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  isSeen ? Icons.check_circle : Icons.check_circle_outline,
                  color: isSeen ? Colors.green : null,
                ),
                tooltip: isSeen ? context.t.species.markAsNotSeen : context.t.species.markAsSeen,
                onPressed: () => toggleSpeciesSeen(ref, speciesId),
              );
            }),
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
    final isEditor = ref.watch(isEditorProvider).asData?.value ?? false;
    final pendingFields = isEditor
        ? (ref.watch(speciesProposalsProvider(species.id)).asData?.value ?? {})
        : const <String>{};
    final threatsAsync = ref.watch(speciesThreatsProvider(species.id));
    final referencesAsync = ref.watch(speciesReferencesProvider(species.id));
    final soundsAsync = ref.watch(speciesSoundsProvider(species.id));

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
        // Badges in same row (conservation status + endemic + trend + native/introduced)
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
            if (species.populationTrend != null)
              _TrendBadge(trend: species.populationTrend!, isDark: isDark),
            if (species.isNative == true && !species.isEndemic)
              _StatusChip(
                label: context.t.species.native,
                color: Colors.teal,
                isDark: isDark,
              ),
            if (species.isIntroduced == true)
              _StatusChip(
                label: context.t.species.introduced,
                color: Colors.orange,
                isDark: isDark,
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
        const SizedBox(height: 16),
        // Altitude range bar
        if (species.altitudeMinM != null || species.altitudeMaxM != null) ...[
          _AltitudeBar(
            minM: species.altitudeMinM,
            maxM: species.altitudeMaxM,
            locale: locale,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
        ],
        // Visit sites strip — where to find this species
        _VisitSitesStrip(speciesId: species.id, locale: locale, isDark: isDark),
        const SizedBox(height: 20),
        // Description
        ..._editableLocalizedSection(
          context,
          label: context.t.species.description,
          en: species.descriptionEn,
          es: species.descriptionEs,
          locale: locale,
          isEditor: isEditor,
          hasPending: pendingFields.any(
              ['description_es', 'description_en'].contains),
          onEdit: () => showFieldProposalSheet(
              context, species as Species, ProposalSection.description),
        ),
        // Habitat
        ..._editableLocalizedSection(
          context,
          label: context.t.species.habitat,
          en: species.habitatEn,
          es: species.habitatEs,
          locale: locale,
          isEditor: isEditor,
          hasPending: pendingFields.any(
              ['habitat_es', 'habitat_en'].contains),
          onEdit: () => showFieldProposalSheet(
              context, species as Species, ProposalSection.habitat),
        ),

        // Extended information (only for logged-in users)
        if (isLoggedIn) ...[
          _ExtendedInfoSection(
            species: species,
            locale: locale,
            isDark: isDark,
            threatsAsync: threatsAsync,
            referencesAsync: referencesAsync,
            isEditor: isEditor,
            pendingFields: pendingFields,
          ),
          if ((soundsAsync.asData?.value ?? []).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SpeciesSoundPlayer(
                sounds: soundsAsync.asData!.value,
                locale: locale,
              ),
            ),
        ]
        else
          _LoginPromptSection(isDark: isDark),
      ],
    );
  }

}

// ─────────────────────────────────────────────────────────────────────────────
// Top-level helpers
// ─────────────────────────────────────────────────────────────────────────────

String _formatEnumValue(String value) =>
    value.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');

String _formatMm(double min, double? max) {
  if (max == null || max == min) return '${min.toStringAsFixed(1)} mm';
  return '${min.toStringAsFixed(1)}–${max.toStringAsFixed(1)} mm';
}

String _webTypeLabel(BuildContext context, String type) {
  final wt = context.t.species.webType;
  return switch (type) {
    'orbicular' => wt.orbicular,
    'cobweb'    => wt.cobweb,
    'irregular' => wt.irregular,
    'funnel'    => wt.funnel,
    'sheet'     => wt.sheet,
    'tubular'   => wt.tubular,
    _           => type,
  };
}


List<Widget> _editableLocalizedSection(
  BuildContext context, {
  required String label,
  String? en,
  String? es,
  required String locale,
  required bool isEditor,
  required bool hasPending,
  required VoidCallback onEdit,
}) {
  final text = locale == 'es' ? (es ?? en) : en;
  if (text == null && !isEditor) return [];
  return [
    _sectionHeaderRow(context,
        label: label, hasPending: hasPending,
        isEditor: isEditor, onEdit: onEdit),
    const SizedBox(height: 8),
    if (text != null)
      Text(text, style: Theme.of(context).textTheme.bodyMedium)
    else
      Text(
        '(sin contenido — toca ✏ para agregar)',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    const SizedBox(height: 20),
  ];
}

Widget _sectionHeaderRow(
  BuildContext context, {
  required String label,
  required bool hasPending,
  required bool isEditor,
  required VoidCallback onEdit,
}) =>
    Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.titleLarge)),
        if (hasPending)
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.6)),
            ),
            child: const Text('pendiente',
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.amber,
                    fontWeight: FontWeight.w600)),
          ),
        if (isEditor)
          GestureDetector(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.edit_outlined,
                  size: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4)),
            ),
          ),
      ],
    );

// ─────────────────────────────────────────────────────────────────────────────
// Extended info section (logged-in users)
// ─────────────────────────────────────────────────────────────────────────────

class _ExtendedInfoSection extends StatelessWidget {
  final dynamic species;
  final String locale;
  final bool isDark;
  final AsyncValue<List<SpeciesThreat>> threatsAsync;
  final AsyncValue<List<SpeciesReference>> referencesAsync;
  final bool isEditor;
  final Set<String> pendingFields;

  const _ExtendedInfoSection({
    required this.species,
    required this.locale,
    required this.isDark,
    required this.threatsAsync,
    required this.referencesAsync,
    this.isEditor = false,
    this.pendingFields = const {},
  });

  Widget _sectionHeader(BuildContext context, String label,
      {required ProposalSection section}) =>
      _sectionHeaderRow(context,
          label: label,
          hasPending: (kSectionFields[section] ?? [])
              .any(pendingFields.contains),
          isEditor: isEditor,
          onEdit: () => showFieldProposalSheet(
              context, species as Species, section));

  @override
  Widget build(BuildContext context) {
    final emptyColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;
    final emptyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: emptyColor,
      fontStyle: FontStyle.italic,
    );
    Widget emptyValue() => Text(context.t.species.noInformation, style: emptyStyle);
    final threats = threatsAsync.asData?.value ?? [];
    final references = referencesAsync.asData?.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Venomous warning
        if (species.venomousToHumans == true) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade900.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade700, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: Colors.red.shade400, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.t.species.venomWarning,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade300,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Morphology (arachnids)
        if (species.sizeMmFemaleMin != null || species.sizeMmMaleMin != null) ...[
          Text(context.t.species.morphology, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (species.sizeMmFemaleMin != null) ...[
            Row(children: [
              const Icon(Icons.straighten_outlined, size: 16),
              const SizedBox(width: 8),
              Text(
                '${context.t.species.female}: ${_formatMm(species.sizeMmFemaleMin!, species.sizeMmFemaleMax)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ]),
            const SizedBox(height: 4),
          ],
          if (species.sizeMmMaleMin != null)
            Row(children: [
              const Icon(Icons.straighten_outlined, size: 16),
              const SizedBox(width: 8),
              Text(
                '${context.t.species.male}: ${_formatMm(species.sizeMmMaleMin!, species.sizeMmMaleMax)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ]),
          const SizedBox(height: 20),
        ],

        // Behavior
        _sectionHeader(context, context.t.species.behavior,
            section: ProposalSection.behavior),
        const SizedBox(height: 8),
        _behaviorWidget(context, emptyValue),
        const SizedBox(height: 20),

        // Reproduction
        _sectionHeader(context, context.t.species.reproduction,
            section: ProposalSection.reproduction),
        const SizedBox(height: 8),
        _reproductionWidget(context, emptyValue),
        const SizedBox(height: 20),

        // Distinguishing Features
        _sectionHeader(context, context.t.species.distinguishingFeatures,
            section: ProposalSection.distinguishingFeatures),
        const SizedBox(height: 8),
        _distinguishingWidget(context, emptyValue),
        if (species.sexualDimorphism != null && (species.sexualDimorphism as String).isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${context.t.species.sexualDimorphism}: ${species.sexualDimorphism}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 20),

        // Best Time to Visit
        if (species.breedingSeason != null || species.activityPattern != null) ...[
          Text(context.t.species.bestTimeToVisit, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (species.breedingSeason != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  '${context.t.species.breedingSeason}: ${species.breedingSeason}',
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
              ],
            ),
            const SizedBox(height: 6),
          ],
          if (species.activityPattern != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.access_time_outlined, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  '${context.t.species.activityPattern}: ${_formatEnumValue(species.activityPattern!)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
              ],
            ),
          const SizedBox(height: 20),
        ],

        // Threats
        if (threats.isNotEmpty) ...[
          Text(context.t.species.threats, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final threat in threats) ...[
            _ThreatCard(
              threat: threat,
              description: locale == 'es'
                  ? (threat.descriptionEs ?? threat.descriptionEn)
                  : threat.descriptionEn,
              isDark: isDark,
              locale: locale,
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),
        ],

        // References
        if (references.isNotEmpty) ...[
          Text(context.t.species.references, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (int i = 0; i < references.length; i++) ...[
            _ReferenceItem(r: references[i], index: i, isDark: isDark),
            if (i < references.length - 1) const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _behaviorWidget(BuildContext context, Widget Function() emptyValue) {
    final parts = <String>[];
    if (species.dietType != null) {
      parts.add('${context.t.species.diet}: ${_formatEnumValue(species.dietType!)}');
    }
    if (species.activityPattern != null) {
      parts.add('${context.t.species.activity}: ${_formatEnumValue(species.activityPattern!)}');
    }
    if (species.socialStructure != null) {
      parts.add('${context.t.species.social}: ${_formatEnumValue(species.socialStructure!)}');
    }
    if (species.primaryFoodSources != null && (species.primaryFoodSources as List).isNotEmpty) {
      parts.add('${context.t.species.food}: ${(species.primaryFoodSources as List).join(', ')}');
    }
    if (species.buildsWeb != null) {
      if (species.buildsWeb!) {
        final webLabel = species.webType != null
            ? _webTypeLabel(context, species.webType!)
            : context.t.species.web;
        parts.add('${context.t.species.web}: $webLabel');
      } else {
        parts.add(context.t.species.noWeb);
      }
    }
    return parts.isEmpty
        ? emptyValue()
        : Text(parts.join(' • '), style: Theme.of(context).textTheme.bodyMedium);
  }

  Widget _reproductionWidget(BuildContext context, Widget Function() emptyValue) {
    final parts = <String>[];
    if (species.breedingSeason != null) {
      parts.add('${context.t.species.season}: ${species.breedingSeason}');
    }
    if (species.clutchSize != null) {
      parts.add('${context.t.species.clutchSize}: ${species.clutchSize}');
    }
    if (species.reproductiveFrequency != null) {
      parts.add('${context.t.species.reproFrequency}: ${species.reproductiveFrequency}');
    }
    return parts.isEmpty
        ? emptyValue()
        : Text(parts.join(' • '), style: Theme.of(context).textTheme.bodyMedium);
  }

  Widget _distinguishingWidget(BuildContext context, Widget Function() emptyValue) {
    final features = locale == 'es'
        ? (species.distinguishingFeaturesEs ?? species.distinguishingFeaturesEn)
        : species.distinguishingFeaturesEn;
    if (features == null || (features as String).isEmpty) return emptyValue();
    return Text(features, style: Theme.of(context).textTheme.bodyMedium);
  }
}

class _ReferenceItem extends StatelessWidget {
  final SpeciesReference r;
  final int index;
  final bool isDark;
  const _ReferenceItem({required this.r, required this.index, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final hasLink = r.url != null || r.doi != null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${index + 1}. ', style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
        )),
        Expanded(
          child: GestureDetector(
            onTap: hasLink ? () async {
              final url = r.url ?? (r.doi != null ? 'https://doi.org/${r.doi}' : null);
              if (url != null) {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            } : null,
            child: Text(
              r.citation,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: hasLink ? (isDark ? Colors.lightBlue : Colors.blue.shade700) : null,
                decoration: hasLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Login prompt (shown when not logged in)
// ─────────────────────────────────────────────────────────────────────────────

class _LoginPromptSection extends StatelessWidget {
  final bool isDark;
  const _LoginPromptSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                      context.t.species.detailedInfoTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.t.species.loginForDetails,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
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
                Consumer(builder: (context, ref, _) {
                  final isSeen = ref.watch(isSpeciesSeenProvider(speciesId));
                  final isLoggedIn = ref.watch(isAuthenticatedProvider);
                  if (!isLoggedIn) return const SizedBox.shrink();
                  return IconButton(
                    icon: Icon(
                      isSeen ? Icons.check_circle : Icons.check_circle_outline,
                      color: isSeen ? Colors.green : null,
                    ),
                    tooltip: isSeen ? context.t.species.markAsNotSeen : context.t.species.markAsSeen,
                    onPressed: () => toggleSpeciesSeen(ref, speciesId),
                  );
                }),
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

class _ThreatCard extends StatelessWidget {
  final SpeciesThreat threat;
  final String? description;
  final bool isDark;
  final String locale;

  const _ThreatCard({
    required this.threat,
    this.description,
    required this.isDark,
    required this.locale,
  });

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high': return Colors.red.shade700;
      case 'critical': return Colors.red.shade900;
      case 'medium': return Colors.orange.shade700;
      case 'low': return Colors.yellow.shade800;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(threat.severity);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  threat.threatType,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  threat.severity.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(description!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Population trend badge
// ─────────────────────────────────────────────────────────────────────────────

class _TrendBadge extends StatelessWidget {
  final String trend;
  final bool isDark;
  const _TrendBadge({required this.trend, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (trend.toLowerCase()) {
      'increasing' => (Icons.trending_up, Colors.green.shade600, trend),
      'stable'     => (Icons.trending_flat, Colors.amber.shade700, trend),
      'decreasing' => (Icons.trending_down, Colors.red.shade600, trend),
      _            => (Icons.trending_flat, Colors.grey, trend),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label[0].toUpperCase() + label.substring(1),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Native / Introduced status chip
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  const _StatusChip({required this.label, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Altitude range bar
// ─────────────────────────────────────────────────────────────────────────────

class _AltitudeBar extends StatelessWidget {
  final int? minM;
  final int? maxM;
  final String locale;
  final bool isDark;

  const _AltitudeBar({this.minM, this.maxM, required this.locale, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const totalMax = 2000; // Galápagos max ~1707m (Wolf Volcano)
    final lo = (minM ?? 0).clamp(0, totalMax);
    final hi = (maxM ?? totalMax).clamp(0, totalMax);
    final startFrac = lo / totalMax;
    final endFrac = hi / totalMax;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t.species.altitudeRange,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth;
          return Stack(
            children: [
              // Background track
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Filled range
              Positioned(
                left: w * startFrac,
                width: (w * (endFrac - startFrac)).clamp(8.0, w),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0 m', style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            )),
            Text(
              '${minM ?? 0}–${maxM ?? totalMax} m',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
            Text('$totalMax m', style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            )),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Visit sites horizontal strip
// ─────────────────────────────────────────────────────────────────────────────

class _VisitSitesStrip extends ConsumerWidget {
  final int speciesId;
  final String locale;
  final bool isDark;

  const _VisitSitesStrip({
    required this.speciesId,
    required this.locale,
    required this.isDark,
  });

  Color _frequencyColor(String? frequency) {
    return switch (frequency?.toLowerCase()) {
      'common'     => Colors.green.shade600,
      'occasional' => Colors.amber.shade700,
      'uncommon'   => Colors.amber.shade700,
      'rare'       => Colors.red.shade600,
      _            => Colors.grey,
    };
  }

  String _frequencyLabel(BuildContext context, String? frequency) {
    return switch (frequency?.toLowerCase()) {
      'common'     => context.t.species.frequency.common,
      'occasional' => context.t.species.frequency.occasional,
      'uncommon'   => context.t.species.frequency.uncommon,
      'rare'       => context.t.species.frequency.rare,
      _            => frequency ?? '',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sitesAsync = ref.watch(speciesVisitSitesProvider(speciesId));
    final sites = sitesAsync.asData?.value ?? [];

    if (sites.isEmpty && sitesAsync is! AsyncLoading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t.species.whereToFind,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        if (sitesAsync is AsyncLoading)
          const SizedBox(height: 36, child: Center(child: LinearProgressIndicator()))
        else
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sites.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final entry = sites[i];
                final siteName = locale == 'es'
                    ? entry.site.nameEs
                    : (entry.site.nameEn ?? entry.site.nameEs);
                final freqColor = _frequencyColor(entry.frequency);
                final freqLabel = _frequencyLabel(context, entry.frequency);
                return GestureDetector(
                  onTap: () => context.goNamed('map'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, size: 13, color: freqColor),
                        const SizedBox(width: 4),
                        Text(
                          siteName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (freqLabel.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: freqColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              freqLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: freqColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
