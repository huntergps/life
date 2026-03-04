import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';
import 'package:galapagos_wildlife/core/widgets/cached_species_image.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:galapagos_wildlife/features/species/providers/species_identification_provider.dart';
import 'package:galapagos_wildlife/features/species/services/recognition_feedback_service.dart';
import 'package:galapagos_wildlife/features/sightings/services/sightings_service.dart';
import 'package:galapagos_wildlife/features/ar_camera/providers/ar_camera_provider.dart';

// ── HUD palette ───────────────────────────────────────────────────────────────
const _cyan       = Color(0xFF00E5FF);
const _cyanDim    = Color(0x2200E5FF);
const _cyanBorder = Color(0x6600E5FF);
const _green      = Color(0xFF00FF9D);
const _hudDark    = Color(0xFF000A14);
const _hudCard    = Color(0xFF001525);

// ── Sheet ─────────────────────────────────────────────────────────────────────

/// HUD-style species identification sheet.
class SpeciesIdSheet extends ConsumerWidget {
  final Uint8List? photoBytes;

  const SpeciesIdSheet({super.key, this.photoBytes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idAsync = ref.watch(speciesIdProvider);
    final isEs    = ref.watch(localeProvider.select((l) => l == 'es'));

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _hudDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            border: Border(
              top:   BorderSide(color: _cyanBorder, width: 1.5),
              left:  BorderSide(color: _cyanBorder, width: 0.5),
              right: BorderSide(color: _cyanBorder, width: 0.5),
            ),
          ),
          child: Column(
            children: [
              _HudHandle(),
              _HudHeader(isEs: isEs, onClose: () => Navigator.pop(context)),
              if (photoBytes != null) _HudPhotoPreview(bytes: photoBytes!),
              const SizedBox(height: 4),
              Expanded(
                child: idAsync.when(
                  loading: () => _HudLoading(isEs: isEs),
                  error:   (e, _) => _HudError(isEs: isEs, error: e),
                  data:    (state) {
                    if (state.isLoading) return _HudLoading(isEs: isEs);
                    if (state.suggestions.isEmpty) return _HudEmpty(isEs: isEs);
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                      itemCount: state.suggestions.length + 1,
                      itemBuilder: (_, i) {
                        if (i == state.suggestions.length) {
                          return _NoMatchButton(
                            isEs: isEs,
                            topSuggestion: state.suggestions.first,
                            photoBytes: photoBytes,
                          );
                        }
                        return _SuggestionTile(
                          suggestion:    state.suggestions[i],
                          topSuggestion: state.suggestions.first,
                          rank:          i + 1,
                          isEs:          isEs,
                          isTop:         i == 0,
                          photoBytes:    photoBytes,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Handle ────────────────────────────────────────────────────────────────────

class _HudHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        width: 36,
        height: 3,
        decoration: BoxDecoration(
          color: _cyanBorder,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HudHeader extends StatelessWidget {
  final bool isEs;
  final VoidCallback onClose;

  const _HudHeader({required this.isEs, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _cyanBorder, width: 0.5)),
        color: Color(0xFF000F1E),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: _green, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GALÁPAGOS WILDLIFE SYSTEM',
                  style: TextStyle(
                    color: _cyan.withValues(alpha: 0.5),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  isEs ? '◉ ANÁLISIS DE IMAGEN — AI·ID' : '◉ IMAGE ANALYSIS — AI·ID',
                  style: const TextStyle(
                    color: _cyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: _hudDark,
                border: Border.all(color: _cyanBorder, width: 1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Icon(Icons.close, color: _cyan, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photo preview ─────────────────────────────────────────────────────────────

class _HudPhotoPreview extends StatelessWidget {
  final Uint8List bytes;
  const _HudPhotoPreview({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: _cyanBorder, width: 1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
            ),
          ),
          // Corner brackets
          Positioned.fill(child: CustomPaint(painter: _CornerPainter())),
          // Label
          Positioned(
            top: 8, left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              color: _hudDark.withValues(alpha: 0.8),
              child: Text(
                'IMAGEN ANALIZADA',
                style: TextStyle(
                  color: _cyan.withValues(alpha: 0.8),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const k = 14.0;
    final p = Paint()
      ..color = _cyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    void bracket(Offset o, double dx, double dy) {
      canvas.drawLine(o, o.translate(dx * k, 0), p);
      canvas.drawLine(o, o.translate(0, dy * k), p);
    }

    bracket(Offset.zero, 1, 1);
    bracket(Offset(size.width, 0), -1, 1);
    bracket(Offset(0, size.height), 1, -1);
    bracket(Offset(size.width, size.height), -1, -1);
  }

  @override
  bool shouldRepaint(_CornerPainter _) => false;
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _HudLoading extends StatelessWidget {
  final bool isEs;
  const _HudLoading({required this.isEs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40, height: 40,
            child: CircularProgressIndicator(
              color: _cyan, strokeWidth: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isEs ? '⟳  ANALIZANDO IMAGEN...' : '⟳  ANALYZING IMAGE...',
            style: const TextStyle(
              color: _cyan, fontSize: 11,
              fontWeight: FontWeight.w700, letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _HudError extends StatelessWidget {
  final bool isEs;
  final Object error;
  const _HudError({required this.isEs, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(
              isEs ? '✗  ERROR DE ANÁLISIS' : '✗  ANALYSIS FAILED',
              style: const TextStyle(
                color: _cyan, fontSize: 11,
                fontWeight: FontWeight.w700, letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: _cyan.withValues(alpha: 0.5), fontSize: 11),
            ),
            const SizedBox(height: 16),
            _HudBtn(
              label: isEs ? 'CERRAR' : 'CLOSE',
              onTap: () => Navigator.pop(context),
              filled: false,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty ─────────────────────────────────────────────────────────────────────

class _HudEmpty extends StatelessWidget {
  final bool isEs;
  const _HudEmpty({required this.isEs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 56, color: _cyanBorder),
          const SizedBox(height: 16),
          Text(
            isEs ? '◌  SIN DETECCIÓN' : '◌  NO DETECTION',
            style: const TextStyle(
              color: _cyan, fontSize: 12,
              fontWeight: FontWeight.w700, letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEs
                ? 'Intenta con una foto más clara del animal'
                : 'Try a clearer photo of the animal',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _cyan.withValues(alpha: 0.45),
              fontSize: 12, letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Suggestion tile ───────────────────────────────────────────────────────────

class _SuggestionTile extends ConsumerStatefulWidget {
  final SpeciesIdSuggestion suggestion;
  final SpeciesIdSuggestion topSuggestion;
  final int rank;
  final bool isEs;
  final bool isTop;
  final Uint8List? photoBytes;

  const _SuggestionTile({
    required this.suggestion,
    required this.topSuggestion,
    required this.rank,
    required this.isEs,
    required this.isTop,
    this.photoBytes,
  });

  @override
  ConsumerState<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends ConsumerState<_SuggestionTile> {
  bool _isSaving     = false;
  bool _isConfirming = false;
  bool _confirmed    = false;

  static Color _iucnColor(String? s) {
    switch (s?.toUpperCase()) {
      case 'CR': return Colors.red.shade400;
      case 'EN': return Colors.orange.shade400;
      case 'VU': return Colors.yellow.shade600;
      case 'NT': return Colors.lightGreen.shade400;
      case 'LC': return _green;
      default:   return Colors.grey.shade500;
    }
  }

  /// Saves recognition feedback only — no sighting, no login required.
  Future<void> _confirmOnly(Species sp) async {
    if (_isConfirming || _confirmed) return;
    setState(() => _isConfirming = true);
    try {
      final location = ref.read(arLocationProvider).asData?.value;
      unawaited(RecognitionFeedbackService.save(
        predictedSpeciesId:  widget.topSuggestion.matchedSpecies?.id,
        predictedConfidence: widget.topSuggestion.score,
        correctSpeciesId:    sp.id,
        userSelectedRank:    widget.rank,
        lat:                 location?.lat,
        lng:                 location?.lng,
      ));
      if (mounted) {
        setState(() => _confirmed = true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: _hudDark,
          content: Row(children: [
            const Icon(Icons.thumb_up_alt_outlined, color: _cyan, size: 16),
            const SizedBox(width: 8),
            Text(
              widget.isEs
                  ? '✓ IDENTIFICACIÓN CONFIRMADA'
                  : '✓ IDENTIFICATION CONFIRMED',
              style: const TextStyle(color: _cyan, letterSpacing: 1),
            ),
          ]),
        ));
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  Future<void> _registerSighting(Species sp) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: _hudDark,
          content: Text(
            widget.isEs
                ? 'Inicia sesión para registrar avistamientos'
                : 'Sign in to register sightings',
            style: const TextStyle(color: _cyan),
          ),
        ));
      }
      return;
    }
    setState(() => _isSaving = true);
    try {
      final location = ref.read(arLocationProvider).asData?.value;
      String? photoUrl;
      if (widget.photoBytes != null) {
        final svc = SightingsService();
        photoUrl = await svc.uploadPhoto(
          bytes: widget.photoBytes!,
          fileName: 'ar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }
      await SightingsService().createSighting(
        speciesId: sp.id,
        observedAt: DateTime.now(),
        latitude: location?.lat,
        longitude: location?.lng,
        photoUrl: photoUrl,
      );
      // Save recognition feedback (non-blocking — never interrupts sighting flow)
      unawaited(RecognitionFeedbackService.save(
        predictedSpeciesId:  widget.topSuggestion.matchedSpecies?.id,
        predictedConfidence: widget.topSuggestion.score,
        correctSpeciesId:    sp.id,
        userSelectedRank:    widget.rank,
        photoUrl:            photoUrl,
        lat:                 location?.lat,
        lng:                 location?.lng,
      ));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: _hudDark,
          content: Row(children: [
            const Icon(Icons.check_circle_outline, color: _green, size: 16),
            const SizedBox(width: 8),
            Text(
              widget.isEs ? 'AVISTAMIENTO REGISTRADO' : 'SIGHTING SAVED',
              style: const TextStyle(color: _green, letterSpacing: 1),
            ),
          ]),
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: _hudDark,
          content: Text(
            widget.isEs ? 'ERROR AL GUARDAR' : 'SAVE FAILED',
            style: TextStyle(color: Colors.red.shade400, letterSpacing: 1),
          ),
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s     = widget.suggestion;
    final sp    = s.matchedSpecies;
    final pct   = (s.score * 100).round();
    final isGps = s.source == 'location';
    final accent = widget.isTop ? _green : _cyan;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _hudCard,
        border: Border.all(
          color: widget.isTop
              ? _green.withValues(alpha: 0.5)
              : _cyanBorder,
          width: widget.isTop ? 1.5 : 0.8,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Rank header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(color: accent.withValues(alpha: 0.3), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Text(
                  widget.rank.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isTop
                      ? (widget.isEs ? '◉ COINCIDENCIA PRINCIPAL' : '◉ TOP MATCH')
                      : (widget.isEs ? '◌ ALTERNATIVA' : '◌ ALTERNATIVE'),
                  style: TextStyle(
                    color: accent.withValues(alpha: 0.8),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
                const Spacer(),
                // Source badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: accent.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGps ? Icons.location_on : Icons.auto_awesome,
                        color: accent, size: 9,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isGps ? 'GPS' : 'AI·ID',
                        style: TextStyle(
                          color: accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail with HUD border + corners
                Stack(
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        border: Border.all(color: accent.withValues(alpha: 0.6), width: 1.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1),
                        child: sp != null
                            ? CachedSpeciesImage(
                                imageUrl: sp.thumbnailUrl ?? SpeciesAssets.thumbnail(sp.id),
                                speciesId: sp.id,
                                width: 72, height: 72,
                              )
                            : Container(
                                color: _hudCard,
                                child: Icon(Icons.help_outline, color: _cyanBorder, size: 28),
                              ),
                      ),
                    ),
                    Positioned.fill(child: CustomPaint(painter: _CornerPainter())),
                  ],
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Common name + IUCN
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              sp != null
                                  ? (widget.isEs ? sp.commonNameEs : sp.commonNameEn)
                                  : s.commonNameEn,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (sp?.conservationStatus != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: _iucnColor(sp!.conservationStatus).withValues(alpha: 0.2),
                                border: Border.all(
                                  color: _iucnColor(sp.conservationStatus).withValues(alpha: 0.7),
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                sp.conservationStatus!.toUpperCase(),
                                style: TextStyle(
                                  color: _iucnColor(sp.conservationStatus),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Scientific name
                      Text(
                        s.scientificName,
                        style: TextStyle(
                          color: _cyan.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Confidence bar
                      Row(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _cyanDim,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: s.score.clamp(0.0, 1.0),
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$pct%',
                            style: TextStyle(
                              color: accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      if (sp == null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.isEs
                              ? 'No está en nuestra base de datos'
                              : 'Not in our database',
                          style: TextStyle(
                            fontSize: 10,
                            color: _cyan.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Action buttons ───────────────────────────────────────────────
          if (sp != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Confirm (lightweight — no sighting, no login needed)
                  _HudBtn(
                    label: _isConfirming
                        ? (widget.isEs ? 'CONFIRMANDO...' : 'CONFIRMING...')
                        : _confirmed
                            ? (widget.isEs ? '✓ CONFIRMADO' : '✓ CONFIRMED')
                            : (widget.isEs
                                ? '✓ CONFIRMAR ESPECIE'
                                : '✓ CONFIRM SPECIES'),
                    icon: _isConfirming
                        ? null
                        : _confirmed
                            ? Icons.check_circle_outline
                            : Icons.thumb_up_alt_outlined,
                    loading: _isConfirming,
                    onTap:   (_isConfirming || _confirmed) ? null : () => _confirmOnly(sp),
                    filled:  _confirmed,
                    accent:  _cyan,
                  ),
                  const SizedBox(height: 6),
                  // View + Register (optional — creates sighting)
                  Row(
                    children: [
                      Expanded(
                        child: _HudBtn(
                          label: widget.isEs ? 'VER ESPECIE' : 'VIEW SPECIES',
                          icon: Icons.arrow_forward,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/species/${sp.id}');
                          },
                          filled: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _HudBtn(
                          label: _isSaving
                              ? (widget.isEs ? 'GUARDANDO...' : 'SAVING...')
                              : (widget.isEs
                                  ? '+ REGISTRAR AVISTAMIENTO'
                                  : '+ REGISTER SIGHTING'),
                          icon:    _isSaving ? null : Icons.bookmark_add_outlined,
                          loading: _isSaving,
                          onTap:   _isSaving ? null : () => _registerSighting(sp),
                          filled:  true,
                          accent:  widget.isTop ? _green : _cyan,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── No match button ───────────────────────────────────────────────────────────

/// Shown at the bottom of the suggestion list.
/// Lets the user indicate the AI was wrong and pick the correct species.
class _NoMatchButton extends ConsumerStatefulWidget {
  final bool isEs;
  final SpeciesIdSuggestion topSuggestion;
  final Uint8List? photoBytes;

  const _NoMatchButton({
    required this.isEs,
    required this.topSuggestion,
    this.photoBytes,
  });

  @override
  ConsumerState<_NoMatchButton> createState() => _NoMatchButtonState();
}

class _NoMatchButtonState extends ConsumerState<_NoMatchButton> {
  Future<void> _onNoMatch() async {
    final correctSpecies = await showDialog<Species>(
      context: context,
      builder: (_) => _SpeciesSearchDialog(isEs: widget.isEs),
    );
    if (correctSpecies == null || !mounted) return;

    final location = ref.read(arLocationProvider).asData?.value;

    // Upload photo for training data (null if unauthenticated or upload fails)
    final photoUrl = widget.photoBytes != null
        ? await RecognitionFeedbackService.uploadFeedbackPhoto(widget.photoBytes!)
        : null;

    unawaited(RecognitionFeedbackService.save(
      predictedSpeciesId:  widget.topSuggestion.matchedSpecies?.id,
      predictedConfidence: widget.topSuggestion.score,
      correctSpeciesId:    correctSpecies.id,
      userSelectedRank:    0,   // 0 = manual correction (not from suggestion list)
      photoUrl:            photoUrl,
      lat:                 location?.lat,
      lng:                 location?.lng,
    ));

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: _hudDark,
      content: Row(children: [
        const Icon(Icons.thumb_up_alt_outlined, color: _cyan, size: 16),
        const SizedBox(width: 8),
        Text(
          widget.isEs
              ? 'CORRECCIÓN GUARDADA — GRACIAS'
              : 'CORRECTION SAVED — THANKS',
          style: const TextStyle(color: _cyan, letterSpacing: 1),
        ),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      child: _HudBtn(
        label: widget.isEs
            ? '✗  LA IA SE EQUIVOCÓ — CORREGIR'
            : '✗  AI WAS WRONG — CORRECT IT',
        icon: Icons.edit_outlined,
        filled: false,
        onTap: _onNoMatch,
      ),
    );
  }
}

// ── Species search dialog ─────────────────────────────────────────────────────

class _SpeciesSearchDialog extends ConsumerStatefulWidget {
  final bool isEs;
  const _SpeciesSearchDialog({required this.isEs});

  @override
  ConsumerState<_SpeciesSearchDialog> createState() =>
      _SpeciesSearchDialogState();
}

class _SpeciesSearchDialogState extends ConsumerState<_SpeciesSearchDialog> {
  List<Species> _all      = [];
  List<Species> _filtered = [];
  final _ctrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSpecies();
    _ctrl.addListener(_filter);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadSpecies() async {
    final list = await fetchDeduped<Species>(idSelector: (s) => s.id);
    if (!mounted) return;
    list.sort((a, b) {
      final na = widget.isEs ? a.commonNameEs : a.commonNameEn;
      final nb = widget.isEs ? b.commonNameEs : b.commonNameEn;
      return na.compareTo(nb);
    });
    setState(() { _all = list; _filtered = list; _loading = false; });
  }

  void _filter() {
    final q = _ctrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all.where((s) {
              final name = widget.isEs ? s.commonNameEs : s.commonNameEn;
              return name.toLowerCase().contains(q) ||
                     s.scientificName.toLowerCase().contains(q);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _hudDark,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: _cyanBorder),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.isEs ? '◉ ESPECIE CORRECTA' : '◉ CORRECT SPECIES',
              style: const TextStyle(
                color: _cyan,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: widget.isEs ? 'Buscar especie...' : 'Search species...',
                hintStyle: TextStyle(color: _cyan.withValues(alpha: 0.4)),
                prefixIcon: const Icon(Icons.search, color: _cyanBorder, size: 18),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: _cyanBorder),
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: _cyan),
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
                filled: true,
                fillColor: _hudCard,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _cyan, strokeWidth: 1.5),
                    )
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final sp   = _filtered[i];
                        final name = widget.isEs ? sp.commonNameEs : sp.commonNameEn;
                        return InkWell(
                          onTap: () => Navigator.pop(context, sp),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 9, horizontal: 4,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: _cyanBorder, width: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white, fontSize: 13,
                                  ),
                                ),
                                Text(
                                  sp.scientificName,
                                  style: TextStyle(
                                    color: _cyan.withValues(alpha: 0.5),
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            _HudBtn(
              label: widget.isEs ? 'CANCELAR' : 'CANCEL',
              filled: false,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ── HUD button ────────────────────────────────────────────────────────────────

class _HudBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool filled;
  final bool loading;
  final VoidCallback? onTap;
  final Color accent;

  const _HudBtn({
    required this.label,
    required this.filled,
    required this.onTap,
    this.icon,
    this.loading = false,
    this.accent = _cyan,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: filled ? accent.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(color: accent.withValues(alpha: filled ? 0.8 : 0.5)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox(
                width: 10, height: 10,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: accent),
              )
            else if (icon != null)
              Icon(icon, color: accent, size: 13),
            if (icon != null || loading) const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
