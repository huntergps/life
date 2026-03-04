import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import '../../services/proposal_service.dart';

// ── Section enum & field-key mapping ──────────────────────────────────────────

enum ProposalSection { description, habitat, behavior, reproduction, distinguishingFeatures }

/// Maps each section to the DB field keys it contains.
/// Used by the pending-proposal indicator on section headers.
const Map<ProposalSection, List<String>> kSectionFields = {
  ProposalSection.description: ['description_es', 'description_en'],
  ProposalSection.habitat: ['habitat_es', 'habitat_en'],
  ProposalSection.behavior: [
    'diet_type', 'activity_pattern', 'social_structure', 'population_trend'
  ],
  ProposalSection.reproduction: [
    'breeding_season', 'clutch_size', 'reproductive_frequency'
  ],
  ProposalSection.distinguishingFeatures: [
    'distinguishing_features_es', 'distinguishing_features_en'
  ],
};

// ── Entry point ───────────────────────────────────────────────────────────────

void showFieldProposalSheet(
  BuildContext context,
  Species species,
  ProposalSection section,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FieldProposalSheet(species: species, section: section),
  );
}

// ── Sheet widget ─────────────────────────────────────────────────────────────

class _FieldProposalSheet extends StatefulWidget {
  final Species species;
  final ProposalSection section;
  const _FieldProposalSheet({required this.species, required this.section});

  @override
  State<_FieldProposalSheet> createState() => _FieldProposalSheetState();
}

class _FieldProposalSheetState extends State<_FieldProposalSheet> {
  bool _loading = false;
  late final TextEditingController _notesCtrl;

  // Bilingual text fields (description / habitat / features)
  TextEditingController? _esCtrl;
  TextEditingController? _enCtrl;

  // Behavior text field
  TextEditingController? _socialCtrl;

  // Reproduction text fields
  TextEditingController? _breedingCtrl;
  TextEditingController? _clutchCtrl;
  TextEditingController? _reproCtrl;

  // Dropdown values
  String? _dietType;
  String? _activityPattern;
  String? _populationTrend;

  static const _dietOptions = [
    'herbivore', 'carnivore', 'omnivore', 'piscivore',
    'insectivore', 'nectarivore', 'frugivore',
  ];
  static const _activityOptions = ['diurnal', 'nocturnal', 'crepuscular'];
  static const _trendOptions = ['increasing', 'stable', 'decreasing'];

