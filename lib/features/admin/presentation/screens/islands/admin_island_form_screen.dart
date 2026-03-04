import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/utils/error_handler.dart';
import '../../../providers/admin_island_provider.dart';
import '../../../providers/admin_category_provider.dart';
import '../../../providers/admin_visit_site_provider.dart';
import '../../widgets/admin_form_field.dart';
import '../../widgets/admin_form_scaffold.dart';
import '../../widgets/admin_map_picker.dart';

// Icon mapping for site types
const _siteTypeIcons = <String, IconData>{
  'trail': Icons.hiking,
  'beach': Icons.beach_access,
  'snorkeling': Icons.pool,
  'diving': Icons.scuba_diving,
  'viewpoint': Icons.visibility,
  'dock': Icons.directions_boat,
};

String _siteTypeLabel(BuildContext context, String type) {
  switch (type) {
    case 'trail': return context.t.admin.siteTypeTrail;
    case 'beach': return context.t.admin.siteTypeBeach;
    case 'snorkeling': return context.t.admin.siteTypeSnorkeling;
    case 'diving': return context.t.admin.siteTypeDiving;
    case 'viewpoint': return context.t.admin.siteTypeViewpoint;
    case 'dock': return context.t.admin.siteTypeDock;
    default: return type;
  }
}

class AdminIslandFormScreen extends ConsumerStatefulWidget {
  final int? islandId;

  const AdminIslandFormScreen({super.key, this.islandId});

  @override
  ConsumerState<AdminIslandFormScreen> createState() => _AdminIslandFormScreenState();
}

