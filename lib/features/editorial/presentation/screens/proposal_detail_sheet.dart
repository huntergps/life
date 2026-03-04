import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shows the full diff of a proposal in a bottom sheet.
void showProposalDetailSheet(
    BuildContext context, Map<String, dynamic> proposal) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ProposalDetailSheet(proposal: proposal),
  );
}

class _ProposalDetailSheet extends StatelessWidget {
  final Map<String, dynamic> proposal;
  const _ProposalDetailSheet({required this.proposal});

  @override
  Widget build(BuildContext context) {
    final changes = proposal['changes'] as Map<String, dynamic>? ?? {};
    final species = proposal['species'] as Map<String, dynamic>?;
    final speciesName = species?['common_name_es'] as String? ??
        'Especie #${proposal['species_id']}';
    final editorNotes = proposal['editor_notes'] as String?;
    final curatorNotes = proposal['curator_notes'] as String?;
    final adminNotes = proposal['admin_notes'] as String?;
    final createdAt = DateTime.tryParse(proposal['created_at'] as String? ?? '');
    final reviewedAt =
        DateTime.tryParse(proposal['reviewed_at'] as String? ?? '');

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(20),
              children: [
                // Header
                Text(speciesName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 4),
                if (createdAt != null)
                  Text(
                    'Enviada el ${DateFormat('dd MMM yyyy, HH:mm').format(createdAt)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                const SizedBox(height: 20),

                // Editor notes
                if (editorNotes != null && editorNotes.isNotEmpty) ...[
                  _SectionHeader('Justificación del editor'),
                  const SizedBox(height: 8),
                  _NoteBubble(editorNotes, color: Colors.blue),
                  const SizedBox(height: 20),
                ],

                // Changes diff
                _SectionHeader('Cambios propuestos'),
                const SizedBox(height: 8),
                if (changes.isEmpty)
                  const Text('Sin cambios registrados.',
                      style: TextStyle(color: Colors.grey))
                else
                  ...changes.entries.map((e) => _DiffRow(
                        fieldName: e.key,
                        oldVal: (e.value as Map<String, dynamic>?)?['old'],
                        newVal: (e.value as Map<String, dynamic>?)?['new'],
                      )),
                const SizedBox(height: 20),

                // Curator notes
                if (curatorNotes != null && curatorNotes.isNotEmpty) ...[
                  _SectionHeader('Notas del curador'),
                  const SizedBox(height: 8),
                  _NoteBubble(curatorNotes, color: Colors.teal),
                  const SizedBox(height: 20),
                ],

                // Admin notes
                if (adminNotes != null && adminNotes.isNotEmpty) ...[
                  _SectionHeader('Decisión del administrador'),
                  const SizedBox(height: 8),
                  if (reviewedAt != null)
                    Text(
                      DateFormat('dd MMM yyyy').format(reviewedAt),
                      style:
                          TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  const SizedBox(height: 4),
                  _NoteBubble(
                    adminNotes,
                    color: proposal['status'] == 'approved'
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      );
}

class _NoteBubble extends StatelessWidget {
  final String text;
  final Color color;
  const _NoteBubble(this.text, {required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(text, style: TextStyle(color: color.withValues(alpha: 0.9))),
      );
}

class _DiffRow extends StatelessWidget {
  final String fieldName;
  final dynamic oldVal;
  final dynamic newVal;

  const _DiffRow({
    required this.fieldName,
    required this.oldVal,
    required this.newVal,
  });

  static const _fieldLabels = {
    'description_es': 'Descripción (ES)',
    'description_en': 'Descripción (EN)',
    'habitat_es': 'Hábitat (ES)',
    'habitat_en': 'Hábitat (EN)',
    'distinguishing_features_es': 'Características (ES)',
    'distinguishing_features_en': 'Características (EN)',
    'conservation_status': 'Estado de conservación',
    'population_estimate': 'Estimado poblacional',
    'weight_kg': 'Peso (kg)',
    'size_cm': 'Talla (cm)',
    'diet_type': 'Tipo de dieta',
    'social_structure': 'Estructura social',
    'activity_pattern': 'Patrón de actividad',
    'breeding_season': 'Temporada de reproducción',
    'lifespan_years': 'Esperanza de vida (años)',
  };

  @override
  Widget build(BuildContext context) {
    final label = _fieldLabels[fieldName] ?? fieldName;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          if (oldVal != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('−  ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text('$oldVal',
                        style: TextStyle(color: Colors.red[800], fontSize: 13)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('+  ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text('${newVal ?? "(vacío)"}',
                      style: TextStyle(color: Colors.green[800], fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
