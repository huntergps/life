import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';

/// Manages the Galápagos PMTiles vector base map.
///
/// The HD file (galapagos_hd.pmtiles, zoom 0-15) is downloaded from Supabase
/// Storage using [FileDownloader] (background_downloader) which uses iOS
/// URLSession with background configuration — the download continues even
/// when the app is suspended or the screen is locked.
class PmTilesManager {
  // Legacy low-zoom asset (zoom 0-14, ~3 MB) bundled with the app.
  static const _assetFileName = 'galapagos.pmtiles';
  static const _assetPath = 'assets/maps/$_assetFileName';

  // HD file (zoom 0-15, ~20-30 MB) downloaded from Supabase Storage.
  static const _hdFileName = 'galapagos_hd.pmtiles';
  static const _hdDownloadUrl =
      'https://pxkopudkwqysfdeprmke.supabase.co/storage/v1/object/public/map-tiles/galapagos_hd.pmtiles';
  static const _hdTaskId = 'galapagos_hd_pmtiles';

  /// Active download task — kept so pause/resume have the task reference.
  static DownloadTask? _activeTask;

  /// Minimum expected size of the HD file in bytes.
  static const _hdMinSize = 5 * 1024 * 1024; // 5 MB

  // ---------------------------------------------------------------------------
  // Path helpers
  // ---------------------------------------------------------------------------

  static Future<String> get _mapsDir async {
    final dir = await getApplicationDocumentsDirectory();
    final mapsDir = Directory('${dir.path}/maps');
    if (!mapsDir.existsSync()) await mapsDir.create(recursive: true);
    return mapsDir.path;
  }

  static Future<String> get localPath async {
    final dir = await _mapsDir;
    // Prefer HD file if available, fall back to asset copy.
    final hdFile = File('$dir/$_hdFileName');
    if (hdFile.existsSync() && hdFile.lengthSync() >= _hdMinSize) {
      return hdFile.path;
    }
    return '$dir/$_assetFileName';
  }

  static Future<String> get _hdLocalPath async {
    final dir = await _mapsDir;
    return '$dir/$_hdFileName';
  }

  // ---------------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------------

  /// Whether any usable PMTiles file exists locally.
  static Future<bool> get isDownloaded async {
    final path = await localPath;
    return File(path).existsSync();
  }

  /// Whether the HD (high-zoom) file has been downloaded.
  static Future<bool> get isHdDownloaded async {
    final path = await _hdLocalPath;
    final file = File(path);
    return file.existsSync() && file.lengthSync() >= _hdMinSize;
  }

  /// Size of the active local PMTiles file in bytes.
  static Future<int> get localFileSize async {
    final path = await localPath;
    final file = File(path);
    return file.existsSync() ? file.lengthSync() : 0;
  }

  // ---------------------------------------------------------------------------
  // HD download via background_downloader (true iOS background)
  // ---------------------------------------------------------------------------

  /// Starts downloading the HD PMTiles file using iOS URLSession background
  /// configuration. The download continues even if the app is suspended.
  ///
  /// [onProgress] receives values 0.0–1.0. [onDone] is called on success.
  /// [onError] is called with an error description on failure.
  static Future<void> downloadHd({
    ValueChanged<double>? onProgress,
    VoidCallback? onDone,
    ValueChanged<String>? onError,
  }) async {
    final hdPath = await _hdLocalPath;

    final task = DownloadTask(
      taskId: _hdTaskId,
      url: _hdDownloadUrl,
      filename: _hdFileName,
      directory: 'maps',
      baseDirectory: BaseDirectory.applicationDocuments,
      updates: Updates.statusAndProgress,
      allowPause: true,
      retries: 3,
    );
    _activeTask = task;

    await FileDownloader().download(
      task,
      onProgress: (progress) => onProgress?.call(progress),
      onStatus: (status) {
        AppLogger.info('PMTiles HD download status: $status');
        switch (status) {
          case TaskStatus.complete:
            _activeTask = null;
            AppLogger.info('PMTiles HD downloaded → $hdPath');
            onDone?.call();
          case TaskStatus.failed:
            _activeTask = null;
            onError?.call('Download failed. Check your connection.');
          case TaskStatus.canceled:
            _activeTask = null;
            onError?.call('Download cancelled.');
          case TaskStatus.notFound:
            _activeTask = null;
            onError?.call('HD map file not found on server.');
          default:
            break;
        }
      },
    );
  }

  /// Cancel any in-progress HD download.
  static Future<void> cancelDownload() async {
    await FileDownloader().cancelTaskWithId(_hdTaskId);
    _activeTask = null;
  }

  /// Pause the in-progress HD download (can be resumed later).
  static Future<void> pauseDownload() async {
    if (_activeTask != null) {
      await FileDownloader().pause(_activeTask!);
    }
  }

  /// Resume a paused HD download.
  static Future<void> resumeDownload({
    ValueChanged<double>? onProgress,
    VoidCallback? onDone,
    ValueChanged<String>? onError,
  }) async {
    if (_activeTask != null) {
      final resumed = await FileDownloader().resume(_activeTask!);
      if (!resumed) {
        // If resume fails, restart
        await downloadHd(onProgress: onProgress, onDone: onDone, onError: onError);
      }
    } else {
      await downloadHd(onProgress: onProgress, onDone: onDone, onError: onError);
    }
  }

  // ---------------------------------------------------------------------------
  // Legacy download (kept for backward compatibility, not background-safe)
  // ---------------------------------------------------------------------------

  /// @deprecated Use [downloadHd] instead. Kept for the PMTiles base map
  /// download path that already worked with the old HTTP client.
  static Future<String> download({
    ValueChanged<double>? onProgress,
  }) async {
    await downloadHd(onProgress: onProgress);
    return await localPath;
  }

  // ---------------------------------------------------------------------------
  // Asset fallback
  // ---------------------------------------------------------------------------

  /// Copies the bundled low-zoom PMTiles (zoom 0-14) from assets to disk.
  static Future<void> copyFromAssets() async {
    try {
      final dir = await _mapsDir;
      final file = File('$dir/$_assetFileName');
      final byteData = await rootBundle.load(_assetPath);
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
      AppLogger.info('PMTiles copied from assets: ${file.lengthSync()} bytes');
    } catch (e) {
      AppLogger.error('Failed to copy PMTiles from assets', e);
      rethrow;
    }
  }

  /// Verifies the active PMTiles file is present and non-empty.
  static Future<bool> verifyIntegrity() async {
    try {
      final path = await localPath;
      final file = File(path);
      if (!file.existsSync()) return false;
      return file.lengthSync() > 100 * 1024; // at least 100 KB
    } catch (e) {
      AppLogger.error('PMTiles integrity check failed', e);
      return false;
    }
  }

  /// Ensures a usable PMTiles file is available (falls back to asset copy).
  static Future<bool> ensureAvailable() async {
    try {
      if (await isDownloaded) {
        if (await verifyIntegrity()) {
          AppLogger.info('PMTiles OK');
          return true;
        }
      }
      AppLogger.info('PMTiles not found or invalid, copying from assets...');
      await copyFromAssets();
      return true;
    } catch (e) {
      AppLogger.error('Failed to ensure PMTiles availability', e);
      return false;
    }
  }

  /// Deletes both the HD file and the asset copy.
  static Future<void> delete() async {
    final dir = await _mapsDir;
    for (final name in [_hdFileName, _assetFileName]) {
      final file = File('$dir/$name');
      if (file.existsSync()) {
        await file.delete();
        AppLogger.info('PMTiles deleted: ${file.path}');
      }
    }
  }
}
