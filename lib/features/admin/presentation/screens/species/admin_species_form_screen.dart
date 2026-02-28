import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/utils/error_handler.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import '../../../providers/admin_species_provider.dart';
import '../../../providers/admin_category_provider.dart';
import '../../../providers/admin_taxonomy_provider.dart';
import '../../widgets/admin_form_field.dart';
import '../../widgets/admin_taxonomy_selector.dart';

/// Conservation status codes with colors.
const _conservationStatusColors = <String, Color>{
  'LC': Colors.green,
  'NT': Colors.lightGreen,
  'VU': Colors.amber,
  'EN': Colors.orange,
  'CR': Colors.red,
  'EW': Colors.purple,
  'EX': Colors.black,
  'DD': Colors.grey,
  'NE': Colors.blueGrey,
};

/// Conservation status label from i18n.
String _conservationLabel(BuildContext context, String code) {
  final c = context.t.conservation;
  return switch (code) {
    'LC' => c.LC,
    'NT' => c.NT,
    'VU' => c.VU,
    'EN' => c.EN,
    'CR' => c.CR,
    'EW' => c.EW,
    'EX' => c.EX,
    'DD' => c.DD,
    _ => c.NE,
  };
}

class AdminSpeciesFormScreen extends ConsumerStatefulWidget {
  final int? speciesId;

  const AdminSpeciesFormScreen({super.key, this.speciesId});

  @override
  ConsumerState<AdminSpeciesFormScreen> createState() =>
      _AdminSpeciesFormScreenState();
}

