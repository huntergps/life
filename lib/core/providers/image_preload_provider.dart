import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifier, StateNotifierProvider;
import 'package:galapagos_wildlife/brick/repository.dart';
import 'package:galapagos_wildlife/core/services/image_preload_service.dart';

/// State for image preloading progress
class ImagePreloadState {
  final ImagePreloadStatus status;
  final int current;
  final int total;
  final String? errorMessage;

  const ImagePreloadState({
    this.status = ImagePreloadStatus.idle,
    this.current = 0,
    this.total = 0,
    this.errorMessage,
  });

  ImagePreloadState copyWith({
    ImagePreloadStatus? status,
    int? current,
    int? total,
    String? errorMessage,
  }) {
    return ImagePreloadState(
      status: status ?? this.status,
      current: current ?? this.current,
      total: total ?? this.total,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  double get progress => total > 0 ? current / total : 0.0;

  bool get isLoading => status == ImagePreloadStatus.loading;
  bool get isCompleted => status == ImagePreloadStatus.completed;
  bool get hasError => status == ImagePreloadStatus.error;
}

enum ImagePreloadStatus {
  idle,
  loading,
  completed,
  error,
}

/// Notifier for managing image preload state
class ImagePreloadNotifier extends StateNotifier<ImagePreloadState> {
  final ImagePreloadService _service;

  ImagePreloadNotifier(this._service) : super(const ImagePreloadState());

  /// Start preloading all species images
  Future<void> preloadImages() async {
    if (state.isLoading) return;

    state = state.copyWith(
      status: ImagePreloadStatus.loading,
      current: 0,
      total: 0,
      errorMessage: null,
    );

    try {
      final successCount = await _service.preloadAllSpeciesImages(
        onProgress: (current, total) {
          state = state.copyWith(
            current: current,
            total: total,
          );
        },
      );

      state = state.copyWith(
        status: ImagePreloadStatus.completed,
        current: successCount,
      );
    } catch (e) {
      state = state.copyWith(
        status: ImagePreloadStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reset state to idle
  void reset() {
    state = const ImagePreloadState();
  }
}

/// Provider for image preload service
final imagePreloadServiceProvider = Provider<ImagePreloadService>((ref) {
  return ImagePreloadService(Repository());
});

/// Provider for image preload state
final imagePreloadProvider =
    StateNotifierProvider<ImagePreloadNotifier, ImagePreloadState>((ref) {
  final service = ref.watch(imagePreloadServiceProvider);
  return ImagePreloadNotifier(service);
});

/// Provider to check estimated download size
final estimatedDownloadSizeProvider = FutureProvider<double>((ref) async {
  final service = ref.watch(imagePreloadServiceProvider);
  return service.estimateDownloadSize();
});

/// Provider to check if images are already cached
final areImagesCachedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(imagePreloadServiceProvider);
  return service.areImagesCached();
});
