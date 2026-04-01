import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/models/species.model.dart';
import 'package:galapagos_wildlife/data/mappers/data_helpers.dart';

import 'package:galapagos_wildlife/features/species/photo_id/services/label_parser.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/tflite_species_classifier.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/location_fallback_service.dart';

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

// ── Providers ───────────────────────────────────────────────────────

/// Set of scientific names (lowercase) that the TFLite model can recognize.
/// Used by species cards to show the "AI" badge.
final aiRecognizedSpeciesProvider = FutureProvider<Set<String>>((ref) async {
  return LabelParser.loadRecognizedNames();
});

// ── Notifier ────────────────────────────────────────────────────────

class SpeciesIdNotifier extends AsyncNotifier<SpeciesIdState> {
  final _classifier = TfliteSpeciesClassifier();

  @override
  Future<SpeciesIdState> build() async {
    ref.onDispose(() => _classifier.dispose());
    final available = await _classifier.initialize();
    return SpeciesIdState(modelAvailable: available);
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
        nearbySpecies = await LocationFallbackService.getNearbySpecies(
          lat, lng, allSpecies,
        );
      }

      List<SpeciesIdSuggestion> suggestions;

      if (_classifier.isAvailable) {
        suggestions = await _runClassification(
          imageBytes, allSpecies, nearbySpecies,
        );
      } else {
        suggestions = _locationFallback(nearbySpecies ?? allSpecies.take(6).toList());
      }

      state = AsyncValue.data(SpeciesIdState(
        suggestions: suggestions,
        modelAvailable: _classifier.isAvailable,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<List<SpeciesIdSuggestion>> _runClassification(
    Uint8List imageBytes,
    List<Species> allSpecies,
    List<Species>? nearbySpecies,
  ) async {
    final labels = _classifier.labels!;
    final predictions = await _classifier.classify(imageBytes, topK: 5);
    final nearbyIds = nearbySpecies?.map((s) => s.id).toSet();

    return predictions.map((pred) {
      final label = pred.labelIndex < labels.length ? labels[pred.labelIndex] : null;

      Species? match;
      if (label != null) {
        match = allSpecies.cast<Species?>().firstWhere(
          (sp) => sp!.scientificName.toLowerCase() == label.scientific.toLowerCase(),
          orElse: () => null,
        );
      }

      final isNearby = match != null && (nearbyIds?.contains(match.id) == true);
      final score = (pred.confidence + (isNearby ? 0.1 : 0.0)).clamp(0.0, 1.0);

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

  void reset() => state = const AsyncValue.data(SpeciesIdState());

  /// Lightweight identification for live camera stream — returns top-1 or null.
  /// Does NOT update provider state.
  Future<SpeciesIdSuggestion?> identifyLiveFrame(
    Uint8List jpegBytes,
    List<Species> allSpecies,
    List<Species>? nearbySpecies,
  ) async {
    if (kIsWeb) return null;
    if (!_classifier.isAvailable) return null;

    try {
      final labels = _classifier.labels!;
      final pred = await _classifier.classifyLiveFrame(jpegBytes);
      if (pred == null) return null;

      final label = pred.labelIndex < labels.length ? labels[pred.labelIndex] : null;
      Species? match;
      if (label != null) {
        match = allSpecies.cast<Species?>().firstWhere(
          (sp) => sp!.scientificName.toLowerCase() == label.scientific.toLowerCase(),
          orElse: () => null,
        );
      }

      final nearbyIds = nearbySpecies?.map((s) => s.id).toSet();
      final isNearby = match != null && (nearbyIds?.contains(match.id) == true);
      final score = (pred.confidence + (isNearby ? 0.1 : 0.0)).clamp(0.0, 1.0);

      return SpeciesIdSuggestion(
        scientificName: label?.scientific ?? 'Unknown',
        commonNameEn:   label?.en ?? 'Unknown',
        commonNameEs:   label?.es ?? 'Unknown',
        score:          score,
        source:         'model',
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
