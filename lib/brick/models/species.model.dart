import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'species'),
)
class Species extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  final int id;

  @Supabase(name: 'category_id')
  final int categoryId;

  @Supabase(name: 'common_name_es')
  final String commonNameEs;

  @Supabase(name: 'common_name_en')
  final String commonNameEn;

  @Supabase(name: 'scientific_name')
  final String scientificName;

  @Supabase(name: 'conservation_status')
  final String? conservationStatus;

  @Supabase(name: 'weight_kg', fromGenerator: "(data['weight_kg'] as num).toDouble()")
  final double? weightKg;

  @Supabase(name: 'size_cm', fromGenerator: "(data['size_cm'] as num).toDouble()")
  final double? sizeCm;

  @Supabase(name: 'population_estimate')
  final int? populationEstimate;

  @Supabase(name: 'lifespan_years')
  final int? lifespanYears;

  @Supabase(name: 'description_es')
  final String? descriptionEs;

  @Supabase(name: 'description_en')
  final String? descriptionEn;

  @Supabase(name: 'habitat_es')
  final String? habitatEs;

  @Supabase(name: 'habitat_en')
  final String? habitatEn;

  @Supabase(name: 'hero_image_url')
  final String? heroImageUrl;

  @Supabase(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @Supabase(name: 'is_endemic')
  final bool isEndemic;

  @Supabase(name: 'taxonomy_kingdom')
  final String? taxonomyKingdom;

  @Supabase(name: 'taxonomy_phylum')
  final String? taxonomyPhylum;

  @Supabase(name: 'taxonomy_class')
  final String? taxonomyClass;

  @Supabase(name: 'taxonomy_order')
  final String? taxonomyOrder;

  @Supabase(name: 'taxonomy_family')
  final String? taxonomyFamily;

  @Supabase(name: 'taxonomy_genus')
  final String? taxonomyGenus;

  // Endemismo
  @Supabase(name: 'is_native')
  final bool? isNative;

  @Supabase(name: 'is_introduced')
  final bool? isIntroduced;

  @Supabase(name: 'endemism_level')
  final String? endemismLevel;

  // Tendencia y Reproducción
  @Supabase(name: 'population_trend')
  final String? populationTrend;

  @Supabase(name: 'breeding_season')
  final String? breedingSeason;

  @Supabase(name: 'clutch_size')
  final String? clutchSize;

  @Supabase(name: 'reproductive_frequency')
  final String? reproductiveFrequency;

  // Comportamiento
  @Supabase(name: 'social_structure')
  final String? socialStructure;

  @Supabase(name: 'activity_pattern')
  final String? activityPattern;

  @Supabase(name: 'diet_type')
  final String? dietType;

  @Supabase(name: 'primary_food_sources')
  final List<String>? primaryFoodSources;

  // Rangos
  @Supabase(name: 'altitude_min_m')
  final int? altitudeMinM;

  @Supabase(name: 'altitude_max_m')
  final int? altitudeMaxM;

  @Supabase(name: 'depth_min_m')
  final int? depthMinM;

  @Supabase(name: 'depth_max_m')
  final int? depthMaxM;

  // Características
  @Supabase(name: 'scientific_name_authorship')
  final String? scientificNameAuthorship;

  @Supabase(name: 'distinguishing_features_es')
  final String? distinguishingFeaturesEs;

  @Supabase(name: 'distinguishing_features_en')
  final String? distinguishingFeaturesEn;

  @Supabase(name: 'sexual_dimorphism')
  final String? sexualDimorphism;

  // IDs externos
  @Supabase(name: 'gbif_taxon_id')
  final String? gbifTaxonId;

  @Supabase(name: 'eol_page_id')
  final String? eolPageId;

  @Supabase(name: 'iucn_assessment_url')
  final String? iucnAssessmentUrl;

  // Multimedia
  @Supabase(name: 'sound_recording_url')
  final String? soundRecordingUrl;

  @Supabase(name: 'video_url')
  final String? videoUrl;

  Species({
    required this.id,
    required this.categoryId,
    required this.commonNameEs,
    required this.commonNameEn,
    required this.scientificName,
    this.conservationStatus,
    this.weightKg,
    this.sizeCm,
    this.populationEstimate,
    this.lifespanYears,
    this.descriptionEs,
    this.descriptionEn,
    this.habitatEs,
    this.habitatEn,
    this.heroImageUrl,
    this.thumbnailUrl,
    this.isEndemic = false,
    this.taxonomyKingdom,
    this.taxonomyPhylum,
    this.taxonomyClass,
    this.taxonomyOrder,
    this.taxonomyFamily,
    this.taxonomyGenus,
    // Endemismo
    this.isNative,
    this.isIntroduced,
    this.endemismLevel,
    // Tendencia y Reproducción
    this.populationTrend,
    this.breedingSeason,
    this.clutchSize,
    this.reproductiveFrequency,
    // Comportamiento
    this.socialStructure,
    this.activityPattern,
    this.dietType,
    this.primaryFoodSources,
    // Rangos
    this.altitudeMinM,
    this.altitudeMaxM,
    this.depthMinM,
    this.depthMaxM,
    // Características
    this.scientificNameAuthorship,
    this.distinguishingFeaturesEs,
    this.distinguishingFeaturesEn,
    this.sexualDimorphism,
    // IDs externos
    this.gbifTaxonId,
    this.eolPageId,
    this.iucnAssessmentUrl,
    // Multimedia
    this.soundRecordingUrl,
    this.videoUrl,
  });
}
