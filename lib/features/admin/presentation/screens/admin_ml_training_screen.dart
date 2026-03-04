import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import '../../services/drive_export_service.dart';

// ── Feedback stats provider ─────────────────────────────────────────────────

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
  final db = Supabase.instance.client;
  final rows = await db
      .from('species_recognition_feedback')
      .select('is_correction, photo_url, is_curator_validated');

  int confirmed = 0, corrections = 0, withPhoto = 0, pending = 0;
  for (final r in rows) {
    if ((r['is_correction'] as bool?) == true) {
      corrections++;
    } else {
      confirmed++;
    }
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

// ── Screen ───────────────────────────────────────────────────────────────────

class AdminMlTrainingScreen extends ConsumerStatefulWidget {
  const AdminMlTrainingScreen({super.key});

  @override
  ConsumerState<AdminMlTrainingScreen> createState() =>
      _AdminMlTrainingScreenState();
}

class _AdminMlTrainingScreenState
    extends ConsumerState<AdminMlTrainingScreen> {
  final _service = DriveExportService();
  final _log = <String>[];
  bool _exporting = false;
  bool _signedIn = false;
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    _service.tryRestoreSession().then((_) {
      if (mounted) setState(() => _signedIn = _service.isSignedIn);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _signIn() async {
    final account = await _service.signIn();
    if (mounted) setState(() => _signedIn = account != null);
  }

  Future<void> _signOut() async {
    await _service.signOut();
    if (mounted) setState(() => _signedIn = false);
  }

  void _startExport() {
    if (_exporting) return;
    setState(() {
      _exporting = true;
      _log.clear();
    });

    _sub = _service.exportTrainingData().listen(
      (msg) {
        if (!mounted) return;
        if (msg == 'DONE') {
          setState(() => _exporting = false);
          ref.invalidate(_feedbackStatsProvider);
        } else if (msg.startsWith('ERROR:')) {
          setState(() {
            _log.add(msg);
            _exporting = false;
          });
        } else {
          setState(() => _log.add(msg));
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _log.add('ERROR: $e');
            _exporting = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsAsync = ref.watch(_feedbackStatsProvider);
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Training Data'),
        backgroundColor: isDark ? AppColors.darkBackground : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Feedback stats ────────────────────────────────────────────────
          _SectionHeader('Datos de Feedback', isDark: isDark),
          statsAsync.when(
            loading: () => const Center(
                child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )),
            error: (e, _) => Text('Error: $e',
                style: const TextStyle(color: Colors.red)),
            data: (stats) => Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _StatRow(
                      icon: Icons.feedback_outlined,
                      label: 'Total registros',
                      value: '${stats.total}',
                      color: primaryColor,
                    ),
                    _StatRow(
                      icon: Icons.check_circle_outline,
                      label: 'Confirmados correctos',
                      value: '${stats.confirmed}',
                      color: Colors.green,
                    ),
                    _StatRow(
                      icon: Icons.edit_note,
                      label: 'Correcciones al modelo',
                      value: '${stats.corrections}',
                      color: Colors.orange,
                    ),
                    _StatRow(
                      icon: Icons.photo_outlined,
                      label: 'Con foto guardada',
                      value: '${stats.withPhoto}',
                      color: primaryColor,
                    ),
                    _StatRow(
                      icon: Icons.pending_outlined,
                      label: 'Sin validar por curador',
                      value: '${stats.pendingValidation}',
                      color: stats.pendingValidation > 0
                          ? Colors.amber
                          : Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Google Drive connection ───────────────────────────────────────
          _SectionHeader('Google Drive', isDark: isDark),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cloud_done,
                        color: _signedIn ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _signedIn ? 'Conectado' : 'No conectado',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _signedIn ? Colors.green : null,
                              ),
                            ),
                            if (_signedIn && _service.userEmail != null)
                              Text(
                                _service.userEmail!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_signedIn)
                        TextButton.icon(
                          onPressed: _exporting ? null : _signOut,
                          icon: const Icon(Icons.logout, size: 16),
                          label: const Text('Salir'),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.red),
                        )
                      else
                        FilledButton.icon(
                          onPressed: _signIn,
                          icon: const Icon(Icons.login, size: 16),
                          label: const Text('Conectar Google'),
                        ),
                    ],
                  ),
                  if (!_signedIn) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Inicia sesión con la cuenta de Google que tiene acceso '
                      'a la carpeta de Drive de entrenamiento.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Export button ─────────────────────────────────────────────────
          _SectionHeader('Exportar a Drive', isDark: isDark),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sube todas las fotos de feedback + metadata.json a la '
                    'carpeta de entrenamiento en Google Drive. '
                    'Se crea una subcarpeta con la fecha/hora.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: (_signedIn && !_exporting) ? _startExport : null,
                    icon: _exporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white),
                          )
                        : const Icon(Icons.upload),
                    label: Text(_exporting
                        ? 'Exportando…'
                        : 'Exportar Training Data'),
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Export log ────────────────────────────────────────────────────
          if (_log.isNotEmpty) ...[
            _SectionHeader('Log de exportación', isDark: isDark),
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
                children: _log
                    .map(
                      (line) => Text(
                        line,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: line.startsWith('ERROR') ||
                                  line.startsWith('⚠️')
                              ? Colors.red
                              : line.startsWith('✅')
                                  ? Colors.green
                                  : isDark
                                      ? Colors.white70
                                      : Colors.black87,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader(this.title, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isDark ? AppColors.accentOrange : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: color,
        ),
      ),
    );
  }
}
