// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Species> _$SpeciesFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Species(
    id: data['id'] as int,
    categoryId: data['category_id'] as int,
    commonNameEs: data['common_name_es'] as String,
    commonNameEn: data['common_name_en'] as String,
    scientificName: data['scientific_name'] as String,
    conservationStatus: data['conservation_status'] == null
        ? null
        : data['conservation_status'] as String?,
    weightKg: data['weight_kg'] == null
        ? null
        : (data['weight_kg'] as num).toDouble(),
    sizeCm: data['size_cm'] == null
        ? null
        : (data['size_cm'] as num).toDouble(),
    populationEstimate: data['population_estimate'] == null
        ? null
        : data['population_estimate'] as int?,
    lifespanYears: data['lifespan_years'] == null
        ? null
        : data['lifespan_years'] as int?,
    descriptionEs: data['description_es'] == null
        ? null
        : data['description_es'] as String?,
    descriptionEn: data['description_en'] == null
        ? null
        : data['description_en'] as String?,
    habitatEs: data['habitat_es'] == null
        ? null
        : data['habitat_es'] as String?,
    habitatEn: data['habitat_en'] == null
        ? null
        : data['habitat_en'] as String?,
    heroImageUrl: data['hero_image_url'] == null
        ? null
        : data['hero_image_url'] as String?,
    thumbnailUrl: data['thumbnail_url'] == null
        ? null
        : data['thumbnail_url'] as String?,
    isEndemic: data['is_endemic'] as bool,
    taxonomyKingdom: data['taxonomy_kingdom'] == null
        ? null
        : data['taxonomy_kingdom'] as String?,
    taxonomyPhylum: data['taxonomy_phylum'] == null
        ? null
        : data['taxonomy_phylum'] as String?,
    taxonomyClass: data['taxonomy_class'] == null
        ? null
        : data['taxonomy_class'] as String?,
    taxonomyOrder: data['taxonomy_order'] == null
        ? null
        : data['taxonomy_order'] as String?,
    taxonomyFamily: data['taxonomy_family'] == null
        ? null
        : data['taxonomy_family'] as String?,
    taxonomyGenus: data['taxonomy_genus'] == null
        ? null
        : data['taxonomy_genus'] as String?,
    isNative: data['is_native'] == null ? null : data['is_native'] as bool?,
    isIntroduced: data['is_introduced'] == null
        ? null
        : data['is_introduced'] as bool?,
    endemismLevel: data['endemism_level'] == null
        ? null
        : data['endemism_level'] as String?,
    populationTrend: data['population_trend'] == null
        ? null
        : data['population_trend'] as String?,
    breedingSeason: data['breeding_season'] == null
        ? null
        : data['breeding_season'] as String?,
    clutchSize: data['clutch_size'] == null
        ? null
        : data['clutch_size'] as String?,
    reproductiveFrequency: data['reproductive_frequency'] == null
        ? null
        : data['reproductive_frequency'] as String?,
    socialStructure: data['social_structure'] == null
        ? null
        : data['social_structure'] as String?,
    activityPattern: data['activity_pattern'] == null
        ? null
        : data['activity_pattern'] as String?,
    dietType: data['diet_type'] == null ? null : data['diet_type'] as String?,
    primaryFoodSources: data['primary_food_sources'] == null
        ? null
        : data['primary_food_sources']?.toList().cast<String>(),
    altitudeMinM: data['altitude_min_m'] == null
        ? null
        : data['altitude_min_m'] as int?,
    altitudeMaxM: data['altitude_max_m'] == null
        ? null
        : data['altitude_max_m'] as int?,
    depthMinM: data['depth_min_m'] == null ? null : data['depth_min_m'] as int?,
    depthMaxM: data['depth_max_m'] == null ? null : data['depth_max_m'] as int?,
    scientificNameAuthorship: data['scientific_name_authorship'] == null
        ? null
        : data['scientific_name_authorship'] as String?,
    distinguishingFeaturesEs: data['distinguishing_features_es'] == null
        ? null
        : data['distinguishing_features_es'] as String?,
    distinguishingFeaturesEn: data['distinguishing_features_en'] == null
        ? null
        : data['distinguishing_features_en'] as String?,
    sexualDimorphism: data['sexual_dimorphism'] == null
        ? null
        : data['sexual_dimorphism'] as String?,
    gbifTaxonId: data['gbif_taxon_id'] == null
        ? null
        : data['gbif_taxon_id'] as String?,
    eolPageId: data['eol_page_id'] == null
        ? null
        : data['eol_page_id'] as String?,
    iucnAssessmentUrl: data['iucn_assessment_url'] == null
        ? null
        : data['iucn_assessment_url'] as String?,
    soundRecordingUrl: data['sound_recording_url'] == null
        ? null
        : data['sound_recording_url'] as String?,
    videoUrl: data['video_url'] == null ? null : data['video_url'] as String?,
  );
}

