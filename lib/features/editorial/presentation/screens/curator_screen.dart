import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import '../../services/proposal_service.dart';

class CuratorScreen extends ConsumerWidget {
  const CuratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pendingFeedbackProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validar correcciones de IA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(pendingFeedbackProvider),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Error: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(pendingFeedbackProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Sin correcciones pendientes',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Todas las correcciones de IA han sido validadas.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(pendingFeedbackProvider),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: _buildList(context, items, ref, isDark),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> items,
      WidgetRef ref, bool isDark) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 800;

    if (isWide) {
      // Two-column grid on wide screens
      return GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.55,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) =>
            _FeedbackCard(feedback: items[i], ref: ref, isDark: isDark),
      );
    }

    // Single column on narrow screens
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) =>
          _FeedbackCard(feedback: items[i], ref: ref, isDark: isDark),
    );
  }
}

// ── Feedback card ─────────────────────────────────────────────────────────────

class _FeedbackCard extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final WidgetRef ref;
  final bool isDark;
  const _FeedbackCard(
      {required this.feedback, required this.ref, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final confidence = (feedback['predicted_confidence'] as num?)?.toDouble();
    final photoUrl = feedback['photo_url'] as String?;
    final rank = feedback['user_selected_rank'] as int? ?? 0;
    final predicted = feedback['predicted'] as Map?;
    final correct = feedback['correct'] as Map?;
    final predictedName = predicted?['common_name_es'] as String?
        ?? 'Especie #${feedback['predicted_species_id']}';
    final predictedSci = predicted?['scientific_name'] as String?;
    final correctName = correct?['common_name_es'] as String?
        ?? 'Especie #${feedback['correct_species_id']}';
    final correctSci = correct?['scientific_name'] as String?;
    final confStr = confidence != null
        ? ' (${(confidence * 100).toStringAsFixed(1)}%)'
        : '';
    final rankStr = rank > 0 ? ' — rango $rank' : ' — búsqueda manual';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Thumbnail row ──────────────────────────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo thumbnail
                SizedBox(
                  width: 130,
                  child: _Thumbnail(url: photoUrl, isDark: isDark),
                ),

                // Info panel
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Predicted
                        _SpeciesRow(
                          icon: Icons.warning_amber_outlined,
                          color: Colors.red,
                          label: 'IA predijo$confStr:',
                          name: predictedName,
                          scientific: predictedSci,
                        ),
                        const SizedBox(height: 8),
                        // Correct
                        _SpeciesRow(
                          icon: Icons.person_outlined,
                          color: Colors.blue,
                          label: 'Usuario corrigió$rankStr:',
                          name: correctName,
                          scientific: correctSci,
                        ),
                        const Spacer(),
                        const Text(
                          '¿La corrección es científicamente correcta?',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Action buttons ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                    label: const Text('No válida',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => _validate(context, false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Válida'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => _validate(context, true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validate(BuildContext context, bool isValid) async {
    final notesCtrl = TextEditingController();
    final notes = await showDialog<String?>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
            isValid ? 'Confirmar corrección válida' : 'Marcar como inválida'),
        content: TextField(
          controller: notesCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Notas científicas (opcional)...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, null),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: isValid ? Colors.green : Colors.red),
            onPressed: () =>
                Navigator.pop(dialogCtx, notesCtrl.text.trim()),
            child: Text(isValid ? 'Confirmar válida' : 'Confirmar inválida'),
          ),
        ],
      ),
    );
    if (notes == null) return;
    try {
      await ProposalService.validateFeedback(
        feedback['id'] as int,
        isValid,
        notes: notes.isEmpty ? null : notes,
      );
      ref.invalidate(pendingFeedbackProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }
}

// ── Thumbnail widget ──────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  final String? url;
  final bool isDark;
  const _Thumbnail({required this.url, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Container(
        color: isDark ? Colors.white10 : Colors.grey[200],
        child: Icon(Icons.photo_camera_outlined,
            size: 40,
            color: isDark ? Colors.white30 : Colors.grey[400]),
      );
    }

    return GestureDetector(
      onTap: () => _openFullscreen(context, url!),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: isDark ? Colors.white10 : Colors.grey[200],
              child: Icon(Icons.broken_image_outlined,
                  color: isDark ? Colors.white30 : Colors.grey[400]),
            ),
          ),
          // Zoom hint overlay
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.zoom_in, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Species info row ──────────────────────────────────────────────────────────

class _SpeciesRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String name;
  final String? scientific;
  const _SpeciesRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.name,
    this.scientific,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: color.withValues(alpha: 0.8))),
              Text(name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color)),
              if (scientific != null)
                Text(scientific!,
                    style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: color.withValues(alpha: 0.65))),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Fullscreen image viewer ────────────────────────────────────────────────────

void _openFullscreen(BuildContext context, String url) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _FullscreenImagePage(url: url),
    ),
  );
}

class _FullscreenImagePage extends StatelessWidget {
  final String url;
  const _FullscreenImagePage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.escape): const _CloseIntent(),
      },
      child: Actions(
        actions: {
          _CloseIntent:
              CallbackAction<_CloseIntent>(onInvoke: (_) {
            Navigator.of(context).pop();
            return null;
          }),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: const Text('Foto del feedback'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cerrar (ESC)',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: PhotoView(
              imageProvider: NetworkImage(url),
              backgroundDecoration:
                  const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 4,
              heroAttributes: PhotoViewHeroAttributes(tag: url),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseIntent extends Intent {
  const _CloseIntent();
}
