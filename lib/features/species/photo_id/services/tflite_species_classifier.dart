import 'dart:typed_data';
import 'package:flutter/foundation.dart' show compute;
import 'package:tflite_flutter/tflite_flutter.dart'
    if (dart.library.html) '../providers/_tflite_stub.dart';

import 'package:galapagos_wildlife/features/species/photo_id/services/label_parser.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/image_preprocessor.dart';

/// Raw prediction result from the TFLite classifier.
class ClassifierPrediction {
  final int labelIndex;
  final double confidence;
  const ClassifierPrediction(this.labelIndex, this.confidence);
}

/// Manages the TFLite model lifecycle and runs inference.
class TfliteSpeciesClassifier {
  static const _modelAsset = 'assets/ml/galapagos_classifier.tflite';

  Interpreter? _interpreter;
  List<LabelEntry>? _labels;
  bool _checked = false;

  /// Whether the model is loaded and ready for inference.
  bool get isAvailable => _interpreter != null && _labels != null;

  /// The loaded labels, or null if not available.
  List<LabelEntry>? get labels => _labels;

  /// Attempt to load the model and labels. Returns true if successful.
  Future<bool> initialize() async {
    if (_checked) return isAvailable;
    _checked = true;
    try {
      _labels = await LabelParser.loadFromAsset();
      _interpreter = await Interpreter.fromAsset(_modelAsset);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Run inference on preprocessed image bytes.
  /// Returns top-[topK] predictions sorted by confidence (descending).
  Future<List<ClassifierPrediction>> classify(
    Uint8List imageBytes, {
    int topK = 5,
  }) async {
    if (!isAvailable) return [];

    final inputBuffer = ImagePreprocessor.preprocess(imageBytes);
    final inputTensor =
        inputBuffer.reshape([1, ImagePreprocessor.imgSize, ImagePreprocessor.imgSize, 3]);
    final outputTensor =
        List.filled(_labels!.length, 0.0).reshape([1, _labels!.length]);

    _interpreter!.run(inputTensor, outputTensor);

    final probs = outputTensor[0] as List<double>;
    final indexed = List.generate(probs.length, (i) => ClassifierPrediction(i, probs[i]));
    indexed.sort((a, b) => b.confidence.compareTo(a.confidence));
    return indexed.take(topK).toList();
  }

  /// Run inference on a live camera frame. Uses [compute] for preprocessing
  /// to avoid blocking the UI thread. Returns top-1 prediction if confidence
  /// exceeds [minConfidence], or null otherwise.
  Future<ClassifierPrediction?> classifyLiveFrame(
    Uint8List jpegBytes, {
    double minConfidence = 0.5,
  }) async {
    if (!isAvailable) return null;

    final inputBuffer = await compute(ImagePreprocessor.preprocess, jpegBytes);
    final inputTensor =
        inputBuffer.reshape([1, ImagePreprocessor.imgSize, ImagePreprocessor.imgSize, 3]);
    final outputTensor =
        List.filled(_labels!.length, 0.0).reshape([1, _labels!.length]);

    _interpreter!.run(inputTensor, outputTensor);

    final probs = outputTensor[0] as List<double>;
    final indexed = List.generate(probs.length, (i) => ClassifierPrediction(i, probs[i]));
    indexed.sort((a, b) => b.confidence.compareTo(a.confidence));

    final top = indexed.first;
    if (top.confidence < minConfidence) return null;
    return top;
  }

  /// Release interpreter resources.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