Future<Map<String, dynamic>> _$SpeciesToSupabase(
  Species instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'category_id': instance.categoryId,
    'common_name_es': instance.commonNameEs,
    'common_name_en': instance.commonNameEn,
    'scientific_name': instance.scientificName,
    'conservation_status': instance.conservationStatus,
    'weight_kg': instance.weightKg,
    'size_cm': instance.sizeCm,
    'population_estimate': instance.populationEstimate,
    'lifespan_years': instance.lifespanYears,
    'description_es': instance.descriptionEs,
    'description_en': instance.descriptionEn,
    'habitat_es': instance.habitatEs,
    'habitat_en': instance.habitatEn,
    'hero_image_url': instance.heroImageUrl,
    'thumbnail_url': instance.thumbnailUrl,
    'is_endemic': instance.isEndemic,
    'taxonomy_kingdom': instance.taxonomyKingdom,
    'taxonomy_phylum': instance.taxonomyPhylum,
    'taxonomy_class': instance.taxonomyClass,
    'taxonomy_order': instance.taxonomyOrder,
    'taxonomy_family': instance.taxonomyFamily,
    'taxonomy_genus': instance.taxonomyGenus,
    'is_native': instance.isNative,
    'is_introduced': instance.isIntroduced,
    'endemism_level': instance.endemismLevel,
    'population_trend': instance.populationTrend,
    'breeding_season': instance.breedingSeason,
    'clutch_size': instance.clutchSize,
    'reproductive_frequency': instance.reproductiveFrequency,
    'social_structure': instance.socialStructure,
    'activity_pattern': instance.activityPattern,
    'diet_type': instance.dietType,
    'primary_food_sources': instance.primaryFoodSources,
    'altitude_min_m': instance.altitudeMinM,
    'altitude_max_m': instance.altitudeMaxM,
    'depth_min_m': instance.depthMinM,
    'depth_max_m': instance.depthMaxM,
    'scientific_name_authorship': instance.scientificNameAuthorship,
    'distinguishing_features_es': instance.distinguishingFeaturesEs,
    'distinguishing_features_en': instance.distinguishingFeaturesEn,
    'sexual_dimorphism': instance.sexualDimorphism,
    'gbif_taxon_id': instance.gbifTaxonId,
    'eol_page_id': instance.eolPageId,
    'iucn_assessment_url': instance.iucnAssessmentUrl,
    'sound_recording_url': instance.soundRecordingUrl,
    'video_url': instance.videoUrl,
  };
}

