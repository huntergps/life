import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'share_card_io.dart' if (dart.library.js_interop) 'share_card_web.dart'
    as platform_share;

/// Generates a visual share card and shares it via the system share sheet.
class ShareCardService {
  ShareCardService._();

  /// Creates a share card widget off-screen, renders it to an image, and
  /// shares the resulting PNG file.
  static Future<void> shareCompletionCard({
    required BuildContext context,
    required String userName,
    required int speciesCount,
    required int daysToComplete,
    required DateTime? firstSeenDate,
    required DateTime? lastSeenDate,
    required String locale,
  }) async {
    final isEs = locale == 'es';
    final dateFormat = DateFormat.yMMMd(locale);

    // Build a share card widget off-screen using a RepaintBoundary
    final key = GlobalKey();
    final widget = RepaintBoundary(
      key: key,
      child: _ShareCardContent(
        userName: userName,
        speciesCount: speciesCount,
        daysToComplete: daysToComplete,
        firstSeenDate: firstSeenDate,
        lastSeenDate: lastSeenDate,
        isEs: isEs,
        dateFormat: dateFormat,
      ),
    );

    // Use an OverlayEntry to render the widget off-screen
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -2000,
        top: -2000,
        child: SizedBox(width: 1080, height: 1920, child: widget),
      ),
    );
    overlay.insert(entry);

    // Wait for rendering
    await Future<void>.delayed(const Duration(milliseconds: 300));

    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        // Fallback to text share
        _shareText(isEs, speciesCount);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _shareText(isEs, speciesCount);
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        platform_share.shareImageBytes(
          pngBytes,
          'galapagos_master_card.png',
        );
        // Also share text via share_plus (works on web)
        await SharePlus.instance.share(
          ShareParams(text: _shareMessage(isEs, speciesCount)),
        );
      } else {
        final filePath = await platform_share.saveTempImage(
          pngBytes,
          'galapagos_master_card.png',
        );
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(filePath)],
            text: _shareMessage(isEs, speciesCount),
            subject: isEs
                ? 'Mi checklist de Galapagos'
                : 'My Galapagos Checklist',
          ),
        );
      }
    } finally {
      entry.remove();
    }
  }

  static String _shareMessage(bool isEs, int speciesCount) {
    final text = isEs
        ? 'Complete las $speciesCount especies iconicas de Galapagos!'
        : 'I spotted all $speciesCount iconic species of Galapagos!';
    return '$text\n\n'
        '#GalapagosWildlife #Big15 #Galapagos\n'
        '${isEs ? "Descarga la app" : "Download the app"}: https://galapagos.tech';
  }

  static void _shareText(bool isEs, int speciesCount) {
    SharePlus.instance.share(
      ShareParams(text: _shareMessage(isEs, speciesCount)),
    );
  }
}

/// The visual card rendered off-screen and captured as an image.
class _ShareCardContent extends StatelessWidget {
  const _ShareCardContent({
    required this.userName,
    required this.speciesCount,
    required this.daysToComplete,
    required this.firstSeenDate,
    required this.lastSeenDate,
    required this.isEs,
    required this.dateFormat,
  });

  final String userName;
  final int speciesCount;
  final int daysToComplete;
  final DateTime? firstSeenDate;
  final DateTime? lastSeenDate;
  final bool isEs;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1920,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D1B2A), // deep navy
            Color(0xFF1B4332), // deep forest green
            Color(0xFF0D1B2A), // deep navy
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 80),
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Trophy icon
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            // Title
            Text(
              isEs ? 'MAESTRO DE GALAPAGOS' : 'GALAPAGOS MASTER',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
                letterSpacing: 3,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // User name
            if (userName.isNotEmpty) ...[
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            // Description
            Text(
              isEs
                  ? 'Observo las $speciesCount especies\niconicas de Galapagos'
                  : 'Observed all $speciesCount iconic\nGalapagos species',
              style: TextStyle(
                fontSize: 26,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Stats row
            if (daysToComplete > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: Text(
                  isEs
                      ? 'Completado en $daysToComplete dias'
                      : 'Completed in $daysToComplete days',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white.withValues(alpha: 0.8),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            if (lastSeenDate != null) ...[
              const SizedBox(height: 16),
              Text(
                dateFormat.format(lastSeenDate!),
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white.withValues(alpha: 0.6),
                  decoration: TextDecoration.none,
                ),
              ),
            ],
            const Spacer(flex: 3),
            // App branding
            Text(
              'galapagos.tech',
              style: TextStyle(
                fontSize: 22,
                color: Colors.white.withValues(alpha: 0.5),
                letterSpacing: 1,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '#GalapagosWildlife',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withValues(alpha: 0.4),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
