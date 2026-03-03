import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart'
    if (dart.library.html) '../../species/providers/_tflite_stub.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';

// ── Assets ──────────────────────────────────────────────────────────────────
const _yoloModelAsset  = 'assets/ml/galapagos_yolo.tflite';
const _yoloLabelsAsset = 'assets/ml/galapagos_yolo_labels.txt';
const _yoloImgSize     = 640;
const _confThreshold   = 0.30;
const _iouThreshold    = 0.45;
const _maxDetections   = 10;

// ── Data classes ─────────────────────────────────────────────────────────────

/// One detected species with bounding box, normalized [0,1] in camera frame.
class YoloDetection {
  final int classId;
  final double score;
  final String scientificName;
  final String commonNameEn;
  /// Normalized rect: left, top, width, height all in [0,1]
  final Rect bbox;
  final Species? matchedSpecies;

  const YoloDetection({
    required this.classId,
    required this.score,
    required this.scientificName,
    required this.commonNameEn,
    required this.bbox,
    this.matchedSpecies,
  });
}

class YoloState {
  final bool modelAvailable;
  final bool isLoading;
  final List<YoloDetection> detections;
  final String? error;

  const YoloState({
    this.modelAvailable = false,
    this.isLoading = false,
    this.detections = const [],
    this.error,
  });

  YoloState copyWith({
    bool? modelAvailable,
    bool? isLoading,
    List<YoloDetection>? detections,
    String? error,
  }) => YoloState(
    modelAvailable: modelAvailable ?? this.modelAvailable,
    isLoading: isLoading ?? this.isLoading,
    detections: detections ?? this.detections,
    error: error,
  );
}

// ── Label entry ──────────────────────────────────────────────────────────────

class _YoloLabel {
  final String scientific;
  final String en;
  const _YoloLabel(this.scientific, this.en);
}

List<_YoloLabel> _parseYoloLabels(String raw) {
  return raw
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .map((l) {
        final parts = l.split('|');
        if (parts.length >= 2) return _YoloLabel(parts[0], parts[1]);
        return _YoloLabel(l, l);
      })
      .toList();
}

// ── Preprocessing (runs in isolate) ─────────────────────────────────────────

Float32List _preprocessForYolo(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Cannot decode image');
  final resized = img.copyResize(decoded, width: _yoloImgSize, height: _yoloImgSize);
  final buffer = Float32List(_yoloImgSize * _yoloImgSize * 3);
  int idx = 0;
  for (int y = 0; y < _yoloImgSize; y++) {
    for (int x = 0; x < _yoloImgSize; x++) {
      final pixel = resized.getPixel(x, y);
      buffer[idx++] = pixel.r.toDouble() / 255.0;
      buffer[idx++] = pixel.g.toDouble() / 255.0;
      buffer[idx++] = pixel.b.toDouble() / 255.0;
    }
  }
  return buffer;
}

// ── Raw detection (pre-NMS) ──────────────────────────────────────────────────

class _RawDet {
  final Rect rect; // normalized ltrb
  final int classId;
  final double score;
  const _RawDet(this.rect, this.classId, this.score);
}

// ── NMS ──────────────────────────────────────────────────────────────────────

double _iou(Rect a, Rect b) {
  final ix = math.max(0.0, math.min(a.right, b.right) - math.max(a.left, b.left));
  final iy = math.max(0.0, math.min(a.bottom, b.bottom) - math.max(a.top, b.top));
  final inter = ix * iy;
  if (inter == 0) return 0;
  final union = a.width * a.height + b.width * b.height - inter;
  return union > 0 ? inter / union : 0;
}

List<_RawDet> _nms(List<_RawDet> candidates) {
  if (candidates.isEmpty) return [];
  final sorted = List<_RawDet>.from(candidates)
    ..sort((a, b) => b.score.compareTo(a.score));
  final kept = <_RawDet>[];
  final suppressed = <int>{};
  for (int i = 0; i < sorted.length; i++) {
    if (suppressed.contains(i)) continue;
    kept.add(sorted[i]);
    if (kept.length >= _maxDetections) break;
    for (int j = i + 1; j < sorted.length; j++) {
      if (suppressed.contains(j)) continue;
      if (sorted[i].classId == sorted[j].classId &&
          _iou(sorted[i].rect, sorted[j].rect) > _iouThreshold) {
        suppressed.add(j);
      }
    }
  }
  return kept;
}

// ── Output parsing ───────────────────────────────────────────────────────────

