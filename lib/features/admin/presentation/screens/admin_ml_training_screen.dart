import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import '../../services/drive_export_service.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

class _FeedbackStats {
  final int total;
  final int validated;
  final int pending;
  final int confirmed;
  final int corrections;
  final int withPhoto;
  final DateTime? lastValidated;

  const _FeedbackStats({
    required this.total,
    required this.validated,
    required this.pending,
    required this.confirmed,
    required this.corrections,
    required this.withPhoto,
    this.lastValidated,
  });
}

final _feedbackStatsProvider = FutureProvider<_FeedbackStats>((ref) async {
  final rows = await Supabase.instance.client
      .from('species_recognition_feedback')
      .select('is_correction, photo_url, is_curator_validated, curator_validated_at')
      .order('curator_validated_at', ascending: false);

  int validated = 0, pending = 0, confirmed = 0, corrections = 0, withPhoto = 0;
  DateTime? lastValidated;

  for (final r in rows) {
    final isVal = (r['is_curator_validated'] as bool?) == true;
    if (isVal) {
      validated++;
      final vAt = r['curator_validated_at'] != null
          ? DateTime.tryParse(r['curator_validated_at'] as String)
          : null;
      if (vAt != null && (lastValidated == null || vAt.isAfter(lastValidated))) {
        lastValidated = vAt;
      }
    } else {
      pending++;
    }
    if ((r['is_correction'] as bool?) == true) { corrections++; } else { confirmed++; }
    if (r['photo_url'] != null) withPhoto++;
  }

  return _FeedbackStats(
    total: rows.length,
    validated: validated,
    pending: pending,
    confirmed: confirmed,
    corrections: corrections,
    withPhoto: withPhoto,
    lastValidated: lastValidated,
  );
});

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminMlTrainingScreen extends ConsumerStatefulWidget {
  const AdminMlTrainingScreen({super.key});
  @override
  ConsumerState<AdminMlTrainingScreen> createState() =>
      _AdminMlTrainingScreenState();
}

class _AdminMlTrainingScreenState extends ConsumerState<AdminMlTrainingScreen> {
  final _service = TrainingExportService();
  final _log = <String>[];
  bool _exporting = false;
  StreamSubscription<String>? _sub;

  // Export mode: null = all validated, or a specific date
  DateTime? _since;
  bool _incrementalMode = false; // toggle for date picker

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _startExport() {
    if (_exporting) return;
    setState(() { _exporting = true; _log.clear(); });

    _sub = _service.exportAsZip(since: _incrementalMode ? _since : null).listen(
      (msg) {
        if (!mounted) return;
        if (msg == 'DONE') {
          setState(() => _exporting = false);
        } else if (msg.startsWith('ERROR:')) {
          setState(() { _log.add(msg); _exporting = false; });
        } else {
          setState(() => _log.add(msg));
        }
      },
      onError: (e) {
        if (mounted) setState(() { _log.add('ERROR: $e'); _exporting = false; });
      },
    );
  }

  Future<void> _pickSinceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _since ?? DateTime.now().subtract(const Duration(days: 7)),
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      helpText: 'Exportar validaciones desde…',
    );
    if (picked != null) setState(() => _since = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsAsync = ref.watch(_feedbackStatsProvider);
    final primary = isDark ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Training Data'),
        backgroundColor: isDark ? AppColors.darkBackground : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Stats card ────────────────────────────────────────────────────
          _Header('Estado del Feedback', isDark: isDark),
          statsAsync.when(
            loading: () => const Center(
                child: Padding(padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator())),
            error: (e, _) => Text('Error: $e',
                style: const TextStyle(color: Colors.red)),
            data: (s) => Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(children: [
                  _StatRow(Icons.feedback_outlined,
                      'Total registros', '${s.total}', primary),
                  _StatRow(Icons.verified_outlined,
                      'Validados por curador', '${s.validated}', Colors.green),
                  _StatRow(Icons.hourglass_empty,
                      'Pendientes de validación', '${s.pending}',
                      s.pending > 0 ? Colors.amber : Colors.green),
                  _StatRow(Icons.check_circle_outline,
                      'Confirmados correctos', '${s.confirmed}', Colors.teal),
                  _StatRow(Icons.edit_note,
                      'Correcciones al modelo', '${s.corrections}', Colors.orange),
                  _StatRow(Icons.photo_outlined,
                      'Con foto', '${s.withPhoto}', primary),
                  if (s.lastValidated != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(children: [
                        Icon(Icons.schedule, size: 14,
                            color: isDark ? Colors.white38 : Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'Última validación: ${_fmtDate(s.lastValidated!)}',
                          style: TextStyle(fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.grey[600]),
                        ),
                      ]),
                    ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Export options ────────────────────────────────────────────────
          _Header('Exportar ZIP para Reentrenamiento', isDark: isDark),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info
                  Row(children: [
                    Icon(Icons.info_outline, size: 16,
                        color: isDark ? Colors.white54 : Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Solo incluye registros validados por un curador.\n'
                        'El ZIP contiene metadata.json + metadata.csv + imágenes.',
                        style: TextStyle(fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.grey[700]),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Incremental toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Exportación incremental',
                        style: TextStyle(fontSize: 14)),
                    subtitle: Text(
                      'Solo validaciones nuevas desde una fecha',
                      style: TextStyle(fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey[600]),
                    ),
                    value: _incrementalMode,
                    activeColor: primary,
                    onChanged: _exporting
                        ? null
                        : (v) => setState(() {
                              _incrementalMode = v;
                              if (!v) _since = null;
                            }),
                  ),

                  // Date picker (only when incremental)
                  if (_incrementalMode) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _exporting ? null : _pickSinceDate,
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_since != null
                          ? 'Desde: ${_fmtDate(_since!)}'
                          : 'Seleccionar fecha de inicio'),
                    ),
                    if (_since == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '⚠️ Selecciona una fecha para la exportación incremental',
                          style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                        ),
                      ),
                  ],
                  const SizedBox(height: 16),

                  // Export button
                  FilledButton.icon(
                    onPressed: (_exporting ||
                            (_incrementalMode && _since == null))
                        ? null
                        : _startExport,
                    icon: _exporting
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.folder_zip_outlined),
                    label: Text(_exporting
                        ? 'Preparando ZIP…'
                        : _incrementalMode
                            ? 'Descargar ZIP incremental'
                            : 'Descargar ZIP completo'),
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Log ───────────────────────────────────────────────────────────
          if (_log.isNotEmpty) ...[
            _Header('Progreso', isDark: isDark),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black45 : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey[300]!),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _log.map((line) => Text(
                  line,
                  style: TextStyle(
                    fontFamily: 'monospace', fontSize: 12,
                    color: line.startsWith('ERROR') || line.startsWith('⚠️')
                        ? Colors.red
                        : line.startsWith('📦')
                            ? Colors.green
                            : isDark ? Colors.white70 : Colors.black87,
                  ),
                )).toList(),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final bool isDark;
  const _Header(this.title, {required this.isDark});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: isDark ? AppColors.accentOrange : AppColors.primary,
            fontWeight: FontWeight.bold)),
  );
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatRow(this.icon, this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    leading: Icon(icon, color: color, size: 20),
    title: Text(label, style: const TextStyle(fontSize: 14)),
    trailing: Text(value,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
  );
}
