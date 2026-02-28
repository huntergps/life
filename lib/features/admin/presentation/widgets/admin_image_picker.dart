import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';

class AdminImagePicker extends StatelessWidget {
  final String? currentImageUrl;
  final String? localPreviewPath;
  final bool isLoading;
  final void Function(File croppedFile) onImageSelected;

  const AdminImagePicker({
    super.key,
    this.currentImageUrl,
    this.localPreviewPath,
    this.isLoading = false,
    required this.onImageSelected,
  });

  Future<void> _pickAndCrop(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      compressQuality: 90,
      maxWidth: 1280,
      maxHeight: 720,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: t.admin.cropImage,
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: t.admin.cropImage,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (cropped != null) {
      onImageSelected(File(cropped.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: currentImageUrl != null ? t.admin.changeImage : t.admin.uploadImage,
      child: GestureDetector(
      onTap: isLoading ? null : () => _pickAndCrop(context),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildContent(isDark),
        ),
      ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (localPreviewPath != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(localPreviewPath!), fit: BoxFit.cover),
          _buildOverlay(),
        ],
      );
    }

    if (currentImageUrl != null && currentImageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(currentImageUrl!, fit: BoxFit.cover),
          _buildOverlay(),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            t.admin.tapToAddImage,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(t.admin.changeImage, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
