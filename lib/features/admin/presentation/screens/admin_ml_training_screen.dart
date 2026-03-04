import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import '../../services/drive_export_service.dart';

// ── Feedback stats provider ──────────────────────────────────────────────────

class _FeedbackStats {
  final int total;
  final int confirmed;
  final int corrections;
  final int withPhoto;
  final int pendingValidation;
  const _FeedbackStats({
    required this.total,
    required this.confirmed,
    required this.corrections,
    required this.withPhoto,
    required this.pendingValidation,
  });
}

final _feedbackStatsProvider = FutureProvider<_FeedbackStats>((ref) async {
  final rows = await Supabase.instance.client
      .from('species_recognition_feedback')
      .select('is_correction, photo_url, is_curator_validated');
  int confirmed = 0, corrections = 0, withPhoto = 0, pending = 0;
  for (final r in rows) {
    if ((r['is_correction'] as bool?) == true) { corrections++; } else { confirmed++; }
    if (r['photo_url'] != null) withPhoto++;
    if (r['is_curator_validated'] == null) pending++;
  }
  return _FeedbackStats(
    total: rows.length,
    confirmed: confirmed,
    corrections: corrections,
    withPhoto: withPhoto,
    pendingValidation: pending,
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

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _startExport() {
    if (_exporting) return;
    setState(() { _exporting = true; _log.clear(); });

    _sub = _service.exportAsZip().listen(
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
          // ── Stats ────────────────────────────────────────────────────────
          _SectionHeader('Datos de Feedback', isDark: isDark),
          statsAsync.when(
            loading: () => const Center(
                child: Padding(padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator())),
            error: (e, _) =>
                Text('Error: $e', style: const TextStyle(color: Colors.red)),
            data: (s) => Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(children: [
                  _StatRow(Icons.feedback_outlined, 'Total registros',
                      '${s.total}', primary),
                  _StatRow(Icons.check_circle_outline, 'Confirmados correctos',
                      '${s.confirmed}', Colors.green),
                  _StatRow(Icons.edit_note, 'Correcciones al modelo',
                      '${s.corrections}', Colors.orange),
                  _StatRow(Icons.photo_outlined, 'Con foto guardada',
                      '${s.withPhoto}', primary),
                  _StatRow(Icons.pending_outlined, 'Sin validar por curador',
                      '${s.pendingValidation}',
                      s.pendingValidation > 0 ? Colors.amber : Colors.green),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Export ────────────────────────────────────────────────────────
          _SectionHeader('Exportar para Reentrenamiento', isDark: isDark),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.folder_zip_outlined, color: primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Genera un ZIP con todas las fotos de feedback '
                          '+ metadata.json + metadata.csv.\n'
                          'Luego súbelo a Google Colab o Google Drive.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _exporting ? null : _startExport,
                    icon: _exporting
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.download_for_offline_outlined),
                    label: Text(_exporting
                        ? 'Preparando ZIP…'
                        : 'Descargar ZIP de entrenamiento'),
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
            _SectionHeader('Progreso', isDark: isDark),
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
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: line.startsWith('ERROR') || line.startsWith('⚠️')
                        ? Colors.red
                        : line.startsWith('✅') || line.startsWith('📦')
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
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader(this.title, {required this.isDark});
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
