import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import '../../services/proposal_service.dart';

/// Bottom sheet that lets an editor propose changes to a species.
///
/// Shows the current values pre-filled. The editor modifies only the fields
/// they want to change. On submit a JSONB diff is generated and submitted
/// as a pending proposal for curator review and admin approval.
void showSpeciesProposalFormSheet(BuildContext context, Species species) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _SpeciesProposalFormSheet(species: species),
  );
}

class _SpeciesProposalFormSheet extends StatefulWidget {
  final Species species;
  const _SpeciesProposalFormSheet({required this.species});
  @override
  State<_SpeciesProposalFormSheet> createState() =>
      _SpeciesProposalFormSheetState();
}

class _SpeciesProposalFormSheetState
    extends State<_SpeciesProposalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Text controllers (pre-filled with current values)
  late final TextEditingController _descEsCtrl;
  late final TextEditingController _descEnCtrl;
  late final TextEditingController _habitatEsCtrl;
  late final TextEditingController _habitatEnCtrl;
  late final TextEditingController _featuresEsCtrl;
  late final TextEditingController _featuresEnCtrl;
  late final TextEditingController _populationCtrl;
  late final TextEditingController _socialCtrl;
  late final TextEditingController _activityCtrl;
  late final TextEditingController _dietCtrl;
  late final TextEditingController _notesCtrl;

  String? _conservationStatus;

  static const _statuses = ['EX', 'EW', 'CR', 'EN', 'VU', 'NT', 'LC', 'DD'];

  @override
  void initState() {
    super.initState();
    final s = widget.species;
    _descEsCtrl = TextEditingController(text: s.descriptionEs ?? '');
    _descEnCtrl = TextEditingController(text: s.descriptionEn ?? '');
    _habitatEsCtrl = TextEditingController(text: s.habitatEs ?? '');
    _habitatEnCtrl = TextEditingController(text: s.habitatEn ?? '');
    _featuresEsCtrl =
        TextEditingController(text: s.distinguishingFeaturesEs ?? '');
    _featuresEnCtrl =
        TextEditingController(text: s.distinguishingFeaturesEn ?? '');
    _populationCtrl =
        TextEditingController(text: s.populationEstimate?.toString() ?? '');
    _socialCtrl = TextEditingController(text: s.socialStructure ?? '');
    _activityCtrl = TextEditingController(text: s.activityPattern ?? '');
    _dietCtrl = TextEditingController(text: s.dietType ?? '');
    _notesCtrl = TextEditingController();
    _conservationStatus = s.conservationStatus;
  }

  @override
  void dispose() {
    for (final c in [
      _descEsCtrl, _descEnCtrl, _habitatEsCtrl, _habitatEnCtrl,
      _featuresEsCtrl, _featuresEnCtrl, _populationCtrl,
      _socialCtrl, _activityCtrl, _dietCtrl, _notesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // Build the JSONB diff: only fields that actually changed
  Map<String, dynamic> _buildDiff() {
    final s = widget.species;
    final diff = <String, dynamic>{};

    void checkText(String key, String? oldVal, TextEditingController ctrl) {
      final newVal = ctrl.text.trim().isEmpty ? null : ctrl.text.trim();
      if (newVal != (oldVal?.trim().isEmpty == true ? null : oldVal?.trim())) {
        diff[key] = {'old': oldVal, 'new': newVal};
      }
    }

    checkText('description_es', s.descriptionEs, _descEsCtrl);
    checkText('description_en', s.descriptionEn, _descEnCtrl);
    checkText('habitat_es', s.habitatEs, _habitatEsCtrl);
    checkText('habitat_en', s.habitatEn, _habitatEnCtrl);
    checkText('distinguishing_features_es', s.distinguishingFeaturesEs, _featuresEsCtrl);
    checkText('distinguishing_features_en', s.distinguishingFeaturesEn, _featuresEnCtrl);
    checkText('social_structure', s.socialStructure, _socialCtrl);
    checkText('activity_pattern', s.activityPattern, _activityCtrl);
    checkText('diet_type', s.dietType, _dietCtrl);

    // Conservation status
    if (_conservationStatus != s.conservationStatus) {
      diff['conservation_status'] = {
        'old': s.conservationStatus,
        'new': _conservationStatus,
      };
    }

    // Population estimate
    final popNew = int.tryParse(_populationCtrl.text.trim());
    if (popNew != s.populationEstimate) {
      diff['population_estimate'] = {
        'old': s.populationEstimate,
        'new': popNew,
      };
    }

    return diff;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final diff = _buildDiff();
    if (diff.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cambios para proponer.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ProposalService.submit(
        speciesId: widget.species.id,
        changes: diff,
        editorNotes: _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propuesta enviada. Pendiente de revisión.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al enviar: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.species;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Form(
        key: _formKey,
        child: Column(
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.edit_note, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Proponer cambio',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(s.commonNameEs,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),
            // Form fields
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _sectionLabel('Descripción (Español)'),
                  _textArea(_descEsCtrl, 'Descripción en español'),
                  _sectionLabel('Descripción (English)'),
                  _textArea(_descEnCtrl, 'Description in English'),
                  _sectionLabel('Hábitat (Español)'),
                  _textArea(_habitatEsCtrl, 'Hábitat en español'),
                  _sectionLabel('Hábitat (English)'),
                  _textArea(_habitatEnCtrl, 'Habitat in English'),
                  _sectionLabel('Características distintivas (ES)'),
                  _textArea(_featuresEsCtrl, 'Características en español'),
                  _sectionLabel('Distinguishing features (EN)'),
                  _textArea(_featuresEnCtrl, 'Features in English'),
                  _sectionLabel('Estado de conservación UICN'),
                  DropdownButtonFormField<String?>(
                    value: _conservationStatus,
                    decoration: _inputDecoration('Estado actual: ${s.conservationStatus ?? "—"}'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sin cambio')),
                      ..._statuses.map((st) => DropdownMenuItem(
                            value: st,
                            child: Text(st),
                          )),
                    ],
                    onChanged: (v) =>
                        setState(() => _conservationStatus = v),
                  ),
                  const SizedBox(height: 16),
                  _sectionLabel('Estimado poblacional'),
                  TextFormField(
                    controller: _populationCtrl,
                    decoration: _inputDecoration(
                        'Actual: ${s.populationEstimate ?? "—"}'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  _sectionLabel('Estructura social'),
                  _textField(_socialCtrl, 'Actual: ${s.socialStructure ?? "—"}'),
                  _sectionLabel('Patrón de actividad'),
                  _textField(_activityCtrl, 'Actual: ${s.activityPattern ?? "—"}'),
                  _sectionLabel('Tipo de dieta'),
                  _textField(_dietCtrl, 'Actual: ${s.dietType ?? "—"}'),
                  const Divider(height: 32),
                  _sectionLabel('Justificación (opcional)'),
                  TextFormField(
                    controller: _notesCtrl,
                    decoration: _inputDecoration(
                        'Explica por qué propones estos cambios...'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_outlined),
                    label: Text(_loading ? 'Enviando...' : 'Enviar propuesta'),
                    onPressed: _loading ? null : _submit,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
      );

  Widget _textArea(TextEditingController ctrl, String hint) =>
      TextFormField(
        controller: ctrl,
        decoration: _inputDecoration(hint),
        maxLines: 4,
        minLines: 2,
      );

  Widget _textField(TextEditingController ctrl, String hint) =>
      TextFormField(
        controller: ctrl,
        decoration: _inputDecoration(hint),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      );
}
