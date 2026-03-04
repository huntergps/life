import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
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
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proposalsAsync = ref.watch(pendingProposalsProvider);
    final feedbackAsync  = ref.watch(pendingFeedbackProvider);

    final proposalCount = proposalsAsync.asData?.value.length;
    final feedbackCount  = feedbackAsync.asData?.value.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del curador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              ref.invalidate(pendingProposalsProvider);
              ref.invalidate(pendingFeedbackProvider);
              ref.invalidate(validatedFeedbackProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(
              icon: Badge(
                isLabelVisible: proposalCount != null && proposalCount > 0,
                label: Text('$proposalCount'),
                child: const Icon(Icons.rate_review_outlined),
              ),
              text: 'Propuestas',
            ),
            Tab(
              icon: Badge(
                isLabelVisible: feedbackCount != null && feedbackCount > 0,
                label: Text('$feedbackCount'),
                child: const Icon(Icons.pending_outlined),
              ),
              text: 'Correc. IA',
            ),
            const Tab(
              icon: Icon(Icons.history),
              text: 'Historial IA',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _ProposalsTab(),
          _PendingFeedbackTab(),
          _HistoryTab(),
        ],
      ),
    );
  }
}

// ── Proposals tab ─────────────────────────────────────────────────────────────

class _ProposalsTab extends ConsumerWidget {
  const _ProposalsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pendingProposalsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
          error: e,
          onRetry: () => ref.invalidate(pendingProposalsProvider)),
      data: (proposals) {
        if (proposals.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 72, color: Colors.grey),
                SizedBox(height: 16),
                Text('Sin propuestas pendientes',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(pendingProposalsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: proposals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
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
                _StatusChip(curatorStatus),
              ],
            ),
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
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () =>
                      showProposalDetailSheet(context, proposal),
                  child: const Text('Ver diff'),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.flag_outlined,
                      size: 16, color: Colors.orange),
                  label: const Text('Observar',
                      style: TextStyle(color: Colors.orange)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange)),
                  onPressed: () => _review(context, 'curator_flagged'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Aprobar'),
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.teal),
                  onPressed: () => _review(context, 'curator_approved'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _review(BuildContext context, String status) async {
    final notesCtrl = TextEditingController();
    final isApproval = status == 'curator_approved';
    final notes = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isApproval
            ? 'Aprobar científicamente'
            : 'Marcar con observación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isApproval
                ? 'El cambio es científicamente correcto. El admin lo verá para aprobación final.'
                : 'Hay algo que revisar. Explica la observación para el admin.'),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              autofocus: !isApproval,
              decoration: InputDecoration(
                hintText: isApproval
                    ? 'Notas adicionales (opcional)...'
                    : 'Observación científica...',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor:
                    isApproval ? Colors.teal : Colors.orange),
            onPressed: () =>
                Navigator.pop(context, notesCtrl.text.trim()),
            child: Text(isApproval ? 'Confirmar' : 'Enviar observación'),
          ),
        ],
      ),
    );
    if (notes == null) return;
    if (!isApproval && notes.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('La observación no puede estar vacía.')),
        );
      }
      return;
    }
    try {
      await ProposalService.curatorReview(
        proposal['id'] as int,
        status,
        notes: notes.isEmpty ? null : notes,
      );
      ref.invalidate(pendingProposalsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isApproval
                ? 'Propuesta marcada como aprobada por curador.'
                : 'Observación enviada al admin.'),
            backgroundColor:
                isApproval ? Colors.teal : Colors.orange,
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
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip(this.status);
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
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ── Pending AI feedback tab ───────────────────────────────────────────────────

class _PendingFeedbackTab extends ConsumerWidget {
  const _PendingFeedbackTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pendingFeedbackProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
          error: e,
          onRetry: () => ref.invalidate(pendingFeedbackProvider)),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 72, color: Colors.grey),
                SizedBox(height: 16),
                Text('Sin correcciones pendientes',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey)),
                SizedBox(height: 6),
                Text('Todas las correcciones han sido validadas.',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(pendingFeedbackProvider),
          child: _FeedbackGrid(items: items, ref: ref, showUndo: false),
        );
      },
    );
  }
}

// ── History tab ───────────────────────────────────────────────────────────────

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(validatedFeedbackProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
          error: e,
          onRetry: () => ref.invalidate(validatedFeedbackProvider)),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 72, color: Colors.grey),
                SizedBox(height: 16),
                Text('Sin validaciones aún',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(validatedFeedbackProvider),
          child: _FeedbackGrid(items: items, ref: ref, showUndo: true),
        );
      },
    );
  }
}

// ── Shared feedback grid ──────────────────────────────────────────────────────

class _FeedbackGrid extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final WidgetRef ref;
  final bool showUndo;
  const _FeedbackGrid(
      {required this.items, required this.ref, required this.showUndo});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    Widget listChild;
    if (isWide) {
      listChild = GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _FeedbackCard(
          feedback: items[i],
          ref: ref,
          isDark: isDark,
          showUndo: showUndo,
        ),
      );
    } else {
      listChild = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _FeedbackCard(
          feedback: items[i],
          ref: ref,
          isDark: isDark,
          showUndo: showUndo,
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: listChild,
      ),
    );
  }
}

// ── Feedback card ─────────────────────────────────────────────────────────────

