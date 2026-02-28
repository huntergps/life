import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/utils/error_handler.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import '../../../providers/admin_visit_site_provider.dart';
import '../../../providers/admin_island_provider.dart';
import '../../../providers/admin_category_provider.dart';
import '../../../providers/admin_species_provider.dart';
import '../../widgets/admin_form_field.dart';
import '../../widgets/admin_map_picker.dart';

String _frequencyLabel(BuildContext context, String key) {
  switch (key) {
    case 'common': return context.t.species.frequency.common;
    case 'uncommon': return context.t.species.frequency.uncommon;
    case 'rare': return context.t.species.frequency.rare;
    case 'occasional': return context.t.species.frequency.occasional;
    default: return key;
  }
}

const _frequencyColors = <String, MaterialColor>{
  'common': Colors.green,
  'uncommon': Colors.amber,
  'rare': Colors.red,
  'occasional': Colors.blue,
};

class AdminVisitSiteFormScreen extends ConsumerStatefulWidget {
  final int? siteId;

  const AdminVisitSiteFormScreen({super.key, this.siteId});

  @override
  ConsumerState<AdminVisitSiteFormScreen> createState() => _AdminVisitSiteFormScreenState();
}

class _AdminVisitSiteFormScreenState extends ConsumerState<AdminVisitSiteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameEsController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _descEsController = TextEditingController();
  final _descEnController = TextEditingController();
  int? _selectedIslandId;
  String? _selectedMonitoringType;
  String? _selectedDifficulty;
  String? _selectedConservationZone;
  String? _selectedPublicUseZone;
  bool _isLoading = false;
  bool _initialized = false;
  bool _hasUnsavedChanges = false;

  double? _selectedLat;
  double? _selectedLng;

  bool get isEditing => widget.siteId != null;

  static const _monitoringTypes = ['MARINO', 'TERRESTRE'];
  static const _difficulties = ['ALTA', 'MEDIA', 'BAJA'];
  static const _conservationZones = [
    'CONSERVACIÓN',
    'APROVECHAMIENTO SUSTENTABLE',
    'TRANSICIÓN',
    'INTANGIBLE',
  ];
  static const _publicUseZones = [
    'RECREATIVA',
    'NATURAL EQUIPADA',
    'NATURAL',
    'CONDICIONADO',
    'CERCANA',
    'POR DETERMINAR',
  ];

  @override
  void initState() {
    super.initState();
    _nameEsController.addListener(_markDirty);
    _nameEnController.addListener(_markDirty);
    _descEsController.addListener(_markDirty);
    _descEnController.addListener(_markDirty);
  }

  void _markDirty() {
    if (_initialized && !_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  @override
  void dispose() {
    _nameEsController.removeListener(_markDirty);
    _nameEnController.removeListener(_markDirty);
    _descEsController.removeListener(_markDirty);
    _descEnController.removeListener(_markDirty);
    _nameEsController.dispose();
    _nameEnController.dispose();
    _descEsController.dispose();
    _descEnController.dispose();
    super.dispose();
  }

  void _populateFields(Map<String, dynamic> data) {
    if (_initialized) return;
    _initialized = true;
    _nameEsController.text = data['name_es'] ?? '';
    _nameEnController.text = data['name_en'] ?? '';
    _descEsController.text = data['description_es'] ?? '';
    _descEnController.text = data['description_en'] ?? '';
    _selectedIslandId = data['island_id'];
    _selectedMonitoringType = data['monitoring_type'];
    _selectedDifficulty = data['difficulty'];
    _selectedConservationZone = data['conservation_zone'];
    _selectedPublicUseZone = data['public_use_zone'];
    _selectedLat = (data['latitude'] as num?)?.toDouble();
    _selectedLng = (data['longitude'] as num?)?.toDouble();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Warn if island not selected (optional but recommended)
    if (_selectedIslandId == null) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sin isla asignada'),
          content: const Text('Este sitio no tiene isla asignada. ¿Desea continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.t.common.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{
        'island_id': _selectedIslandId,
        'name_es': _nameEsController.text.trim(),
        'name_en': _nameEnController.text.trim().isEmpty ? null : _nameEnController.text.trim(),
        'latitude': _selectedLat,
        'longitude': _selectedLng,
        'description_es': _descEsController.text.trim().isEmpty ? null : _descEsController.text.trim(),
        'description_en': _descEnController.text.trim().isEmpty ? null : _descEnController.text.trim(),
        'monitoring_type': _selectedMonitoringType,
        'difficulty': _selectedDifficulty,
        'conservation_zone': _selectedConservationZone,
        'public_use_zone': _selectedPublicUseZone,
      };

      if (isEditing) data['id'] = widget.siteId;

      final service = ref.read(adminSupabaseServiceProvider);
      await service.upsertVisitSite(data);
      ref.invalidate(adminVisitSitesProvider);

      if (mounted) {
        _hasUnsavedChanges = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? context.t.admin.visitSiteUpdated : context.t.admin.visitSiteCreated)),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final islandsAsync = ref.watch(adminIslandsProvider);

    if (isEditing) {
      final siteAsync = ref.watch(adminVisitSiteProvider(widget.siteId!));
      return siteAsync.when(
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
          return _buildForm(context, isDark, islandsAsync);
        },
      );
    }

    return _buildForm(context, isDark, islandsAsync);
  }

  Widget _buildForm(BuildContext context, bool isDark, AsyncValue<List<Map<String, dynamic>>> islandsAsync) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
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
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: Text(context.t.admin.discard),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? '${context.t.admin.editItem} ${context.t.admin.visitSites}' : '${context.t.admin.newItem} ${context.t.admin.visitSites}'),
          backgroundColor: isDark ? AppColors.darkBackground : null,
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              IconButton(icon: const Icon(Icons.check), tooltip: context.t.common.save, onPressed: _save),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Form(
              key: _formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Island dropdown (optional)
                      islandsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: LinearProgressIndicator(),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(context.t.admin.errorLoadingIslands(error: e.toString())),
                        ),
                        data: (islands) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DropdownButtonFormField<int>(
                            value: _selectedIslandId,
                            decoration: InputDecoration(
                              labelText: context.t.admin.island,
                              hintText: 'Sin isla asignada',
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : Colors.grey[300]!),
                              ),
                              filled: isDark,
                              fillColor: isDark ? AppColors.darkSurface : null,
                            ),
                            dropdownColor: isDark ? AppColors.darkCard : null,
                            items: [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text('Sin isla', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600])),
                              ),
                              ...islands.map((i) => DropdownMenuItem(
                                value: i['id'] as int,
                                child: Text(i['name_es'] ?? i['name_en'] ?? '', style: TextStyle(color: isDark ? Colors.white : null)),
                              )),
                            ],
                            onChanged: (v) => setState(() {
                              _selectedIslandId = v;
                              if (_initialized) _hasUnsavedChanges = true;
                            }),
                          ),
                        ),
                      ),

                      // Monitoring type & Difficulty row
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildMonitoringTypeDropdown(isDark)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDifficultyDropdown(isDark)),
                          ],
                        )
                      else ...[
                        _buildMonitoringTypeDropdown(isDark),
                        _buildDifficultyDropdown(isDark),
                      ],

                      // Conservation zone & Public use zone row
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildConservationZoneDropdown(isDark)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPublicUseZoneDropdown(isDark)),
                          ],
                        )
                      else ...[
                        _buildConservationZoneDropdown(isDark),
                        _buildPublicUseZoneDropdown(isDark),
                      ],

                      AdminBilingualField(
                        label: context.t.admin.name,
                        controllerEs: _nameEsController,
                        controllerEn: _nameEnController,
                        required: true,
                        sideBySide: isWide,
                      ),
                      const SizedBox(height: 8),
                      // Map picker
                      AdminMapPicker(
                        initialLatitude: _selectedLat,
                        initialLongitude: _selectedLng,
                        onLocationChanged: (record) {
                          setState(() {
                            _selectedLat = record.$1;
                            _selectedLng = record.$2;
                            if (_initialized) _hasUnsavedChanges = true;
                          });
                        },
                      ),
                      AdminBilingualField(
                        label: context.t.species.description,
                        controllerEs: _descEsController,
                        controllerEn: _descEnController,
                        maxLines: 4,
                        sideBySide: isWide,
                      ),

                      // ── Catalog sections (only when editing) ──
                      if (isEditing) ...[
                        const SizedBox(height: 8),
                        _buildCatalogSection(
                          context: context,
                          isDark: isDark,
                          icon: Icons.category,
                          title: 'Tipos de Sitio',
                          catalogAsync: ref.watch(siteTypeCatalogProvider),
                          assignedAsync: ref.watch(visitSiteTypesProvider(widget.siteId!)),
                          assignedIdKey: 'type_id',
                          catalogIdKey: 'id',
                          catalogNameKey: 'name',
                          onSet: (ids) async {
                            final service = ref.read(adminSupabaseServiceProvider);
                            await service.setVisitSiteTypes(widget.siteId!, ids);
                            ref.invalidate(visitSiteTypesProvider(widget.siteId!));
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildCatalogSection(
                          context: context,
                          isDark: isDark,
                          icon: Icons.directions_boat,
                          title: 'Modalidades de Acceso',
                          catalogAsync: ref.watch(siteModalityCatalogProvider),
                          assignedAsync: ref.watch(visitSiteModalitiesProvider(widget.siteId!)),
                          assignedIdKey: 'modality_id',
                          catalogIdKey: 'id',
                          catalogNameKey: 'name',
                          onSet: (ids) async {
                            final service = ref.read(adminSupabaseServiceProvider);
                            await service.setVisitSiteModalities(widget.siteId!, ids);
                            ref.invalidate(visitSiteModalitiesProvider(widget.siteId!));
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildCatalogSection(
                          context: context,
                          isDark: isDark,
                          icon: Icons.directions_run,
                          title: 'Actividades',
                          catalogAsync: ref.watch(siteActivityCatalogProvider),
                          assignedAsync: ref.watch(visitSiteActivitiesProvider(widget.siteId!)),
                          assignedIdKey: 'activity_id',
                          catalogIdKey: 'id',
                          catalogNameKey: 'name',
                          onSet: (ids) async {
                            final service = ref.read(adminSupabaseServiceProvider);
                            await service.setVisitSiteActivities(widget.siteId!, ids);
                            ref.invalidate(visitSiteActivitiesProvider(widget.siteId!));
                          },
                        ),
                      ],

                      // ── Species Section ──
                      const SizedBox(height: 24),
                      _buildSpeciesSection(context, isDark),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Dropdown helpers ──────────────────────────────────────────────────────

  Widget _buildMonitoringTypeDropdown(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedMonitoringType,
        decoration: InputDecoration(
          labelText: 'Tipo de Monitoreo',
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isDark ? AppColors.darkBorder : Colors.grey[300]!),
          ),
          filled: isDark,
          fillColor: isDark ? AppColors.darkSurface : null,
        ),
        dropdownColor: isDark ? AppColors.darkCard : null,
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text('Sin especificar', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600])),
          ),
          ..._monitoringTypes.map((t) => DropdownMenuItem(
            value: t,
            child: Text(t, style: TextStyle(color: isDark ? Colors.white : null)),
          )),
        ],
        onChanged: (v) => setState(() {
          _selectedMonitoringType = v;
          if (_initialized) _hasUnsavedChanges = true;
        }),
      ),
    );
  }

  Widget _buildDifficultyDropdown(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedDifficulty,
        decoration: InputDecoration(
          labelText: 'Dificultad',
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isDark ? AppColors.darkBorder : Colors.grey[300]!),
          ),
          filled: isDark,
          fillColor: isDark ? AppColors.darkSurface : null,
        ),
        dropdownColor: isDark ? AppColors.darkCard : null,
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text('Sin especificar', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600])),
          ),
          ..._difficulties.map((d) => DropdownMenuItem(
            value: d,
            child: Text(d, style: TextStyle(color: isDark ? Colors.white : null)),
          )),
        ],
        onChanged: (v) => setState(() {
          _selectedDifficulty = v;
          if (_initialized) _hasUnsavedChanges = true;
        }),
      ),
    );
  }

  Widget _buildConservationZoneDropdown(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedConservationZone,
        decoration: InputDecoration(
          labelText: 'Zonificación',
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isDark ? AppColors.darkBorder : Colors.grey[300]!),
          ),
          filled: isDark,
          fillColor: isDark ? AppColors.darkSurface : null,
        ),
        dropdownColor: isDark ? AppColors.darkCard : null,
        isExpanded: true,
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text('Sin especificar', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600])),
          ),
          ..._conservationZones.map((z) => DropdownMenuItem(
            value: z,
            child: Text(z, style: TextStyle(color: isDark ? Colors.white : null)),
          )),
        ],
        onChanged: (v) => setState(() {
          _selectedConservationZone = v;
          if (_initialized) _hasUnsavedChanges = true;
        }),
      ),
    );
  }

  Widget _buildPublicUseZoneDropdown(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedPublicUseZone,
        decoration: InputDecoration(
          labelText: 'Zona Uso Público',
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isDark ? AppColors.darkBorder : Colors.grey[300]!),
          ),
          filled: isDark,
          fillColor: isDark ? AppColors.darkSurface : null,
        ),
        dropdownColor: isDark ? AppColors.darkCard : null,
        isExpanded: true,
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text('Sin especificar', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600])),
          ),
          ..._publicUseZones.map((z) => DropdownMenuItem(
            value: z,
            child: Text(z, style: TextStyle(color: isDark ? Colors.white : null)),
          )),
        ],
        onChanged: (v) => setState(() {
          _selectedPublicUseZone = v;
          if (_initialized) _hasUnsavedChanges = true;
        }),
      ),
    );
  }

  // ── Catalog section builder (types, modalities, activities) ──────────────

  Widget _buildCatalogSection({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required AsyncValue<List<Map<String, dynamic>>> catalogAsync,
    required AsyncValue<List<Map<String, dynamic>>> assignedAsync,
    required String assignedIdKey,
    required String catalogIdKey,
    required String catalogNameKey,
    required Future<void> Function(List<String> ids) onSet,
  }) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: isDark ? AppColors.darkBorder : Colors.grey[300]),
        const SizedBox(height: 8),
        // Section header
        Row(
          children: [
            Icon(icon, color: isDark ? AppColors.primaryLight : AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : null,
              ),
            ),
            const Spacer(),
            // Add button
            TextButton.icon(
              onPressed: () => _showCatalogDialog(
                context: context,
                isDark: isDark,
                title: title,
                catalogAsync: catalogAsync,
                assignedAsync: assignedAsync,
                assignedIdKey: assignedIdKey,
                catalogIdKey: catalogIdKey,
                catalogNameKey: catalogNameKey,
                onSet: onSet,
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Agregar'),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Chips for assigned items
        assignedAsync.when(
          loading: () => const SizedBox(height: 32, child: LinearProgressIndicator()),
          error: (e, _) => Text('Error: $e', style: TextStyle(color: AppColors.error)),
          data: (assigned) {
            if (assigned.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Ninguno asignado',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey[500],
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                  ),
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 4,
              children: assigned.map((item) {
                // Nested catalog data may come as a Map or be null
                final catalogData = item[_catalogTableKey(assignedIdKey)] as Map<String, dynamic>?;
                final name = catalogData?[catalogNameKey] as String? ?? item[assignedIdKey]?.toString() ?? '';
                final itemId = item[assignedIdKey]?.toString() ?? '';
                return Chip(
                  label: Text(name, style: const TextStyle(fontSize: 12)),
                  backgroundColor: isDark
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : AppColors.primaryLight.withValues(alpha: 0.15),
                  labelStyle: TextStyle(color: isDark ? AppColors.primaryLight : AppColors.primary),
                  deleteIcon: Icon(Icons.close, size: 14, color: isDark ? Colors.white54 : Colors.grey[600]),
                  onDeleted: () async {
                    // Remove this item by rebuilding list without it
                    final remaining = assigned
                        .where((a) => a[assignedIdKey]?.toString() != itemId)
                        .map((a) => a[assignedIdKey]?.toString() ?? '')
                        .where((id) => id.isNotEmpty)
                        .toList();
                    await onSet(remaining);
                  },
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  // Maps the assigned junction key to the nested catalog table key returned by Supabase
  String _catalogTableKey(String assignedIdKey) {
    switch (assignedIdKey) {
      case 'type_id': return 'site_type_catalog';
      case 'modality_id': return 'site_modality_catalog';
      case 'activity_id': return 'site_activity_catalog';
      default: return assignedIdKey;
    }
  }

  Future<void> _showCatalogDialog({
    required BuildContext context,
    required bool isDark,
    required String title,
    required AsyncValue<List<Map<String, dynamic>>> catalogAsync,
    required AsyncValue<List<Map<String, dynamic>>> assignedAsync,
    required String assignedIdKey,
    required String catalogIdKey,
    required String catalogNameKey,
    required Future<void> Function(List<String> ids) onSet,
  }) async {
    final catalog = catalogAsync.asData?.value ?? [];
    final assigned = assignedAsync.asData?.value ?? [];
    final assignedIds = assigned
        .map((a) => a[assignedIdKey]?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    final selected = Set<String>.from(assignedIds);

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : null,
          title: Text(title, style: TextStyle(color: isDark ? Colors.white : null)),
          content: SizedBox(
            width: 350,
            child: catalog.isEmpty
                ? Text(
                    'No hay elementos en el catálogo',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: catalog.map((item) {
                      final itemId = item[catalogIdKey]?.toString() ?? '';
                      final itemName = item[catalogNameKey] as String? ?? itemId;
                      final isChecked = selected.contains(itemId);
                      return CheckboxListTile(
                        value: isChecked,
                        title: Text(itemName, style: TextStyle(color: isDark ? Colors.white : null, fontSize: 14)),
                        activeColor: isDark ? AppColors.primaryLight : AppColors.primary,
                        dense: true,
                        onChanged: (checked) {
                          setDialogState(() {
                            if (checked == true) {
                              selected.add(itemId);
                            } else {
                              selected.remove(itemId);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.t.common.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await onSet(selected.toList());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(context.t.common.save),
            ),
          ],
        ),
      ),
    );
  }

  // ── Species Section ──────────────────────────────────────────────────────

  Widget _buildSpeciesSection(BuildContext context, bool isDark) {
    if (!isEditing) {
      return _buildSpeciesPlaceholder(isDark);
    }

    final speciesSitesAsync = ref.watch(speciesSitesByVisitSiteProvider(widget.siteId!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: isDark ? AppColors.darkBorder : Colors.grey[300]),
        const SizedBox(height: 8),

        speciesSitesAsync.when(
          loading: () => _buildSpeciesSectionHeader(isDark, null),
          error: (_, _) => _buildSpeciesSectionHeader(isDark, null),
          data: (items) => _buildSpeciesSectionHeader(isDark, items.length),
        ),
        const SizedBox(height: 12),

        speciesSitesAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.t.admin.errorLoadingSpecies(error: e.toString()),
                style: TextStyle(color: AppColors.error)),
          ),
          data: (speciesSites) => Column(
            children: [
              if (speciesSites.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    context.t.admin.noSpeciesForSite,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                ...speciesSites.map((rel) => _buildSpeciesCard(rel, isDark)),
            ],
          ),
        ),

        const SizedBox(height: 12),

        _InlineAddSpeciesForm(
          siteId: widget.siteId!,
          isDark: isDark,
          onAdded: () {
            ref.invalidate(speciesSitesByVisitSiteProvider(widget.siteId!));
          },
        ),
      ],
    );
  }

  Widget _buildSpeciesPlaceholder(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: isDark ? AppColors.darkBorder : Colors.grey[300]),
        const SizedBox(height: 8),
        _buildSpeciesSectionHeader(isDark, null),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : Colors.grey[300]!,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  context.t.admin.saveSiteFirst,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeciesSectionHeader(bool isDark, int? count) {
    return Row(
      children: [
        Icon(
          Icons.pets,
          color: isDark ? AppColors.primaryLight : AppColors.primary,
          size: 22,
        ),
        const SizedBox(width: 8),
        Text(
          context.t.admin.speciesSection,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : null,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpeciesCard(Map<String, dynamic> rel, bool isDark) {
    final species = rel['species'] as Map<String, dynamic>?;
    final speciesId = (species?['id'] ?? rel['species_id']) as int;
    final commonNameEs = species?['common_name_es'] as String? ?? '';
    final commonNameEn = species?['common_name_en'] as String? ?? '';
    final scientificName = species?['scientific_name'] as String? ?? '';
    final thumbnailUrl = species?['thumbnail_url'] as String?;
    final frequency = rel['frequency'] as String? ?? 'common';
    final visitSiteId = rel['visit_site_id'] as int;

    final locale = context.t.$meta.locale.languageCode;
    final displayName = locale == 'es'
        ? (commonNameEs.isNotEmpty ? commonNameEs : commonNameEn)
        : (commonNameEn.isNotEmpty ? commonNameEn : commonNameEs);

    final freqLabel = _frequencyLabel(context, frequency);
    final MaterialColor freqColor = _frequencyColors[frequency] ?? Colors.grey;

    final localAsset = SpeciesAssets.thumbnail(speciesId);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? AppColors.darkCard : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : Colors.grey[300]!,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 40,
                height: 40,
                child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                    ? Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, e, s) => localAsset != null
                            ? Image.asset(localAsset, fit: BoxFit.cover)
                            : Container(
                                color: isDark ? AppColors.darkSurface : Colors.grey[200],
                                child: Icon(Icons.pets, size: 20, color: isDark ? Colors.white38 : Colors.grey),
                              ),
                      )
                    : localAsset != null
                        ? Image.asset(localAsset, fit: BoxFit.cover)
                        : Container(
                            color: isDark ? AppColors.darkSurface : Colors.grey[200],
                            child: Icon(Icons.pets, size: 20, color: isDark ? Colors.white38 : Colors.grey),
                          ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : null,
                    ),
                  ),
                  if (scientificName.isNotEmpty)
                    Text(
                      scientificName,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: freqColor.withValues(alpha: isDark ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                freqLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? freqColor.withValues(alpha: 0.9) : freqColor.shade700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: AppColors.error),
              onPressed: () => _deleteSpeciesSite(speciesId, visitSiteId, displayName),
              tooltip: context.t.common.delete,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSpeciesSite(int speciesId, int visitSiteId, String speciesName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.admin.deleteSpeciesFromSite),
        content: Text(context.t.admin.confirmDeleteSpeciesFromSite(name: speciesName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(context.t.common.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final service = ref.read(adminSupabaseServiceProvider);
      await service.deleteSpeciesSite(speciesId, visitSiteId);
      ref.invalidate(speciesSitesByVisitSiteProvider(widget.siteId!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.admin.speciesRemovedFromSite)),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Inline Add Species Form
// ──────────────────────────────────────────────────────────────────────────────

class _InlineAddSpeciesForm extends ConsumerStatefulWidget {
  final int siteId;
  final bool isDark;
  final VoidCallback onAdded;

  const _InlineAddSpeciesForm({
    required this.siteId,
    required this.isDark,
    required this.onAdded,
  });

  @override
  ConsumerState<_InlineAddSpeciesForm> createState() => _InlineAddSpeciesFormState();
}

class _InlineAddSpeciesFormState extends ConsumerState<_InlineAddSpeciesForm> {
  int? _selectedSpeciesId;
  String _selectedFrequency = 'common';
  bool _isAdding = false;

  static const _frequencies = ['common', 'uncommon', 'rare', 'occasional'];

  Future<void> _addSpecies() async {
    if (_selectedSpeciesId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.admin.selectSpeciesRequired)),
      );
      return;
    }

    final currentData = ref.read(speciesSitesByVisitSiteProvider(widget.siteId));
    final existing = currentData.asData?.value ?? [];
    final isDuplicate = existing.any((r) => r['species_id'] == _selectedSpeciesId);
    if (isDuplicate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t.admin.speciesAlreadyAssociated),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isAdding = true);
    try {
      final service = ref.read(adminSupabaseServiceProvider);
      await service.upsertSpeciesSite({
        'species_id': _selectedSpeciesId,
        'visit_site_id': widget.siteId,
        'frequency': _selectedFrequency,
      });

      if (mounted) {
        setState(() {
          _selectedSpeciesId = null;
          _selectedFrequency = 'common';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.admin.speciesAddedToSite)),
        );
        widget.onAdded();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final speciesListAsync = ref.watch(adminSpeciesListProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: widget.isDark ? AppColors.darkCard : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: widget.isDark
              ? AppColors.primaryLight.withValues(alpha: 0.4)
              : AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle_outline,
                    color: widget.isDark ? AppColors.primaryLight : AppColors.primary,
                    size: 20),
                const SizedBox(width: 8),
                Text(
                  context.t.admin.addSpecies,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            speciesListAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('${context.t.common.error}: $e'),
              data: (species) => DropdownButtonFormField<int>(
                value: _selectedSpeciesId,
                decoration: InputDecoration(
                  labelText: context.t.admin.species,
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.isDark ? AppColors.darkBorder : Colors.grey[300]!,
                    ),
                  ),
                  filled: widget.isDark,
                  fillColor: widget.isDark ? AppColors.darkSurface : null,
                ),
                dropdownColor: widget.isDark ? AppColors.darkCard : null,
                isExpanded: true,
                items: species.map((s) => DropdownMenuItem(
                  value: s['id'] as int,
                  child: Text(
                    s['common_name_es'] ?? s['common_name_en'] ?? '',
                    style: TextStyle(color: widget.isDark ? Colors.white : null),
                  ),
                )).toList(),
                onChanged: (v) => setState(() => _selectedSpeciesId = v),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFrequency,
                    decoration: InputDecoration(
                      labelText: context.t.admin.frequency,
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: widget.isDark ? AppColors.darkBorder : Colors.grey[300]!,
                        ),
                      ),
                      filled: widget.isDark,
                      fillColor: widget.isDark ? AppColors.darkSurface : null,
                    ),
                    dropdownColor: widget.isDark ? AppColors.darkCard : null,
                    items: _frequencies.map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(
                        _frequencyLabel(context, f),
                        style: TextStyle(color: widget.isDark ? Colors.white : null),
                      ),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedFrequency = v ?? 'common'),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isAdding ? null : _addSpecies,
                    icon: _isAdding
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: Text(_isAdding ? context.t.admin.adding : context.t.common.add),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
