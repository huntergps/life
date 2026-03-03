import 'dart:typed_data';
import 'package:flutter/foundation.dart'
    show kIsWeb, compute, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';
import 'package:galapagos_wildlife/core/widgets/cached_species_image.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:galapagos_wildlife/features/sightings/services/sightings_service.dart';
import 'package:galapagos_wildlife/features/species/providers/species_identification_provider.dart';
import '../../providers/ar_camera_provider.dart';
import '../../providers/yolo_detection_provider.dart';
import '../painters/bbox_overlay_painter.dart';
import 'package:image/image.dart' as img;

// ─── HUD palette ─────────────────────────────────────────────────────────────

const _cyan      = Color(0xFF00E5FF);
const _cyanBorder= Color(0x7700E5FF);
const _green     = Color(0xFF00FF9D);
const _hudDark   = Color(0xCC000A14);

// ─── YUV420 → JPEG (isolate) ─────────────────────────────────────────────────

Uint8List _convertYuv420ToJpeg(Map<String, dynamic> args) {
  final int w          = args['w']           as int;
  final int h          = args['h']           as int;
  final Uint8List y    = args['y']           as Uint8List;
  final Uint8List u    = args['u']           as Uint8List;
  final Uint8List v    = args['v']           as Uint8List;
  final int yStride    = args['yRowStride']  as int;
  final int uStride    = args['uRowStride']  as int;
  final int uPixStride = args['uPixelStride']as int;

  final out = img.Image(width: w, height: h);
  for (int row = 0; row < h; row++) {
    for (int col = 0; col < w; col++) {
      final int yp = y[row * yStride + col] & 0xFF;
      final int uvIdx = uPixStride * (col ~/ 2) + uStride * (row ~/ 2);
      final int up = u[uvIdx] & 0xFF;
      final int vp = v[uvIdx] & 0xFF;
      final int r = (yp + 1.402 * (vp - 128)).clamp(0, 255).toInt();
      final int g = (yp - 0.344 * (up - 128) - 0.714 * (vp - 128)).clamp(0, 255).toInt();
      final int b = (yp + 1.772 * (up - 128)).clamp(0, 255).toInt();
      out.setPixelRgb(col, row, r, g, b);
    }
  }
  return Uint8List.fromList(img.encodeJpg(out, quality: 70));
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class ArCameraScreen extends ConsumerStatefulWidget {
  const ArCameraScreen({super.key});

  @override
  ConsumerState<ArCameraScreen> createState() => _ArCameraScreenState();
}

class _ArCameraScreenState extends ConsumerState<ArCameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  static bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);


  CameraController? _cameraController;
  bool _cameraInitializing = true;
  bool _isCapturing = false;
  bool _isAnalyzing = false;
  DateTime? _lastAnalysis;
  String? _cameraError;
  String? _lastDetectedName;

  List<Species>? _cachedAllSpecies;
  List<Species>? _cachedNearbySpecies;

  // YOLO multi-detection state
  List<YoloDetection> _yoloDetections = [];
  bool _isPaused = false;

  // ── Animations ──────────────────────────────────────────────────────────────
  late final AnimationController _scanCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _revealCtrl;
  late final AnimationController _cornerCtrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _cornerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    if (_isMobile) _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _cameraController;
    if (c == null || !c.value.isInitialized) return;
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        if (c.value.isStreamingImages) c.stopImageStream();
        _scanCtrl.stop();
        _pulseCtrl.stop();
      case AppLifecycleState.resumed:
        if (!c.value.isStreamingImages && !_isPaused) _startLiveStream();
        _scanCtrl.repeat();
        _pulseCtrl.repeat();
      default:
        break;
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() { _cameraError = 'No cameras'; _cameraInitializing = false; });
        return;
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (mounted) {
        setState(() {
          _cameraController = controller;
          _cameraInitializing = false;
        });
        _startLiveStream();
        _preloadSpeciesCache();
      }
    } catch (e) {
      if (mounted) setState(() { _cameraError = e.toString(); _cameraInitializing = false; });
    }
  }

  Future<void> _preloadSpeciesCache() async {
    _cachedAllSpecies = await fetchDeduped<Species>(idSelector: (s) => s.id);
    try {
      final nearby = await ref.read(fieldCameraSpeciesProvider.future);
      _cachedNearbySpecies = nearby.map((e) => e.species).toList();
    } catch (_) {
      _cachedNearbySpecies = null;
    }
  }

  void _startLiveStream() {
    _cameraController?.startImageStream((CameraImage image) {
      if (_isCapturing) return;
      final now = DateTime.now();
      if (_lastAnalysis != null && now.difference(_lastAnalysis!).inMilliseconds < 1500) return;
      if (_isAnalyzing) return;
      _lastAnalysis = now;
      _isAnalyzing = true;
      _processLiveFrame(image).catchError((_) { _isAnalyzing = false; });
    });
  }

  Future<void> _processLiveFrame(CameraImage image) async {
    try {
      Uint8List? jpegBytes;
      if (image.format.group == ImageFormatGroup.jpeg) {
        jpegBytes = Uint8List.fromList(image.planes[0].bytes);
      } else if (image.format.group == ImageFormatGroup.yuv420 && image.planes.length >= 3) {
        jpegBytes = await compute(_convertYuv420ToJpeg, {
          'w': image.width,
          'h': image.height,
          'y': Uint8List.fromList(image.planes[0].bytes),
          'u': Uint8List.fromList(image.planes[1].bytes),
          'v': Uint8List.fromList(image.planes[2].bytes),
          'yRowStride': image.planes[0].bytesPerRow,
          'uRowStride': image.planes[1].bytesPerRow,
          'uPixelStride': image.planes[1].bytesPerPixel ?? 2,
        });
      }

      final allSpecies = _cachedAllSpecies;
      if (allSpecies == null) { _isAnalyzing = false; return; }

      final yoloState = ref.read(yoloProvider);

      if (jpegBytes != null && yoloState.modelAvailable) {
        // ── YOLO path: multi-object detection with bounding boxes ────────────
        final detections = await ref.read(yoloProvider.notifier).detectLiveFrame(
          jpegBytes, allSpecies, _cachedNearbySpecies,
        );
        if (mounted) {
          setState(() => _yoloDetections = detections);
          // Sync arLiveResultProvider with best YOLO hit (for HUD data panel)
          if (detections.isNotEmpty) {
            final best = detections.reduce((a, b) => a.score > b.score ? a : b);
            final newName = best.scientificName;
            if (newName != _lastDetectedName) {
              _lastDetectedName = newName;
              _revealCtrl..reset()..forward();
            }
            if (best.matchedSpecies != null) {
              ref.read(arLiveResultProvider.notifier).state = ArLiveResult(
                suggestion: SpeciesIdSuggestion(
                  scientificName: best.scientificName,
                  commonNameEn:   best.commonNameEn,
                  commonNameEs:   best.commonNameEn,
                  score:          best.score,
                  source:         'yolo',
                  matchedSpecies: best.matchedSpecies,
                ),
                detectedAt: DateTime.now(),
              );
            }
          } else {
            _lastDetectedName = null;
            ref.read(arLiveResultProvider.notifier).state = null;
          }
        }
      } else {
        // YOLO model not available — clear detections
        if (mounted) setState(() => _yoloDetections = []);
      }
    } finally {
      _isAnalyzing = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    _cornerCtrl.dispose();
    _revealCtrl.dispose();
    final c = _cameraController;
    if (c != null) {
      if (c.value.isStreamingImages) c.stopImageStream();
      c.dispose();
    }
    ref.read(arLiveResultProvider.notifier).state = null;
    super.dispose();
  }

  /// Freezes or resumes the live YOLO stream.
  /// When paused the last YOLO detections stay visible so the user can
  /// comfortably tap "SAVE" on any bounding-box card.
  void _togglePause() {
    if (_cameraController == null) return;
    if (_isPaused) {
      setState(() => _isPaused = false);
      _startLiveStream();
    } else {
      if (_cameraController!.value.isStreamingImages) {
        _cameraController!.stopImageStream();
      }
      setState(() => _isPaused = true);
    }
  }

  Future<void> _quickSaveSighting(Species species) async {
    final user = Supabase.instance.client.auth.currentUser;
    final isEs = ref.read(localeProvider.select((l) => l == 'es'));
    if (user == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: _hudDark,
        content: Text(isEs ? 'Inicia sesión para registrar' : 'Sign in to register',
            style: const TextStyle(color: _cyan)),
      ));
      return;
    }
    final location = ref.read(arLocationProvider).asData?.value;
    try {
      await SightingsService().createSighting(
        speciesId: species.id,
        observedAt: DateTime.now(),
        latitude: location?.lat,
        longitude: location?.lng,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: _hudDark,
        content: Row(children: [
          const Icon(Icons.check_circle_outline, color: _green, size: 16),
          const SizedBox(width: 8),
          Text(isEs ? 'AVISTAMIENTO REGISTRADO' : 'SIGHTING SAVED',
              style: const TextStyle(color: _green, letterSpacing: 1)),
        ]),
      ));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: _hudDark,
        content: Text(isEs ? 'ERROR AL GUARDAR' : 'SAVE FAILED',
            style: TextStyle(color: Colors.red.shade400, letterSpacing: 1)),
      ));
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEs = ref.watch(localeProvider.select((l) => l == 'es'));

    if (!_isMobile) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text(
          isEs ? 'Cámara de Campo requiere dispositivo móvil'
               : 'Field Camera requires a mobile device',
          style: const TextStyle(color: _cyan, letterSpacing: 1),
        )),
      );
    }

    if (_cameraInitializing) {
      return _HudBootScreen(isEs: isEs, onBack: _goBack);
    }

    if (_cameraError != null || _cameraController == null) {
      return _HudErrorScreen(isEs: isEs, error: _cameraError, onBack: _goBack);
    }

    final liveResult = ref.watch(arLiveResultProvider);
    final nearbySpecies = ref.watch(fieldCameraSpeciesProvider);
    final hasDetection = liveResult != null;
    final yoloAvailable = ref.watch(yoloProvider.select((s) => s.modelAvailable));
    final nativePreview = _cameraController!.value.previewSize!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera preview ────────────────────────────────────────────────
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: nativePreview.height,
              height: nativePreview.width,
              child: CameraPreview(_cameraController!),
            ),
          ),

          // ── YOLO bounding boxes overlay ───────────────────────────────────
          if (yoloAvailable && _yoloDetections.isNotEmpty)
            CustomPaint(
              painter: BboxOverlayPainter(
                detections: _yoloDetections,
                nativePreviewSize: nativePreview,
              ),
            ),

          // ── Scan line (looping) — hide when YOLO active ───────────────────
          if (!yoloAvailable)
            AnimatedBuilder(
              animation: _scanCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ScanLinePainter(_scanCtrl.value),
              ),
            ),

          // ── HUD corner frame ──────────────────────────────────────────────
          AnimatedBuilder(
            animation: _cornerCtrl,
            builder: (_, __) => CustomPaint(
              painter: _HudFramePainter(
                progress: _cornerCtrl.value,
                locked: hasDetection,
              ),
            ),
          ),

          // ── Target lock crosshair (classifier mode only) ──────────────────
          if (hasDetection && !yoloAvailable)
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => CustomPaint(
                painter: _TargetLockPainter(_pulseCtrl.value),
              ),
            ),

          // ── Top HUD bar ───────────────────────────────────────────────────
          SafeArea(
            child: _HudTopBar(
              isEs: isEs,
              isAnalyzing: _isAnalyzing,
              hasDetection: hasDetection,
              yoloActive: yoloAvailable,
              onBack: _goBack,
            ),
          ),

          // ── YOLO multi-detection list ─────────────────────────────────────
          if (yoloAvailable && _yoloDetections.isNotEmpty)
            Positioned(
              bottom: 200,
              left: 12,
              right: 12,
              child: _YoloDetectionList(
                detections: _yoloDetections,
                isEs: isEs,
                revealAnim: _revealCtrl,
                onSave: (det) {
                  if (det.matchedSpecies != null) _quickSaveSighting(det.matchedSpecies!);
                },
                onView: (det) {
                  if (det.matchedSpecies != null) {
                    context.goNamed('species-detail',
                      pathParameters: {'id': '${det.matchedSpecies!.id}'});
                  }
                },
              ),
            ),

          // ── YOLO not available — suggest Photo ID ─────────────────────────
          if (!yoloAvailable)
            Positioned(
              bottom: 200,
              left: 16,
              right: 16,
              child: _YoloUnavailableBanner(isEs: isEs),
            ),

          // ── Bottom controls ───────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: _HudBottomControls(
                isEs:         isEs,
                nearbySpecies: nearbySpecies,
                isPaused:     _isPaused,
                onTogglePause: _togglePause,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────

