import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'species_images'),
)
class SpeciesImage extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  final int id;

  @Supabase(name: 'species_id')
  final int speciesId;

  @Supabase(name: 'image_url')
  final String imageUrl;

  @Supabase(name: 'caption_es')
  final String? captionEs;

  @Supabase(name: 'caption_en')
  final String? captionEn;

  @Supabase(name: 'sort_order')
  final int sortOrder;

  @Supabase(name: 'is_primary')
  final bool isPrimary;

  @Supabase(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @Supabase(name: 'card_thumbnail_url')
  final String? cardThumbnailUrl;

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
