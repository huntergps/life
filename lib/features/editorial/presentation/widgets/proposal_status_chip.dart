import 'package:flutter/material.dart';

/// Pill badge for proposal status (pending / approved / rejected / withdrawn).
class ProposalStatusChip extends StatelessWidget {
  final String status;
  const ProposalStatusChip({super.key, required this.status});

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
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

/// Column badge for curator review status (curator_approved / curator_flagged).
class CuratorStatusBadge extends StatelessWidget {
  final String status;
  const CuratorStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      'curator_approved' =>
        ('Aprobado', Colors.teal, Icons.check_circle_outline),
      'curator_flagged' =>
        ('Observación', Colors.orange, Icons.flag_outlined),
      _ => ('Sin revisar', Colors.grey, Icons.hourglass_empty),
    };
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