class _AdminSpeciesFormScreenState
    extends ConsumerState<AdminSpeciesFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TabController _tabController;

  // Basic info
  final _nameEsController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _scientificNameController = TextEditingController();
  // Physical
  final _weightController = TextEditingController();
  final _sizeController = TextEditingController();
  final _populationController = TextEditingController();
  final _lifespanController = TextEditingController();
  // Descriptions
  final _descEsController = TextEditingController();
  final _descEnController = TextEditingController();
  final _habitatEsController = TextEditingController();
  final _habitatEnController = TextEditingController();
  // Distinguishing features
  final _distinguishingFeaturesEsController = TextEditingController();
  final _distinguishingFeaturesEnController = TextEditingController();
  // Behavior
  final _primaryFoodSourcesController = TextEditingController();
  // Reproduction
  final _breedingSeasonController = TextEditingController();
  final _clutchSizeController = TextEditingController();
  final _reproductiveFrequencyController = TextEditingController();
  // Geographic ranges
  final _altitudeMinController = TextEditingController();
  final _altitudeMaxController = TextEditingController();
  final _depthMinController = TextEditingController();
  final _depthMaxController = TextEditingController();

  // Taxonomy (selected via tree)
  int? _selectedGenusId;

  int? _selectedCategoryId;
  String? _conservationStatus;
  bool _isEndemic = false;
  // Endemism and origin
  bool _isNative = false;
  bool _isIntroduced = false;
  String? _endemismLevel;
  // Conservation
  String? _populationTrend;
  // Behavior
  String? _socialStructure;
  String? _activityPattern;
  String? _dietType;
  // Characteristics
  bool _sexualDimorphism = false;

  String? _heroImageUrl;
  bool _isLoading = false;
  bool _initialized = false;
  bool _isPopulating = false;
  bool _hasUnsavedChanges = false;

  bool get isEditing => widget.speciesId != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final allControllers = [
      _nameEsController,
      _nameEnController,
      _scientificNameController,
      _weightController,
      _sizeController,
      _populationController,
      _lifespanController,
      _descEsController,
      _descEnController,
      _habitatEsController,
      _habitatEnController,
      _distinguishingFeaturesEsController,
      _distinguishingFeaturesEnController,
      _primaryFoodSourcesController,
      _breedingSeasonController,
      _clutchSizeController,
      _reproductiveFrequencyController,
      _altitudeMinController,
      _altitudeMaxController,
      _depthMinController,
      _depthMaxController,
    ];
    for (final c in allControllers) {
      c.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (_isPopulating) return;
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameEsController.dispose();
    _nameEnController.dispose();
    _scientificNameController.dispose();
    _weightController.dispose();
    _sizeController.dispose();
    _populationController.dispose();
    _lifespanController.dispose();
    _descEsController.dispose();
    _descEnController.dispose();
    _habitatEsController.dispose();
    _habitatEnController.dispose();
    _distinguishingFeaturesEsController.dispose();
    _distinguishingFeaturesEnController.dispose();
    _primaryFoodSourcesController.dispose();
    _breedingSeasonController.dispose();
    _clutchSizeController.dispose();
    _reproductiveFrequencyController.dispose();
    _altitudeMinController.dispose();
    _altitudeMaxController.dispose();
    _depthMinController.dispose();
    _depthMaxController.dispose();
    super.dispose();
  }

  void _populateFields(Map<String, dynamic> data) {
    // Always keep hero image in sync
    _heroImageUrl = data['hero_image_url'];

    if (_initialized) return;
    _initialized = true;
    _isPopulating = true;
    _nameEsController.text = data['common_name_es'] ?? '';
    _nameEnController.text = data['common_name_en'] ?? '';
    _scientificNameController.text = data['scientific_name'] ?? '';
    _weightController.text = '${data['weight_kg'] ?? ''}';
    _sizeController.text = '${data['size_cm'] ?? ''}';
    _populationController.text = '${data['population_estimate'] ?? ''}';
    _lifespanController.text = '${data['lifespan_years'] ?? ''}';
    _descEsController.text = data['description_es'] ?? '';
    _descEnController.text = data['description_en'] ?? '';
    _habitatEsController.text = data['habitat_es'] ?? '';
    _habitatEnController.text = data['habitat_en'] ?? '';
    _distinguishingFeaturesEsController.text = data['distinguishing_features_es'] ?? '';
    _distinguishingFeaturesEnController.text = data['distinguishing_features_en'] ?? '';
    _primaryFoodSourcesController.text = data['primary_food_sources'] ?? '';
    _breedingSeasonController.text = data['breeding_season'] ?? '';
    _clutchSizeController.text = '${data['clutch_size'] ?? ''}';
    _reproductiveFrequencyController.text = data['reproductive_frequency'] ?? '';
    _altitudeMinController.text = '${data['altitude_min_m'] ?? ''}';
    _altitudeMaxController.text = '${data['altitude_max_m'] ?? ''}';
    _depthMinController.text = '${data['depth_min_m'] ?? ''}';
    _depthMaxController.text = '${data['depth_max_m'] ?? ''}';
    _selectedCategoryId = data['category_id'];
    _conservationStatus = data['conservation_status'];
    _isEndemic = data['is_endemic'] ?? false;
    _isNative = data['is_native'] ?? false;
    _isIntroduced = data['is_introduced'] ?? false;
    _endemismLevel = data['endemism_level'];
    _populationTrend = data['population_trend'];
    _socialStructure = data['social_structure'];
    _activityPattern = data['activity_pattern'];
    _dietType = data['diet_type'];
    _sexualDimorphism = data['sexual_dimorphism'] ?? false;
    _selectedGenusId = data['genus_id'];
    _isPopulating = false;
  }

  /// Validate the form across both tabs. If validation fails on another tab,
  /// switch to it so the user can see the errors.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _switchToFirstErrorTab();
      return;
    }
    if (_selectedCategoryId == null) {
      _tabController.animateTo(0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.admin.selectCategoryRequired)),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      final service = ref.read(adminSupabaseServiceProvider);

      // Resolve taxonomy text fields from genus_id
      Map<String, String?>? taxonomyFields;
      if (_selectedGenusId != null) {
        taxonomyFields = await resolveTaxonomyFromGenusId(_selectedGenusId!);
      }

      final data = <String, dynamic>{
        'category_id': _selectedCategoryId,
        'common_name_es': _nameEsController.text.trim(),
        'common_name_en': _nameEnController.text.trim(),
        'scientific_name': _scientificNameController.text.trim(),
        'conservation_status': _conservationStatus,
        'weight_kg': double.tryParse(_weightController.text),
        'size_cm': double.tryParse(_sizeController.text),
        'population_estimate': int.tryParse(_populationController.text),
        'lifespan_years': int.tryParse(_lifespanController.text),
        'description_es': _descEsController.text.trim().isEmpty
            ? null
            : _descEsController.text.trim(),
        'description_en': _descEnController.text.trim().isEmpty
            ? null
            : _descEnController.text.trim(),
        'habitat_es': _habitatEsController.text.trim().isEmpty
            ? null
            : _habitatEsController.text.trim(),
        'habitat_en': _habitatEnController.text.trim().isEmpty
            ? null
            : _habitatEnController.text.trim(),
        'distinguishing_features_es': _distinguishingFeaturesEsController.text.trim().isEmpty
            ? null
            : _distinguishingFeaturesEsController.text.trim(),
        'distinguishing_features_en': _distinguishingFeaturesEnController.text.trim().isEmpty
            ? null
            : _distinguishingFeaturesEnController.text.trim(),
        'primary_food_sources': _primaryFoodSourcesController.text.trim().isEmpty
            ? null
            : _primaryFoodSourcesController.text.trim(),
        'breeding_season': _breedingSeasonController.text.trim().isEmpty
            ? null
            : _breedingSeasonController.text.trim(),
        'clutch_size': int.tryParse(_clutchSizeController.text),
        'reproductive_frequency': _reproductiveFrequencyController.text.trim().isEmpty
            ? null
            : _reproductiveFrequencyController.text.trim(),
        'altitude_min_m': int.tryParse(_altitudeMinController.text),
        'altitude_max_m': int.tryParse(_altitudeMaxController.text),
        'depth_min_m': int.tryParse(_depthMinController.text),
        'depth_max_m': int.tryParse(_depthMaxController.text),
        'is_endemic': _isEndemic,
        'is_native': _isNative,
        'is_introduced': _isIntroduced,
        'endemism_level': _endemismLevel,
        'population_trend': _populationTrend,
        'social_structure': _socialStructure,
        'activity_pattern': _activityPattern,
        'diet_type': _dietType,
        'sexual_dimorphism': _sexualDimorphism,
        'genus_id': _selectedGenusId,
        'taxonomy_kingdom': taxonomyFields?['taxonomy_kingdom'],
        'taxonomy_phylum': taxonomyFields?['taxonomy_phylum'],
        'taxonomy_class': taxonomyFields?['taxonomy_class'],
        'taxonomy_order': taxonomyFields?['taxonomy_order'],
        'taxonomy_family': taxonomyFields?['taxonomy_family'],
        'taxonomy_genus': taxonomyFields?['taxonomy_genus'],
      };

      if (isEditing) {
        data['id'] = widget.speciesId;
      }

      await service.upsertSpecies(data);

      ref.invalidate(adminSpeciesListProvider);

      if (mounted) {
        setState(() => _hasUnsavedChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isEditing
                  ? context.t.admin.speciesUpdated
                  : context.t.admin.speciesCreated)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _switchToFirstErrorTab() {
    // Tab 0: basic (name_es, name_en, scientific_name, category)
    final basicHasError = _nameEsController.text.trim().isEmpty ||
        _nameEnController.text.trim().isEmpty ||
        _scientificNameController.text.trim().isEmpty ||
        _selectedCategoryId == null;
    if (basicHasError) {
      _tabController.animateTo(0);
      return;
    }
    // Default to tab 0
    _tabController.animateTo(0);
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.admin.unsavedChangesTitle),
        content: Text(context.t.admin.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.t.common.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _hasUnsavedChanges = false);
              context.pop();
            },
            child: Text(context.t.admin.discard),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    if (isEditing) {
      final speciesAsync = ref.watch(adminSpeciesProvider(widget.speciesId!));
      return speciesAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: Text(context.t.admin.editItem)),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(title: Text(context.t.admin.editItem)),
          body: Center(child: Text('${context.t.common.error}: $e')),
        ),
        data: (data) {
          if (data != null) _populateFields(data);
          return _buildForm(context, isDark, categoriesAsync);
        },
      );
    }

    return _buildForm(context, isDark, categoriesAsync);
  }

  Widget _buildForm(BuildContext context, bool isDark,
      AsyncValue<List<Map<String, dynamic>>> categoriesAsync) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showDiscardDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing
              ? '${context.t.admin.editItem} ${context.t.admin.species}'
              : '${context.t.admin.newItem} ${context.t.admin.species}'),
          backgroundColor: isDark ? AppColors.darkBackground : null,
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              IconButton(
                  icon: const Icon(Icons.check),
                  tooltip: context.t.common.save,
                  onPressed: _save),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: isDark ? AppColors.accentOrange : AppColors.primary,
            unselectedLabelColor:
                isDark ? Colors.white54 : Colors.grey[600],
            indicatorColor:
                isDark ? AppColors.accentOrange : AppColors.primary,
            tabs: [
              Tab(text: context.t.admin.tabGeneral),
              Tab(text: context.t.admin.tabDescription),
              Tab(text: 'Detalles'), // TODO: Add to i18n
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              _TabGeneral(
                parent: this,
                isDark: isDark,
                categoriesAsync: categoriesAsync,
              ),
              _TabDescripcion(
                parent: this,
                isDark: isDark,
              ),
              _TabDetalles(
                parent: this,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// TAB 0 - General (Taxonomy + Hero + Basic + Classification + Physical)
// ════════════════════════════════════════════════
class _TabGeneral extends StatefulWidget {
  final _AdminSpeciesFormScreenState parent;
  final bool isDark;
  final AsyncValue<List<Map<String, dynamic>>> categoriesAsync;

  const _TabGeneral({
    required this.parent,
    required this.isDark,
    required this.categoriesAsync,
  });

  @override
  State<_TabGeneral> createState() => _TabGeneralState();
}

class _TabGeneralState extends State<_TabGeneral>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        if (isWide) {
          return _buildWideLayout(context, constraints);
        } else {
          return _buildNarrowLayout(context);
        }
      },
    );
  }

  /// Wide layout: taxonomy tree on left (~40%), form fields on right (~60%)
  Widget _buildWideLayout(
      BuildContext context, BoxConstraints constraints) {
    final isDark = widget.isDark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel: Taxonomy tree
        SizedBox(
          width: constraints.maxWidth * 0.4,
          child: _buildTaxonomyPanel(context, isDark),
        ),
        // Divider
        Container(
          width: 1,
          color: isDark ? AppColors.darkBorder : Colors.grey[300],
        ),
        // Right panel: Hero + Basic + Classification + Physical
        Expanded(
          child: _buildFormFieldsPanel(context, isDark, isWide: true),
        ),
      ],
    );
  }

  /// Narrow layout: stacked vertically
  Widget _buildNarrowLayout(BuildContext context) {
    final isDark = widget.isDark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hero image
        _buildSectionHeader(context, isDark, context.t.admin.heroImage),
        _buildHeroPreview(context, isDark),
        const SizedBox(height: 20),

        // Basic info
        _buildSectionHeader(context, isDark, context.t.admin.basicInfo),
        AdminBilingualField(
          label: context.t.admin.commonName,
          controllerEs: widget.parent._nameEsController,
          controllerEn: widget.parent._nameEnController,
          required: true,
          sideBySide: false,
        ),
        AdminFormField(
          label: context.t.species.scientificName,
          controller: widget.parent._scientificNameController,
          required: true,
        ),
        const SizedBox(height: 12),

        // Classification
        _buildSectionHeader(
            context, isDark, context.t.admin.category),
        _buildCategoryDropdown(context, isDark),
        _buildConservationDropdown(context, isDark),
        _buildConservationTrendDropdown(context, isDark),
        _buildEndemismSection(context, isDark),
        const SizedBox(height: 12),

        // Physical
        _buildSectionHeader(
            context, isDark, context.t.admin.physicalChars),
        _buildPhysicalFields(context, isDark, isWide: false),
        const SizedBox(height: 20),

        // Taxonomy (collapsible)
        _buildCollapsibleTaxonomy(context, isDark),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTaxonomyPanel(BuildContext context, bool isDark) {
    final p = widget.parent;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildSectionHeader(
            context, isDark, context.t.species.taxonomy),
        const SizedBox(height: 4),
        AdminTaxonomySelector(
          selectedGenusId: p._selectedGenusId,
          onGenusSelected: (genusId) {
            p.setState(() => p._selectedGenusId = genusId);
            p._markDirty();
          },
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildFormFieldsPanel(BuildContext context, bool isDark,
      {required bool isWide}) {
    final p = widget.parent;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hero image
        _buildSectionHeader(context, isDark, context.t.admin.heroImage),
        _buildHeroPreview(context, isDark),
        const SizedBox(height: 20),

        // Basic info
        _buildSectionHeader(context, isDark, context.t.admin.basicInfo),
        AdminBilingualField(
          label: context.t.admin.commonName,
          controllerEs: p._nameEsController,
          controllerEn: p._nameEnController,
          required: true,
          sideBySide: isWide,
        ),
        AdminFormField(
          label: context.t.species.scientificName,
          controller: p._scientificNameController,
          required: true,
        ),
        const SizedBox(height: 12),

        // Classification
        _buildSectionHeader(
            context, isDark, context.t.admin.category),
        _buildCategoryDropdown(context, isDark),
        _buildConservationDropdown(context, isDark),
        _buildConservationTrendDropdown(context, isDark),
        _buildEndemismSection(context, isDark),
        const SizedBox(height: 12),

        // Physical
        _buildSectionHeader(
            context, isDark, context.t.admin.physicalChars),
        _buildPhysicalFields(context, isDark, isWide: isWide),
        const SizedBox(height: 80),
      ],
    );
  }

  // ── Shared builders ──

  Widget _buildSectionHeader(
      BuildContext context, bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isDark ? AppColors.accentOrange : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildHeroPreview(BuildContext context, bool isDark) {
    final p = widget.parent;
    if (!p.isEditing) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : Colors.grey[300]!),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.t.admin.saveFirstToManageImages,
              style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final networkUrl = p._heroImageUrl;
    final assetPath = SpeciesAssets.heroImage(p.widget.speciesId!) ??
        SpeciesAssets.thumbnail(p.widget.speciesId!);
    final hasNetwork = networkUrl != null && networkUrl.isNotEmpty;
    final hasAsset = assetPath != null;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: hasNetwork
                ? Image.network(networkUrl, fit: BoxFit.cover)
                : hasAsset
                    ? Image.asset(assetPath, fit: BoxFit.cover)
                    : Container(
                        color: isDark
                            ? AppColors.darkSurface
                            : Colors.grey[100],
                        child: Center(
                          child: Icon(Icons.image_outlined,
                              size: 48,
                              color: isDark
                                  ? Colors.white38
                                  : Colors.grey[400]),
                        ),
                      ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context
                .push('/admin/species/${p.widget.speciesId}/images'),
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(context.t.admin.manageImagesBtn),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, bool isDark) {
    final p = widget.parent;
    return widget.categoriesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('${context.t.common.error}: $e'),
      data: (categories) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<int>(
          initialValue: p._selectedCategoryId,
          decoration: InputDecoration(
            labelText: '${context.t.admin.category} *',
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color:
                      isDark ? AppColors.darkBorder : Colors.grey[300]!),
            ),
            filled: isDark,
            fillColor: isDark ? AppColors.darkSurface : null,
          ),
          dropdownColor: isDark ? AppColors.darkCard : null,
          items: categories
              .map((c) => DropdownMenuItem(
                    value: c['id'] as int,
                    child: Text(c['name_en'] ?? '',
                        style:
                            TextStyle(color: isDark ? Colors.white : null)),
                  ))
              .toList(),
          onChanged: (v) {
            p.setState(() => p._selectedCategoryId = v);
            p._markDirty();
          },
          validator: (v) => v == null ? context.t.admin.required : null,
        ),
      ),
    );
  }

  Widget _buildConservationDropdown(BuildContext context, bool isDark) {
    final p = widget.parent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: p._conservationStatus,
        decoration: InputDecoration(
          labelText: context.t.species.conservationStatus,
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color:
                    isDark ? AppColors.darkBorder : Colors.grey[300]!),
          ),
          filled: isDark,
          fillColor: isDark ? AppColors.darkSurface : null,
        ),
        dropdownColor: isDark ? AppColors.darkCard : null,
        items: _conservationStatusColors.entries.map((e) {
          final code = e.key;
          final color = e.value;
          final label = _conservationLabel(context, code);
          return DropdownMenuItem<String>(
            value: code,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: code == 'NE'
                        ? Border.all(
                            color: isDark ? Colors.white54 : Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    '$code - $label',
                    style:
                        TextStyle(color: isDark ? Colors.white : null),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) {
          p.setState(() => p._conservationStatus = v);
          p._markDirty();
        },
      ),
    );
  }

  Widget _buildConservationTrendDropdown(BuildContext context, bool isDark) {
    final p = widget.parent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: p._populationTrend,
        decoration: InputDecoration(
          labelText: 'Population Trend', // TODO: i18n
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : Colors.grey[300]!),
          ),
          filled: isDark,
          fillColor: isDark ? AppColors.darkSurface : null,
        ),
        dropdownColor: isDark ? AppColors.darkCard : null,
        items: const [
          DropdownMenuItem(value: 'increasing', child: Text('Increasing')),
          DropdownMenuItem(value: 'stable', child: Text('Stable')),
          DropdownMenuItem(value: 'decreasing', child: Text('Decreasing')),
          DropdownMenuItem(value: 'unknown', child: Text('Unknown')),
        ],
        onChanged: (v) {
          p.setState(() => p._populationTrend = v);
          p._markDirty();
        },
      ),
    );
  }

  Widget _buildEndemismSection(BuildContext context, bool isDark) {
    final p = widget.parent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkboxes for origin
        CheckboxListTile(
          title: Text('Native', style: TextStyle(color: isDark ? Colors.white : null)),
          value: p._isNative,
          onChanged: (v) {
            p.setState(() => p._isNative = v ?? false);
            p._markDirty();
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
        ),
        CheckboxListTile(
          title: Text('Introduced', style: TextStyle(color: isDark ? Colors.white : null)),
          value: p._isIntroduced,
          onChanged: (v) {
            p.setState(() => p._isIntroduced = v ?? false);
            p._markDirty();
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
        ),
        CheckboxListTile(
          title: Text(context.t.admin.endemic,
              style: TextStyle(color: isDark ? Colors.white : null)),
          value: p._isEndemic,
          onChanged: (v) {
            p.setState(() => p._isEndemic = v ?? false);
            p._markDirty();
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
        ),
        const SizedBox(height: 8),
        // Endemism level dropdown
        DropdownButtonFormField<String>(
          value: p._endemismLevel,
          decoration: InputDecoration(
            labelText: 'Endemism Level', // TODO: i18n
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : Colors.grey[300]!),
            ),
            filled: isDark,
            fillColor: isDark ? AppColors.darkSurface : null,
          ),
          dropdownColor: isDark ? AppColors.darkCard : null,
          items: const [
            DropdownMenuItem(value: 'archipelago', child: Text('Archipelago Endemic')),
            DropdownMenuItem(value: 'island_specific', child: Text('Island-Specific Endemic')),
          ],
          onChanged: (v) {
            p.setState(() => p._endemismLevel = v);
            p._markDirty();
          },
        ),
      ],
    );
  }

  Widget _buildPhysicalFields(BuildContext context, bool isDark,
      {required bool isWide}) {
    final p = widget.parent;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdminFormField(
                label: context.t.admin.weightKg,
                controller: p._weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AdminFormField(
                label: context.t.admin.sizeCm,
                controller: p._sizeController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: AdminFormField(
                label: context.t.admin.populationField,
                controller: p._populationController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AdminFormField(
                label: context.t.admin.lifespanYears,
                controller: p._lifespanController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Collapsible taxonomy section for narrow screens.
  Widget _buildCollapsibleTaxonomy(BuildContext context, bool isDark) {
    final p = widget.parent;
    return ExpansionTile(
      title: Text(
        context.t.species.taxonomy,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isDark ? AppColors.accentOrange : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      initiallyExpanded: p._selectedGenusId != null,
      children: [
        AdminTaxonomySelector(
          selectedGenusId: p._selectedGenusId,
          onGenusSelected: (genusId) {
            p.setState(() => p._selectedGenusId = genusId);
            p._markDirty();
          },
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════
// TAB 1 - Descripcion (Description + Habitat, bilingual)
// ════════════════════════════════════════════════
class _TabDescripcion extends StatefulWidget {
  final _AdminSpeciesFormScreenState parent;
  final bool isDark;

  const _TabDescripcion({
    required this.parent,
    required this.isDark,
  });

  @override
  State<_TabDescripcion> createState() => _TabDescripcionState();
}

class _TabDescripcionState extends State<_TabDescripcion>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        if (isWide) {
          return _buildWideLayout(context, constraints);
        } else {
          return _buildNarrowLayout(context);
        }
      },
    );
  }

  /// Wide layout: side-by-side ES/EN columns, each expanding to fill height
  Widget _buildWideLayout(
      BuildContext context, BoxConstraints constraints) {
    final p = widget.parent;
    final isDark = widget.isDark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Description section
          _buildSectionHeader(
              context, isDark, context.t.species.description),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildExpandingTextField(
                    context: context,
                    isDark: isDark,
                    label: '${context.t.species.description} (ES)',
                    controller: p._descEsController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildExpandingTextField(
                    context: context,
                    isDark: isDark,
                    label: '${context.t.species.description} (EN)',
                    controller: p._descEnController,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Habitat section
          _buildSectionHeader(
              context, isDark, context.t.species.habitat),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildExpandingTextField(
                    context: context,
                    isDark: isDark,
                    label: '${context.t.species.habitat} (ES)',
                    controller: p._habitatEsController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildExpandingTextField(
                    context: context,
                    isDark: isDark,
                    label: '${context.t.species.habitat} (EN)',
                    controller: p._habitatEnController,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Narrow layout: stacked vertically with tall text areas
  Widget _buildNarrowLayout(BuildContext context) {
    final p = widget.parent;
    final isDark = widget.isDark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
            context, isDark, context.t.species.description),
        const SizedBox(height: 4),
        _buildTallTextField(
          context: context,
          isDark: isDark,
          label: '${context.t.species.description} (ES)',
          controller: p._descEsController,
        ),
        const SizedBox(height: 12),
        _buildTallTextField(
          context: context,
          isDark: isDark,
          label: '${context.t.species.description} (EN)',
          controller: p._descEnController,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader(
            context, isDark, context.t.species.habitat),
        const SizedBox(height: 4),
        _buildTallTextField(
          context: context,
          isDark: isDark,
          label: '${context.t.species.habitat} (ES)',
          controller: p._habitatEsController,
        ),
        const SizedBox(height: 12),
        _buildTallTextField(
          context: context,
          isDark: isDark,
          label: '${context.t.species.habitat} (EN)',
          controller: p._habitatEnController,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isDark ? AppColors.accentOrange : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  /// TextField that EXPANDS to fill all available height (for wide layout).
  Widget _buildExpandingTextField({
    required BuildContext context,
    required bool isDark,
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      expands: true,
      maxLines: null,
      minLines: null,
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(color: isDark ? Colors.white : null),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            width: 2,
          ),
        ),
        filled: isDark,
        fillColor: isDark ? AppColors.darkSurface : null,
      ),
    );
  }

  /// TextField with fixed tall height (for narrow/phone layout).
  Widget _buildTallTextField({
    required BuildContext context,
    required bool isDark,
    required String label,
    required TextEditingController controller,
  }) {
    return SizedBox(
      height: 200,
      child: TextFormField(
        controller: controller,
        expands: true,
        maxLines: null,
        minLines: null,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(color: isDark ? Colors.white : null),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color:
                    isDark ? AppColors.darkBorder : Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? AppColors.primaryLight : AppColors.primary,
              width: 2,
            ),
          ),
          filled: isDark,
          fillColor: isDark ? AppColors.darkSurface : null,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// TAB 2 - Detalles (New detailed fields in collapsible sections)
// ════════════════════════════════════════════════
class _TabDetalles extends StatefulWidget {
  final _AdminSpeciesFormScreenState parent;
  final bool isDark;

  const _TabDetalles({
    required this.parent,
    required this.isDark,
  });

  @override
  State<_TabDetalles> createState() => _TabDetallesState();
}

class _TabDetallesState extends State<_TabDetalles>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final p = widget.parent;
    final isDark = widget.isDark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Behavior section
        _buildBehaviorSection(context, isDark, p),
        const SizedBox(height: 8),

        // Reproduction section
        _buildReproductionSection(context, isDark, p),
        const SizedBox(height: 8),

        // Distinguishing features section
        _buildDistinguishingFeaturesSection(context, isDark, p),
        const SizedBox(height: 8),

        // Geographic ranges section
        _buildGeographicRangesSection(context, isDark, p),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildBehaviorSection(BuildContext context, bool isDark, _AdminSpeciesFormScreenState p) {
    return ExpansionTile(
      title: Text(
        'Comportamiento', // TODO: i18n
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isDark ? AppColors.accentOrange : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.symmetric(vertical: 8),
      initiallyExpanded: false,
      children: [
        // Social structure dropdown
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
            value: p._socialStructure,
            decoration: InputDecoration(
              labelText: 'Social Structure', // TODO: i18n
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : Colors.grey[300]!),
              ),
              filled: isDark,
              fillColor: isDark ? AppColors.darkSurface : null,
            ),
            dropdownColor: isDark ? AppColors.darkCard : null,
            items: const [
              DropdownMenuItem(value: 'solitary', child: Text('Solitary')),
              DropdownMenuItem(value: 'pair', child: Text('Pair')),
              DropdownMenuItem(value: 'small_group', child: Text('Small Group')),
              DropdownMenuItem(value: 'colony', child: Text('Colony')),
              DropdownMenuItem(value: 'harem', child: Text('Harem')),
            ],
            onChanged: (v) {
              p.setState(() => p._socialStructure = v);
              p._markDirty();
            },
          ),
        ),

        // Activity pattern dropdown
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
            value: p._activityPattern,
            decoration: InputDecoration(
              labelText: 'Activity Pattern', // TODO: i18n
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : Colors.grey[300]!),
              ),
              filled: isDark,
              fillColor: isDark ? AppColors.darkSurface : null,
            ),
            dropdownColor: isDark ? AppColors.darkCard : null,
            items: const [
              DropdownMenuItem(value: 'diurnal', child: Text('Diurnal')),
              DropdownMenuItem(value: 'nocturnal', child: Text('Nocturnal')),
              DropdownMenuItem(value: 'crepuscular', child: Text('Crepuscular')),
            ],
            onChanged: (v) {
              p.setState(() => p._activityPattern = v);
              p._markDirty();
            },
          ),
        ),

        // Diet type dropdown
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
            value: p._dietType,
            decoration: InputDecoration(
              labelText: 'Diet Type', // TODO: i18n
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : Colors.grey[300]!),
              ),
              filled: isDark,
              fillColor: isDark ? AppColors.darkSurface : null,
            ),
            dropdownColor: isDark ? AppColors.darkCard : null,
            items: const [
              DropdownMenuItem(value: 'carnivore', child: Text('Carnivore')),
              DropdownMenuItem(value: 'herbivore', child: Text('Herbivore')),
              DropdownMenuItem(value: 'omnivore', child: Text('Omnivore')),
              DropdownMenuItem(value: 'insectivore', child: Text('Insectivore')),
              DropdownMenuItem(value: 'piscivore', child: Text('Piscivore')),
              DropdownMenuItem(value: 'frugivore', child: Text('Frugivore')),
              DropdownMenuItem(value: 'nectarivore', child: Text('Nectarivore')),
            ],
            onChanged: (v) {
              p.setState(() => p._dietType = v);
              p._markDirty();
            },
          ),
        ),

        // Primary food sources text field
        AdminFormField(
          label: 'Primary Food Sources', // TODO: i18n
          controller: p._primaryFoodSourcesController,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildReproductionSection(BuildContext context, bool isDark, _AdminSpeciesFormScreenState p) {
    return ExpansionTile(
      title: Text(
        'Reproducción', // TODO: i18n
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isDark ? AppColors.accentOrange : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.symmetric(vertical: 8),
      initiallyExpanded: false,
      children: [
        AdminFormField(
          label: 'Breeding Season', // TODO: i18n
          controller: p._breedingSeasonController,
        ),
        AdminFormField(
          label: 'Clutch Size', // TODO: i18n
          controller: p._clutchSizeController,
          keyboardType: TextInputType.number,
        ),
        AdminFormField(
          label: 'Reproductive Frequency', // TODO: i18n
          controller: p._reproductiveFrequencyController,
        ),
      ],
    );
  }

  Widget _buildDistinguishingFeaturesSection(BuildContext context, bool isDark, _AdminSpeciesFormScreenState p) {
    return ExpansionTile(
      title: Text(
        'Características Distintivas', // TODO: i18n
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isDark ? AppColors.accentOrange : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.symmetric(vertical: 8),
      initiallyExpanded: false,
      children: [
        AdminFormField(
          label: 'Distinguishing Features (ES)', // TODO: i18n
          controller: p._distinguishingFeaturesEsController,
          maxLines: 4,
        ),
        AdminFormField(
          label: 'Distinguishing Features (EN)', // TODO: i18n
          controller: p._distinguishingFeaturesEnController,
          maxLines: 4,
        ),
        CheckboxListTile(
          title: Text('Sexual Dimorphism',
              style: TextStyle(color: isDark ? Colors.white : null)),
          value: p._sexualDimorphism,
          onChanged: (v) {
            p.setState(() => p._sexualDimorphism = v ?? false);
            p._markDirty();
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildGeographicRangesSection(BuildContext context, bool isDark, _AdminSpeciesFormScreenState p) {
    return ExpansionTile(
      title: Text(
        'Rangos Geográficos', // TODO: i18n
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isDark ? AppColors.accentOrange : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.symmetric(vertical: 8),
      initiallyExpanded: false,
      children: [
        Row(
          children: [
            Expanded(
              child: AdminFormField(
                label: 'Altitude Min (m)', // TODO: i18n
                controller: p._altitudeMinController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AdminFormField(
                label: 'Altitude Max (m)', // TODO: i18n
                controller: p._altitudeMaxController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: AdminFormField(
                label: 'Depth Min (m)', // TODO: i18n
                controller: p._depthMinController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AdminFormField(
                label: 'Depth Max (m)', // TODO: i18n
                controller: p._depthMaxController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