class _FeedbackCard extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final WidgetRef ref;
  final bool isDark;
  final bool showUndo;
  const _FeedbackCard({
    required this.feedback,
    required this.ref,
    required this.isDark,
    required this.showUndo,
  });

  @override
  Widget build(BuildContext context) {
    final confidence =
        (feedback['predicted_confidence'] as num?)?.toDouble();
    final photoUrl = feedback['photo_url'] as String?;
    final rank = feedback['user_selected_rank'] as int? ?? 0;
    final predicted = feedback['predicted'] as Map?;
    final correct = feedback['correct'] as Map?;
    final predictedName = predicted?['common_name_es'] as String? ??
        'Especie #${feedback['predicted_species_id']}';
    final predictedSci = predicted?['scientific_name'] as String?;
    final correctName = correct?['common_name_es'] as String? ??
        'Especie #${feedback['correct_species_id']}';
    final correctSci = correct?['scientific_name'] as String?;
    final confStr = confidence != null
        ? ' (${(confidence * 100).toStringAsFixed(1)}%)'
        : '';
    final rankStr =
        rank > 0 ? ' — rango $rank' : ' — búsqueda manual';

    final isValidated = feedback['is_curator_validated'] as bool?;
    final curatorNotes = feedback['curator_notes'] as String?;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showUndo && isValidated != null)
            Container(
              color: isValidated
                  ? Colors.green.shade700
                  : Colors.red.shade700,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    isValidated ? Icons.check_circle : Icons.cancel,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isValidated
                        ? 'Validada como correcta'
                        : 'Validada como incorrecta',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  if (curatorNotes != null &&
                      curatorNotes.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '— $curatorNotes',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 120,
                  child: _Thumbnail(url: photoUrl, isDark: isDark),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(14, 12, 14, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SpeciesRow(
                          icon: Icons.warning_amber_outlined,
                          color: Colors.red,
                          label: 'IA predijo$confStr:',
                          name: predictedName,
                          scientific: predictedSci,
                        ),
                        const SizedBox(height: 8),
                        _SpeciesRow(
                          icon: Icons.person_outlined,
                          color: Colors.blue,
                          label: 'Usuario corrigió$rankStr:',
                          name: correctName,
                          scientific: correctSci,
                        ),
                        if (!showUndo) ...[
                          const Spacer(),
                          const Text(
                            '¿La corrección es científicamente correcta?',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: showUndo
                ? OutlinedButton.icon(
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('Deshacer validación'),
                    onPressed: () => _undo(context),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close,
                              size: 16, color: Colors.red),
                          label: const Text('No válida',
                              style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                          ),
                          onPressed: () => _validate(context, false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Válida'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                          ),
                          onPressed: () => _validate(context, true),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _validate(BuildContext context, bool isValid) async {
    final notesCtrl = TextEditingController();
    final notes = await showDialog<String?>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(isValid
            ? 'Confirmar corrección válida'
            : 'Marcar como inválida'),
        content: TextField(
          controller: notesCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Notas científicas (opcional)...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, null),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: isValid ? Colors.green : Colors.red),
            onPressed: () =>
                Navigator.pop(dialogCtx, notesCtrl.text.trim()),
            child: Text(
                isValid ? 'Confirmar válida' : 'Confirmar inválida'),
          ),
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
      ref.invalidate(validatedFeedbackProvider);
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

  Future<void> _undo(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Deshacer validación'),
        content: const Text(
            'Esto devuelve el registro al estado pendiente para revisarlo de nuevo.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Deshacer')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ProposalService.undoFeedbackValidation(
          feedback['id'] as int);
      ref.invalidate(pendingFeedbackProvider);
      ref.invalidate(validatedFeedbackProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Validación deshecha. Registro devuelto a pendientes.')),
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

// ── Thumbnail ─────────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  final String? url;
  final bool isDark;
  const _Thumbnail({required this.url, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Container(
        color: isDark ? Colors.white10 : Colors.grey[200],
        child: Icon(Icons.photo_camera_outlined,
            size: 36,
            color: isDark ? Colors.white30 : Colors.grey[400]),
      );
    }
    return GestureDetector(
      onTap: () => _openFullscreen(context, url!),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: isDark ? Colors.white10 : Colors.grey[200],
              child: Icon(Icons.broken_image_outlined,
                  color: isDark ? Colors.white30 : Colors.grey[400]),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.zoom_in,
                  size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Species info row ──────────────────────────────────────────────────────────

class _SpeciesRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String name;
  final String? scientific;
  const _SpeciesRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.name,
    this.scientific,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: color.withValues(alpha: 0.8))),
              Text(name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color)),
              if (scientific != null)
                Text(scientific!,
                    style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: color.withValues(alpha: 0.65))),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Fullscreen image viewer ───────────────────────────────────────────────────

void _openFullscreen(BuildContext context, String url) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _FullscreenImagePage(url: url),
    ),
  );
}

class _FullscreenImagePage extends StatelessWidget {
  final String url;
  const _FullscreenImagePage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.escape):
            const _CloseIntent(),
      },
      child: Actions(
        actions: {
          _CloseIntent: CallbackAction<_CloseIntent>(onInvoke: (_) {
            Navigator.of(context).pop();
            return null;
          }),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: const Text('Foto del feedback'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cerrar (ESC)',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: PhotoView(
              imageProvider: NetworkImage(url),
              backgroundDecoration:
                  const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 4,
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseIntent extends Intent {
  const _CloseIntent();
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Error: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: onRetry,
                child: const Text('Reintentar')),
          ],
        ),
      );
}
