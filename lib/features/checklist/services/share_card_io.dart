import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Saves [bytes] to a temporary file and returns the file path.
Future<String> saveTempImage(Uint8List bytes, String fileName) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}

/// No-op on native — image sharing is handled via XFile.
void shareImageBytes(Uint8List bytes, String fileName) {}
