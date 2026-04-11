import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/pigeon.g.dart' show PreferredBackend;
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';

/// Status of the Gemma 4 E2B model on this device.
enum GemmaModelStatus {
  notDownloaded, // Model not present
  downloading, // Currently downloading
  ready, // Ready to use
  unsupported, // Device doesn't meet requirements (RAM, OS)
}

/// Service for on-device species identification using Gemma 4 E2B via flutter_gemma.
/// The model is downloaded on-demand (not bundled with the app).
class GemmaSpeciesService {
  /// Approximate model size for display purposes.
  static const modelSizeLabel = '1.3 GB';

  /// Gemma 4 E2B .litertlm file for mobile (iOS/Android) from LiteRT Community.
  static const _modelUrl =
      'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm';

  static InferenceModel? _model;

  /// Check if the device can run Gemma 4 E2B.
  /// flutter_gemma handles detailed platform compatibility internally;
  /// we gate on platform family here.
  static bool get isDeviceSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  static ModelFileManager get _manager =>
      FlutterGemmaPlugin.instance.modelManager;

  /// Check if the model is downloaded and ready.
  static Future<GemmaModelStatus> checkStatus() async {
    if (!isDeviceSupported) return GemmaModelStatus.unsupported;

    try {
      final isInstalled = await _manager.isModelInstalled;
      if (isInstalled) {
        // Model is installed — clear any stale downloading flag
        await Bootstrap.prefs.setBool('gemma_downloading', false);
        return GemmaModelStatus.ready;
      }
    } catch (_) {}

    // If flag says downloading but model isn't installed, the download
    // was interrupted (app killed, network lost). Reset the flag.
    final downloading = Bootstrap.prefs.getBool('gemma_downloading') ?? false;
    if (downloading) {
      await Bootstrap.prefs.setBool('gemma_downloading', false);
      try { await _manager.deleteModel(); } catch (_) {} // clean partial file
    }

    return GemmaModelStatus.notDownloaded;
  }

  /// Download the model file. Returns progress stream (0.0 to 1.0).
  static Stream<double> downloadModel() async* {
    if (!isDeviceSupported) return;

    await Bootstrap.prefs.setBool('gemma_downloading', true);

    try {
      // downloadModelFromNetworkWithProgress yields int percentages (0-100)
      await for (final percent
          in _manager.downloadModelFromNetworkWithProgress(_modelUrl)) {
        yield percent / 100.0;
      }

      await Bootstrap.prefs.setBool('gemma_downloading', false);
      yield 1.0;
    } catch (e) {
      await Bootstrap.prefs.setBool('gemma_downloading', false);
      debugPrint('Gemma model download failed: $e');
      rethrow;
    }
  }

  /// Delete the downloaded model to free space.
  static Future<void> deleteModel() async {
    if (!isDeviceSupported) return;
    try {
      await _disposeModel();
      await _manager.deleteModel();
    } catch (e) {
      debugPrint('Gemma delete model failed: $e');
    }
  }

  static Future<void> _disposeModel() async {
    if (_model != null) {
      try {
        await _model!.close();
      } catch (_) {}
      _model = null;
    }
  }

  /// Initialize the model for inference (call once after download).
  static Future<bool> _ensureInitialized() async {
    if (_model != null) return true;
    try {
      _model = await FlutterGemmaPlugin.instance.createModel(
        modelType: ModelType.gemmaIt,
        maxTokens: 512,
        preferredBackend: PreferredBackend.gpu,
        supportImage: true,
        maxNumImages: 1,
      );
      return true;
    } catch (e) {
      debugPrint('Gemma init failed: $e');
      _model = null;
      return false;
    }
  }

  /// Identify a species from an image using Gemma 4 E2B vision.
  /// Returns null if the model is not ready or identification fails.
  static Future<GemmaIdentificationResult?> identify(
      Uint8List imageBytes) async {
    final status = await checkStatus();
    if (status != GemmaModelStatus.ready) return null;

    if (!await _ensureInitialized()) return null;

    try {
      // Create a fresh chat session with image support
      final chat = await _model!.createChat(
        supportImage: true,
        temperature: 0.2,
        topK: 1,
      );
      // Send image + text together
      await chat.addQueryChunk(Message.withImage(
        text: 'You are a Galapagos Islands wildlife expert. '
            'Identify the species in this photo. '
            'Respond with ONLY a JSON object: '
            '{"species": "English common name", "confidence": 0.0-1.0, '
            '"description": "brief description"}. '
            'If unsure, set confidence below 0.3.',
        imageBytes: imageBytes,
        isUser: true,
      ));

      final response = await chat.generateChatResponse();

      String responseText = '';
      if (response is TextResponse) {
        responseText = response.token;
      }

      if (responseText.isEmpty) return null;

      // Parse JSON from response
      final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(responseText);
      if (jsonMatch == null) return null;

      final data = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      return GemmaIdentificationResult(
        speciesName: data['species'] as String? ?? 'unknown',
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
        description: data['description'] as String? ?? '',
      );
    } catch (e) {
      debugPrint('Gemma identification failed: $e');
      return null;
    }
  }
}

class GemmaIdentificationResult {
  final String speciesName;
  final double confidence;
  final String description;

  GemmaIdentificationResult({
    required this.speciesName,
    required this.confidence,
    required this.description,
  });
}
