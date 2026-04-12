import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import 'package:galapagos_wildlife/models/species.model.dart';
import 'package:galapagos_wildlife/models/visit_site.model.dart';
import 'package:galapagos_wildlife/features/admin/providers/admin_auth_provider.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'species_detail_provider.dart';

class SpeciesMapScreen extends ConsumerStatefulWidget {
  final Species species;
  const SpeciesMapScreen({super.key, required this.species});

  @override
  ConsumerState<SpeciesMapScreen> createState() => _SpeciesMapScreenState();
}

class _SpeciesMapScreenState extends ConsumerState<SpeciesMapScreen> {
  final MapController _mapController = MapController();
  bool _didFitBounds = false;

  @override
  Widget build(BuildContext context) {
    final sitesAsync = ref.watch(speciesVisitSitesProvider(widget.species.id));
    final isAdmin = ref.watch(isAdminProvider).asData?.value ?? false;
    final isEditor = ref.watch(isEditorProvider).asData?.value ?? false;
    final canEdit = isAdmin || isEditor;
    final locale = ref.watch(localeProvider);
    final isEs = locale == 'es';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEs ? widget.species.commonNameEs : widget.species.commonNameEn,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: isEs ? 'Leyenda' : 'Legend',
            onPressed: () => _showLegend(context, isEs),
          ),
        ],
      ),
      body: sitesAsync.when(
        data: (entries) {
          final validEntries = entries
              .where((e) =>
                  e.site.latitude != null && e.site.longitude != null)
              .toList();

          if (!_didFitBounds && validEntries.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fitBounds(validEntries.map((e) => e.site).toList());
            });
            _didFitBounds = true;
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    AppConstants.galapagosDefaultLat,
                    AppConstants.galapagosDefaultLng,
                  ),
                  initialZoom: AppConstants.galapagosDefaultZoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.galapagos.galapagos_wildlife',
                    maxNativeZoom: 19,
                  ),
                  if (isDark)
                    ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        -1, 0, 0, 0, 255, //
                        0, -1, 0, 0, 255,
                        0, 0, -1, 0, 255,
                        0, 0, 0, 0.7, 0,
                      ]),
                      child: TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.galapagos.galapagos_wildlife',
                        maxNativeZoom: 19,
                      ),
                    ),
                  MarkerLayer(
                    markers: validEntries.map((entry) {
                      final site = entry.site;
                      final freq = entry.frequency ?? 'common';
                      return Marker(
                        point: LatLng(site.latitude!, site.longitude!),
                        width: 36,
                        height: 36,
                        child: GestureDetector(
                          onTap: () =>
                              _showSiteInfo(context, site, freq, isEs),
                          onLongPress: canEdit
                              ? () => _confirmRemoveSite(
                                  context, site, isEs)
                              : null,
                          child: Icon(
                            Icons.place,
                            color: _frequencyColor(freq),
                            size: 32,
                            shadows: const [
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              // Legend
              Positioned(
                left: 12,
                bottom: 12,
                child: _FrequencyLegend(isEs: isEs),
              ),
              if (validEntries.isEmpty)
                Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        isEs
                            ? 'No hay sitios registrados para esta especie'
                            : 'No sites recorded for this species',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: sitesAsync.when(
        data: (_) => canEdit
            ? FloatingActionButton(
                heroTag: 'species_map_add',
                onPressed: () => _showAddSiteSheet(context, isEs),
                child: const Icon(Icons.add),
              )
            : null,
        loading: () => null,
        error: (_, _) => null,
      ),
    );
  }

  void _fitBounds(List<VisitSite> sites) {
    if (sites.isEmpty) return;
    final points = sites
        .where((s) => s.latitude != null && s.longitude != null)
        .map((s) => LatLng(s.latitude!, s.longitude!))
        .toList();
    if (points.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(points);
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60),
          maxZoom: 14,
        ),
      );
    } catch (_) {
      // Map not yet ready
    }
  }

  Color _frequencyColor(String frequency) => switch (frequency) {
        'common' => Colors.green,
        'uncommon' => Colors.amber.shade700,
        'occasional' => Colors.orange,
        'rare' => Colors.red,
        _ => Colors.blue,
      };

  String _frequencyLabel(String frequency, bool isEs) =>
      switch (frequency) {
        'common' => isEs ? 'Comun' : 'Common',
        'uncommon' => isEs ? 'Poco comun' : 'Uncommon',
        'occasional' => isEs ? 'Ocasional' : 'Occasional',
        'rare' => isEs ? 'Raro' : 'Rare',
        _ => frequency,
      };

  void _showSiteInfo(
      BuildContext context, VisitSite site, String frequency, bool isEs) {
    final siteName = isEs ? site.nameEs : (site.nameEn ?? site.nameEs);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              siteName,
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: _frequencyColor(frequency)),
                const SizedBox(width: 8),
                Text(
                  _frequencyLabel(frequency, isEs),
                  style: Theme.of(ctx).textTheme.bodyLarge,
                ),
              ],
            ),
            if (site.monitoringType != null) ...[
              const SizedBox(height: 4),
              Text(
                '${isEs ? 'Tipo' : 'Type'}: ${site.monitoringType}',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLegend(BuildContext context, bool isEs) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEs ? 'Frecuencia de avistamiento' : 'Sighting frequency',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final f in ['common', 'uncommon', 'occasional', 'rare'])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.place, color: _frequencyColor(f), size: 24),
                    const SizedBox(width: 8),
                    Text(_frequencyLabel(f, isEs)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemoveSite(
      BuildContext context, VisitSite site, bool isEs) async {
    final siteName = isEs ? site.nameEs : (site.nameEn ?? site.nameEs);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEs ? 'Eliminar sitio' : 'Remove site'),
        content: Text(
          isEs
              ? 'Quitar "$siteName" de esta especie?'
              : 'Remove "$siteName" from this species?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isEs ? 'Cancelar' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isEs ? 'Eliminar' : 'Remove',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await Supabase.instance.client
          .from('species_sites')
          .delete()
          .eq('species_id', widget.species.id)
          .eq('visit_site_id', site.id);
      ref.invalidate(speciesVisitSitesProvider(widget.species.id));
      _didFitBounds = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEs ? 'Sitio eliminado' : 'Site removed'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showAddSiteSheet(BuildContext context, bool isEs) async {
    final sitesAsync = ref.read(speciesVisitSitesProvider(widget.species.id));
    final existingSiteIds = sitesAsync.asData?.value
            .map((e) => e.site.id)
            .whereType<int>()
            .toSet() ??
        <int>{};

    // Fetch all visit sites
    List<VisitSite> allSites;
    try {
      final rows = await Supabase.instance.client
          .from('visit_sites')
          .select('id, name_es, name_en, latitude, longitude, monitoring_type')
          .order('name_es');
      allSites = rows
          .map<VisitSite>((r) => VisitSite(
                id: r['id'] as int,
                nameEs: r['name_es'] as String,
                nameEn: r['name_en'] as String?,
                latitude: r['latitude'] == null
                    ? null
                    : (r['latitude'] as num).toDouble(),
                longitude: r['longitude'] == null
                    ? null
                    : (r['longitude'] as num).toDouble(),
                monitoringType: r['monitoring_type'] as String?,
              ))
          .where((s) => !existingSiteIds.contains(s.id))
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sites: $e')),
        );
      }
      return;
    }

    if (!mounted) return;

    final result = await showModalBottomSheet<({int siteId, String frequency})>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => _AddSiteSheet(
          sites: allSites,
          isEs: isEs,
          scrollController: scrollController,
        ),
      ),
    );

    if (result == null || !mounted) return;

    try {
      await Supabase.instance.client.from('species_sites').insert({
        'species_id': widget.species.id,
        'visit_site_id': result.siteId,
        'frequency': result.frequency,
      });
      ref.invalidate(speciesVisitSitesProvider(widget.species.id));
      _didFitBounds = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEs ? 'Sitio agregado' : 'Site added'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Frequency legend widget
// ---------------------------------------------------------------------------

class _FrequencyLegend extends StatelessWidget {
  final bool isEs;
  const _FrequencyLegend({required this.isEs});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Colors.green, isEs ? 'Comun' : 'Common'),
      (Colors.amber.shade700, isEs ? 'Poco comun' : 'Uncommon'),
      (Colors.orange, isEs ? 'Ocasional' : 'Occasional'),
      (Colors.red, isEs ? 'Raro' : 'Rare'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (color, label) in items) ...[
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet to add a site association
// ---------------------------------------------------------------------------

class _AddSiteSheet extends StatefulWidget {
  final List<VisitSite> sites;
  final bool isEs;
  final ScrollController scrollController;

  const _AddSiteSheet({
    required this.sites,
    required this.isEs,
    required this.scrollController,
  });

  @override
  State<_AddSiteSheet> createState() => _AddSiteSheetState();
}

class _AddSiteSheetState extends State<_AddSiteSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.sites.where((s) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return s.nameEs.toLowerCase().contains(q) ||
          (s.nameEn?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            widget.isEs ? 'Agregar sitio' : 'Add site',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: widget.isEs ? 'Buscar sitio...' : 'Search site...',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final site = filtered[i];
              final name = widget.isEs
                  ? site.nameEs
                  : (site.nameEn ?? site.nameEs);
              return ListTile(
                title: Text(name),
                subtitle: site.monitoringType != null
                    ? Text(site.monitoringType!)
                    : null,
                trailing: const Icon(Icons.add_circle_outline),
                onTap: () => _pickFrequency(ctx, site),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickFrequency(BuildContext context, VisitSite site) async {
    final frequencies = ['common', 'uncommon', 'occasional', 'rare'];
    final labels = widget.isEs
        ? ['Comun', 'Poco comun', 'Ocasional', 'Raro']
        : ['Common', 'Uncommon', 'Occasional', 'Rare'];

    final freq = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(widget.isEs ? 'Frecuencia' : 'Frequency'),
        children: [
          for (var i = 0; i < frequencies.length; i++)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, frequencies[i]),
              child: Text(labels[i]),
            ),
        ],
      ),
    );

    if (freq != null && mounted) {
      Navigator.pop(context, (siteId: site.id, frequency: freq));
    }
  }
}
