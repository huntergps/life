import 'dart:io';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/adaptive_layout.dart';
import 'package:galapagos_wildlife/core/constants/supabase_constants.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/species_image.model.dart';
import 'package:galapagos_wildlife/brick/repository.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:galapagos_wildlife/features/species/providers/species_list_provider.dart';
import 'package:galapagos_wildlife/features/species/providers/species_detail_provider.dart';
import 'package:galapagos_wildlife/features/home/providers/home_provider.dart';
import '../../../providers/admin_image_provider.dart';
import '../../../providers/admin_category_provider.dart';
import '../../../providers/admin_species_provider.dart';
import '../../../services/image_processing_service.dart';
import '../../widgets/admin_delete_dialog.dart';

/// Downloads a file from [url] to a temporary path and returns the [File].
Future<File> _downloadToTemp(String url, String filename) async {
  final httpClient = HttpClient();
  final request = await httpClient.getUrl(Uri.parse(url));
  final response = await request.close();
  final tempFile = File('${Directory.systemTemp.path}/$filename');
  final sink = tempFile.openWrite();
  await response.pipe(sink);
  return tempFile;
}

class AdminSpeciesImagesScreen extends ConsumerStatefulWidget {
  final int speciesId;

  const AdminSpeciesImagesScreen({super.key, required this.speciesId});

  @override
  ConsumerState<AdminSpeciesImagesScreen> createState() => _AdminSpeciesImagesScreenState();
}

class _AdminSpeciesImagesScreenState extends ConsumerState<AdminSpeciesImagesScreen> {
  UploadStage _uploadStage = UploadStage.idle;
  bool get _isUploading => _uploadStage != UploadStage.idle && _uploadStage != UploadStage.done && _uploadStage != UploadStage.error;

  void _setStage(UploadStage stage) {
    if (mounted) setState(() => _uploadStage = stage);
    // Also update the shared provider for external consumers
    ref.read(imageUploadStateProvider.notifier).state = ImageUploadState(
      stage: stage,
      message: ImageUploadState.stageMessage(stage),
    );
  }

  /// Sync Brick cache from server and invalidate all related providers.
  /// Called after any image change so BOTH admin and user-facing UI update.
  Future<void> _syncAllProviders() async {
    // Sync Brick cache (species row may have changed via trigger)
    await Repository().get<Species>(policy: OfflineFirstGetPolicy.awaitRemote);
    await Repository().get<SpeciesImage>(policy: OfflineFirstGetPolicy.awaitRemote);
    // Admin providers (direct Supabase)
    ref.invalidate(adminSpeciesImagesProvider(widget.speciesId));
    ref.invalidate(adminSpeciesListProvider);
    // User-facing providers (Brick localOnly — now reading from updated cache)
    ref.invalidate(speciesListProvider);
    ref.invalidate(featuredSpeciesProvider);
    ref.invalidate(speciesImagesProvider(widget.speciesId));
    ref.invalidate(speciesDetailProvider(widget.speciesId));
  }

  Future<void> _addImage() async {
    _setStage(UploadStage.picking);

    final cropTitle = context.t.admin.cropImage; // Capture before await

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      _setStage(UploadStage.idle);
      return;
    }

    _setStage(UploadStage.cropping);

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      compressQuality: 70,
      maxWidth: 1280,
      maxHeight: 720,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: cropTitle,
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: cropTitle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    if (cropped == null) {
      _setStage(UploadStage.idle);
      return;
    }

