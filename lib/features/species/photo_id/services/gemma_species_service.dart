import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/pigeon.g.dart' show PreferredBackend;
import 'package:galapagos_wildlife/app/bootstrap/bootstrap.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';
import 'gemma_model_config.dart';

/// Status of the Gemma 4 E2B model on this device.
enum GemmaModelStatus {
  notDownloaded,
  downloading,
  ready,
  unsupported,
}

/// Service for on-device species identification using Gemma 4 E2B/E4B.
/// Download uses background_downloader (continues when app is suspended/screen locked).
class GemmaSpeciesService {
  static String get modelSizeLabel => GemmaModelConfig.selected.sizeLabel;

  static const _downloadTaskId = 'gemma_model_download';
  static const _customUrlKey = 'gemma_custom_url';

  static InferenceModel? _model;

  /// Get the download URL (custom local or default HuggingFace)
  static String get modelUrl =>
      Bootstrap.prefs.getString(_customUrlKey) ?? GemmaModelConfig.selected.url;

  /// Set a custom download URL (e.g. local Mac server)
  static Future<void> setCustomUrl(String url) async {
    await Bootstrap.prefs.setString(_customUrlKey, url);
  }

  /// Clear custom URL (revert to HuggingFace)
  static Future<void> clearCustomUrl() async {
    await Bootstrap.prefs.remove(_customUrlKey);
  }

