import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import '../../services/proposal_service.dart';

class CuratorScreen extends ConsumerWidget {
  const CuratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validar correcciones de IA'),
      ),
      body: const _CuratorFeedbackTab(),
    );
  }
}

// ── AI Feedback validation ─────────────────────────────────────────────────────

class _CuratorFeedbackTab extends ConsumerWidget {
  const _CuratorFeedbackTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pendingFeedbackProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorRetry(
          error: e, onRetry: () => ref.invalidate(pendingFeedbackProvider)),
      data: (items) {
        if (items.isEmpty) {
          return const _EmptyState(
            icon: Icons.check_circle_outline,
            message: 'No hay correcciones de IA pendientes de validación.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(pendingFeedbackProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) =>
                _FeedbackTile(feedback: items[i], ref: ref),
          ),
        );
      },
    );
  }
}

class _FeedbackTile extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final WidgetRef ref;
  const _FeedbackTile({required this.feedback, required this.ref});

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photoUrl != null)
              GestureDetector(
                onTap: () => _openFullscreen(context, photoUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    photoUrl,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            // Predicted species
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_outlined,
                    color: Colors.red, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IA predijo: $predictedName'
                        '${confidence != null ? ' (${(confidence * 100).toStringAsFixed(1)}%)' : ''}',
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w500),
                      ),
                      if (predictedSci != null)
                        Text(predictedSci,
                            style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Colors.red.shade300)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Correct species (user selection)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Colors.green, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuario seleccionó: $correctName'
                        '${rank > 0 ? ' (rango $rank)' : ' (búsqueda manual)'}',
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.w500),
                      ),
                      if (correctSci != null)
                        Text(correctSci,
                            style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Colors.green.shade400)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '¿La corrección del usuario es científicamente correcta?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('No válida',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red)),
                    onPressed: () => _validate(context, false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Válida'),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.green),
                    onPressed: () => _validate(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _validate(BuildContext context, bool isValid) async {
    final notesCtrl = TextEditingController();
    // Use dialogCtx (not outer context) for Navigator.pop so only the dialog closes
    final notes = await showDialog<String?>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(isValid ? 'Confirmar corrección válida' : 'Marcar como inválida'),
        content: TextField(
          controller: notesCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Notas (opcional)...',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, null),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogCtx, notesCtrl.text.trim()),
              child: const Text('Confirmar')),
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

// ── Fullscreen image viewer ────────────────────────────────────────────────────

void _openFullscreen(BuildContext context, String url) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Foto del feedback'),
        ),
        body: PhotoView(
          imageProvider: NetworkImage(url),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
        ),
      ),
    ),
  );
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
}

class _ErrorRetry extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Error: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      );
}