    try {
      _setStage(UploadStage.compressing);

      final bytes = await File(cropped.path).readAsBytes();
      final service = ref.read(adminSupabaseServiceProvider);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Compress full image (target <=150KB, quality 75->40)
      final compressed = ImageProcessingService.compressImage(bytes);

      _setStage(UploadStage.uploading);

      final imageUrl = await service.uploadImage(
        bucket: SupabaseConstants.speciesImagesBucket,
        path: '${widget.speciesId}/gallery_$timestamp.jpg',
        bytes: compressed,
      );

      _setStage(UploadStage.generatingThumbnail);

      // Generate and upload gallery thumbnail (400x225, quality 75)
      final thumbBytes = ImageProcessingService.generateThumbnail(bytes);
      final thumbnailUrl = await service.uploadImage(
        bucket: SupabaseConstants.speciesImagesBucket,
        path: '${widget.speciesId}/thumb_gallery_$timestamp.jpg',
        bytes: thumbBytes,
      );

      // Get current images to determine sort_order and if this is the first image
      final images = await service.getSpeciesImages(widget.speciesId);
      final maxOrder = images.isEmpty
          ? 0
          : images.map((i) => (i['sort_order'] as int?) ?? 0).reduce((a, b) => a > b ? a : b);
      final isFirst = images.isEmpty;

      await service.upsertSpeciesImage({
        'species_id': widget.speciesId,
        'image_url': imageUrl,
        'thumbnail_url': thumbnailUrl,
        'sort_order': maxOrder + 1,
        'is_primary': isFirst, // Auto-set first image as primary
      });

      await _syncAllProviders();

      _setStage(UploadStage.done);

      // Auto-dismiss done state after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _uploadStage == UploadStage.done) {
          _setStage(UploadStage.idle);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.admin.imageAdded)),
        );
      }
    } catch (_) {
      _setStage(UploadStage.error);

      // Auto-dismiss error state after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _uploadStage == UploadStage.error) {
          _setStage(UploadStage.idle);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.common.error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _setPrimary(Map<String, dynamic> image) async {
    final imageId = image['id'] as int;
    final imageUrl = image['image_url'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) return;

    final cropTitle = context.t.admin.cropImage; // Capture before await

    // 1. Download the full image to a temp file for the cropper
    _setStage(UploadStage.picking);
    late final File tempFile;
    try {
      tempFile = await _downloadToTemp(imageUrl, 'primary_crop_$imageId.jpg');
    } catch (_) {
      _setStage(UploadStage.idle);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.common.error), backgroundColor: AppColors.error),
        );
      }
      return;
    }
    _setStage(UploadStage.idle);

    if (!mounted) return;

    // 2. Show 1:1 cropper -- admin can zoom/resize freely to pick the best focal area
    _setStage(UploadStage.cropping);
    final cropped = await ImageCropper().cropImage(
      sourcePath: tempFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: cropTitle,
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: cropTitle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    // Clean up temp file
    try { await tempFile.delete(); } catch (_) {}

    // 3. Cancelled -- keep current primary image and its thumbnail unchanged
    if (cropped == null) {
      _setStage(UploadStage.idle);
      return;
    }

    // 4. Accepted -- now send to server
    try {
      _setStage(UploadStage.compressing);

      // Generate 400x400 card thumbnail from the cropped region
      final croppedBytes = await File(cropped.path).readAsBytes();
      final cardThumbBytes = ImageProcessingService.generateCardThumbnail(croppedBytes);

      _setStage(UploadStage.uploading);

      // Upload card thumbnail to storage
      final service = ref.read(adminSupabaseServiceProvider);
      final cardThumbUrl = await service.uploadImage(
        bucket: SupabaseConstants.speciesImagesBucket,
        path: '${widget.speciesId}/card_thumb_$imageId.jpg',
        bytes: cardThumbBytes,
      );

      // Update DB: set as primary + card_thumbnail_url (trigger syncs to species)
      await service.updateSpeciesImage(imageId, {
        'is_primary': true,
        'card_thumbnail_url': cardThumbUrl,
      });

      // Sync Brick cache + invalidate all providers (admin + user-facing)
      await _syncAllProviders();

      _setStage(UploadStage.done);

      // Auto-dismiss done state after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _uploadStage == UploadStage.done) {
          _setStage(UploadStage.idle);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.admin.primarySet)),
        );
      }
    } catch (_) {
      _setStage(UploadStage.error);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _uploadStage == UploadStage.error) {
          _setStage(UploadStage.idle);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.common.error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _deleteImage(Map<String, dynamic> image) async {
    final confirmed = await AdminDeleteDialog.show(
      context,
      entityName: 'this image',
      onConfirm: () {},
    );
    if (confirmed != true) return;

    try {
      final service = ref.read(adminSupabaseServiceProvider);
      await service.deleteSpeciesImage(image['id']);
      await _syncAllProviders();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.common.error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _reorder(List<Map<String, dynamic>> images, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = images.removeAt(oldIndex);
    images.insert(newIndex, item);

    final orders = <Map<String, dynamic>>[];
    for (var i = 0; i < images.length; i++) {
      orders.add({'id': images[i]['id'], 'sort_order': i});
    }

    try {
      final service = ref.read(adminSupabaseServiceProvider);
      await service.updateImageSortOrders(orders);
      await _syncAllProviders();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.common.error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(adminSpeciesImagesProvider(widget.speciesId));
    final speciesAsync = ref.watch(adminSpeciesProvider(widget.speciesId));
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve species name for the title
    final speciesName = speciesAsync.asData?.value != null
        ? (locale == 'es'
            ? speciesAsync.asData!.value!['common_name_es']
            : speciesAsync.asData!.value!['common_name_en']) as String?
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(speciesName != null
            ? '${context.t.admin.speciesImages} — $speciesName'
            : context.t.admin.speciesImages),
        backgroundColor: isDark ? AppColors.darkBackground : null,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _addImage,
        tooltip: context.t.admin.newItem,
        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        child: _isUploading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.add_photo_alternate, color: Colors.white),
      ),
      body: Column(
        children: [
          // Upload progress banner
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _uploadStage != UploadStage.idle
                ? _UploadProgressBanner(
                    key: ValueKey(_uploadStage),
                    stage: _uploadStage,
                    isDark: isDark,
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
          Expanded(
            child: imagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${context.t.common.error}: $e')),
        data: (images) {
          if (images.isEmpty) {
            final localGallery = SpeciesAssets.gallery(widget.speciesId);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(context.t.admin.noImagesYet),
                  const SizedBox(height: 8),
                  Text(context.t.admin.tapAddImages, style: const TextStyle(color: Colors.grey)),
                  if (localGallery.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      '${localGallery.length} local asset(s) available as reference',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 72,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        itemCount: localGallery.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(localGallery[index], height: 72, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }
          return AdaptiveLayout.constrainedContent(
            maxWidth: 900,
            child: ReorderableListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: AdaptiveLayout.responsivePadding(context),
              ),
            itemCount: images.length,
            onReorder: (oldIndex, newIndex) => _reorder(List.from(images), oldIndex, newIndex),
            itemBuilder: (context, index) {
              final image = images[index];
              final isPrimary = image['is_primary'] == true;
              return Card(
                key: ValueKey(image['id']),
                margin: const EdgeInsets.only(bottom: 12),
                color: isDark ? AppColors.darkCard : null,
                elevation: isDark ? 0 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isPrimary
                      ? BorderSide(color: isDark ? AppColors.accentOrange : AppColors.primary, width: 2)
                      : isDark
                          ? const BorderSide(color: AppColors.darkBorder, width: 0.5)
                          : BorderSide.none,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(image['image_url'] ?? '', fit: BoxFit.cover),
                          ),
                        ),
                        if (isPrimary)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.accentOrange : AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.t.admin.primaryImage,
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.drag_handle, color: isDark ? Colors.white38 : Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              image['caption_en'] ?? 'Image ${index + 1}',
                              style: TextStyle(color: isDark ? Colors.white70 : null),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isPrimary ? Icons.star : Icons.star_outline,
                              color: isPrimary
                                  ? (isDark ? AppColors.accentOrange : AppColors.primary)
                                  : (isDark ? Colors.white38 : Colors.grey),
                            ),
                            tooltip: context.t.admin.setPrimary,
                            onPressed: isPrimary ? null : () => _setPrimary(image),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: AppColors.error),
                            tooltip: context.t.common.delete,
                            onPressed: () => _deleteImage(image),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            ),
          );
        },
      ),
          ),
        ],
      ),
    );
  }
}

