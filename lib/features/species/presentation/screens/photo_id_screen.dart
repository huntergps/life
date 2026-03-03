import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';
import 'package:galapagos_wildlife/core/widgets/cached_species_image.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:galapagos_wildlife/features/sightings/services/sightings_service.dart';
import 'package:galapagos_wildlife/features/species/providers/species_identification_provider.dart';
import 'package:galapagos_wildlife/features/species/services/recognition_feedback_service.dart';
import 'package:galapagos_wildlife/features/ar_camera/providers/ar_camera_provider.dart';

// ── HUD palette ───────────────────────────────────────────────────────────────
const _cyan       = Color(0xFF00E5FF);
const _cyanDim    = Color(0x2200E5FF);
const _cyanBorder = Color(0x6600E5FF);
const _green      = Color(0xFF00FF9D);
const _hudDark    = Color(0xFF000A14);
const _hudCard    = Color(0xFF001525);

// ── Screen ────────────────────────────────────────────────────────────────────

/// Full-screen species identification by static photo.
/// Uses TFLite classifier (speciesIdProvider) — completely separate from
/// the real-time YOLO AR camera (/field-camera).
class PhotoIdScreen extends ConsumerStatefulWidget {
  const PhotoIdScreen({super.key});

  @override
  ConsumerState<PhotoIdScreen> createState() => _PhotoIdScreenState();
}

