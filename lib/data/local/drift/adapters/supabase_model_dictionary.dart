// ignore_for_file: lines_longer_than_80_chars
/// Hand-written Supabase adapters and model dictionary for the wildlife app.
///
/// In a fully generated setup these would be produced by
/// `drift_offline_first_with_supabase_build`. Since the models are simple
/// (no associations) we write them by hand to avoid the build complexity.
library;

import 'package:drift_supabase/drift_supabase.dart';

import '../../../../models/category.model.dart';
import '../../../../models/island.model.dart';
import '../../../../models/sighting.model.dart';
import '../../../../models/species.model.dart';
import '../../../../models/species_image.model.dart';
import '../../../../models/species_reference.model.dart';
import '../../../../models/species_site.model.dart';
import '../../../../models/species_threat.model.dart';
import '../../../../models/trail.model.dart';
import '../../../../models/user_favorite.model.dart';
import '../../../../models/user_profile.model.dart';
import '../../../../models/user_site_wishlist.model.dart';
import '../../../../models/user_species_checklist.model.dart';
import '../../../../models/visit_site.model.dart';

// ---------------------------------------------------------------------------
// Column helper — shorthand for non-association columns.
// ---------------------------------------------------------------------------

RuntimeSupabaseColumnDefinition _col(String name) =>
    RuntimeSupabaseColumnDefinition(association: false, columnName: name);

// ---------------------------------------------------------------------------
// Category
// ---------------------------------------------------------------------------

class CategoryAdapter extends SupabaseAdapter<Category> {
  @override
  String get supabaseTableName => 'categories';

  @override
  Set<String> get uniqueFields => {'id'};

  @override
  bool get defaultToNull => false;

  @override
  bool get ignoreDuplicates => false;

  @override
  Map<String, RuntimeSupabaseColumnDefinition> get fieldsToSupabaseColumns => {
        'id': _col('id'),
        'slug': _col('slug'),
        'nameEs': _col('name_es'),
        'nameEn': _col('name_en'),
        'iconName': _col('icon_name'),
        'sortOrder': _col('sort_order'),
      };

