import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Image preprocessing for TFLite MobileNetV3 input.
///
/// Letterbox-resizes to 224x224 and normalizes pixel values to [-1, 1].
/// Preserves the original aspect ratio to avoid distorting or cropping.
class ImagePreprocessor {
  const ImagePreprocessor._();

  /// Target image size for the model input.
  static const imgSize = 224;

  /// Preprocess raw image bytes into a Float32List tensor ready for TFLite.
  ///
  /// The image is scale-to-fit within 224x224 (no crop, no stretch),
  /// placed on a black canvas. Black padding normalizes to -1.0.
  static Float32List preprocess(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('No se pudo decodificar la imagen');

    // Scale-to-fit within 224x224
    final scaleW = imgSize / decoded.width;
    final scaleH = imgSize / decoded.height;
    final scale = scaleW < scaleH ? scaleW : scaleH;
    final newW = (decoded.width * scale).round().clamp(1, imgSize);
    final newH = (decoded.height * scale).round().clamp(1, imgSize);
    final scaled = img.copyResize(decoded, width: newW, height: newH);

    // Black canvas 224x224; empty area = -1.0 after normalization
    final canvas = img.Image(width: imgSize, height: imgSize);
    img.compositeImage(
      canvas,
      scaled,
      dstX: (imgSize - newW) ~/ 2,
      dstY: (imgSize - newH) ~/ 2,
    );

    final buffer = Float32List(imgSize * imgSize * 3);
    int idx = 0;
    for (int y = 0; y < imgSize; y++) {
      for (int x = 0; x < imgSize; x++) {
        final pixel = canvas.getPixel(x, y);
        buffer[idx++] = (pixel.r.toDouble() / 127.5) - 1.0;
        buffer[idx++] = (pixel.g.toDouble() / 127.5) - 1.0;
        buffer[idx++] = (pixel.b.toDouble() / 127.5) - 1.0;
      }
    }
    return buffer;
  }
}
