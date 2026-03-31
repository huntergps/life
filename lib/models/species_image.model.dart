import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class SpeciesImage extends OfflineFirstWithSupabaseModel {
  final int id;

  final int speciesId;

  final String imageUrl;

  final String? captionEs;

  final String? captionEn;

  final int sortOrder;

  final bool isPrimary;

  final String? thumbnailUrl;

  final String? cardThumbnailUrl;

  @override
  Object? get primaryKey => id;

  SpeciesImage({
    required this.id,
    required this.speciesId,
    required this.imageUrl,
    this.captionEs,
    this.captionEn,
    this.sortOrder = 0,
    this.isPrimary = false,
    this.thumbnailUrl,
    this.cardThumbnailUrl,
  });
}
