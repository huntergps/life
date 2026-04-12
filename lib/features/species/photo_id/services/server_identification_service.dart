import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

/// Result from the remote LLaVA-based species identification server.
class ServerIdentificationResult {
  final String species;
  final double confidence;
  final String reasoning;

  const ServerIdentificationResult({
    required this.species,
    required this.confidence,
    required this.reasoning,
  });
}

/// Sends an image to the LLaVA API server for species identification.
///
/// This is used as a fallback when the on-device TFLite model produces
/// low-confidence results and the device has internet connectivity.
class ServerIdentificationService {
  // TODO: Move to environment config / .env
  static const _baseUrl = 'https://life-api.galapagos.tech';

  /// Check if the server is available (with a short timeout).
  static Future<bool> isAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Send an image to the LLaVA server for identification.
  ///
  /// Returns `null` if the server is unreachable, times out, or returns
  /// an unparseable response.
  static Future<ServerIdentificationResult?> identify(
    Uint8List imageBytes,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/identify'),
      );
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'photo.jpg',
      ));

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
          );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ServerIdentificationResult(
        species: data['species'] as String? ?? 'unknown',
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
        reasoning: data['reasoning'] as String? ?? '',
      );
    } catch (e) {
      debugPrint('Server identification failed: $e');
      return null;
    }
  }
}
