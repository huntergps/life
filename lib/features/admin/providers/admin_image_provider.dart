import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:galapagos_wildlife/core/constants/supabase_constants.dart';
import 'admin_category_provider.dart';
import '../services/admin_supabase_service.dart';
import '../services/image_processing_service.dart';

enum ImageUploadStatus { idle, picking, cropping, compressing, uploading, done, error }

/// Fine-grained upload stage with user-visible messages.
enum UploadStage {
  idle,
  picking,
  cropping,
  compressing,
  uploading,
  generatingThumbnail,
  done,
  error,
}

class ImageUploadState {
  final ImageUploadStatus status;
  final UploadStage stage;
  final String message;
  final String? heroUrl;
  final String? thumbnailUrl;
  final String? errorMessage;
  final double progress;

  const ImageUploadState({
    this.status = ImageUploadStatus.idle,
    this.stage = UploadStage.idle,
    this.message = '',
    this.heroUrl,
    this.thumbnailUrl,
    this.errorMessage,
    this.progress = 0,
  });

  ImageUploadState copyWith({
    ImageUploadStatus? status,
    UploadStage? stage,
    String? message,
    String? heroUrl,
    String? thumbnailUrl,
    String? errorMessage,
    double? progress,
  }) {
    return ImageUploadState(
      status: status ?? this.status,
      stage: stage ?? this.stage,
      message: message ?? this.message,
      heroUrl: heroUrl ?? this.heroUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  /// Helper to get localised stage message.
  static String stageMessage(UploadStage stage) {
    switch (stage) {
      case UploadStage.idle:
        return '';
      case UploadStage.picking:
        return 'Seleccionando imagen...';
      case UploadStage.cropping:
        return 'Recortando imagen...';
      case UploadStage.compressing:
        return 'Comprimiendo imagen...';
      case UploadStage.uploading:
        return 'Subiendo imagen...';
      case UploadStage.generatingThumbnail:
        return 'Generando miniatura...';
      case UploadStage.done:
        return '\u00a1Imagen subida!';
      case UploadStage.error:
        return 'Error al subir imagen';
    }
  }
}

final imageUploadStateProvider = StateProvider<ImageUploadState>((ref) {
  return const ImageUploadState();
});

Future<({String heroUrl, String thumbUrl})> processAndUploadImage({
  required Uint8List imageBytes,
  required int speciesId,
  required AdminSupabaseService service,
}) async {
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  // Compress hero image
  final heroBytes = ImageProcessingService.compressImage(imageBytes);

  // Generate thumbnail
  final thumbBytes = ImageProcessingService.generateThumbnail(imageBytes);

  // Upload hero
  final heroUrl = await service.uploadImage(
    bucket: SupabaseConstants.speciesImagesBucket,
    path: '$speciesId/hero_$timestamp.jpg',
    bytes: heroBytes,
  );

  // Upload thumbnail
  final thumbUrl = await service.uploadImage(
    bucket: SupabaseConstants.speciesImagesBucket,
    path: '$speciesId/thumb_$timestamp.jpg',
    bytes: thumbBytes,
  );

  return (heroUrl: heroUrl, thumbUrl: thumbUrl);
}

final adminSpeciesImagesProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, speciesId) async {
  final service = ref.watch(adminSupabaseServiceProvider);
  return service.getSpeciesImages(speciesId);
});
