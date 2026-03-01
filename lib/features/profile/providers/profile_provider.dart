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
import 'package:galapagos_wildlife/core/utils/brick_helpers.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';
import 'package:galapagos_wildlife/features/admin/services/image_processing_service.dart';

/// Fetches the current user's profile from Brick (offline-first) or Supabase (web)
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  if (kIsWeb) {
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (data == null) return null;
    return userProfileFromRow(data as Map<String, dynamic>);
  }

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
  if (kIsWeb) {
    // Fetch existing to preserve unmodified fields
    final existing = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    final existingProfile =
        existing != null ? userProfileFromRow(existing as Map<String, dynamic>) : null;

    await Supabase.instance.client.from('profiles').upsert({
      'id': userId,
      'display_name': displayName ?? existingProfile?.displayName,
      'bio': bio ?? existingProfile?.bio,
      'birth_date': (birthDate ?? existingProfile?.birthDate)?.toIso8601String(),
      'country': country ?? existingProfile?.country,
      'country_code': countryCode ?? existingProfile?.countryCode,
      'avatar_url': avatarUrl ?? existingProfile?.avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
    return;
  }

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
Future<String?> pickAndUploadAvatar(String userId) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked == null) return null;

  final Uint8List bytes;

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    // Try ImageCropper on mobile
    String imagePath = picked.path;
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
      // ImageCropper not available, continue with original
    }
    bytes = await File(imagePath).readAsBytes();
  } else {
    // Web or desktop: read bytes directly from XFile (works without dart:io File)
    bytes = await picked.readAsBytes();
  }

  // Compress and crop to square using ImageProcessingService
  final compressed = ImageProcessingService.compressImage(
    bytes,
    maxWidth: 512,
    maxHeight: 512,
    initialQuality: 80,
    targetMaxBytes: 100 * 1024,
    cropToSquare: true,
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