  @override
  void initState() {
    super.initState();
    final s = widget.species;
    _notesCtrl = TextEditingController();
    switch (widget.section) {
      case ProposalSection.description:
        _esCtrl = TextEditingController(text: s.descriptionEs ?? '');
        _enCtrl = TextEditingController(text: s.descriptionEn ?? '');
      case ProposalSection.habitat:
        _esCtrl = TextEditingController(text: s.habitatEs ?? '');
        _enCtrl = TextEditingController(text: s.habitatEn ?? '');
      case ProposalSection.distinguishingFeatures:
        _esCtrl = TextEditingController(
            text: s.distinguishingFeaturesEs ?? '');
        _enCtrl = TextEditingController(
            text: s.distinguishingFeaturesEn ?? '');
      case ProposalSection.behavior:
        _dietType = s.dietType;
        _activityPattern = s.activityPattern;
        _populationTrend = s.populationTrend;
        _socialCtrl = TextEditingController(text: s.socialStructure ?? '');
      case ProposalSection.reproduction:
        _breedingCtrl =
            TextEditingController(text: s.breedingSeason ?? '');
        _clutchCtrl = TextEditingController(
            text: s.clutchSize?.toString() ?? '');
        _reproCtrl = TextEditingController(
            text: s.reproductiveFrequency ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in [
      _notesCtrl, _esCtrl, _enCtrl, _socialCtrl,
      _breedingCtrl, _clutchCtrl, _reproCtrl,
    ]) {
      c?.dispose();
    }
    super.dispose();
  }

  // ── Diff builder ────────────────────────────────────────────────────────────

  Map<String, dynamic> _buildDiff() {
    final s = widget.species;
    final diff = <String, dynamic>{};

    void checkText(String key, String? oldVal, TextEditingController? ctrl) {
      if (ctrl == null) return;
      final newVal = ctrl.text.trim().isEmpty ? null : ctrl.text.trim();
      final oldNorm = (oldVal?.trim().isEmpty ?? true) ? null : oldVal!.trim();
      if (newVal != oldNorm) diff[key] = {'old': oldVal, 'new': newVal};
    }

    void checkEnum(String key, String? oldVal, String? newVal) {
      if (newVal != oldVal) diff[key] = {'old': oldVal, 'new': newVal};
    }

    switch (widget.section) {
      case ProposalSection.description:
        checkText('description_es', s.descriptionEs, _esCtrl);
        checkText('description_en', s.descriptionEn, _enCtrl);
      case ProposalSection.habitat:
        checkText('habitat_es', s.habitatEs, _esCtrl);
        checkText('habitat_en', s.habitatEn, _enCtrl);
      case ProposalSection.distinguishingFeatures:
        checkText('distinguishing_features_es',
            s.distinguishingFeaturesEs, _esCtrl);
        checkText('distinguishing_features_en',
            s.distinguishingFeaturesEn, _enCtrl);
      case ProposalSection.behavior:
        checkEnum('diet_type', s.dietType, _dietType);
        checkEnum('activity_pattern', s.activityPattern, _activityPattern);
        checkEnum('population_trend', s.populationTrend, _populationTrend);
        checkText('social_structure', s.socialStructure, _socialCtrl);
      case ProposalSection.reproduction:
        checkText('breeding_season', s.breedingSeason, _breedingCtrl);
        checkText('clutch_size', s.clutchSize?.toString(), _clutchCtrl);
        checkText('reproductive_frequency',
            s.reproductiveFrequency, _reproCtrl);
    }

    return diff;
  }

  Future<void> _submit() async {
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
              content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _sectionTitle => switch (widget.section) {
        ProposalSection.description => 'Descripción',
        ProposalSection.habitat => 'Hábitat',
        ProposalSection.behavior => 'Comportamiento',
        ProposalSection.reproduction => 'Reproducción',
        ProposalSection.distinguishingFeatures => 'Características distintivas',
      };

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.edit_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Proponer cambio — $_sectionTitle',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        widget.species.commonNameEs,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 20),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ..._buildFields(),
                const Divider(height: 32),
                _label('Justificación (opcional)'),
                TextFormField(
                  controller: _notesCtrl,
                  decoration:
                      _dec('Explica por qué propones este cambio...'),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
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
    );
  }

  List<Widget> _buildFields() => switch (widget.section) {
        ProposalSection.description ||
        ProposalSection.habitat ||
        ProposalSection.distinguishingFeatures =>
          _bilingualFields(),
        ProposalSection.behavior => _behaviorFields(),
        ProposalSection.reproduction => _reproductionFields(),
      };

  // ── Bilingual (ES + EN) fields ───────────────────────────────────────────────

  List<Widget> _bilingualFields() {
    final s = widget.species;
    final (oldEs, oldEn) = switch (widget.section) {
      ProposalSection.description =>
        (s.descriptionEs, s.descriptionEn),
      ProposalSection.habitat =>
        (s.habitatEs, s.habitatEn),
      _ =>
        (s.distinguishingFeaturesEs, s.distinguishingFeaturesEn),
    };
    return [
      _label('Español'),
      _currentValue(oldEs),
      TextFormField(
        controller: _esCtrl!,
        decoration: _dec('Nueva versión en español'),
        maxLines: 4,
        minLines: 2,
      ),
      const SizedBox(height: 16),
      _label('English'),
      _currentValue(oldEn),
      TextFormField(
        controller: _enCtrl!,
        decoration: _dec('New version in English'),
        maxLines: 4,
        minLines: 2,
      ),
    ];
  }

  // ── Behavior fields ──────────────────────────────────────────────────────────

  List<Widget> _behaviorFields() {
    final s = widget.species;
    return [
      _label('Tipo de dieta'),
      _dropdownField(
        current: s.dietType,
        value: _dietType,
        options: _dietOptions,
        onChanged: (v) => setState(() => _dietType = v),
      ),
      const SizedBox(height: 14),
      _label('Patrón de actividad'),
      _dropdownField(
        current: s.activityPattern,
        value: _activityPattern,
        options: _activityOptions,
        onChanged: (v) => setState(() => _activityPattern = v),
      ),
      const SizedBox(height: 14),
      _label('Tendencia poblacional'),
      _dropdownField(
        current: s.populationTrend,
        value: _populationTrend,
        options: _trendOptions,
        onChanged: (v) => setState(() => _populationTrend = v),
      ),
      const SizedBox(height: 14),
      _label('Estructura social'),
      _currentValue(s.socialStructure),
      TextFormField(
          controller: _socialCtrl!, decoration: _dec('Nuevo valor...')),
    ];
  }

  // ── Reproduction fields ──────────────────────────────────────────────────────

  List<Widget> _reproductionFields() {
    final s = widget.species;
    return [
      _label('Temporada de reproducción'),
      _currentValue(s.breedingSeason),
      TextFormField(
          controller: _breedingCtrl!, decoration: _dec('Nuevo valor...')),
      const SizedBox(height: 14),
      _label('Tamaño de puesta / nidada'),
      _currentValue(s.clutchSize?.toString()),
      TextFormField(
          controller: _clutchCtrl!, decoration: _dec('Nuevo valor...')),
      const SizedBox(height: 14),
      _label('Frecuencia reproductiva'),
      _currentValue(s.reproductiveFrequency),
      TextFormField(
          controller: _reproCtrl!, decoration: _dec('Nuevo valor...')),
    ];
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _dropdownField({
    required String? current,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (current != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('Actual: $current',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          DropdownButtonFormField<String?>(
            initialValue: value,
            decoration: _dec('Seleccionar...'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Sin cambio')),
              ...options.map(
                  (o) => DropdownMenuItem(value: o, child: Text(o))),
            ],
            onChanged: onChanged,
          ),
        ],
      );

  Widget _currentValue(String? val) {
    if (val == null || val.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.text_snippet_outlined,
              size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              val,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
      );

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      );
}