/// Parses YOLOv8n raw output: [1, nc+4, 8400]
/// Returns raw detections above conf threshold (pre-NMS).
List<_RawDet> _parseRawOutput(
  List<List<List<double>>> output,
  int numClasses,
) {
  final candidates = <_RawDet>[];
  final anchorCount = output[0][0].length; // typically 8400

  for (int i = 0; i < anchorCount; i++) {
    double maxScore = 0;
    int bestClass = 0;
    for (int c = 0; c < numClasses; c++) {
      final s = output[0][4 + c][i];
      if (s > maxScore) {
        maxScore = s;
        bestClass = c;
      }
    }
    if (maxScore < _confThreshold) continue;

    final cx = output[0][0][i];
    final cy = output[0][1][i];
    final w  = output[0][2][i];
    final h  = output[0][3][i];

    final left   = (cx - w / 2).clamp(0.0, 1.0);
    final top    = (cy - h / 2).clamp(0.0, 1.0);
    final right  = (cx + w / 2).clamp(0.0, 1.0);
    final bottom = (cy + h / 2).clamp(0.0, 1.0);

    candidates.add(_RawDet(
      Rect.fromLTRB(left, top, right, bottom),
      bestClass,
      maxScore,
    ));
  }
  return candidates;
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class YoloDetectionNotifier extends Notifier<YoloState> {
  Interpreter? _interpreter;
  List<_YoloLabel>? _labels;
  List<int>? _outputShape;
  bool _checked = false;

  @override
  YoloState build() {
    ref.onDispose(() => _interpreter?.close());
    _loadModel();
    return const YoloState();
  }

  Future<void> _loadModel() async {
    if (_checked) return;
    _checked = true;
    try {
      final raw = await rootBundle.loadString(_yoloLabelsAsset);
      _labels = _parseYoloLabels(raw);
      _interpreter = await Interpreter.fromAsset(_yoloModelAsset);
      _outputShape = _interpreter!.getOutputTensor(0).shape;
      state = state.copyWith(modelAvailable: true);
    } catch (_) {
      // Model not found yet (not trained) — silent fail, fallback to classifier
      state = state.copyWith(modelAvailable: false);
    }
  }

  /// Returns detections for a live camera frame (throttled stream).
  /// Fast path — does NOT update provider state (call from image stream callback).
  Future<List<YoloDetection>> detectLiveFrame(
    Uint8List jpegBytes,
    List<Species> allSpecies,
    List<Species>? nearbySpecies,
  ) async {
    if (kIsWeb) return [];
    final interpreter = _interpreter;
    final labels = _labels;
    if (interpreter == null || labels == null) return [];

    try {
      final inputBuf = await compute(_preprocessForYolo, jpegBytes);
      final inputTensor = inputBuf.reshape([1, _yoloImgSize, _yoloImgSize, 3]);

      final nc = labels.length;
      final anchorCount = _anchorCount();
      final rawOut = [List.generate(nc + 4, (_) => List<double>.filled(anchorCount, 0.0))];

      interpreter.run(inputTensor, rawOut);

      final candidates = _parseRawOutput(rawOut, nc);
      final kept = _nms(candidates);

      return _toDetections(kept, labels, allSpecies, nearbySpecies);
    } catch (_) {
      return [];
    }
  }

  int _anchorCount() {
    if (_outputShape != null && _outputShape!.length >= 3) {
      return _outputShape![2];
    }
    return 8400; // YOLOv8n default
  }

  List<YoloDetection> _toDetections(
    List<_RawDet> raw,
    List<_YoloLabel> labels,
    List<Species> allSpecies,
    List<Species>? nearbySpecies,
  ) {
    final nearbyIds = nearbySpecies?.map((s) => s.id).toSet();
    return raw.map((d) {
      final label = d.classId < labels.length ? labels[d.classId] : null;
      final Species? match = label == null
          ? null
          : allSpecies.cast<Species?>().firstWhere(
              (sp) => sp!.scientificName.toLowerCase() == label.scientific.toLowerCase(),
              orElse: () => null,
            );
      final isNearby = match != null && (nearbyIds?.contains(match.id) == true);
      final score = (d.score + (isNearby ? 0.05 : 0.0)).clamp(0.0, 1.0);

      return YoloDetection(
        classId: d.classId,
        score: score,
        scientificName: label?.scientific ?? 'Unknown',
        commonNameEn:   label?.en ?? 'Unknown',
        bbox:           d.rect,
        matchedSpecies: match,
      );
    }).toList();
  }

  void clearDetections() {
    state = state.copyWith(detections: []);
  }
}

final yoloProvider = NotifierProvider<YoloDetectionNotifier, YoloState>(
  YoloDetectionNotifier.new,
);
