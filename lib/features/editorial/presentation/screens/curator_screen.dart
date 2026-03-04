import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import '../../services/proposal_service.dart';
import 'proposal_detail_sheet.dart';

class CuratorScreen extends ConsumerStatefulWidget {
  const CuratorScreen({super.key});
  @override
  ConsumerState<CuratorScreen> createState() => _CuratorScreenState();
}

class _CuratorScreenState extends ConsumerState<CuratorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del curador'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.edit_document), text: 'Propuestas'),
            Tab(icon: Icon(Icons.psychology_outlined), text: 'IA Feedback'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _CuratorProposalsTab(),
          _CuratorFeedbackTab(),
        ],
      ),
    );
  }
}

// ── Tab 1: Pending proposals ──────────────────────────────────────────────────

class _CuratorProposalsTab extends ConsumerWidget {
  const _CuratorProposalsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pendingProposalsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorRetry(error: e, onRetry: () => ref.invalidate(pendingProposalsProvider)),
      data: (proposals) {
        if (proposals.isEmpty) {
          return const _EmptyState(
            icon: Icons.check_circle_outline,
            message: 'No hay propuestas pendientes de revisión.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(pendingProposalsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: proposals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) =>
                _CuratorProposalTile(proposal: proposals[i], ref: ref),
          ),
        );
      },
    );
  }
}

class _CuratorProposalTile extends StatelessWidget {
  final Map<String, dynamic> proposal;
  final WidgetRef ref;
  const _CuratorProposalTile({required this.proposal, required this.ref});

  @override
  Widget build(BuildContext context) {
    final curatorStatus = proposal['curator_status'] as String? ?? 'pending_review';
    final species = proposal['species'] as Map<String, dynamic>?;
    final speciesName = species?['common_name_es'] as String? ?? 'Especie #${proposal['species_id']}';
    final changes = proposal['changes'] as Map<String, dynamic>? ?? {};
    final reviewed = curatorStatus != 'pending_review';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(speciesName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                if (reviewed)
                  _CuratorStatusChip(curatorStatus),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${changes.length} campo(s) modificado(s): ${changes.keys.join(', ')}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (proposal['editor_notes'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Editor: ${proposal['editor_notes']}',
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () =>
                      showProposalDetailSheet(context, proposal),
                  child: const Text('Ver diff'),
                ),
                const Spacer(),
                if (!reviewed) ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.flag_outlined, size: 16,
                        color: Colors.orange),
                    label: const Text('Observar',
                        style: TextStyle(color: Colors.orange)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                    ),
                    onPressed: () =>
                        _review(context, 'curator_flagged'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Aprobar'),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.teal),
                    onPressed: () =>
                        _review(context, 'curator_approved'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _review(BuildContext context, String status) async {
    final notesCtrl = TextEditingController();
    final notes = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(status == 'curator_approved'
            ? 'Aprobar propuesta'
            : 'Marcar con observaciones'),
        content: TextField(
          controller: notesCtrl,
          decoration: const InputDecoration(
            hintText: 'Notas científicas (opcional)...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, notesCtrl.text.trim()),
              child: const Text('Confirmar')),
        ],
      ),
    );
    if (notes == null) return;
    try {
      await ProposalService.curatorReview(
        proposal['id'] as int,
        status,
        notes: notes.isEmpty ? null : notes,
      );
      ref.invalidate(pendingProposalsProvider);
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

// ── Tab 2: AI Feedback validation ─────────────────────────────────────────────

class _CuratorFeedbackTab extends ConsumerWidget {
  const _CuratorFeedbackTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pendingFeedbackProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorRetry(error: e, onRetry: () => ref.invalidate(pendingFeedbackProvider)),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  photoUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 10),
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
    final notes = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isValid ? 'Confirmar corrección válida' : 'Marcar como inválida'),
        content: TextField(
          controller: notesCtrl,
          decoration: const InputDecoration(
            hintText: 'Notas (opcional)...',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, notesCtrl.text.trim()),
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

// ── Shared widgets ────────────────────────────────────────────────────────────

class _CuratorStatusChip extends StatelessWidget {
  final String status;
  const _CuratorStatusChip(this.status);
  @override
  Widget build(BuildContext context) {
    final (label, color) = status == 'curator_approved'
        ? ('Aprobado', Colors.teal)
        : ('Observado', Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

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
