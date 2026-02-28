import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import 'package:galapagos_wildlife/features/map/providers/map_download_provider.dart';
import 'package:galapagos_wildlife/features/map/providers/pmtiles_provider.dart';
import 'package:galapagos_wildlife/features/map/services/pmtiles_manager.dart';

/// Bottom sheet for downloading offline map data:
///  • HD PMTiles base map (vector, zoom 0–15, ~25 MB)
///  • ESRI satellite tiles for Galápagos (zoom 5–13, ~50–150 MB)
class MapDownloadSheet extends ConsumerStatefulWidget {
  const MapDownloadSheet({super.key});

  @override
  ConsumerState<MapDownloadSheet> createState() => _MapDownloadSheetState();
}

class _MapDownloadSheetState extends ConsumerState<MapDownloadSheet> {
  // ── PMTiles state ──────────────────────────────────────────────────────────
  bool _hdDownloaded = false;
  int _hdSizeBytes = 0;

  // ── Satellite state ────────────────────────────────────────────────────────
  int _satelliteTileCount = 0;
  double _satelliteSizeKb = 0;

  bool _loading = true;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final downloaded = await PmTilesManager.isHdDownloaded;
      final size = await PmTilesManager.localFileSize;
      final satStats = await FMTCStore('satelliteCache').stats.all;