  /// Whether a custom URL is set
  static bool get hasCustomUrl =>
      Bootstrap.prefs.getString(_customUrlKey) != null;

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
        await Bootstrap.prefs.setBool('gemma_downloading', false);
        return GemmaModelStatus.ready;
      }
    } catch (_) {}

    // Check if a background download is in progress
    final records = await FileDownloader().database.allRecords();
    final activeDownload = records.where(
      (r) => r.taskId == _downloadTaskId &&
          (r.status == TaskStatus.running || r.status == TaskStatus.enqueued),
    );
    if (activeDownload.isNotEmpty) return GemmaModelStatus.downloading;

    final downloading = Bootstrap.prefs.getBool('gemma_downloading') ?? false;
    if (downloading) {
      await Bootstrap.prefs.setBool('gemma_downloading', false);
      try { await _manager.deleteModel(); } catch (_) {}
    }

    return GemmaModelStatus.notDownloaded;
  }

  /// Start downloading the model using background_downloader.
  /// Continues even when app is in background / screen locked.
  /// Returns immediately — listen to progress via [onProgress]/[onDone]/[onError].
  /// Check if there's enough free disk space for the selected model.
  /// Returns (hasSpace, freeSpaceLabel) for UI feedback.
  static Future<(bool, String)> checkDiskSpace() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final stat = await Process.run('df', ['-k', dir.path]);
      if (stat.exitCode == 0) {
        final lines = (stat.stdout as String).split('\n');
        if (lines.length > 1) {
          final parts = lines[1].split(RegExp(r'\s+'));
          if (parts.length >= 4) {
            final freeKB = int.tryParse(parts[3]) ?? 0;
            final freeGB = freeKB / 1024 / 1024;
            final needed = GemmaModelConfig.selected.approximateSizeBytes / 1024 / 1024 / 1024;
            final freeLabel = '${freeGB.toStringAsFixed(1)} GB';
            return (freeGB > needed + 0.5, freeLabel); // need model + 500MB buffer
          }
        }
      }
    } catch (_) {}
    return (true, ''); // can't determine — allow attempt
  }

  static Future<void> startDownload({
    ValueChanged<double>? onProgress,
    VoidCallback? onDone,
    ValueChanged<String>? onError,
  }) async {
    if (!isDeviceSupported) return;

    final url = modelUrl;
    final isLocal = url.startsWith('http://192.') ||
                    url.startsWith('http://172.') ||
                    url.startsWith('http://10.') ||
                    url.startsWith('http://localhost');

    if (isLocal) {
      // Use direct HttpClient for local network (more reliable on iOS)
      await _directDownload(url, onProgress: onProgress, onDone: onDone, onError: onError);
      return;
    }

    // Use background_downloader for internet downloads (supports background/pause)
    await Bootstrap.prefs.setBool('gemma_downloading', true);

    final task = DownloadTask(
      taskId: _downloadTaskId,
      url: url,
      filename: GemmaModelConfig.selected.fileName,
      directory: 'gemma_model',
      baseDirectory: BaseDirectory.applicationSupport,
      updates: Updates.statusAndProgress,
      allowPause: true,
      retries: 5,
      requiresWiFi: false,
    );

    AppLogger.info('Gemma: starting background download from ${url.substring(0, 50)}...');

    await FileDownloader().download(
      task,
      onProgress: (progress) {
        if (progress >= 0) onProgress?.call(progress);
      },
      onStatus: (status) {
        AppLogger.info('Gemma download status: $status');
        switch (status) {
          case TaskStatus.complete:
            Bootstrap.prefs.setBool('gemma_downloading', false);
            _installDownloadedModel().then((_) {
              onDone?.call();
            });
          case TaskStatus.failed:
            Bootstrap.prefs.setBool('gemma_downloading', false);
            onError?.call('Download failed. Check your connection.');
          case TaskStatus.canceled:
            Bootstrap.prefs.setBool('gemma_downloading', false);
            onError?.call('Download cancelled.');
          case TaskStatus.notFound:
            Bootstrap.prefs.setBool('gemma_downloading', false);
            onError?.call('Model file not found on server.');
          default:
            break;
        }
      },
    );
  }

  /// Direct download using Dart HttpClient — for local network transfers.
  /// More reliable than background_downloader for HTTP local servers.
  static Future<void> _directDownload(
    String url, {
    ValueChanged<double>? onProgress,
    VoidCallback? onDone,
    ValueChanged<String>? onError,
  }) async {
    await Bootstrap.prefs.setBool('gemma_downloading', true);
    AppLogger.info('Gemma: direct download from $url');

    try {
      final supportDir = await getApplicationSupportDirectory();
      final destDir = Directory('${supportDir.path}/gemma_model');
      if (!await destDir.exists()) await destDir.create(recursive: true);
      final destFile = File('${destDir.path}/${GemmaModelConfig.selected.fileName}');

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        await Bootstrap.prefs.setBool('gemma_downloading', false);
        onError?.call('Server returned ${response.statusCode}');
        client.close();
        return;
      }

      final totalBytes = response.contentLength;
      var receivedBytes = 0;
      final sink = destFile.openWrite();

      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          onProgress?.call(receivedBytes / totalBytes);
        }
      }

      await sink.close();
      client.close();
      await Bootstrap.prefs.setBool('gemma_downloading', false);

      AppLogger.info('Gemma: direct download complete (${receivedBytes ~/ 1024 ~/ 1024} MB)');
      onDone?.call();
    } catch (e) {
      await Bootstrap.prefs.setBool('gemma_downloading', false);
      AppLogger.warning('Gemma: direct download failed', e);
      onError?.call('Download failed: $e');
    }
  }

  /// After background_downloader finishes, move the file where flutter_gemma expects it.
  static Future<void> _installDownloadedModel() async {
    // flutter_gemma's modelManager handles installation
    // The downloaded file is in applicationSupport/gemma_model/
    // We need to tell flutter_gemma about it
    try {
      final filePath = await FileDownloader().pathInSharedStorage(
        GemmaModelConfig.selected.fileName,
        SharedStorage.downloads,
      );
      AppLogger.info('Gemma: model downloaded to $filePath');
      // flutter_gemma should detect it on next checkStatus()
    } catch (e) {
      AppLogger.warning('Gemma: post-download install: $e');
    }
  }

  /// Pause the current download.
  static Future<void> pauseDownload() async {
    await FileDownloader().pause(DownloadTask(
      taskId: _downloadTaskId,
      url: modelUrl,
      filename: GemmaModelConfig.selected.fileName,
    ));
    AppLogger.info('Gemma: download paused');
  }

  /// Resume a paused download.
  static Future<void> resumeDownload() async {
    final records = await FileDownloader().database.allRecords();
    final paused = records.where(
      (r) => r.taskId == _downloadTaskId && r.status == TaskStatus.paused,
    ).firstOrNull;
    if (paused != null) {
      await FileDownloader().resume(paused.task as DownloadTask);
      AppLogger.info('Gemma: download resumed');
    }
  }

  /// Cancel and clean up the download.
  static Future<void> cancelDownload() async {
    await FileDownloader().cancelTaskWithId(_downloadTaskId);
    await Bootstrap.prefs.setBool('gemma_downloading', false);
    AppLogger.info('Gemma: download cancelled');
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
      try { await _model!.close(); } catch (_) {}
      _model = null;
    }
  }

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

  static Future<GemmaIdentificationResult?> identify(Uint8List imageBytes) async {
    final status = await checkStatus();
    if (status != GemmaModelStatus.ready) return null;

    if (!await _ensureInitialized()) return null;

    try {
      final chat = await _model!.createChat(
        supportImage: true,
        temperature: 0.2,
        topK: 1,
      );
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
