import 'dart:typed_data';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter/foundation.dart' show kIsWeb, compute;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:latlong2/latlong.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/species_site.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';

// ── Constantes del modelo ────────────────────────────────────────────
const _modelAsset  = 'assets/ml/galapagos_classifier.tflite';
const _labelsAsset = 'assets/ml/labels.txt';

/// Set of scientific names (lowercase) that the TFLite model can recognize.
/// Used by species cards to show the "AI" badge.
final aiRecognizedSpeciesProvider = FutureProvider<Set<String>>((ref) async {
  try {
    final raw = await rootBundle.loadString(_labelsAsset);
    return raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => l.split('|').first.toLowerCase())
        .toSet();
  } catch (_) {
    return {};
  }
});
const _imgSize     = 224;

// ── Data classes ─────────────────────────────────────────────────────

class SpeciesIdSuggestion {
  final String scientificName;
  final String commonNameEn;
  final String commonNameEs;
  final double score;
  final String source; // 'model' | 'location'
  final Species? matchedSpecies;

  const SpeciesIdSuggestion({
    required this.scientificName,
    required this.commonNameEn,
    required this.commonNameEs,
    required this.score,
    required this.source,
    this.matchedSpecies,
  });
}

class SpeciesIdState {
  final bool isLoading;
  final List<SpeciesIdSuggestion> suggestions;
  final String? error;
  final bool modelAvailable;

  const SpeciesIdState({
    this.isLoading = false,
    this.suggestions = const [],
    this.error,
    this.modelAvailable = false,
  });
}

// ── Label parser ─────────────────────────────────────────────────────

class _LabelEntry {
  final String scientific;
  final String en;
  final String es;
  const _LabelEntry(this.scientific, this.en, this.es);
}

List<_LabelEntry> _parseLabels(String raw) {
  return raw
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .map((l) {
        final parts = l.split('|');
        if (parts.length >= 3) return _LabelEntry(parts[0], parts[1], parts[2]);
        if (parts.length == 2) return _LabelEntry(parts[0], parts[1], parts[1]);
        return _LabelEntry(l, l, l);
      })
      .toList();
}

// ── Image preprocessing ──────────────────────────────────────────────

/// Letterbox-resize a 224×224 y normaliza a [-1, 1] (MobileNetV3).
/// Preserva el aspect ratio original para no distorsionar ni recortar al animal.
Float32List _preprocessImage(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('No se pudo decodificar la imagen');
  // Scale-to-fit dentro de 224×224 (sin crop, sin stretch)
  final scaleW = _imgSize / decoded.width;
  final scaleH = _imgSize / decoded.height;
  final scale  = scaleW < scaleH ? scaleW : scaleH;
  final newW   = (decoded.width  * scale).round().clamp(1, _imgSize);
  final newH   = (decoded.height * scale).round().clamp(1, _imgSize);
  final scaled = img.copyResize(decoded, width: newW, height: newH);
  // Canvas negro 224×224; el área vacía = -1.0 tras normalización
  final canvas = img.Image(width: _imgSize, height: _imgSize);
  img.compositeImage(canvas, scaled,
    dstX: (_imgSize - newW) ~/ 2,
    dstY: (_imgSize - newH) ~/ 2,
  );
  final buffer = Float32List(_imgSize * _imgSize * 3);
  int idx = 0;
  for (int y = 0; y < _imgSize; y++) {
    for (int x = 0; x < _imgSize; x++) {
      final pixel = canvas.getPixel(x, y);
      buffer[idx++] = (pixel.r.toDouble() / 127.5) - 1.0;
      buffer[idx++] = (pixel.g.toDouble() / 127.5) - 1.0;
      buffer[idx++] = (pixel.b.toDouble() / 127.5) - 1.0;
    }
  }
  return buffer;
}

// ── Notifier ─────────────────────────────────────────────────────────

