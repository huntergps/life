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

      // 3. Check File Provider Storage (AirDrop on newer iOS)
      // iOS may put AirDropped files in the app group container
      final appSupportDir = await getApplicationSupportDirectory();
      // Walk up to find the container root and check common paths
      final containerRoot = appSupportDir.parent;
      final possiblePaths = [
        '${containerRoot.path}/File Provider Storage/Downloads',
        '${containerRoot.path}/tmp',
        '${containerRoot.path}/Documents',
      ];
      for (final p in possiblePaths) {
        final dir = Directory(p);
        if (await dir.exists()) {
          final found = await _scanAndInstall(dir);
          if (found) return true;
        }
      }

      // 4. Also scan the shared AppGroup container
      // The path from the error: /private/var/mobile/Containers/Shared/AppGroup/*/File Provider Storage/Downloads/
      try {
        final sharedBase = Directory('/private/var/mobile/Containers/Shared/AppGroup');
        if (await sharedBase.exists()) {
          await for (final groupDir in sharedBase.list()) {
            if (groupDir is Directory) {
              final fpDir = Directory('${groupDir.path}/File Provider Storage/Downloads');
              if (await fpDir.exists()) {
                final found = await _scanAndInstall(fpDir);
                if (found) return true;
              }
            }
          }
        }
      } catch (_) {
        // Permission denied for shared containers — expected on sandboxed iOS
      }
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
