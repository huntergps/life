import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// No-op on web — file path sharing is not supported.
Future<String> saveTempImage(Uint8List bytes, String fileName) async {
  return '';
}

/// Triggers a browser download of the PNG image.
void shareImageBytes(Uint8List bytes, String fileName) {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