class SpeciesIdNotifier extends AsyncNotifier<SpeciesIdState> {
  Interpreter? _interpreter;
  List<_LabelEntry>? _labels;
  bool _modelChecked = false;

  @override
  Future<SpeciesIdState> build() async {
    ref.onDispose(() => _interpreter?.close());
    final available = await _checkModelAvailable();
    return SpeciesIdState(modelAvailable: available);
  }

  Future<bool> _checkModelAvailable() async {
    if (_modelChecked) return _interpreter != null;
    _modelChecked = true;
    try {
      final labelsRaw = await rootBundle.loadString(_labelsAsset);
      _labels = _parseLabels(labelsRaw);
      _interpreter = await Interpreter.fromAsset(_modelAsset);
      return true;
    } catch (_) {
      // Modelo no encontrado — modo fallback por ubicación
      return false;
    }
  }

  Future<void> identify(
    Uint8List imageBytes, {
    double? lat,
    double? lng,
  }) async {
    if (kIsWeb) {
      state = const AsyncValue.data(SpeciesIdState(
        error: 'La identificación requiere un dispositivo móvil',
      ));
      return;
    }

    state = const AsyncValue.loading();
    try {
      final allSpecies = await fetchDeduped<Species>(idSelector: (s) => s.id);

      List<Species>? nearbySpecies;
      if (lat != null && lng != null) {
        nearbySpecies = await _getNearbySpecies(lat, lng, allSpecies);
      }

      List<SpeciesIdSuggestion> suggestions;

      if (_interpreter != null && _labels != null) {
        suggestions = await _runTfliteInference(
          imageBytes,
          allSpecies,
          nearbySpecies,
        );
      } else {
        // Fallback: sugerencias por ubicación (sin modelo)
        suggestions = _locationFallback(nearbySpecies ?? allSpecies.take(6).toList());
      }

      state = AsyncValue.data(SpeciesIdState(
        suggestions: suggestions,
        modelAvailable: _interpreter != null,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Inferencia TFLite: preprocesa imagen, ejecuta modelo, retorna top-5.
  Future<List<SpeciesIdSuggestion>> _runTfliteInference(
    Uint8List imageBytes,
    List<Species> allSpecies,
    List<Species>? nearbySpecies,
  ) async {
    final interpreter = _interpreter!;
    final labels = _labels!;

    // Preprocesar
    final inputBuffer = _preprocessImage(imageBytes);
    final inputTensor = inputBuffer.reshape([1, _imgSize, _imgSize, 3]);
    final outputTensor = List.filled(labels.length, 0.0).reshape([1, labels.length]);

    interpreter.run(inputTensor, outputTensor);

    final probs = outputTensor[0] as List<double>;

    // Top-5 resultados
    final indexed = List.generate(probs.length, (i) => (i, probs[i]));
    indexed.sort((a, b) => b.$2.compareTo(a.$2));
    final top5 = indexed.take(5).toList();

    final nearbyIds = nearbySpecies?.map((s) => s.id).toSet();

    return top5.map((entry) {
      final idx = entry.$1;
      final confidence = entry.$2;
      final label = idx < labels.length ? labels[idx] : null;

      // Buscar en DB por nombre científico
      Species? match;
      if (label != null) {
        match = allSpecies.cast<Species?>().firstWhere(
          (sp) => sp!.scientificName.toLowerCase() == label.scientific.toLowerCase(),
          orElse: () => null,
        );
      }

      // Bonus por ubicación
      final isNearby = match != null && (nearbyIds?.contains(match.id) == true);
      final score = (confidence + (isNearby ? 0.1 : 0.0)).clamp(0.0, 1.0);

      return SpeciesIdSuggestion(
        scientificName: label?.scientific ?? 'Unknown',
        commonNameEn:   label?.en ?? 'Unknown',
        commonNameEs:   label?.es ?? 'Unknown',
        score:          score,
        source:         'model',
        matchedSpecies: match,
      );
    }).toList();
  }

  /// Sin modelo: devuelve especies del sitio más cercano como sugerencias.
  List<SpeciesIdSuggestion> _locationFallback(List<Species> candidates) {
    return candidates.take(5).map((sp) => SpeciesIdSuggestion(
      scientificName: sp.scientificName,
      commonNameEn:   sp.commonNameEn,
      commonNameEs:   sp.commonNameEs,
      score:          0.3,
      source:         'location',
      matchedSpecies: sp,
    )).toList();
  }

  Future<List<Species>> _getNearbySpecies(
    double lat,
    double lng,
    List<Species> allSpecies,
  ) async {
    try {
      final sites = await fetchDeduped<VisitSite>(idSelector: (s) => s.id);
      if (sites.isEmpty) return [];
      const dist = Distance();
      final userPos = LatLng(lat, lng);
      VisitSite? nearest;
      double nearestDist = double.infinity;
      for (final site in sites) {
        if (site.latitude == null || site.longitude == null) continue;
        final d = dist.distance(userPos, LatLng(site.latitude!, site.longitude!));
        if (d < nearestDist && d < 3000) {
          nearestDist = d;
          nearest = site;
        }
      }
      if (nearest == null) return [];
      final speciesSites = await fetchDeduped<SpeciesSite>(
        idSelector: (ss) => ss.id,
        policy: OfflineFirstGetPolicy.localOnly,
        query: Query(where: [Where('visitSiteId').isExactly(nearest.id)]),
      );
      final ids = speciesSites.map((ss) => ss.speciesId).toSet();
      return allSpecies.where((sp) => ids.contains(sp.id)).toList();
    } catch (_) {
      return [];
    }
  }

  void reset() => state = const AsyncValue.data(SpeciesIdState());

  /// Lightweight identification for live camera stream — returns top-1 or null.
  /// Does NOT update provider state. Call from camera screen on throttled frames.
  Future<SpeciesIdSuggestion?> identifyLiveFrame(
    Uint8List jpegBytes,
    List<Species> allSpecies,
    List<Species>? nearbySpecies,
  ) async {
    if (kIsWeb) return null;
    // Live AR overlay only activates when the TFLite model is running.
    // Location fallback (no model) only shows in the manual-capture SpeciesIdSheet.
    if (_interpreter == null || _labels == null) return null;
    try {
      final inputBuffer = await compute(_preprocessImage, jpegBytes);
      final inputTensor = inputBuffer.reshape([1, _imgSize, _imgSize, 3]);
      final outputTensor =
          List.filled(_labels!.length, 0.0).reshape([1, _labels!.length]);
      _interpreter!.run(inputTensor, outputTensor);
      final probs = outputTensor[0] as List<double>;
      final indexed = List.generate(probs.length, (i) => (i, probs[i]));
      indexed.sort((a, b) => b.$2.compareTo(a.$2));
      final top = indexed.first;
      if (top.$2 < 0.5) return null;
      final idx = top.$1;
      final label = idx < _labels!.length ? _labels![idx] : null;
      Species? match;
      if (label != null) {
        match = allSpecies.cast<Species?>().firstWhere(
          (sp) => sp!.scientificName.toLowerCase() == label.scientific.toLowerCase(),
          orElse: () => null,
        );
      }
      final nearbyIds = nearbySpecies?.map((s) => s.id).toSet();
      final isNearby = match != null && (nearbyIds?.contains(match.id) == true);
      final score = (top.$2 + (isNearby ? 0.1 : 0.0)).clamp(0.0, 1.0);
      return SpeciesIdSuggestion(
        scientificName: label?.scientific ?? 'Unknown',
        commonNameEn: label?.en ?? 'Unknown',
        commonNameEs: label?.es ?? 'Unknown',
        score: score,
        source: 'model',
        matchedSpecies: match,
      );
    } catch (_) {
      return null;
    }
  }
}

final speciesIdProvider =
    AsyncNotifierProvider<SpeciesIdNotifier, SpeciesIdState>(
  SpeciesIdNotifier.new,
);
