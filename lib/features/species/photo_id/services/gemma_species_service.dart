import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';

/// Status of the Gemma 4 E2B model on this device.
enum GemmaModelStatus {
  notDownloaded, // Model not present
  downloading, // Currently downloading
  ready, // Ready to use
  unsupported, // Device doesn't meet requirements (RAM, OS)
}

/// Service for on-device species identification using Gemma 4 E2B.
/// The model is downloaded on-demand (not bundled with the app).
///
/// This is a preparation layer -- the actual MediaPipe/LiteRT integration
/// will be added when the Flutter bindings are available.
class GemmaSpeciesService {
  static const _modelFileName = 'gemma4_e2b_q4.task';
  static const _modelSizeBytes = 1400000000; // ~1.3 GB
  static const _modelUrl =
      'https://life-api.galapagos.tech/models/gemma4_e2b_q4.task';

  /// Approximate model size for display purposes.
  static const modelSizeLabel = '1.3 GB';

  /// Check if the device can run Gemma 4 E2B
  static bool get isDeviceSupported {
    if (kIsWeb) return false;
    // TODO: Check actual device RAM via platform channel
    // For now, assume modern devices (2022+) are supported
    return true;
  }

  /// Check if the model is downloaded and ready
  static Future<GemmaModelStatus> checkStatus() async {
    if (!isDeviceSupported) return GemmaModelStatus.unsupported;
    if (kIsWeb) return GemmaModelStatus.unsupported;

    final dir = await getApplicationSupportDirectory();
    final modelFile = File('${dir.path}/$_modelFileName');

    if (await modelFile.exists()) {
      final size = await modelFile.length();
      if (size > _modelSizeBytes * 0.9) {
        // Allow 10% tolerance
        return GemmaModelStatus.ready;
      }
    }

    final downloading = Bootstrap.prefs.getBool('gemma_downloading') ?? false;
    if (downloading) return GemmaModelStatus.downloading;

    return GemmaModelStatus.notDownloaded;
  }

  /// Download the model file. Returns progress stream (0.0 to 1.0).
  static Stream<double> downloadModel() async* {
    if (kIsWeb) return;

    await Bootstrap.prefs.setBool('gemma_downloading', true);

    try {
      final dir = await getApplicationSupportDirectory();
      final modelFile = File('${dir.path}/$_modelFileName');

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(_modelUrl));
      final response = await request.close();

      final totalBytes = response.contentLength;
      var receivedBytes = 0;

      final sink = modelFile.openWrite();

      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          yield receivedBytes / totalBytes;
        }
      }

      await sink.close();
      client.close();

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
    if (kIsWeb) return;
    final dir = await getApplicationSupportDirectory();
    final modelFile = File('${dir.path}/$_modelFileName');
    if (await modelFile.exists()) {
      await modelFile.delete();
    }
  }

  /// Identify a species from an image using Gemma 4 E2B.
  /// Returns null if the model is not ready or identification fails.
  ///
  /// TODO: Implement actual MediaPipe LLM Inference API integration
  /// when Flutter bindings become available. For now, this is a stub
  /// that returns null (falling through to the next identification level).
  static Future<GemmaIdentificationResult?> identify(
      Uint8List imageBytes) async {
    final status = await checkStatus();
    if (status != GemmaModelStatus.ready) return null;

    // TODO: Actual inference via MediaPipe LLM Inference API
    // The integration will use platform channels:
    // - iOS: LiteRT or Core ML
    // - Android: Google AI Edge SDK (LiteRT-LM)
    //
    // Prompt template:
    // "Identify the Galapagos wildlife species in this photo.
    //  Respond with JSON: {species, confidence, description}"

    debugPrint('Gemma 4 E2B: model ready but inference not yet implemented');
    return null;
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