class _AdminIslandFormScreenState extends ConsumerState<AdminIslandFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameEsController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _areaController = TextEditingController();
  final _descEsController = TextEditingController();
  final _descEnController = TextEditingController();
  bool _isLoading = false;
  bool _initialized = false;
  bool _hasUnsavedChanges = false;

  double? _selectedLat;
  double? _selectedLng;

  bool get isEditing => widget.islandId != null;

  List<TextEditingController> get _controllers => [
        _nameEsController,
        _nameEnController,
        _areaController,
        _descEsController,
        _descEnController,
      ];

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (_initialized && !_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.removeListener(_markDirty);
      c.dispose();
    }
    super.dispose();
  }

  void _populateFields(Map<String, dynamic> data) {
    if (_initialized) return;
    _initialized = true;
    _nameEsController.text = data['name_es'] ?? '';
    _nameEnController.text = data['name_en'] ?? '';
    _areaController.text = '${data['area_km2'] ?? ''}';
    _descEsController.text = data['description_es'] ?? '';
    _descEnController.text = data['description_en'] ?? '';
    _selectedLat = (data['latitude'] as num?)?.toDouble();
    _selectedLng = (data['longitude'] as num?)?.toDouble();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{
        'name_es': _nameEsController.text.trim(),
        'name_en': _nameEnController.text.trim(),
        'latitude': _selectedLat,
        'longitude': _selectedLng,
        'area_km2': double.tryParse(_areaController.text),
        'description_es': _descEsController.text.trim().isEmpty
            ? null
            : _descEsController.text.trim(),
        'description_en': _descEnController.text.trim().isEmpty
            ? null
            : _descEnController.text.trim(),
      };
      if (isEditing) data['id'] = widget.islandId;

      final service = ref.read(adminSupabaseServiceProvider);
      await service.upsertIsland(data);
      ref.invalidate(adminIslandsProvider);

      if (mounted) {
        _hasUnsavedChanges = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? context.t.admin.islandUpdated : context.t.admin.islandCreated)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      final islandAsync = ref.watch(adminIslandProvider(widget.islandId!));
      return islandAsync.when(
        loading: () => const AdminFormLoadingScaffold(),
        error: (e, _) => AdminFormLoadingScaffold(error: e),
        data: (data) {
          if (data != null) _populateFields(data);
          return _buildForm(context);
        },
      );
    }

    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.sizeOf(context).width > 600;

    return AdminFormScaffold(
      formKey: _formKey,
      isEditing: isEditing,
      entityLabel: context.t.admin.islands,
      hasUnsavedChanges: _hasUnsavedChanges,
      isLoading: _isLoading,
      onSave: _save,
      children: [
        AdminBilingualField(
          label: context.t.admin.name,
          controllerEs: _nameEsController,
          controllerEn: _nameEnController,
          required: true,
          sideBySide: isWide,
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        if (isWide)
          SizedBox(
            width: 200,
            child: AdminFormField(
              label: context.t.admin.areaKm2,
              controller: _areaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          )
        else
          AdminFormField(
            label: context.t.admin.areaKm2,
            controller: _areaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        AdminBilingualField(
          label: context.t.species.description,
          controllerEs: _descEsController,
          controllerEn: _descEnController,
          maxLines: 4,
          sideBySide: isWide,
        ),
        const SizedBox(height: 24),
        _buildVisitSitesSection(context, isDark, isWide),
      ],
    );
  }

  Widget _buildVisitSitesSection(BuildContext context, bool isDark, bool isWide) {
    if (!isEditing) return _buildVisitSitesPlaceholder(context, isDark);

    final sitesAsync = ref.watch(visitSitesByIslandProvider(widget.islandId!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: isDark ? AppColors.darkBorder : Colors.grey[300]),
        const SizedBox(height: 8),
        sitesAsync.when(
          loading: () => _buildSectionHeader(context, isDark, null),
          error: (_, _) => _buildSectionHeader(context, isDark, null),
          data: (sites) => _buildSectionHeader(context, isDark, sites.length),
        ),
        const SizedBox(height: 12),
        sitesAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.t.admin.errorLoadingSites(error: e.toString()),
                style: TextStyle(color: AppColors.error)),
          ),
          data: (sites) => Column(
            children: [
              if (sites.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    context.t.admin.noVisitSitesForIsland,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                ...sites.map((site) => _ReadOnlySiteCard(
                      key: ValueKey(site['id']),
                      site: site,
                      isDark: isDark,
                      onTap: () => context.go('/admin/visit-sites/${site['id']}/edit'),
                    )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisitSitesPlaceholder(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: isDark ? AppColors.darkBorder : Colors.grey[300]),
        const SizedBox(height: 8),
        _buildSectionHeader(context, isDark, null),
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
              Icon(Icons.info_outline, size: 18,
                  color: isDark ? Colors.white54 : Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                context.t.admin.saveIslandFirst,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, bool isDark, int? count) {
    return Row(
      children: [
        Icon(Icons.place,
            color: isDark ? AppColors.primaryLight : AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          context.t.admin.visitSitesSection,
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
}

// ──────────────────────────────────────────────────────────────────────────────
// Read-only Visit Site Card (navigates to edit form on tap)
// ──────────────────────────────────────────────────────────────────────────────

class _ReadOnlySiteCard extends StatelessWidget {
  final Map<String, dynamic> site;
  final bool isDark;
  final VoidCallback onTap;

  const _ReadOnlySiteCard({
    super.key,
    required this.site,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final siteType = site['site_type'] as String? ?? '';
    final icon = _siteTypeIcons[siteType] ?? Icons.place;
    final nameEn = site['name_en'] as String? ?? '';
    final nameEs = site['name_es'] as String? ?? '';
    final siteName = nameEn.isNotEmpty
        ? nameEn
        : nameEs.isNotEmpty
            ? nameEs
            : context.t.admin.unnamed;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? AppColors.darkCard : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : Colors.grey[300]!,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                  size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(siteName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : null,
                        )),
                    if (siteType.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.primaryLight.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _siteTypeLabel(context, siteType),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primaryDark,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  size: 20,
                  color: isDark ? Colors.white38 : Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
