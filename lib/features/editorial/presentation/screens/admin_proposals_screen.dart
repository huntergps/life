import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import '../../services/proposal_service.dart';
import '../widgets/proposal_status_chip.dart';
import 'proposal_detail_sheet.dart';

/// Admin screen: review pending proposals and approve or reject them.
class AdminProposalsScreen extends ConsumerWidget {
  const AdminProposalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pendingProposalsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propuestas pendientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(pendingProposalsProvider),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Error: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(pendingProposalsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (proposals) {
          if (proposals.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No hay propuestas pendientes.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(pendingProposalsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: proposals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _AdminProposalTile(proposal: proposals[i], ref: ref),
            ),
          );
        },
      ),
    );
  }
}

class _AdminProposalTile extends StatelessWidget {
  final Map<String, dynamic> proposal;
  final WidgetRef ref;
  const _AdminProposalTile({required this.proposal, required this.ref});

  @override
  Widget build(BuildContext context) {
    final species = proposal['species'] as Map<String, dynamic>?;
    final speciesName = species?['common_name_es'] as String? ??
        'Especie #${proposal['species_id']}';
    final changes = proposal['changes'] as Map<String, dynamic>? ?? {};
    final editorNotes = proposal['editor_notes'] as String?;
    final curatorStatus =
        proposal['curator_status'] as String? ?? 'pending_review';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(speciesName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 2),
                      Text(
                        '${changes.length} campo(s): ${changes.keys.join(', ')}',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                CuratorStatusBadge(status: curatorStatus),
              ],
            ),

            // Editor notes
            if (editorNotes != null && editorNotes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Editor: $editorNotes',
                    style: const TextStyle(fontSize: 13),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ),
            ],

            // Curator notes
            if (proposal['curator_notes'] != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: curatorStatus == 'curator_approved'
                      ? Colors.teal.withValues(alpha: 0.07)
                      : Colors.orange.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Curador: ${proposal['curator_notes']}',
                    style: const TextStyle(fontSize: 13),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ),
            ],

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                TextButton(
                  onPressed: () =>
                      showProposalDetailSheet(context, proposal),
                  child: const Text('Ver diff'),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.close, size: 16,
                      color: Colors.red),
                  label: const Text('Rechazar',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red)),
                  onPressed: () => _reject(context),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Aprobar'),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  onPressed: () => _approve(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approve(BuildContext context) async {
    final notesCtrl = TextEditingController();
    final notes = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aprobar propuesta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Esto aplicará los cambios directamente a la especie.'),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                hintText: 'Notas del admin (opcional)...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary),
            onPressed: () =>
                Navigator.pop(context, notesCtrl.text.trim()),
            child: const Text('Confirmar aprobación'),
          ),
        ],
      ),
    );
    if (notes == null) return;
    try {
      await ProposalService.approve(
        proposal['id'] as int,
        notes: notes.isEmpty ? null : notes,
      );
      ref.invalidate(pendingProposalsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propuesta aprobada y cambios aplicados.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
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

  Future<void> _reject(BuildContext context) async {
    final notesCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rechazar propuesta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Motivo del rechazo (obligatorio):'),
            const SizedBox(height: 8),
            TextField(
              controller: notesCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Indica por qué se rechaza...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final reason = notesCtrl.text.trim();
    if (reason.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('El motivo del rechazo es obligatorio.')),
        );
      }
      return;
    }
    try {
      await ProposalService.reject(proposal['id'] as int, reason);
      ref.invalidate(pendingProposalsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Propuesta rechazada.')),
        );
      }
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

