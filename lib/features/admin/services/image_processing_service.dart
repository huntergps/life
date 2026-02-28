import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessingService {
  static const int heroMaxWidth = 1280;
  static const int heroMaxHeight = 720;
  static const int thumbWidth = 400;
  static const int thumbHeight = 225;
  static const int cardThumbSize = 400;
  static const int maxFileSizeBytes = 150 * 1024; // 150KB

  /// Compress image to JPEG, iteratively reducing quality until under [maxFileSizeBytes].
  /// Starts at [initialQuality] and decreases by 5 each step down to [minQuality].
  /// If [cropToSquare] is true, center-crops the image to 1:1 before resizing.
  static Uint8List compressImage(
    Uint8List bytes, {
    int maxWidth = heroMaxWidth,
    int maxHeight = heroMaxHeight,
    int initialQuality = 75,
    int minQuality = 40,
    int? targetMaxBytes,
    bool cropToSquare = false,
  }) {
    var decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Failed to decode image');

    // Center-crop to square if requested (for avatars)
    if (cropToSquare) {
      final side = decoded.height < decoded.width ? decoded.height : decoded.width;
      final x = (decoded.width - side) ~/ 2;
      final y = (decoded.height - side) ~/ 2;
      decoded = img.copyCrop(decoded, x: x, y: y, width: side, height: side);
    }

    // Resize if larger than target dimensions
    if (decoded.width > maxWidth || decoded.height > maxHeight) {
      decoded = img.copyResize(
        decoded,
        width: maxWidth,
        height: maxHeight,
        maintainAspect: true,
      );
    }

    final maxBytes = targetMaxBytes ?? maxFileSizeBytes;

    // Iteratively compress until under target size
    int quality = initialQuality;
    Uint8List result = Uint8List.fromList(img.encodeJpg(decoded, quality: quality));

    while (result.length > maxBytes && quality > minQuality) {
      quality -= 5;
      result = Uint8List.fromList(img.encodeJpg(decoded, quality: quality));
    }

    return result;
  }

  /// Generate a 16:9 gallery thumbnail from image bytes.
  static Uint8List generateThumbnail(Uint8List bytes) {
    var decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Failed to decode image');

    final thumbnail = img.copyResize(
      decoded,
      width: thumbWidth,
      height: thumbHeight,
      maintainAspect: true,
    );

    return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 75));
  }

  /// Generate a 1:1 card thumbnail from already-cropped bytes (from ImageCropper).
  /// Resizes to 400x400 JPEG.
  static Uint8List generateCardThumbnail(Uint8List croppedBytes) {
    var decoded = img.decodeImage(croppedBytes);
    if (decoded == null) throw Exception('Failed to decode image');

    final thumb = img.copyResize(decoded, width: cardThumbSize, height: cardThumbSize);
    return Uint8List.fromList(img.encodeJpg(thumb, quality: 75));
  }

  /// Generate a center-crop 1:1 card thumbnail from a 16:9 image (for seeding).
  /// Crops the center square, then resizes to 400x400.
  static Uint8List generateCardThumbnailCenterCrop(Uint8List bytes) {
    var decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Failed to decode image');

    // Center-crop to square
    final side = decoded.height < decoded.width ? decoded.height : decoded.width;
    final x = (decoded.width - side) ~/ 2;
    final y = (decoded.height - side) ~/ 2;
    final cropped = img.copyCrop(decoded, x: x, y: y, width: side, height: side);

    final thumb = img.copyResize(cropped, width: cardThumbSize, height: cardThumbSize);
    return Uint8List.fromList(img.encodeJpg(thumb, quality: 75));
  }
}
