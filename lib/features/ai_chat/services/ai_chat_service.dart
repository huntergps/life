import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/pigeon.g.dart' show PreferredBackend;
import 'package:galapagos_wildlife/features/species/photo_id/services/gemma_species_service.dart';

/// Manages a persistent Gemma 4 E2B chat session for the AI naturalist guide.
class AiChatService {
  static InferenceModel? _model;
  static dynamic _chat;

  static const systemPrompt =
      'You are a friendly naturalist guide specialized in the Galapagos Islands wildlife. '
      'You help tourists identify species, learn about animal behavior, and understand '
      'conservation. Keep answers concise (2-3 sentences). If shown a photo, identify '
      'the species and share an interesting fact. If asked about safety, always mention '
      'park regulations. Respond in the same language the user writes in.';

  /// Check whether the Gemma model is downloaded and ready.
  static Future<bool> isAvailable() async {
    final status = await GemmaSpeciesService.checkStatus();
    return status == GemmaModelStatus.ready;
  }

  /// Send a message (with optional image) and get the AI response.
  static Future<String> sendMessage(String text, {Uint8List? image}) async {
    _model ??= await FlutterGemmaPlugin.instance.createModel(
      modelType: ModelType.gemmaIt,
      maxTokens: 512,
      preferredBackend: PreferredBackend.gpu,
      supportImage: true,
      maxNumImages: 1,
    );

    if (_chat == null) {
      _chat = await _model!.createChat(
        supportImage: true,
        temperature: 0.7,
        topK: 40,
      );
      // Send system prompt to prime the model
      await _chat.addQueryChunk(Message.text(
        text: systemPrompt,
        isUser: true,
      ));
      // Consume the system prompt response (we discard it)
      await _chat.generateChatResponse();
    }

    if (image != null) {
      await _chat.addQueryChunk(Message.withImage(
        text: text.isEmpty ? 'What is this animal?' : text,
        imageBytes: image,
        isUser: true,
      ));
    } else {
      await _chat.addQueryChunk(Message.text(
        text: text,
        isUser: true,
      ));
    }

    final response = await _chat.generateChatResponse();
    if (response is TextResponse) {
      return response.token;
    }
    return 'I could not generate a response.';
  }

  /// Reset the chat session (start a new conversation).
  static void resetChat() {
    _chat = null;
  }

  /// Dispose model and chat (free resources).
  static void dispose() {
    _chat = null;
    if (_model != null) {
      try {
        _model!.close();
      } catch (_) {}
      _model = null;
    }
  }
}