Future<Species> _$SpeciesFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Species(
    id: data['id'] as int,
    categoryId: data['category_id'] as int,
    commonNameEs: data['common_name_es'] as String,
    commonNameEn: data['common_name_en'] as String,
    scientificName: data['scientific_name'] as String,
    conservationStatus: data['conservation_status'] == null
        ? null
        : data['conservation_status'] as String?,
    weightKg: data['weight_kg'] == null ? null : (data['weight_kg'] as num).toDouble(),
    sizeCm: data['size_cm'] == null ? null : (data['size_cm'] as num).toDouble(),
    populationEstimate: data['population_estimate'] == null
        ? null
        : data['population_estimate'] as int?,
    lifespanYears: data['lifespan_years'] == null
        ? null
        : data['lifespan_years'] as int?,
    descriptionEs: data['description_es'] == null
        ? null
        : data['description_es'] as String?,
    descriptionEn: data['description_en'] == null
        ? null
        : data['description_en'] as String?,
    habitatEs: data['habitat_es'] == null
        ? null
        : data['habitat_es'] as String?,
    habitatEn: data['habitat_en'] == null
        ? null
        : data['habitat_en'] as String?,
    heroImageUrl: data['hero_image_url'] == null
        ? null
        : data['hero_image_url'] as String?,
    thumbnailUrl: data['thumbnail_url'] == null
        ? null
        : data['thumbnail_url'] as String?,
    isEndemic: data['is_endemic'] == 1,
    taxonomyKingdom: data['taxonomy_kingdom'] == null
        ? null
        : data['taxonomy_kingdom'] as String?,
    taxonomyPhylum: data['taxonomy_phylum'] == null
        ? null
        : data['taxonomy_phylum'] as String?,
    taxonomyClass: data['taxonomy_class'] == null
        ? null
        : data['taxonomy_class'] as String?,
    taxonomyOrder: data['taxonomy_order'] == null
        ? null
        : data['taxonomy_order'] as String?,
    taxonomyFamily: data['taxonomy_family'] == null
        ? null
        : data['taxonomy_family'] as String?,
    taxonomyGenus: data['taxonomy_genus'] == null
        ? null
        : data['taxonomy_genus'] as String?,
    isNative: data['is_native'] == null ? null : data['is_native'] == 1,
    isIntroduced: data['is_introduced'] == null
        ? null
        : data['is_introduced'] == 1,
    endemismLevel: data['endemism_level'] == null
        ? null
        : data['endemism_level'] as String?,
    populationTrend: data['population_trend'] == null
        ? null
        : data['population_trend'] as String?,
    breedingSeason: data['breeding_season'] == null
        ? null
        : data['breeding_season'] as String?,
    clutchSize: data['clutch_size'] == null
        ? null
        : data['clutch_size'] as String?,
    reproductiveFrequency: data['reproductive_frequency'] == null
        ? null
        : data['reproductive_frequency'] as String?,
    socialStructure: data['social_structure'] == null
        ? null
        : data['social_structure'] as String?,
    activityPattern: data['activity_pattern'] == null
        ? null
        : data['activity_pattern'] as String?,
    dietType: data['diet_type'] == null ? null : data['diet_type'] as String?,
    primaryFoodSources: data['primary_food_sources'] == null
        ? null
        : jsonDecode(data['primary_food_sources']).toList().cast<String>(),
    altitudeMinM: data['altitude_min_m'] == null
        ? null
        : data['altitude_min_m'] as int?,
    altitudeMaxM: data['altitude_max_m'] == null
        ? null
        : data['altitude_max_m'] as int?,
    depthMinM: data['depth_min_m'] == null ? null : data['depth_min_m'] as int?,
    depthMaxM: data['depth_max_m'] == null ? null : data['depth_max_m'] as int?,
    scientificNameAuthorship: data['scientific_name_authorship'] == null
        ? null
        : data['scientific_name_authorship'] as String?,
    distinguishingFeaturesEs: data['distinguishing_features_es'] == null
        ? null
        : data['distinguishing_features_es'] as String?,
    distinguishingFeaturesEn: data['distinguishing_features_en'] == null
        ? null
        : data['distinguishing_features_en'] as String?,
    sexualDimorphism: data['sexual_dimorphism'] == null
        ? null
        : data['sexual_dimorphism'] as String?,
    gbifTaxonId: data['gbif_taxon_id'] == null
        ? null
        : data['gbif_taxon_id'] as String?,
    eolPageId: data['eol_page_id'] == null
        ? null
        : data['eol_page_id'] as String?,
    iucnAssessmentUrl: data['iucn_assessment_url'] == null
        ? null
        : data['iucn_assessment_url'] as String?,
    soundRecordingUrl: data['sound_recording_url'] == null
        ? null
        : data['sound_recording_url'] as String?,
    videoUrl: data['video_url'] == null ? null : data['video_url'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SpeciesToSqlite(
  Species instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'category_id': instance.categoryId,
    'common_name_es': instance.commonNameEs,
    'common_name_en': instance.commonNameEn,
    'scientific_name': instance.scientificName,
    'conservation_status': instance.conservationStatus,
    'weight_kg': instance.weightKg,
    'size_cm': instance.sizeCm,
    'population_estimate': instance.populationEstimate,
    'lifespan_years': instance.lifespanYears,
    'description_es': instance.descriptionEs,
    'description_en': instance.descriptionEn,
    'habitat_es': instance.habitatEs,
    'habitat_en': instance.habitatEn,
    'hero_image_url': instance.heroImageUrl,
    'thumbnail_url': instance.thumbnailUrl,
    'is_endemic': instance.isEndemic ? 1 : 0,
    'taxonomy_kingdom': instance.taxonomyKingdom,
    'taxonomy_phylum': instance.taxonomyPhylum,
    'taxonomy_class': instance.taxonomyClass,
    'taxonomy_order': instance.taxonomyOrder,
    'taxonomy_family': instance.taxonomyFamily,
    'taxonomy_genus': instance.taxonomyGenus,
    'is_native': instance.isNative == null
        ? null
        : (instance.isNative! ? 1 : 0),
    'is_introduced': instance.isIntroduced == null
        ? null
        : (instance.isIntroduced! ? 1 : 0),
    'endemism_level': instance.endemismLevel,
    'population_trend': instance.populationTrend,
    'breeding_season': instance.breedingSeason,
    'clutch_size': instance.clutchSize,
    'reproductive_frequency': instance.reproductiveFrequency,
    'social_structure': instance.socialStructure,
    'activity_pattern': instance.activityPattern,
    'diet_type': instance.dietType,
    'primary_food_sources': instance.primaryFoodSources == null
        ? null
        : jsonEncode(instance.primaryFoodSources),
    'altitude_min_m': instance.altitudeMinM,
    'altitude_max_m': instance.altitudeMaxM,
    'depth_min_m': instance.depthMinM,
    'depth_max_m': instance.depthMaxM,
    'scientific_name_authorship': instance.scientificNameAuthorship,
    'distinguishing_features_es': instance.distinguishingFeaturesEs,
    'distinguishing_features_en': instance.distinguishingFeaturesEn,
    'sexual_dimorphism': instance.sexualDimorphism,
    'gbif_taxon_id': instance.gbifTaxonId,
    'eol_page_id': instance.eolPageId,
    'iucn_assessment_url': instance.iucnAssessmentUrl,
    'sound_recording_url': instance.soundRecordingUrl,
    'video_url': instance.videoUrl,
  };
}

/// Construct a [Species]
class SpeciesAdapter extends OfflineFirstWithSupabaseAdapter<Species> {
  SpeciesAdapter();

  @override
  final supabaseTableName = 'species';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'categoryId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'category_id',
    ),
    'commonNameEs': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'common_name_es',
    ),
    'commonNameEn': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'common_name_en',
    ),
    'scientificName': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'scientific_name',
    ),
    'conservationStatus': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'conservation_status',
    ),
    'weightKg': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'weight_kg',
    ),
    'sizeCm': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'size_cm',
    ),
    'populationEstimate': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'population_estimate',
    ),
    'lifespanYears': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'lifespan_years',
    ),
    'descriptionEs': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'description_es',
    ),
    'descriptionEn': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'description_en',
    ),
    'habitatEs': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'habitat_es',
    ),
    'habitatEn': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'habitat_en',
    ),
    'heroImageUrl': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'hero_image_url',
    ),
    'thumbnailUrl': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'thumbnail_url',
    ),
    'isEndemic': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'is_endemic',
    ),
    'taxonomyKingdom': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'taxonomy_kingdom',
    ),
    'taxonomyPhylum': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'taxonomy_phylum',
    ),
    'taxonomyClass': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'taxonomy_class',
    ),
    'taxonomyOrder': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'taxonomy_order',
    ),
    'taxonomyFamily': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'taxonomy_family',
    ),
    'taxonomyGenus': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'taxonomy_genus',
    ),
    'isNative': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'is_native',
    ),
    'isIntroduced': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'is_introduced',
    ),
    'endemismLevel': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'endemism_level',
    ),
    'populationTrend': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'population_trend',
    ),
    'breedingSeason': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'breeding_season',
    ),
    'clutchSize': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'clutch_size',
    ),
    'reproductiveFrequency': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'reproductive_frequency',
    ),
    'socialStructure': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'social_structure',
    ),
    'activityPattern': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'activity_pattern',
    ),
    'dietType': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'diet_type',
    ),
    'primaryFoodSources': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'primary_food_sources',
    ),
    'altitudeMinM': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'altitude_min_m',
    ),
    'altitudeMaxM': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'altitude_max_m',
    ),
    'depthMinM': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'depth_min_m',
    ),
    'depthMaxM': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'depth_max_m',
    ),
    'scientificNameAuthorship': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'scientific_name_authorship',
    ),
    'distinguishingFeaturesEs': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'distinguishing_features_es',
    ),
    'distinguishingFeaturesEn': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'distinguishing_features_en',
    ),
    'sexualDimorphism': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'sexual_dimorphism',
    ),
    'gbifTaxonId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'gbif_taxon_id',
    ),
    'eolPageId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'eol_page_id',
    ),
    'iucnAssessmentUrl': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'iucn_assessment_url',
    ),
    'soundRecordingUrl': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'sound_recording_url',
    ),
    'videoUrl': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'video_url',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'id'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'id': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'id',
      iterable: false,
      type: int,
    ),
    'categoryId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'category_id',
      iterable: false,
      type: int,
    ),
    'commonNameEs': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'common_name_es',
      iterable: false,
      type: String,
    ),
    'commonNameEn': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'common_name_en',
      iterable: false,
      type: String,
    ),
    'scientificName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'scientific_name',
      iterable: false,
      type: String,
    ),
    'conservationStatus': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'conservation_status',
      iterable: false,
      type: String,
    ),
    'weightKg': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'weight_kg',
      iterable: false,
      type: double,
    ),
    'sizeCm': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'size_cm',
      iterable: false,
      type: double,
    ),
    'populationEstimate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'population_estimate',
      iterable: false,
      type: int,
    ),
    'lifespanYears': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'lifespan_years',
      iterable: false,
      type: int,
    ),
    'descriptionEs': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'description_es',
      iterable: false,
      type: String,
    ),
    'descriptionEn': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'description_en',
      iterable: false,
      type: String,
    ),
    'habitatEs': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'habitat_es',
      iterable: false,
      type: String,
    ),
    'habitatEn': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'habitat_en',
      iterable: false,
      type: String,
    ),
    'heroImageUrl': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'hero_image_url',
      iterable: false,
      type: String,
    ),
    'thumbnailUrl': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'thumbnail_url',
      iterable: false,
      type: String,
    ),
    'isEndemic': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_endemic',
      iterable: false,
      type: bool,
    ),
    'taxonomyKingdom': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'taxonomy_kingdom',
      iterable: false,
      type: String,
    ),
    'taxonomyPhylum': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'taxonomy_phylum',
      iterable: false,
      type: String,
    ),
    'taxonomyClass': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'taxonomy_class',
      iterable: false,
      type: String,
    ),
    'taxonomyOrder': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'taxonomy_order',
      iterable: false,
      type: String,
    ),
    'taxonomyFamily': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'taxonomy_family',
      iterable: false,
      type: String,
    ),
    'taxonomyGenus': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'taxonomy_genus',
      iterable: false,
      type: String,
    ),
    'isNative': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_native',
      iterable: false,
      type: bool,
    ),
    'isIntroduced': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_introduced',
      iterable: false,
      type: bool,
    ),
    'endemismLevel': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'endemism_level',
      iterable: false,
      type: String,
    ),
    'populationTrend': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'population_trend',
      iterable: false,
      type: String,
    ),
    'breedingSeason': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'breeding_season',
      iterable: false,
      type: String,
    ),
    'clutchSize': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'clutch_size',
      iterable: false,
      type: String,
    ),
    'reproductiveFrequency': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'reproductive_frequency',
      iterable: false,
      type: String,
    ),
    'socialStructure': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'social_structure',
      iterable: false,
      type: String,
    ),
    'activityPattern': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'activity_pattern',
      iterable: false,
      type: String,
    ),
    'dietType': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'diet_type',
      iterable: false,
      type: String,
    ),
    'primaryFoodSources': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'primary_food_sources',
      iterable: true,
      type: String,
    ),
    'altitudeMinM': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'altitude_min_m',
      iterable: false,
      type: int,
    ),
    'altitudeMaxM': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'altitude_max_m',
      iterable: false,
      type: int,
    ),
    'depthMinM': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'depth_min_m',
      iterable: false,
      type: int,
    ),
    'depthMaxM': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'depth_max_m',
      iterable: false,
      type: int,
    ),
    'scientificNameAuthorship': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'scientific_name_authorship',
      iterable: false,
      type: String,
    ),
    'distinguishingFeaturesEs': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'distinguishing_features_es',
      iterable: false,
      type: String,
    ),
    'distinguishingFeaturesEn': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'distinguishing_features_en',
      iterable: false,
      type: String,
    ),
    'sexualDimorphism': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sexual_dimorphism',
      iterable: false,
      type: String,
    ),
    'gbifTaxonId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'gbif_taxon_id',
      iterable: false,
      type: String,
    ),
    'eolPageId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'eol_page_id',
      iterable: false,
      type: String,
    ),
    'iucnAssessmentUrl': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'iucn_assessment_url',
      iterable: false,
      type: String,
    ),
    'soundRecordingUrl': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sound_recording_url',
      iterable: false,
      type: String,
    ),
    'videoUrl': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'video_url',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    Species instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'Species';

  @override
  Future<Species> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    Species input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Species> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    Species input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SpeciesToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