class _PhotoIdScreenState extends ConsumerState<PhotoIdScreen>
    with SingleTickerProviderStateMixin {
  Uint8List? _photo;
  bool _isProcessing = false;
  late final AnimationController _scanCtrl;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    // Clear stale results from a previous session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(speciesIdProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    if (_isProcessing) return;
    final xFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (xFile == null || !mounted) return;
    final bytes = await xFile.readAsBytes();
    ref.read(speciesIdProvider.notifier).reset();
    setState(() { _photo = bytes; _isProcessing = true; });
    final location = ref.read(arLocationProvider).asData?.value;
    await ref.read(speciesIdProvider.notifier).identify(
      bytes,
      lat: location?.lat,
      lng: location?.lng,
    );
    if (mounted) setState(() => _isProcessing = false);
  }

  void _reset() {
    ref.read(speciesIdProvider.notifier).reset();
    setState(() { _photo = null; _isProcessing = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isEs    = ref.watch(localeProvider.select((l) => l == 'es'));
    final idAsync = ref.watch(speciesIdProvider);

    return Scaffold(
      backgroundColor: _hudDark,
      body: SafeArea(
        child: Column(
          children: [
            _PIdHeader(
              isEs:    isEs,
              onBack:  () => context.pop(),
              onReset: _photo != null ? _reset : null,
            ),
            Expanded(
              child: _photo == null
                  ? _IdleView(
                      isEs:      isEs,
                      scanCtrl:  _scanCtrl,
                      onCamera:  () => _pick(ImageSource.camera),
                      onGallery: () => _pick(ImageSource.gallery),
                    )
                  : _ActiveView(
                      isEs:        isEs,
                      photo:       _photo!,
                      isProcessing: _isProcessing,
                      idAsync:     idAsync,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _PIdHeader extends StatelessWidget {
  final bool isEs;
  final VoidCallback onBack;
  final VoidCallback? onReset;

  const _PIdHeader({
    required this.isEs,
    required this.onBack,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: const BoxDecoration(
        color: Color(0xFF000F1E),
        border: Border(bottom: BorderSide(color: _cyanBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _hudDark,
                border: Border.all(color: _cyanBorder),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Icon(Icons.arrow_back, color: _cyan, size: 18),
            ),
          ),
          const SizedBox(width: 12),
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
                  isEs
                      ? '◉ IDENTIFICACIÓN POR FOTO — AI·ID'
                      : '◉ PHOTO IDENTIFICATION — AI·ID',
                  style: const TextStyle(
                    color: _cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (onReset != null)
            GestureDetector(
              onTap: onReset,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: _cyanBorder),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh, color: _cyan, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      isEs ? 'NUEVA' : 'NEW',
                      style: const TextStyle(
                        color: _cyan,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Idle view ─────────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  final bool isEs;
  final AnimationController scanCtrl;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _IdleView({
    required this.isEs,
    required this.scanCtrl,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _cyanBorder, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_search_outlined,
                              color: _cyanBorder, size: 56),
                          const SizedBox(height: 16),
                          Text(
                            isEs ? '◉ ZONA DE ANÁLISIS' : '◉ ANALYSIS ZONE',
                            style: const TextStyle(
                              color: _cyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isEs
                                ? 'Selecciona o toma\nuna fotografía del animal'
                                : 'Select or take\na photo of the animal',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _cyan.withValues(alpha: 0.45),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(painter: _PIdCornerPainter()),
                  ),
                  Positioned.fill(
                    child: ClipRect(
                      child: AnimatedBuilder(
                        animation: scanCtrl,
                        builder: (_, __) => CustomPaint(
                          painter: _PIdScanLinePainter(scanCtrl.value),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Row(
            children: [
              Expanded(
                child: _BigBtn(
                  icon:  Icons.camera_alt_outlined,
                  label: isEs ? 'CÁMARA' : 'CAMERA',
                  onTap: onCamera,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _BigBtn(
                  icon:  Icons.photo_library_outlined,
                  label: isEs ? 'GALERÍA' : 'GALLERY',
                  onTap: onGallery,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Active view (photo preview + loading/results) ─────────────────────────────

class _ActiveView extends StatelessWidget {
  final bool isEs;
  final Uint8List photo;
  final bool isProcessing;
  final AsyncValue<SpeciesIdState> idAsync;

  const _ActiveView({
    required this.isEs,
    required this.photo,
    required this.isProcessing,
    required this.idAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Compact 16:9 photo preview
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: _cyanBorder),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: Image.memory(photo, fit: BoxFit.contain),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(painter: _PIdCornerPainter()),
              ),
              Positioned(
                top: 6, left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  color: _hudDark.withValues(alpha: 0.8),
                  child: Text(
                    isEs ? 'IMAGEN ANALIZADA' : 'ANALYZED IMAGE',
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
        ),
        const SizedBox(height: 8),
        // Results area
        Expanded(
          child: idAsync.when(
            loading: () => _LoadingWidget(isEs: isEs),
            error:   (e, _) => _ErrorWidget(isEs: isEs, error: e),
            data: (state) {
              if (state.isLoading || isProcessing) return _LoadingWidget(isEs: isEs);
              if (state.suggestions.isEmpty) return _EmptyWidget(isEs: isEs);
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                itemCount: state.suggestions.length + 1,
                itemBuilder: (_, i) {
                  // "AI WRONG" button at TOP so it's immediately visible
                  if (i == 0) {
                    return _NoMatchTile(
                      isEs:          isEs,
                      topSuggestion: state.suggestions.first,
                      photo:         photo,
                    );
                  }
                  final idx = i - 1;
                  return _ResultTile(
                    suggestion:    state.suggestions[idx],
                    topSuggestion: state.suggestions.first,
                    rank:          idx + 1,
                    isEs:          isEs,
                    isTop:         idx == 0,
                    photo:         photo,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Result tile ───────────────────────────────────────────────────────────────

class _ResultTile extends ConsumerStatefulWidget {
  final SpeciesIdSuggestion suggestion;
  final SpeciesIdSuggestion topSuggestion;
  final int rank;
  final bool isEs;
  final bool isTop;
  final Uint8List photo;

  const _ResultTile({
    required this.suggestion,
    required this.topSuggestion,
    required this.rank,
    required this.isEs,
    required this.isTop,
    required this.photo,
  });

  @override
  ConsumerState<_ResultTile> createState() => _ResultTileState();
}

class _ResultTileState extends ConsumerState<_ResultTile> {
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
      // Upload photo in background (SHA-256 dedup — same photo = same URL, no re-upload)
      unawaited(RecognitionFeedbackService.uploadFeedbackPhoto(widget.photo).then((photoUrl) {
        RecognitionFeedbackService.save(
          predictedSpeciesId:  widget.topSuggestion.matchedSpecies?.id,
          predictedConfidence: widget.topSuggestion.score,
          correctSpeciesId:    sp.id,
          userSelectedRank:    widget.rank,
          photoUrl:            photoUrl,
          lat:                 location?.lat,
          lng:                 location?.lng,
        );
      }));
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

  Future<void> _register(Species sp) async {
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
      final svc = SightingsService();
      final photoUrl = await svc.uploadPhoto(
        bytes: widget.photo,
        fileName: 'photoid_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await svc.createSighting(
        speciesId:  sp.id,
        observedAt: DateTime.now(),
        latitude:   location?.lat,
        longitude:  location?.lng,
        photoUrl:   photoUrl,
      );
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
    final s      = widget.suggestion;
    final sp     = s.matchedSpecies;
    final pct    = (s.score * 100).round();
    final isGps  = s.source == 'location';
    final accent = widget.isTop ? _green : _cyan;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _hudCard,
        border: Border.all(
          color: widget.isTop ? _green.withValues(alpha: 0.5) : _cyanBorder,
          width: widget.isTop ? 1.5 : 0.8,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Rank header ────────────────────────────────────────────────────
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
          // ── Body ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail + corner brackets
                Stack(
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: accent.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
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
                                child: Icon(Icons.help_outline,
                                    color: _cyanBorder, size: 28),
                              ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(painter: _PIdCornerPainter()),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _iucnColor(sp!.conservationStatus)
                                    .withValues(alpha: 0.2),
                                border: Border.all(
                                  color: _iucnColor(sp.conservationStatus)
                                      .withValues(alpha: 0.7),
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
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Action buttons ─────────────────────────────────────────────────
          if (sp != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Confirm (lightweight — no sighting, no login needed)
                  _PIdBtn(
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
                        child: _PIdBtn(
                          label:  widget.isEs ? 'VER ESPECIE' : 'VIEW SPECIES',
                          icon:   Icons.arrow_forward,
                          filled: false,
                          onTap:  () => context.push('/species/${sp.id}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _PIdBtn(
                          label: _isSaving
                              ? (widget.isEs ? 'GUARDANDO...' : 'SAVING...')
                              : (widget.isEs
                                  ? '+ REGISTRAR AVISTAMIENTO'
                                  : '+ REGISTER SIGHTING'),
                          icon:    _isSaving ? null : Icons.bookmark_add_outlined,
                          loading: _isSaving,
                          onTap:   _isSaving ? null : () => _register(sp),
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

// ── No-match tile ─────────────────────────────────────────────────────────────

class _NoMatchTile extends ConsumerStatefulWidget {
  final bool isEs;
  final SpeciesIdSuggestion topSuggestion;
  final Uint8List photo;

  const _NoMatchTile({
    required this.isEs,
    required this.topSuggestion,
    required this.photo,
  });

  @override
  ConsumerState<_NoMatchTile> createState() => _NoMatchTileState();
}

class _NoMatchTileState extends ConsumerState<_NoMatchTile> {
  Future<void> _onNoMatch() async {
    final correctSpecies = await showDialog<Species>(
      context: context,
      builder: (_) => _SpeciesSearchDialog(isEs: widget.isEs),
    );
    if (correctSpecies == null || !mounted) return;

    final location = ref.read(arLocationProvider).asData?.value;
    // Upload the photo in background (SHA-256 dedup — same photo = same URL)
    unawaited(RecognitionFeedbackService.uploadFeedbackPhoto(widget.photo).then((photoUrl) {
      RecognitionFeedbackService.save(
        predictedSpeciesId:  widget.topSuggestion.matchedSpecies?.id,
        predictedConfidence: widget.topSuggestion.score,
        correctSpeciesId:    correctSpecies.id,
        userSelectedRank:    0,
        photoUrl:            photoUrl,
        lat:                 location?.lat,
        lng:                 location?.lng,
      );
    }));

    if (!mounted) return;
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
      child: _PIdBtn(
        label:  widget.isEs
            ? '✗  LA IA SE EQUIVOCÓ — CORREGIR'
            : '✗  AI WAS WRONG — CORRECT IT',
        icon:   Icons.edit_outlined,
        filled: false,
        onTap:  _onNoMatch,
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

  // Normaliza acentos para búsqueda tolerante: pingüino → pinguino
  static String _norm(String s) => s.toLowerCase()
      .replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i')
      .replaceAll('ó', 'o').replaceAll('ú', 'u').replaceAll('ü', 'u')
      .replaceAll('ñ', 'n');

  void _filter() {
    final q = _norm(_ctrl.text);
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all.where((s) {
              // Busca en ES, EN y nombre científico (independiente del idioma)
              return _norm(s.commonNameEs).contains(q) ||
                     _norm(s.commonNameEn).contains(q) ||
                     _norm(s.scientificName).contains(q);
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
                hintText: widget.isEs
                    ? 'Buscar especie...'
                    : 'Search species...',
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
                      child: CircularProgressIndicator(
                        color: _cyan, strokeWidth: 1.5,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final sp   = _filtered[i];
                        final name = widget.isEs
                            ? sp.commonNameEs
                            : sp.commonNameEn;
                        return InkWell(
                          onTap: () => Navigator.pop(context, sp),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 9, horizontal: 4,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _cyanBorder, width: 0.3,
                                ),
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
            _PIdBtn(
              label:  widget.isEs ? 'CANCELAR' : 'CANCEL',
              filled: false,
              onTap:  () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _PIdCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const k = 14.0;
    final p = Paint()
      ..color = _cyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    void b(Offset o, double dx, double dy) {
      canvas.drawLine(o, o.translate(dx * k, 0), p);
      canvas.drawLine(o, o.translate(0, dy * k), p);
    }
    b(Offset.zero, 1, 1);
    b(Offset(size.width, 0), -1, 1);
    b(Offset(0, size.height), 1, -1);
    b(Offset(size.width, size.height), -1, -1);
  }

  @override
  bool shouldRepaint(_PIdCornerPainter _) => false;
}

class _PIdScanLinePainter extends CustomPainter {
  final double t;
  const _PIdScanLinePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * t;
    final rect = Rect.fromLTWH(0, y - 2, size.width, 50);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _cyan.withValues(alpha: 0.15),
            _cyan.withValues(alpha: 0.0),
          ],
        ).createShader(rect),
    );
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = _cyan.withValues(alpha: 0.5)
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(_PIdScanLinePainter old) => old.t != t;
}

// ── Helper state widgets ──────────────────────────────────────────────────────

class _LoadingWidget extends StatelessWidget {
  final bool isEs;
  const _LoadingWidget({required this.isEs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40, height: 40,
            child: CircularProgressIndicator(color: _cyan, strokeWidth: 1.5),
          ),
          const SizedBox(height: 20),
          Text(
            isEs ? '⟳  ANALIZANDO IMAGEN...' : '⟳  ANALYZING IMAGE...',
            style: const TextStyle(
              color: _cyan,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final bool isEs;
  final Object error;
  const _ErrorWidget({required this.isEs, required this.error});

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
                color: _cyan,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: _cyan.withValues(alpha: 0.5), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  final bool isEs;
  const _EmptyWidget({required this.isEs});

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
              color: _cyan,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
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
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable button widgets ───────────────────────────────────────────────────

class _BigBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BigBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _hudCard,
          border: Border.all(color: _cyanBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _cyan, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: _cyan,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PIdBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool filled;
  final bool loading;
  final VoidCallback? onTap;
  final Color accent;

  const _PIdBtn({
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
          border: Border.all(
            color: accent.withValues(alpha: filled ? 0.8 : 0.5),
          ),
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
