import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';

/// Checks for .litertlm files received via AirDrop, Share Sheet, or
/// iTunes/Finder File Sharing and installs them for flutter_gemma.
///
/// - AirDrop / "Open In": iOS copies the file to Documents/Inbox/
/// - Finder File Sharing: user drags file to the app's Documents folder
///   (requires UIFileSharingEnabled + LSSupportsOpeningDocumentsInPlace in Info.plist)
class GemmaFileReceiver {
  static const _validExtensions = ['.litertlm', '.task'];

  /// Check both Documents/Inbox (AirDrop) and Documents root (Finder).
  /// If a model file is found, copies it to applicationSupport/gemma_model/
  /// where flutter_gemma can find it, then deletes the original.
  ///
  /// Returns `true` if a model was installed.
  static Future<bool> checkForReceivedModel() async {
    if (kIsWeb) return false;

    try {
      final docsDir = await getApplicationDocumentsDirectory();

      // 1. Check Documents/Inbox (AirDrop / Share Sheet)
      final inboxDir = Directory('${docsDir.path}/Inbox');
      if (await inboxDir.exists()) {
        final result = await _scanAndInstall(inboxDir);
        if (result) return true;
      }

      // 2. Check Documents root (Finder File Sharing / iTunes)
      final result = await _scanAndInstall(docsDir);
      if (result) return true;
    } catch (e) {
      AppLogger.warning('GemmaFileReceiver: check failed', e);
    }

    return false;
  }

  /// Scans a directory for model files and installs the first one found.
  static Future<bool> _scanAndInstall(Directory dir) async {
    final entities = await dir.list().toList();
    for (final entity in entities) {
      if (entity is File) {
        final name = entity.path.split('/').last.toLowerCase();
        if (_validExtensions.any((ext) => name.endsWith(ext))) {
          AppLogger.info('GemmaFileReceiver: found model file: $name in ${dir.path}');
          return _installModel(entity);
        }
      }
    }
    return false;
  }

  /// Copies the model file to applicationSupport/gemma_model/ and removes
  /// the original from Documents or Inbox.
  static Future<bool> _installModel(File sourceFile) async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final destDir = Directory('${supportDir.path}/gemma_model');
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }

      final fileName = sourceFile.path.split('/').last;
      final destFile = File('${destDir.path}/$fileName');

      // Copy first (Inbox files may not allow move due to permissions)
      await sourceFile.copy(destFile.path);

      // Remove original to free space
      try {
        await sourceFile.delete();
      } catch (_) {
        // Inbox file deletion may fail on some iOS versions — not critical
      }

      AppLogger.info('GemmaFileReceiver: model installed to ${destFile.path}');
      return true;
    } catch (e) {
      AppLogger.warning('GemmaFileReceiver: install failed', e);
      return false;
    }
  }
}