/// Progress banner widget shown at the top during upload operations.
class _UploadProgressBanner extends StatelessWidget {
  final UploadStage stage;
  final bool isDark;

  const _UploadProgressBanner({
    super.key,
    required this.stage,
    required this.isDark,
  });

  static String _stageMessageI18n(BuildContext context, UploadStage stage) {
    switch (stage) {
      case UploadStage.idle: return '';
      case UploadStage.picking: return context.t.admin.uploadPicking;
      case UploadStage.cropping: return context.t.admin.uploadCropping;
      case UploadStage.compressing: return context.t.admin.uploadCompressing;
      case UploadStage.uploading: return context.t.admin.uploadUploading;
      case UploadStage.generatingThumbnail: return context.t.admin.uploadGeneratingThumbnail;
      case UploadStage.done: return context.t.admin.uploadDone;
      case UploadStage.error: return context.t.admin.uploadError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = stage == UploadStage.done;
    final isError = stage == UploadStage.error;
    final message = _stageMessageI18n(context, stage);

    final Color bannerColor;
    final Color textColor;
    final Color progressColor;
    final IconData icon;

    if (isDone) {
      bannerColor = isDark ? const Color(0xFF1A3A1C) : const Color(0xFFE8F5E9);
      textColor = isDark ? AppColors.primaryLight : AppColors.primary;
      progressColor = AppColors.primaryLight;
      icon = Icons.check_circle;
    } else if (isError) {
      bannerColor = isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFDE8E8);
      textColor = AppColors.error;
      progressColor = AppColors.error;
      icon = Icons.error;
    } else {
      bannerColor = isDark ? AppColors.darkCard : const Color(0xFFF5F5F5);
      textColor = isDark ? Colors.white70 : Colors.black87;
      progressColor = isDark ? AppColors.accentOrange : AppColors.primary;
      icon = Icons.cloud_upload;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bannerColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (!isDone && !isError) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
