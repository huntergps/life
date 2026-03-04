import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import '../../services/proposal_service.dart';
import 'proposal_detail_sheet.dart';

class MyProposalsScreen extends ConsumerWidget {
  const MyProposalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myProposalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis propuestas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(myProposalsProvider),
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
                onPressed: () => ref.invalidate(myProposalsProvider),
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
                  Icon(Icons.edit_note, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No tienes propuestas aún.\nAbre una especie y toca el botón "Proponer cambio".',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myProposalsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: proposals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) =>
                  _ProposalTile(proposal: proposals[i], ref: ref),
            ),
          );
        },
      ),
    );
  }
}

class _ProposalTile extends StatelessWidget {
  final Map<String, dynamic> proposal;
  final WidgetRef ref;

  const _ProposalTile({required this.proposal, required this.ref});

  @override
  Widget build(BuildContext context) {
    final status = proposal['status'] as String;
    final curatorStatus = proposal['curator_status'] as String? ?? 'pending_review';
    final species = proposal['species'] as Map<String, dynamic>?;
    final speciesName = species?['common_name_es'] as String? ?? 'Especie #${proposal['species_id']}';
    final createdAt = DateTime.tryParse(proposal['created_at'] as String? ?? '');
    final changes = proposal['changes'] as Map<String, dynamic>? ?? {};
    final fieldCount = changes.length;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showProposalDetailSheet(context, proposal),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      speciesName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  _StatusChip(status: status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$fieldCount campo${fieldCount == 1 ? '' : 's'} modificado${fieldCount == 1 ? '' : 's'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              if (status == 'pending') ...[
                const SizedBox(height: 4),
                _CuratorStatusBadge(curatorStatus: curatorStatus),
              ],
              if (proposal['admin_notes'] != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: status == 'approved'
                        ? Colors.green.withValues(alpha: 0.08)
                        : Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Admin: ${proposal['admin_notes']}',
                    style: TextStyle(
                      fontSize: 13,
                      color: status == 'approved'
                          ? Colors.green[700]
                          : Colors.red[700],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (createdAt != null)
                    Text(
                      DateFormat('dd MMM yyyy').format(createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  if (status == 'pending')
                    TextButton.icon(
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Retirar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                      ),
                      onPressed: () => _withdraw(context),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _withdraw(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Retirar propuesta'),
        content: const Text(
            '¿Seguro que quieres retirar esta propuesta? No se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Retirar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ProposalService.withdraw(proposal['id'] as int);
      ref.invalidate(myProposalsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'pending' => ('Pendiente', Colors.orange),
      'approved' => ('Aprobado', Colors.green),
      'rejected' => ('Rechazado', Colors.red),
      'withdrawn' => ('Retirado', Colors.grey),
      _ => (status, Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _CuratorStatusBadge extends StatelessWidget {
  final String curatorStatus;
  const _CuratorStatusBadge({required this.curatorStatus});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (curatorStatus) {
      'curator_approved' => ('Curador: aprobado', Icons.check_circle_outline, Colors.teal),
      'curator_flagged' => ('Curador: observaciones', Icons.flag_outlined, Colors.orange),
      _ => ('Esperando revisión del curador', Icons.hourglass_empty, Colors.grey),
    };
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
