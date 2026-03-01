import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import '../widgets/visit_summary_card.dart';

class VisitSummaryScreen extends ConsumerStatefulWidget {
  final int speciesSeen;
  final int totalSightings;
  final String? displayName;

  const VisitSummaryScreen({
    super.key,
    required this.speciesSeen,
    required this.totalSightings,
    this.displayName,
  });

  @override
  ConsumerState<VisitSummaryScreen> createState() => _VisitSummaryScreenState();
}

class _VisitSummaryScreenState extends ConsumerState<VisitSummaryScreen> {
  final _screenshotController = ScreenshotController();
  bool _sharing = false;

  Future<void> _shareCard() async {
    setState(() => _sharing = true);
    try {
      final image = await _screenshotController.capture();
      if (image == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/galapagos_visit.png');
      await file.writeAsBytes(image);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'My Galapagos Wildlife visit summary!',
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not share image')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isEs = locale == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEs ? 'Resumen de Visita' : 'Visit Summary'),
        actions: [
          IconButton(
            icon: _sharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            tooltip: isEs ? 'Compartir' : 'Share',
            onPressed: _sharing ? null : _shareCard,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Screenshot(
                controller: _screenshotController,
                child: VisitSummaryCard(
                  speciesSeen: widget.speciesSeen,
                  totalSightings: widget.totalSightings,
                  displayName: widget.displayName,
                  locale: locale,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _sharing ? null : _shareCard,
                icon: const Icon(Icons.share),
                label: Text(isEs ? 'Compartir Resumen' : 'Share Summary'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