class _ScanLinePainter extends CustomPainter {
  final double t;
  const _ScanLinePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * t;

    // Trailing glow
    final glowRect = Rect.fromLTWH(0, y - 2, size.width, 60);
    final glowGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _cyan.withValues(alpha: 0.18),
        _cyan.withValues(alpha: 0.0),
      ],
    ).createShader(glowRect);
    canvas.drawRect(glowRect, Paint()..shader = glowGrad);

    // The line
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = _cyan.withValues(alpha: 0.6)
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(_ScanLinePainter old) => old.t != t;
}

class _HudFramePainter extends CustomPainter {
  final double progress;
  final bool locked;
  const _HudFramePainter({required this.progress, required this.locked});

  @override
  void paint(Canvas canvas, Size size) {
    const margin = 28.0;
    const bracketLen = 36.0;
    final len = bracketLen * progress.clamp(0.0, 1.0);
    final color = locked ? _green : _cyan;
    final paint = Paint()
      ..color = color.withValues(alpha: locked ? 0.9 : 0.7)
      ..strokeWidth = locked ? 2.5 : 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    void drawBracket(Offset corner, double dx, double dy) {
      canvas.drawLine(corner, corner.translate(dx * len, 0), paint);
      canvas.drawLine(corner, corner.translate(0, dy * len), paint);
    }

    drawBracket(Offset(margin, margin), 1, 1);                               // TL
    drawBracket(Offset(size.width - margin, margin), -1, 1);                 // TR
    drawBracket(Offset(margin, size.height - margin), 1, -1);                // BL
    drawBracket(Offset(size.width - margin, size.height - margin), -1, -1);  // BR

    // Thin full-edge lines at very low opacity
    if (progress >= 1.0) {
      final edgePaint = Paint()
        ..color = color.withValues(alpha: 0.07)
        ..strokeWidth = 1.0;
      canvas.drawRect(
        Rect.fromLTWH(margin, margin, size.width - margin * 2, size.height - margin * 2),
        edgePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_HudFramePainter old) =>
      old.progress != progress || old.locked != locked;
}

class _TargetLockPainter extends CustomPainter {
  final double pulse;
  const _TargetLockPainter(this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    // Outer pulsing ring
    final outerR = 56.0 + 14.0 * pulse;
    canvas.drawCircle(
      center, outerR,
      Paint()
        ..color = _green.withValues(alpha: 0.35 * (1.0 - pulse))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Inner ring
    canvas.drawCircle(
      center, 38.0,
      Paint()
        ..color = _green.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Crosshair
    const gap = 12.0;
    const len = 18.0;
    final hp = Paint()
      ..color = _green.withValues(alpha: 0.9)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(center.dx - gap - len, center.dy), Offset(center.dx - gap, center.dy), hp);
    canvas.drawLine(Offset(center.dx + gap, center.dy), Offset(center.dx + gap + len, center.dy), hp);
    canvas.drawLine(Offset(center.dx, center.dy - gap - len), Offset(center.dx, center.dy - gap), hp);
    canvas.drawLine(Offset(center.dx, center.dy + gap), Offset(center.dx, center.dy + gap + len), hp);

    // Center dot
    canvas.drawCircle(center, 2.5, Paint()..color = _green..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_TargetLockPainter old) => old.pulse != pulse;
}

// ─── HUD Top Bar ──────────────────────────────────────────────────────────────

class _HudTopBar extends StatelessWidget {
  final bool isEs;
  final bool isAnalyzing;
  final bool hasDetection;
  final bool yoloActive;
  final VoidCallback onBack;

  const _HudTopBar({
    required this.isEs,
    required this.isAnalyzing,
    required this.hasDetection,
    required this.onBack,
    this.yoloActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final String status;
    final Color statusColor;
    if (hasDetection) {
      status = isEs ? '◉ OBJETIVO DETECTADO' : '◉ TARGET ACQUIRED';
      statusColor = _green;
    } else if (isAnalyzing) {
      status = isEs ? '⟳ ANALIZANDO...' : '⟳ SCANNING...';
      statusColor = _cyan;
    } else {
      status = isEs ? '◌ SISTEMA ACTIVO' : '◌ SYSTEM ACTIVE';
      statusColor = _cyan.withValues(alpha: 0.55);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: _hudDark,
                border: Border.all(color: _cyanBorder, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.arrow_back, color: _cyan, size: 18),
            ),
          ),
          const SizedBox(width: 10),

          // System label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GALÁPAGOS WILDLIFE SYSTEM',
                  style: TextStyle(
                    color: _cyan.withValues(alpha: 0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // AI / YOLO badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _hudDark,
              border: Border.all(color: yoloActive ? _green.withValues(alpha: 0.6) : _cyanBorder, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(yoloActive ? Icons.grid_view_rounded : Icons.auto_awesome,
                    color: yoloActive ? _green : _cyan, size: 12),
                const SizedBox(width: 5),
                Text(
                  yoloActive ? 'YOLO·v8' : 'AI·ID',
                  style: TextStyle(
                    color: yoloActive ? _green : _cyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ─── HUD Bottom Controls ──────────────────────────────────────────────────────

class _HudBottomControls extends StatelessWidget {
  final bool isEs;
  final bool isPaused;
  final AsyncValue<List<({Species species, String frequency})>> nearbySpecies;
  final VoidCallback onTogglePause;

  const _HudBottomControls({
    required this.isEs,
    required this.isPaused,
    required this.nearbySpecies,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nearby species row
        nearbySpecies.when(
          data: (list) {
            if (list.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 6),
                  child: Text(
                    isEs ? '◈ ESPECIES CERCANAS' : '◈ NEARBY SPECIES',
                    style: TextStyle(
                      color: _cyan.withValues(alpha: 0.7),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => _HudSpeciesChip(
                      species: list[i].species,
                      isEs: isEs,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 16),

        // Freeze / resume button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onTogglePause,
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hudDark,
                  border: Border.all(
                    color: isPaused ? _green : _cyan,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isPaused ? _green : _cyan).withValues(alpha: 0.3),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  size: 34,
                  color: isPaused ? _green : _cyan,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPaused
                      ? (isEs ? 'CONGELADO' : 'FROZEN')
                      : (isEs ? 'DETECCIÓN YOLO' : 'YOLO DETECTION'),
                  style: TextStyle(
                    color: (isPaused ? _green : _cyan).withValues(alpha: 0.9),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
                Text(
                  isPaused
                      ? (isEs ? 'Toca ▶ para reanudar' : 'Tap ▶ to resume')
                      : (isEs ? 'Toca ⏸ para congelar' : 'Tap ⏸ to freeze'),
                  style: TextStyle(
                    color: _cyan.withValues(alpha: 0.4),
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── YOLO unavailable banner ─────────────────────────────────────────────────

class _YoloUnavailableBanner extends StatelessWidget {
  final bool isEs;
  const _YoloUnavailableBanner({required this.isEs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _hudDark,
        border: Border.all(color: _cyanBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: _cyan, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEs ? 'MODELO YOLO NO DISPONIBLE' : 'YOLO MODEL UNAVAILABLE',
                  style: const TextStyle(
                    color: _cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isEs
                      ? 'Usa Identificación por Foto para reconocer especies'
                      : 'Use Photo ID to identify species from a photo',
                  style: TextStyle(
                    color: _cyan.withValues(alpha: 0.55),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push('/photo-id'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(color: _cyan.withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                isEs ? 'FOTO ID' : 'PHOTO ID',
                style: const TextStyle(
                  color: _cyan,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HudSpeciesChip extends StatelessWidget {
  final Species species;
  final bool isEs;
  const _HudSpeciesChip({required this.species, required this.isEs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.goNamed('species-detail', pathParameters: {'id': '${species.id}'}),
      child: Container(
        width: 68,
        decoration: BoxDecoration(
          color: _hudDark,
          border: Border.all(color: _cyanBorder, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: CachedSpeciesImage(
                imageUrl: species.thumbnailUrl ?? SpeciesAssets.thumbnail(species.id),
                speciesId: species.id,
                width: 44, height: 44,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                (isEs ? species.commonNameEs : species.commonNameEn).split(' ').first,
                style: const TextStyle(color: _cyan, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.3),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Boot / Error screens ─────────────────────────────────────────────────────

class _HudBootScreen extends StatelessWidget {
  final bool isEs;
  final VoidCallback onBack;
  const _HudBootScreen({required this.isEs, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: _cyan),
                onPressed: onBack,
              ),
            ]),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48, height: 48,
                      child: CircularProgressIndicator(color: _cyan, strokeWidth: 1.5),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'INICIANDO SISTEMA...',
                      style: TextStyle(color: _cyan, fontSize: 11, letterSpacing: 2.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudErrorScreen extends StatelessWidget {
  final bool isEs;
  final String? error;
  final VoidCallback onBack;
  const _HudErrorScreen({required this.isEs, required this.error, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: _cyan),
                onPressed: onBack,
              ),
            ]),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 56, color: _cyan.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text(
                      isEs ? 'SE REQUIERE ACCESO A CÁMARA' : 'CAMERA ACCESS REQUIRED',
                      style: TextStyle(color: _cyan.withValues(alpha: 0.7), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 8),
                      Text(error!, style: TextStyle(color: _cyan.withValues(alpha: 0.3), fontSize: 10), textAlign: TextAlign.center),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── YOLO Multi-Detection List ────────────────────────────────────────────────

class _YoloDetectionList extends StatelessWidget {
  final List<YoloDetection> detections;
  final bool isEs;
  final Animation<double> revealAnim;
  final void Function(YoloDetection) onSave;
  final void Function(YoloDetection) onView;

  const _YoloDetectionList({
    required this.detections,
    required this.isEs,
    required this.revealAnim,
    required this.onSave,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: revealAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              isEs
                  ? '◉ ${detections.length} ESPECIE${detections.length > 1 ? 'S' : ''} DETECTADA${detections.length > 1 ? 'S' : ''}'
                  : '◉ ${detections.length} SPECIES DETECTED',
              style: const TextStyle(
                color: _green, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2.0,
              ),
            ),
          ),
          ...detections.take(3).map((det) => _YoloDetectionCard(
            detection: det, isEs: isEs,
            onSave: () => onSave(det),
            onView: () => onView(det),
          )),
        ],
      ),
    );
  }
}

class _YoloDetectionCard extends StatelessWidget {
  final YoloDetection detection;
  final bool isEs;
  final VoidCallback onSave;
  final VoidCallback onView;

  const _YoloDetectionCard({
    required this.detection, required this.isEs,
    required this.onSave, required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final color = BboxOverlayPainter.classColor(detection.classId);
    final pct = (detection.score * 100).round();
    final hasMatch = detection.matchedSpecies != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC000A14),
        border: Border(left: BorderSide(color: color, width: 3)),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(4), bottomRight: Radius.circular(4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    detection.commonNameEn,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${detection.scientificName}  ·  $pct%',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55), fontSize: 9, fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (hasMatch) ...[
              GestureDetector(
                onTap: onView,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: _cyanBorder), borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    isEs ? 'VER' : 'VIEW',
                    style: const TextStyle(color: _cyan, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: onSave,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: _cyan.withValues(alpha: 0.15),
                    border: Border.all(color: _cyanBorder), borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Icon(Icons.bookmark_add_outlined, color: _cyan, size: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
