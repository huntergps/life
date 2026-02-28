import 'dart:io';
import 'dart:typed_data';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:galapagos_wildlife/brick/models/user_profile.model.dart';
import 'package:galapagos_wildlife/brick/repository.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';
import 'package:galapagos_wildlife/features/admin/services/image_processing_service.dart';

/// Fetches the current user's profile from Brick (offline-first)
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final profiles = await Repository().get<UserProfile>(
    policy: OfflineFirstGetPolicy.awaitRemote,
    query: Query(where: [Where('id').isExactly(user.id)]),
  );

  return profiles.isEmpty ? null : profiles.first;
});

/// Upserts profile data for the current user
Future<void> updateProfile({
  required String userId,
  String? displayName,
  String? bio,
  DateTime? birthDate,
  String? country,
  String? countryCode,
  String? avatarUrl,
}) async {
  // Get existing profile first to preserve unmodified fields
  final existing = await Repository().get<UserProfile>(
    policy: OfflineFirstGetPolicy.localOnly,
    query: Query(where: [Where('id').isExactly(userId)]),
  );

  final existingProfile = existing.isEmpty ? null : existing.first;

  final profile = UserProfile(
    id: userId,
    displayName: displayName ?? existingProfile?.displayName,
    bio: bio ?? existingProfile?.bio,
    birthDate: birthDate ?? existingProfile?.birthDate,
    country: country ?? existingProfile?.country,
    countryCode: countryCode ?? existingProfile?.countryCode,
    avatarUrl: avatarUrl ?? existingProfile?.avatarUrl,
    createdAt: existingProfile?.createdAt ?? DateTime.now(),
    updatedAt: DateTime.now(),
  );

  await Repository().upsert<UserProfile>(profile);
}

/// Picks, crops (1:1 square), compresses, and uploads avatar image.
/// Returns the public URL of the uploaded avatar.
///
/// Note: Image cropper only works on iOS/Android. On macOS/Web, the image
/// is automatically cropped to square using the image package.
Future<String?> pickAndUploadAvatar(String userId) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked == null) return null;

  String imagePath = picked.path;

  // Try to use ImageCropper on mobile platforms (iOS/Android)
  if (Platform.isAndroid || Platform.isIOS) {
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Avatar',
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Avatar',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );
      if (cropped != null) {
        imagePath = cropped.path;
      }
    } catch (e) {
      // ImageCropper failed, continue with original image
      print('ImageCropper not available: $e');
    }
  }

  // Read and process the image (crop to square if needed on macOS/Web)
  final bytes = await File(imagePath).readAsBytes();

  // Compress and crop to square 1:1 using ImageProcessingService
  final compressed = ImageProcessingService.compressImage(
    bytes,
    maxWidth: 512,
    maxHeight: 512,
    initialQuality: 80,
    targetMaxBytes: 100 * 1024,
    cropToSquare: true, // This will be handled by ImageProcessingService
  );

  final path = '$userId/avatar.jpg';
  await Supabase.instance.client.storage.from('avatars').uploadBinary(
        path,
        Uint8List.fromList(compressed),
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );

  final publicUrl =
      Supabase.instance.client.storage.from('avatars').getPublicUrl(path);

  // Bust cache by appending timestamp
  return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
}