  @override
  Future<Category> fromSupabase(
    Map<String, dynamic> data, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      Category(
        id: data['id'] as int,
        slug: data['slug'] as String,
        nameEs: data['name_es'] as String,
        nameEn: data['name_en'] as String,
        iconName: data['icon_name'] as String?,
        sortOrder: (data['sort_order'] as int?) ?? 0,
      );

  @override
  Future<Map<String, dynamic>> toSupabase(
    Category instance, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      {
        'id': instance.id,
        'slug': instance.slug,
        'name_es': instance.nameEs,
        'name_en': instance.nameEn,
        'icon_name': instance.iconName,
        'sort_order': instance.sortOrder,
      };
}

// ---------------------------------------------------------------------------
// Island
// ---------------------------------------------------------------------------

class IslandAdapter extends SupabaseAdapter<Island> {
  @override
  String get supabaseTableName => 'islands';

  @override
  Set<String> get uniqueFields => {'id'};

  @override
  bool get defaultToNull => false;

  @override
  bool get ignoreDuplicates => false;

  @override
  Map<String, RuntimeSupabaseColumnDefinition> get fieldsToSupabaseColumns => {
        'id': _col('id'),
        'nameEs': _col('name_es'),
        'nameEn': _col('name_en'),
        'latitude': _col('latitude'),
        'longitude': _col('longitude'),
        'areaKm2': _col('area_km2'),
        'areaHa': _col('area_ha'),
        'descriptionEs': _col('description_es'),
        'descriptionEn': _col('description_en'),
        'parkId': _col('park_id'),
        'islandType': _col('island_type'),
        'classification': _col('classification'),
        'isPopulated': _col('is_populated'),
      };

  @override
  Future<Island> fromSupabase(
    Map<String, dynamic> data, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      Island(
        id: data['id'] as int,
        nameEs: data['name_es'] as String,
        nameEn: data['name_en'] as String,
        latitude: (data['latitude'] as num?)?.toDouble(),
        longitude: (data['longitude'] as num?)?.toDouble(),
        areaKm2: (data['area_km2'] as num?)?.toDouble(),
        areaHa: (data['area_ha'] as num?)?.toDouble(),
        descriptionEs: data['description_es'] as String?,
        descriptionEn: data['description_en'] as String?,
        parkId: data['park_id'] as String?,
        islandType: data['island_type'] as String?,
        classification: data['classification'] as String?,
        isPopulated: data['is_populated'] as bool?,
      );

  @override
  Future<Map<String, dynamic>> toSupabase(
    Island instance, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      {
        'id': instance.id,
        'name_es': instance.nameEs,
        'name_en': instance.nameEn,
        'latitude': instance.latitude,
        'longitude': instance.longitude,
        'area_km2': instance.areaKm2,
        'area_ha': instance.areaHa,
        'description_es': instance.descriptionEs,
        'description_en': instance.descriptionEn,
        'park_id': instance.parkId,
        'island_type': instance.islandType,
        'classification': instance.classification,
        'is_populated': instance.isPopulated,
      };
}

// ---------------------------------------------------------------------------
// Species
// ---------------------------------------------------------------------------

class SpeciesAdapter extends SupabaseAdapter<Species> {
  @override
  String get supabaseTableName => 'species';

  @override
  Set<String> get uniqueFields => {'id'};

  @override
  bool get defaultToNull => false;

  @override
  bool get ignoreDuplicates => false;

  @override
  Map<String, RuntimeSupabaseColumnDefinition> get fieldsToSupabaseColumns => {
        'id': _col('id'),
        'categoryId': _col('category_id'),
        'commonNameEs': _col('common_name_es'),
        'commonNameEn': _col('common_name_en'),
        'scientificName': _col('scientific_name'),
        'conservationStatus': _col('conservation_status'),
        'weightKg': _col('weight_kg'),
        'sizeCm': _col('size_cm'),
        'populationEstimate': _col('population_estimate'),
        'lifespanYears': _col('lifespan_years'),
        'descriptionEs': _col('description_es'),
        'descriptionEn': _col('description_en'),
        'habitatEs': _col('habitat_es'),
        'habitatEn': _col('habitat_en'),
        'heroImageUrl': _col('hero_image_url'),
        'thumbnailUrl': _col('thumbnail_url'),
        'isEndemic': _col('is_endemic'),
        'taxonomyKingdom': _col('taxonomy_kingdom'),
        'taxonomyPhylum': _col('taxonomy_phylum'),
        'taxonomyClass': _col('taxonomy_class'),
        'taxonomyOrder': _col('taxonomy_order'),
        'taxonomyFamily': _col('taxonomy_family'),
        'taxonomyGenus': _col('taxonomy_genus'),
        'isNative': _col('is_native'),
        'isIntroduced': _col('is_introduced'),
        'endemismLevel': _col('endemism_level'),
        'populationTrend': _col('population_trend'),
        'breedingSeason': _col('breeding_season'),
        'clutchSize': _col('clutch_size'),
        'reproductiveFrequency': _col('reproductive_frequency'),
        'socialStructure': _col('social_structure'),
        'activityPattern': _col('activity_pattern'),
        'dietType': _col('diet_type'),
        'primaryFoodSources': _col('primary_food_sources'),
        'altitudeMinM': _col('altitude_min_m'),
        'altitudeMaxM': _col('altitude_max_m'),
        'depthMinM': _col('depth_min_m'),
        'depthMaxM': _col('depth_max_m'),
        'scientificNameAuthorship': _col('scientific_name_authorship'),
        'distinguishingFeaturesEs': _col('distinguishing_features_es'),
        'distinguishingFeaturesEn': _col('distinguishing_features_en'),
        'sexualDimorphism': _col('sexual_dimorphism'),
        'gbifTaxonId': _col('gbif_taxon_id'),
        'eolPageId': _col('eol_page_id'),
        'iucnAssessmentUrl': _col('iucn_assessment_url'),
        'soundRecordingUrl': _col('sound_recording_url'),
        'videoUrl': _col('video_url'),
        'sizeMmFemaleMin': _col('size_mm_female_min'),
        'sizeMmFemaleMax': _col('size_mm_female_max'),
        'sizeMmMaleMin': _col('size_mm_male_min'),
        'sizeMmMaleMax': _col('size_mm_male_max'),
        'buildsWeb': _col('builds_web'),
        'webType': _col('web_type'),
        'venomousToHumans': _col('venomous_to_humans'),
        'inaturalistTaxonId': _col('inaturalist_taxon_id'),
        'datazoneId': _col('datazone_id'),
      };

  @override
  Future<Species> fromSupabase(
    Map<String, dynamic> data, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      Species(
        id: data['id'] as int,
        categoryId: data['category_id'] as int,
        commonNameEs: data['common_name_es'] as String,
        commonNameEn: data['common_name_en'] as String,
        scientificName: data['scientific_name'] as String,
        conservationStatus: data['conservation_status'] as String?,
        weightKg: (data['weight_kg'] as num?)?.toDouble(),
        sizeCm: (data['size_cm'] as num?)?.toDouble(),
        populationEstimate: data['population_estimate'] as int?,
        lifespanYears: data['lifespan_years'] as int?,
        descriptionEs: data['description_es'] as String?,
        descriptionEn: data['description_en'] as String?,
        habitatEs: data['habitat_es'] as String?,
        habitatEn: data['habitat_en'] as String?,
        heroImageUrl: data['hero_image_url'] as String?,
        thumbnailUrl: data['thumbnail_url'] as String?,
        isEndemic: (data['is_endemic'] as bool?) ?? false,
        taxonomyKingdom: data['taxonomy_kingdom'] as String?,
        taxonomyPhylum: data['taxonomy_phylum'] as String?,
        taxonomyClass: data['taxonomy_class'] as String?,
        taxonomyOrder: data['taxonomy_order'] as String?,
        taxonomyFamily: data['taxonomy_family'] as String?,
        taxonomyGenus: data['taxonomy_genus'] as String?,
        isNative: data['is_native'] as bool?,
        isIntroduced: data['is_introduced'] as bool?,
        endemismLevel: data['endemism_level'] as String?,
        populationTrend: data['population_trend'] as String?,
        breedingSeason: data['breeding_season'] as String?,
        clutchSize: data['clutch_size'] as String?,
        reproductiveFrequency: data['reproductive_frequency'] as String?,
        socialStructure: data['social_structure'] as String?,
        activityPattern: data['activity_pattern'] as String?,
        dietType: data['diet_type'] as String?,
        primaryFoodSources: (data['primary_food_sources'] as List?)?.cast<String>(),
        altitudeMinM: data['altitude_min_m'] as int?,
        altitudeMaxM: data['altitude_max_m'] as int?,
        depthMinM: data['depth_min_m'] as int?,
        depthMaxM: data['depth_max_m'] as int?,
        scientificNameAuthorship: data['scientific_name_authorship'] as String?,
        distinguishingFeaturesEs: data['distinguishing_features_es'] as String?,
        distinguishingFeaturesEn: data['distinguishing_features_en'] as String?,
        sexualDimorphism: data['sexual_dimorphism'] as String?,
        gbifTaxonId: data['gbif_taxon_id'] as String?,
        eolPageId: data['eol_page_id'] as String?,
        iucnAssessmentUrl: data['iucn_assessment_url'] as String?,
        soundRecordingUrl: data['sound_recording_url'] as String?,
        videoUrl: data['video_url'] as String?,
        sizeMmFemaleMin: (data['size_mm_female_min'] as num?)?.toDouble(),
        sizeMmFemaleMax: (data['size_mm_female_max'] as num?)?.toDouble(),
        sizeMmMaleMin: (data['size_mm_male_min'] as num?)?.toDouble(),
        sizeMmMaleMax: (data['size_mm_male_max'] as num?)?.toDouble(),
        buildsWeb: data['builds_web'] as bool?,
        webType: data['web_type'] as String?,
        venomousToHumans: data['venomous_to_humans'] as bool?,
        inaturalistTaxonId: data['inaturalist_taxon_id'] is int
            ? data['inaturalist_taxon_id'] as int?
            : int.tryParse(data['inaturalist_taxon_id'] as String? ?? ''),
        datazoneId: data['datazone_id'] is int
            ? data['datazone_id'] as int?
            : int.tryParse(data['datazone_id'] as String? ?? ''),
      );

  @override
  Future<Map<String, dynamic>> toSupabase(
    Species instance, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      {
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
        'size_mm_female_min': instance.sizeMmFemaleMin,
        'size_mm_female_max': instance.sizeMmFemaleMax,
        'size_mm_male_min': instance.sizeMmMaleMin,
        'size_mm_male_max': instance.sizeMmMaleMax,
        'builds_web': instance.buildsWeb,
        'web_type': instance.webType,
        'venomous_to_humans': instance.venomousToHumans,
        'inaturalist_taxon_id': instance.inaturalistTaxonId,
        'datazone_id': instance.datazoneId,
      };
}

// ---------------------------------------------------------------------------
// Sighting
// ---------------------------------------------------------------------------

class SightingAdapter extends SupabaseAdapter<Sighting> {
  @override
  String get supabaseTableName => 'sightings';

  @override
  Set<String> get uniqueFields => {'id'};

  @override
  bool get defaultToNull => false;

  @override
  bool get ignoreDuplicates => false;

  @override
  Map<String, RuntimeSupabaseColumnDefinition> get fieldsToSupabaseColumns => {
        'id': _col('id'),
        'userId': _col('user_id'),
        'speciesId': _col('species_id'),
        'visitSiteId': _col('visit_site_id'),
        'observedAt': _col('observed_at'),
        'notes': _col('notes'),
        'latitude': _col('latitude'),
        'longitude': _col('longitude'),
        'photoUrl': _col('photo_url'),
      };

  @override
  Future<Sighting> fromSupabase(
    Map<String, dynamic> data, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      Sighting(
        id: data['id'] as int,
        userId: data['user_id'] as String,
        speciesId: data['species_id'] as int,
        visitSiteId: data['visit_site_id'] as int?,
        observedAt: data['observed_at'] != null
            ? DateTime.parse(data['observed_at'] as String)
            : null,
        notes: data['notes'] as String?,
        latitude: (data['latitude'] as num?)?.toDouble(),
        longitude: (data['longitude'] as num?)?.toDouble(),
        photoUrl: data['photo_url'] as String?,
      );

  @override
  Future<Map<String, dynamic>> toSupabase(
    Sighting instance, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      {
        'id': instance.id,
        'user_id': instance.userId,
        'species_id': instance.speciesId,
        'visit_site_id': instance.visitSiteId,
        'observed_at': instance.observedAt?.toIso8601String(),
        'notes': instance.notes,
        'latitude': instance.latitude,
        'longitude': instance.longitude,
        'photo_url': instance.photoUrl,
      };
}

// ---------------------------------------------------------------------------
// SpeciesImage
// ---------------------------------------------------------------------------

class SpeciesImageAdapter extends SupabaseAdapter<SpeciesImage> {
  @override
  String get supabaseTableName => 'species_images';

  @override
  Set<String> get uniqueFields => {'id'};

  @override
  bool get defaultToNull => false;

  @override
  bool get ignoreDuplicates => false;

  @override
  Map<String, RuntimeSupabaseColumnDefinition> get fieldsToSupabaseColumns => {
        'id': _col('id'),
        'speciesId': _col('species_id'),
        'imageUrl': _col('image_url'),
        'captionEs': _col('caption_es'),
        'captionEn': _col('caption_en'),
        'sortOrder': _col('sort_order'),
        'isPrimary': _col('is_primary'),
        'thumbnailUrl': _col('thumbnail_url'),
        'cardThumbnailUrl': _col('card_thumbnail_url'),
      };

  @override
  Future<SpeciesImage> fromSupabase(
    Map<String, dynamic> data, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      SpeciesImage(
        id: data['id'] as int,
        speciesId: data['species_id'] as int,
        imageUrl: data['image_url'] as String,
        captionEs: data['caption_es'] as String?,
        captionEn: data['caption_en'] as String?,
        sortOrder: (data['sort_order'] as int?) ?? 0,
        isPrimary: (data['is_primary'] as bool?) ?? false,
        thumbnailUrl: data['thumbnail_url'] as String?,
        cardThumbnailUrl: data['card_thumbnail_url'] as String?,
      );

  @override
  Future<Map<String, dynamic>> toSupabase(
    SpeciesImage instance, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      {
        'id': instance.id,
        'species_id': instance.speciesId,
        'image_url': instance.imageUrl,
        'caption_es': instance.captionEs,
        'caption_en': instance.captionEn,
        'sort_order': instance.sortOrder,
        'is_primary': instance.isPrimary,
        'thumbnail_url': instance.thumbnailUrl,
        'card_thumbnail_url': instance.cardThumbnailUrl,
      };
}

// ---------------------------------------------------------------------------
// SpeciesReference
// ---------------------------------------------------------------------------

class SpeciesReferenceAdapter extends SupabaseAdapter<SpeciesReference> {
  @override
  String get supabaseTableName => 'species_references';

  @override
  Set<String> get uniqueFields => {'id'};

  @override
  bool get defaultToNull => false;

  @override
  bool get ignoreDuplicates => false;

  @override
  Map<String, RuntimeSupabaseColumnDefinition> get fieldsToSupabaseColumns => {
        'id': _col('id'),
        'speciesId': _col('species_id'),
        'citation': _col('citation'),
        'url': _col('url'),
        'doi': _col('doi'),
        'referenceType': _col('reference_type'),
      };

  @override
  Future<SpeciesReference> fromSupabase(
    Map<String, dynamic> data, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      SpeciesReference(
        id: data['id'] as int,
        speciesId: data['species_id'] as int,
        citation: (data['citation'] as String?) ?? '',
        url: data['url'] as String?,
        doi: data['doi'] as String?,
        referenceType: data['reference_type'] as String?,
      );

  @override
  Future<Map<String, dynamic>> toSupabase(
    SpeciesReference instance, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      {
        'id': instance.id,
        'species_id': instance.speciesId,
        'citation': instance.citation,
        'url': instance.url,
        'doi': instance.doi,
        'reference_type': instance.referenceType,
      };
}

// ---------------------------------------------------------------------------
// SpeciesSite
// ---------------------------------------------------------------------------

class SpeciesSiteAdapter extends SupabaseAdapter<SpeciesSite> {
  @override
  String get supabaseTableName => 'species_sites';

  @override
  Set<String> get uniqueFields => {'id'};

  @override
  bool get defaultToNull => false;

  @override
  bool get ignoreDuplicates => false;

  @override
  Map<String, RuntimeSupabaseColumnDefinition> get fieldsToSupabaseColumns => {
        'id': _col('id'),
        'speciesId': _col('species_id'),
        'visitSiteId': _col('visit_site_id'),
        'frequency': _col('frequency'),
      };

  @override
  Future<SpeciesSite> fromSupabase(
    Map<String, dynamic> data, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      SpeciesSite(
        id: data['id'] as int,
        speciesId: data['species_id'] as int,
        visitSiteId: data['visit_site_id'] as int,
        frequency: data['frequency'] as String?,
      );

  @override
  Future<Map<String, dynamic>> toSupabase(
    SpeciesSite instance, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      {
        'id': instance.id,
        'species_id': instance.speciesId,
        'visit_site_id': instance.visitSiteId,
        'frequency': instance.frequency,
      };
}

// ---------------------------------------------------------------------------
// SpeciesThreat
// ---------------------------------------------------------------------------

class SpeciesThreatAdapter extends SupabaseAdapter<SpeciesThreat> {
  @override
  String get supabaseTableName => 'species_threats';

  @override
  Set<String> get uniqueFields => {'id'};

  @override
  bool get defaultToNull => false;

  @override
  bool get ignoreDuplicates => false;

  @override
  Map<String, RuntimeSupabaseColumnDefinition> get fieldsToSupabaseColumns => {
        'id': _col('id'),
        'speciesId': _col('species_id'),
        'threatType': _col('threat_category'),
        'severity': _col('severity'),
        'descriptionEs': _col('description_es'),
        'descriptionEn': _col('description_en'),
      };

  @override
  Future<SpeciesThreat> fromSupabase(
    Map<String, dynamic> data, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      SpeciesThreat(
        id: data['id'] as int,
        speciesId: data['species_id'] as int,
        threatType: (data['threat_category'] as String?) ?? '',
        severity: data['severity'] as String?,
        descriptionEs: data['description_es'] as String?,
        descriptionEn: data['description_en'] as String?,
      );

  @override
  Future<Map<String, dynamic>> toSupabase(
    SpeciesThreat instance, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      {
        'id': instance.id,
        'species_id': instance.speciesId,
        'threat_category': instance.threatType,
        'severity': instance.severity,
        'description_es': instance.descriptionEs,
        'description_en': instance.descriptionEn,
      };
}

// ---------------------------------------------------------------------------
// Trail
// ---------------------------------------------------------------------------

class TrailAdapter extends SupabaseAdapter<Trail> {
  @override
  String get supabaseTableName => 'trails';

  @override
  Set<String> get uniqueFields => {'id'};

  @override
  bool get defaultToNull => false;

  @override
  bool get ignoreDuplicates => false;

  @override
  Map<String, RuntimeSupabaseColumnDefinition> get fieldsToSupabaseColumns => {
        'id': _col('id'),
        'nameEn': _col('name_en'),
        'nameEs': _col('name_es'),
        'descriptionEn': _col('description_en'),
        'descriptionEs': _col('description_es'),
        'islandId': _col('island_id'),
        'visitSiteId': _col('visit_site_id'),
        'difficulty': _col('difficulty'),
        'distanceKm': _col('distance_km'),
        'estimatedMinutes': _col('estimated_minutes'),
        'coordinates': _col('coordinates'),
        'elevationGainM': _col('elevation_gain_m'),
        'userId': _col('user_id'),
      };

  @override
  Future<Trail> fromSupabase(
    Map<String, dynamic> data, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      Trail(
        id: data['id'] as int,
        nameEn: (data['name_en'] as String?) ?? '',
        nameEs: (data['name_es'] as String?) ?? '',
        descriptionEn: data['description_en'] as String?,
        descriptionEs: data['description_es'] as String?,
        islandId: data['island_id'] as int?,
        visitSiteId: data['visit_site_id'] as int?,
        difficulty: data['difficulty'] as String?,
        distanceKm: (data['distance_km'] as num?)?.toDouble(),
        estimatedMinutes: data['estimated_minutes'] as int?,
        coordinates: (data['coordinates'] as String?) ?? '[]',
        elevationGainM: (data['elevation_gain_m'] as num?)?.toDouble(),
        userId: data['user_id'] as String?,
      );

  @override
  Future<Map<String, dynamic>> toSupabase(
    Trail instance, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      {
        'id': instance.id,
        'name_en': instance.nameEn,
        'name_es': instance.nameEs,
        'description_en': instance.descriptionEn,
        'description_es': instance.descriptionEs,
        'island_id': instance.islandId,
        'visit_site_id': instance.visitSiteId,
        'difficulty': instance.difficulty,
        'distance_km': instance.distanceKm,
        'estimated_minutes': instance.estimatedMinutes,
        'coordinates': instance.coordinates,
        'elevation_gain_m': instance.elevationGainM,
        'user_id': instance.userId,
      };
}

// ---------------------------------------------------------------------------
// UserFavorite
// ---------------------------------------------------------------------------

class UserFavoriteAdapter extends SupabaseAdapter<UserFavorite> {
  @override
  String get supabaseTableName => 'user_favorites';

  @override
  Set<String> get uniqueFields => {'id'};

  @override
  bool get defaultToNull => false;

  @override
  bool get ignoreDuplicates => false;

  @override
  Map<String, RuntimeSupabaseColumnDefinition> get fieldsToSupabaseColumns => {
        'id': _col('id'),
        'userId': _col('user_id'),
        'speciesId': _col('species_id'),
      };

  @override
  Future<UserFavorite> fromSupabase(
    Map<String, dynamic> data, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      UserFavorite(
        id: data['id'] as int,
        userId: data['user_id'] as String,
        speciesId: data['species_id'] as int,
      );

  @override
  Future<Map<String, dynamic>> toSupabase(
    UserFavorite instance, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      {
        'id': instance.id,
        'user_id': instance.userId,
        'species_id': instance.speciesId,
      };
}

// ---------------------------------------------------------------------------
// UserProfile
// ---------------------------------------------------------------------------

class UserProfileAdapter extends SupabaseAdapter<UserProfile> {
  @override
  String get supabaseTableName => 'profiles';

  @override
  Set<String> get uniqueFields => {'id'};

  @override
  bool get defaultToNull => false;

  @override
  bool get ignoreDuplicates => false;

  @override
  Map<String, RuntimeSupabaseColumnDefinition> get fieldsToSupabaseColumns => {
        'id': _col('id'),
        'displayName': _col('display_name'),
        'bio': _col('bio'),
        'birthDate': _col('birth_date'),
        'country': _col('country'),
        'countryCode': _col('country_code'),
        'avatarUrl': _col('avatar_url'),
        'createdAt': _col('created_at'),
        'updatedAt': _col('updated_at'),
        'userType': _col('user_type'),
        'affiliation': _col('affiliation'),
      };

  @override
  Future<UserProfile> fromSupabase(
    Map<String, dynamic> data, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      UserProfile(
        id: data['id'] as String,
        displayName: data['display_name'] as String?,
        bio: data['bio'] as String?,
        birthDate: data['birth_date'] != null
            ? DateTime.tryParse(data['birth_date'] as String)
            : null,
        country: data['country'] as String?,
        countryCode: data['country_code'] as String?,
        avatarUrl: data['avatar_url'] as String?,
        createdAt: data['created_at'] != null
            ? DateTime.tryParse(data['created_at'] as String)
            : null,
        updatedAt: data['updated_at'] != null
            ? DateTime.tryParse(data['updated_at'] as String)
            : null,
        userType: data['user_type'] as String? ?? 'tourist',
        affiliation: data['affiliation'] as String?,
      );

  @override
  Future<Map<String, dynamic>> toSupabase(
    UserProfile instance, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      {
        'id': instance.id,
        'display_name': instance.displayName,
        'bio': instance.bio,
        'birth_date': instance.birthDate?.toIso8601String(),
        'country': instance.country,
        'country_code': instance.countryCode,
        'avatar_url': instance.avatarUrl,
        'created_at': instance.createdAt?.toIso8601String(),
        'updated_at': instance.updatedAt?.toIso8601String(),
        'user_type': instance.userType,
        'affiliation': instance.affiliation,
      };
}

// ---------------------------------------------------------------------------
// UserSiteWishlist
// ---------------------------------------------------------------------------

class UserSiteWishlistAdapter extends SupabaseAdapter<UserSiteWishlist> {
  @override
  String get supabaseTableName => 'user_site_wishlist';

  @override
  Set<String> get uniqueFields => {'id'};

  @override
  bool get defaultToNull => false;

  @override
  bool get ignoreDuplicates => false;

  @override
  Map<String, RuntimeSupabaseColumnDefinition> get fieldsToSupabaseColumns => {
        'id': _col('id'),
        'userId': _col('user_id'),
        'visitSiteId': _col('visit_site_id'),
        'createdAt': _col('created_at'),
      };

  @override
  Future<UserSiteWishlist> fromSupabase(
    Map<String, dynamic> data, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      UserSiteWishlist(
        id: data['id'] as int,
        userId: data['user_id'] as String,
        visitSiteId: data['visit_site_id'] as int,
        createdAt: data['created_at'] != null
            ? DateTime.tryParse(data['created_at'] as String)
            : null,
      );

  @override
  Future<Map<String, dynamic>> toSupabase(
    UserSiteWishlist instance, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      {
        'id': instance.id,
        'user_id': instance.userId,
        'visit_site_id': instance.visitSiteId,
        'created_at': instance.createdAt?.toIso8601String(),
      };
}

// ---------------------------------------------------------------------------
// UserSpeciesChecklist
// ---------------------------------------------------------------------------

class UserSpeciesChecklistAdapter extends SupabaseAdapter<UserSpeciesChecklist> {
  @override
  String get supabaseTableName => 'user_species_checklist';

  @override
  Set<String> get uniqueFields => {'id'};

  @override
  bool get defaultToNull => false;

  @override
  bool get ignoreDuplicates => false;

  @override
  Map<String, RuntimeSupabaseColumnDefinition> get fieldsToSupabaseColumns => {
        'id': _col('id'),
        'userId': _col('user_id'),
        'speciesId': _col('species_id'),
        'seenAt': _col('seen_at'),
      };

  @override
  Future<UserSpeciesChecklist> fromSupabase(
    Map<String, dynamic> data, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      UserSpeciesChecklist(
        id: data['id'] as int,
        userId: data['user_id'] as String,
        speciesId: data['species_id'] as int,
        seenAt: data['seen_at'] != null
            ? DateTime.tryParse(data['seen_at'] as String)
            : null,
      );

  @override
  Future<Map<String, dynamic>> toSupabase(
    UserSpeciesChecklist instance, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      {
        'id': instance.id,
        'user_id': instance.userId,
        'species_id': instance.speciesId,
        'seen_at': instance.seenAt?.toIso8601String(),
      };
}

// ---------------------------------------------------------------------------
// VisitSite
// ---------------------------------------------------------------------------

class VisitSiteAdapter extends SupabaseAdapter<VisitSite> {
  @override
  String get supabaseTableName => 'visit_sites';

  @override
  Set<String> get uniqueFields => {'id'};

  @override
  bool get defaultToNull => false;

  @override
  bool get ignoreDuplicates => false;

  @override
  Map<String, RuntimeSupabaseColumnDefinition> get fieldsToSupabaseColumns => {
        'id': _col('id'),
        'islandId': _col('island_id'),
        'nameEs': _col('name_es'),
        'nameEn': _col('name_en'),
        'latitude': _col('latitude'),
        'longitude': _col('longitude'),
        'descriptionEs': _col('description_es'),
        'descriptionEn': _col('description_en'),
        'monitoringType': _col('monitoring_type'),
        'difficulty': _col('difficulty'),
        'conservationZone': _col('conservation_zone'),
        'publicUseZone': _col('public_use_zone'),
        'capacity': _col('capacity'),
        'status': _col('status'),
        'attractionEs': _col('attraction_es'),
        'abbreviation': _col('abbreviation'),
        'parkId': _col('park_id'),
      };

  @override
  Future<VisitSite> fromSupabase(
    Map<String, dynamic> data, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      VisitSite(
        id: data['id'] as int,
        islandId: data['island_id'] as int?,
        nameEs: data['name_es'] as String,
        nameEn: data['name_en'] as String?,
        latitude: (data['latitude'] as num?)?.toDouble(),
        longitude: (data['longitude'] as num?)?.toDouble(),
        descriptionEs: data['description_es'] as String?,
        descriptionEn: data['description_en'] as String?,
        monitoringType: data['monitoring_type'] as String?,
        difficulty: data['difficulty'] as String?,
        conservationZone: data['conservation_zone'] as String?,
        publicUseZone: data['public_use_zone'] as String?,
        capacity: data['capacity'] as int?,
        status: data['status'] as String?,
        attractionEs: data['attraction_es'] as String?,
        abbreviation: data['abbreviation'] as String?,
        parkId: data['park_id'] as String?,
      );

  @override
  Future<Map<String, dynamic>> toSupabase(
    VisitSite instance, {
    required covariant Object provider,
    covariant Object? repository,
  }) async =>
      {
        'id': instance.id,
        'island_id': instance.islandId,
        'name_es': instance.nameEs,
        'name_en': instance.nameEn,
        'latitude': instance.latitude,
        'longitude': instance.longitude,
        'description_es': instance.descriptionEs,
        'description_en': instance.descriptionEn,
        'monitoring_type': instance.monitoringType,
        'difficulty': instance.difficulty,
        'conservation_zone': instance.conservationZone,
        'public_use_zone': instance.publicUseZone,
        'capacity': instance.capacity,
        'status': instance.status,
        'attraction_es': instance.attractionEs,
        'abbreviation': instance.abbreviation,
        'park_id': instance.parkId,
      };
}

// ---------------------------------------------------------------------------
// Model dictionary — singleton registry of all adapters.
// ---------------------------------------------------------------------------

final supabaseModelDictionary = SupabaseModelDictionary({
  Category: CategoryAdapter(),
  Island: IslandAdapter(),
  Species: SpeciesAdapter(),
  Sighting: SightingAdapter(),
  SpeciesImage: SpeciesImageAdapter(),
  SpeciesReference: SpeciesReferenceAdapter(),
  SpeciesSite: SpeciesSiteAdapter(),
  SpeciesThreat: SpeciesThreatAdapter(),
  Trail: TrailAdapter(),
  UserFavorite: UserFavoriteAdapter(),
  UserProfile: UserProfileAdapter(),
  UserSiteWishlist: UserSiteWishlistAdapter(),
  UserSpeciesChecklist: UserSpeciesChecklistAdapter(),
  VisitSite: VisitSiteAdapter(),
});