      if (!mounted) return;
      setState(() {
        _hdDownloaded = downloaded;
        _hdSizeBytes = size;
        _satelliteTileCount = satStats.length;
        _satelliteSizeKb = satStats.size;
        _loading = false;
      });
    } catch (e) {
      AppLogger.error('Failed to load map download status', e);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _localError = e.toString();
      });
    }
  }

  // ── PMTiles delete ─────────────────────────────────────────────────────────

  Future<void> _deleteMap() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar mapa HD'),
        content: const Text(
          '¿Deseas eliminar el mapa HD descargado? '
          'Podrás volver a descargarlo cuando tengas conexión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await PmTilesManager.delete();
      ref.invalidate(pmtilesAvailableProvider);
      ref.invalidate(pmtilesFileSizeProvider);
      ref.invalidate(pmtilesVectorTileProvider);
      if (!mounted) return;
      await _loadStatus();
    } catch (e) {
      AppLogger.error('Failed to delete PMTiles', e);
      if (!mounted) return;
      setState(() => _localError = e.toString());
    }
  }

  // ── Satellite delete ────────────────────────────────────────────────────────

  Future<void> _deleteSatelliteTiles() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar imágenes satelitales'),
        content: const Text(
          '¿Deseas eliminar las imágenes satelitales descargadas? '
          'Podrás volver a descargarlas cuando tengas conexión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(mapDownloadProvider.notifier).deleteSatelliteTiles();
    if (!mounted) return;
    await _loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final downloadState = ref.watch(mapDownloadProvider);
    final isDownloading = downloadState.isActive;
    final isPaused = downloadState.isPaused;

    // Refresh status when any download completes
    ref.listen(mapDownloadProvider, (prev, next) {
      if (prev?.status == DownloadStatus.downloading &&
          next.status == DownloadStatus.completed) {
        _loadStatus();
      }
      if (prev?.satelliteStatus == DownloadStatus.downloading &&
          next.satelliteStatus == DownloadStatus.completed) {
        _loadStatus();
      }
    });

    final sizeMB = (_hdSizeBytes / (1024 * 1024)).toStringAsFixed(1);
    final satSizeMB = (_satelliteSizeKb / 1024).toStringAsFixed(0);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Section: PMTiles base map ────────────────────────────────────

            Text(
              'Mapa Vectorial HD',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Mapa detallado de las Islas Galápagos para usar sin conexión. '
              'Incluye senderos, puntos de visita e islas.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),

            _buildStatusCard(theme, downloadState, sizeMB),
            const SizedBox(height: 16),

            // Background download notice
            _buildBackgroundNotice(theme),
            const SizedBox(height: 20),

            // PMTiles action buttons
            if (_loading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (isDownloading) ...[
              _buildProgressCard(theme, downloadState),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(mapDownloadProvider.notifier).pause(),
                      icon: const Icon(Icons.pause, size: 18),
                      label: const Text('Pausar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(mapDownloadProvider.notifier).cancel(),
                      icon: const Icon(Icons.stop, size: 18),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (isPaused) ...[
              _buildProgressCard(theme, downloadState),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(mapDownloadProvider.notifier).resume(),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Continuar descarga'),
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(mapDownloadProvider.notifier).cancel(),
                icon: const Icon(Icons.stop, size: 18),
                label: const Text('Cancelar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ] else if (_hdDownloaded) ...[
              FilledButton.icon(
                onPressed: () {
                  ref.read(mapTileModeProvider.notifier).state =
                      MapTileMode.vector;
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.hd, size: 18),
                label: const Text('Usar Mapa HD'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _deleteMap,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Eliminar mapa descargado'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ] else ...[
              FilledButton.icon(
                onPressed: () =>
                    ref.read(mapDownloadProvider.notifier).downloadBaseMap(),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Descargar Mapa HD (~25 MB)'),
              ),
            ],

            // PMTiles error
            if (downloadState.status == DownloadStatus.error &&
                downloadState.errorMessage != null) ...[
              const SizedBox(height: 12),
              _buildErrorCard(theme, downloadState.errorMessage!,
                  () => ref.read(mapDownloadProvider.notifier).downloadBaseMap()),
            ],

            // ── Section: Satellite tiles ─────────────────────────────────────

            const SizedBox(height: 28),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 20),

            Text(
              'Imágenes Satelitales',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Descarga las imágenes satelitales de todas las islas '
              '(zoom 5–13) para ver el mapa satélite sin conexión.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),

            _buildSatelliteStatusCard(
                theme, downloadState, satSizeMB, _satelliteTileCount),
            const SizedBox(height: 16),

            // Satellite action buttons
            if (_loading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (downloadState.isSatelliteActive) ...[
              _buildSatelliteProgressCard(theme, downloadState),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(mapDownloadProvider.notifier).pauseSatellite(),
                      icon: const Icon(Icons.pause, size: 18),
                      label: const Text('Pausar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ref
                          .read(mapDownloadProvider.notifier)
                          .cancelSatellite(),
                      icon: const Icon(Icons.stop, size: 18),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (downloadState.isSatellitePaused) ...[
              _buildSatelliteProgressCard(theme, downloadState),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(mapDownloadProvider.notifier).resumeSatellite(),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Continuar descarga'),
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(mapDownloadProvider.notifier).cancelSatellite(),
                icon: const Icon(Icons.stop, size: 18),
                label: const Text('Cancelar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ] else if (_satelliteTileCount > 0 ||
                downloadState.satelliteStatus == DownloadStatus.completed) ...[
              FilledButton.icon(
                onPressed: () {
                  ref.read(mapTileModeProvider.notifier).state =
                      MapTileMode.satellite;
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.satellite_alt, size: 18),
                label: const Text('Ver Mapa Satelital'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(mapDownloadProvider.notifier).downloadSatelliteTiles(),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Actualizar imágenes'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _deleteSatelliteTiles,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text('Eliminar ($satSizeMB MB)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ] else ...[
              FilledButton.icon(
                onPressed: () =>
                    ref.read(mapDownloadProvider.notifier).downloadSatelliteTiles(),
                icon: const Icon(Icons.satellite_alt, size: 18),
                label: const Text('Descargar satélite (~50–150 MB)'),
              ),
            ],

            // Satellite error
            if (downloadState.satelliteStatus == DownloadStatus.error &&
                downloadState.satelliteErrorMessage != null) ...[
              const SizedBox(height: 12),
              _buildErrorCard(
                theme,
                downloadState.satelliteErrorMessage!,
                () => ref
                    .read(mapDownloadProvider.notifier)
                    .downloadSatelliteTiles(),
              ),
            ],

            // General local error
            if (_localError != null) ...[
              const SizedBox(height: 8),
              Text(
                _localError!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── PMTiles status card ────────────────────────────────────────────────────

  Widget _buildStatusCard(
      ThemeData theme, MapDownloadState downloadState, String sizeMB) {
    final isDownloading = downloadState.isActive;
    final isPaused = downloadState.isPaused;

    Color statusColor;
    IconData statusIcon;
    String statusText;
    String subtitleText;

    if (_hdDownloaded) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Mapa HD disponible offline';
      subtitleText = 'Zoom hasta nivel 15 · $sizeMB MB · Galápagos completo';
    } else if (isDownloading) {
      statusColor = theme.colorScheme.primary;
      statusIcon = Icons.downloading;
      statusText = 'Descargando mapa HD...';
      subtitleText =
          '${(downloadState.overallProgress * 100).toStringAsFixed(0)}% completado';
    } else if (isPaused) {
      statusColor = Colors.orange;
      statusIcon = Icons.pause_circle;
      statusText = 'Descarga en pausa';
      subtitleText =
          '${(downloadState.overallProgress * 100).toStringAsFixed(0)}% completado';
    } else {
      statusColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
      statusIcon = Icons.map_outlined;
      statusText = 'Mapa HD no descargado';
      subtitleText = 'Zoom hasta nivel 15 · ~25 MB · Galápagos completo';
    }

    return _StatusCard(
      theme: theme,
      icon: statusIcon,
      color: statusColor,
      title: statusText,
      subtitle: subtitleText,
    );
  }

  // ── PMTiles progress card ──────────────────────────────────────────────────

  Widget _buildProgressCard(ThemeData theme, MapDownloadState downloadState) {
    return _ProgressCard(
      theme: theme,
      progress: downloadState.overallProgress,
      label:
          '~${((1 - downloadState.overallProgress) * 25).toStringAsFixed(0)} MB restantes',
    );
  }

  // ── Satellite status card ──────────────────────────────────────────────────

  Widget _buildSatelliteStatusCard(ThemeData theme,
      MapDownloadState downloadState, String satSizeMB, int tileCount) {
    final isDownloading = downloadState.isSatelliteActive;
    final isPaused = downloadState.isSatellitePaused;
    final isCompleted = downloadState.satelliteStatus == DownloadStatus.completed;
    final hasTiles = tileCount > 0;

    Color statusColor;
    IconData statusIcon;
    String statusText;
    String subtitleText;

    if (isCompleted || hasTiles) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Imágenes satelitales disponibles offline';
      subtitleText = hasTiles
          ? '$tileCount teselas · $satSizeMB MB · Galápagos completo'
          : 'Galápagos completo · zoom 5–13';
    } else if (isDownloading) {
      statusColor = theme.colorScheme.primary;
      statusIcon = Icons.downloading;
      statusText = 'Descargando imágenes satelitales...';
      final pct = (downloadState.satelliteProgress * 100).toStringAsFixed(0);
      subtitleText = downloadState.satelliteMaxTiles > 0
          ? '$pct% · ${downloadState.satelliteTilesAttempted}/${downloadState.satelliteMaxTiles} teselas'
          : '$pct% completado';
    } else if (isPaused) {
      statusColor = Colors.orange;
      statusIcon = Icons.pause_circle;
      statusText = 'Descarga en pausa';
      final pct = (downloadState.satelliteProgress * 100).toStringAsFixed(0);
      subtitleText = '$pct% completado';
    } else {
      statusColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
      statusIcon = Icons.satellite_alt_outlined;
      statusText = 'Imágenes satelitales no descargadas';
      subtitleText = 'Zoom 5–13 · ~50–150 MB · Galápagos completo';
    }

    return _StatusCard(
      theme: theme,
      icon: statusIcon,
      color: statusColor,
      title: statusText,
      subtitle: subtitleText,
    );
  }

  // ── Satellite progress card ────────────────────────────────────────────────

  Widget _buildSatelliteProgressCard(
      ThemeData theme, MapDownloadState downloadState) {
    final pct = downloadState.satelliteProgress;
    final remaining = downloadState.satelliteMaxTiles > 0
        ? '${downloadState.satelliteMaxTiles - downloadState.satelliteTilesAttempted} teselas restantes'
        : 'calculando...';

    return _ProgressCard(
      theme: theme,
      progress: pct,
      label: remaining,
    );
  }

  // ── Background download notice ─────────────────────────────────────────────

  Widget _buildBackgroundNotice(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.offline_bolt, size: 18, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Las descargas continúan aunque bloquees el iPhone o cambies de app.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error card ─────────────────────────────────────────────────────────────

  Widget _buildErrorCard(
      ThemeData theme, String message, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

// ── Shared card widgets ────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _StatusCard({
    required this.theme,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final ThemeData theme;
  final double progress;
  final String label;

  const _ProgressCard({
    required this.theme,
    required this.progress,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
