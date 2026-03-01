import 'dart:async';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/brick/models/category.model.dart';
import 'package:galapagos_wildlife/brick/models/island.model.dart';
import 'package:galapagos_wildlife/brick/models/sighting.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/brick/models/species_image.model.dart';
import 'package:galapagos_wildlife/brick/models/species_site.model.dart';
import 'package:galapagos_wildlife/brick/models/user_profile.model.dart';
import 'package:galapagos_wildlife/brick/models/visit_site.model.dart';
import 'package:galapagos_wildlife/brick/repository.dart';

// ---------------------------------------------------------------------------
// Web-only: Supabase JSON → model converters
// ---------------------------------------------------------------------------

Category categoryFromRow(Map<String, dynamic> r) => Category(
      id: r['id'] as int,
      slug: r['slug'] as String,
      nameEs: r['name_es'] as String,
      nameEn: r['name_en'] as String,
      iconName: r['icon_name'] as String?,
      sortOrder: (r['sort_order'] as int?) ?? 0,
    );

Species speciesFromRow(Map<String, dynamic> r) => Species(
      id: r['id'] as int,
      categoryId: r['category_id'] as int,
      commonNameEs: r['common_name_es'] as String,
      commonNameEn: r['common_name_en'] as String,
      scientificName: r['scientific_name'] as String,
      conservationStatus: r['conservation_status'] as String?,
      weightKg: (r['weight_kg'] as num?)?.toDouble(),
      sizeCm: (r['size_cm'] as num?)?.toDouble(),
      populationEstimate: r['population_estimate'] as int?,
      lifespanYears: r['lifespan_years'] as int?,
      descriptionEs: r['description_es'] as String?,
      descriptionEn: r['description_en'] as String?,
      habitatEs: r['habitat_es'] as String?,
      habitatEn: r['habitat_en'] as String?,
      heroImageUrl: r['hero_image_url'] as String?,
      thumbnailUrl: r['thumbnail_url'] as String?,
      isEndemic: (r['is_endemic'] as bool?) ?? false,
      taxonomyKingdom: r['taxonomy_kingdom'] as String?,
      taxonomyPhylum: r['taxonomy_phylum'] as String?,
      taxonomyClass: r['taxonomy_class'] as String?,
      taxonomyOrder: r['taxonomy_order'] as String?,
      taxonomyFamily: r['taxonomy_family'] as String?,
      taxonomyGenus: r['taxonomy_genus'] as String?,
      isNative: r['is_native'] as bool?,
      isIntroduced: r['is_introduced'] as bool?,
      endemismLevel: r['endemism_level'] as String?,
      populationTrend: r['population_trend'] as String?,
      breedingSeason: r['breeding_season'] as String?,
      clutchSize: r['clutch_size'] as String?,
      reproductiveFrequency: r['reproductive_frequency'] as String?,
      socialStructure: r['social_structure'] as String?,
      activityPattern: r['activity_pattern'] as String?,
      dietType: r['diet_type'] as String?,
      primaryFoodSources: (r['primary_food_sources'] as List?)?.cast<String>(),
      altitudeMinM: r['altitude_min_m'] as int?,
      altitudeMaxM: r['altitude_max_m'] as int?,
      depthMinM: r['depth_min_m'] as int?,
      depthMaxM: r['depth_max_m'] as int?,
      scientificNameAuthorship: r['scientific_name_authorship'] as String?,
      distinguishingFeaturesEs: r['distinguishing_features_es'] as String?,
      distinguishingFeaturesEn: r['distinguishing_features_en'] as String?,
      sexualDimorphism: r['sexual_dimorphism'] as String?,
      gbifTaxonId: r['gbif_taxon_id'] as String?,
      eolPageId: r['eol_page_id'] as String?,
      iucnAssessmentUrl: r['iucn_assessment_url'] as String?,
      soundRecordingUrl: r['sound_recording_url'] as String?,
      videoUrl: r['video_url'] as String?,
    );

SpeciesImage speciesImageFromRow(Map<String, dynamic> r) => SpeciesImage(
      id: r['id'] as int,
      speciesId: r['species_id'] as int,
      imageUrl: r['image_url'] as String,
      captionEs: r['caption_es'] as String?,
      captionEn: r['caption_en'] as String?,
      sortOrder: (r['sort_order'] as int?) ?? 0,
      isPrimary: (r['is_primary'] as bool?) ?? false,
      thumbnailUrl: r['thumbnail_url'] as String?,
      cardThumbnailUrl: r['card_thumbnail_url'] as String?,
    );

SpeciesSite speciesSiteFromRow(Map<String, dynamic> r) => SpeciesSite(
      id: r['id'] as int,
      speciesId: r['species_id'] as int,
      visitSiteId: r['visit_site_id'] as int,
      frequency: r['frequency'] as String?,
    );

Island islandFromRow(Map<String, dynamic> r) => Island(
      id: r['id'] as int,
      nameEs: r['name_es'] as String,
      nameEn: r['name_en'] as String,
      latitude: (r['latitude'] as num?)?.toDouble(),
      longitude: (r['longitude'] as num?)?.toDouble(),
      areaKm2: (r['area_km2'] as num?)?.toDouble(),
      areaHa: (r['area_ha'] as num?)?.toDouble(),
      descriptionEs: r['description_es'] as String?,
      descriptionEn: r['description_en'] as String?,
      parkId: r['park_id'] as String?,
      islandType: r['island_type'] as String?,
      classification: r['classification'] as String?,
      isPopulated: r['is_populated'] as bool?,
    );

VisitSite visitSiteFromRow(Map<String, dynamic> r) => VisitSite(
      id: r['id'] as int,
      islandId: r['island_id'] as int?,
      nameEs: r['name_es'] as String,
      nameEn: r['name_en'] as String?,
      latitude: (r['latitude'] as num?)?.toDouble(),
      longitude: (r['longitude'] as num?)?.toDouble(),
      descriptionEs: r['description_es'] as String?,
      descriptionEn: r['description_en'] as String?,
      monitoringType: r['monitoring_type'] as String?,
      difficulty: r['difficulty'] as String?,
      conservationZone: r['conservation_zone'] as String?,
      publicUseZone: r['public_use_zone'] as String?,
      capacity: r['capacity'] as int?,
      status: r['status'] as String?,
      attractionEs: r['attraction_es'] as String?,
      abbreviation: r['abbreviation'] as String?,
      parkId: r['park_id'] as String?,
    );

UserProfile userProfileFromRow(Map<String, dynamic> r) => UserProfile(
      id: r['id'] as String,
      displayName: r['display_name'] as String?,
      bio: r['bio'] as String?,
      birthDate: r['birth_date'] != null
          ? DateTime.tryParse(r['birth_date'] as String)
          : null,
      country: r['country'] as String?,
      countryCode: r['country_code'] as String?,
      avatarUrl: r['avatar_url'] as String?,
      createdAt: r['created_at'] != null
          ? DateTime.tryParse(r['created_at'] as String)
          : null,
      updatedAt: r['updated_at'] != null
          ? DateTime.tryParse(r['updated_at'] as String)
          : null,
    );

Sighting sightingFromRow(Map<String, dynamic> r) => Sighting(
      id: r['id'] as int,
      userId: r['user_id'] as String,
      speciesId: r['species_id'] as int,
      visitSiteId: r['visit_site_id'] as int?,
      observedAt: r['observed_at'] != null
          ? DateTime.parse(r['observed_at'] as String)
          : null,
      notes: r['notes'] as String?,
      latitude: (r['latitude'] as num?)?.toDouble(),
      longitude: (r['longitude'] as num?)?.toDouble(),
      photoUrl: r['photo_url'] as String?,
    );

/// Fetches a list from Brick with local-first strategy.
///
/// By default returns local SQLite data immediately and fires a background
/// sync so the next read gets fresh data.
///
/// Set [awaitRemote] = true to wait for Supabase before returning.
/// When online this guarantees all columns are populated from the server;
/// when offline it falls back to the local cache automatically.
///
/// Deduplicates results by [idSelector] (last occurrence wins = freshest data).
Future<List<T>> fetchDeduped<T extends OfflineFirstWithSupabaseModel>({
  required int Function(T) idSelector,
  OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.awaitRemote,
  Query? query,
  bool awaitRemote = false,
}) async {
  final repo = Repository();

  List<T> raw;

  if (awaitRemote) {
    // Await Supabase response so all server-side columns are populated.
    // Falls back to local cache on any network error.
    try {
      raw = await repo.get<T>(
        policy: OfflineFirstGetPolicy.awaitRemote,
        query: query,
      );
    } catch (_) {
      raw = await repo.get<T>(
        policy: OfflineFirstGetPolicy.localOnly,
        query: query,
      );
    }
  } else {
    // Fast local-first path: return SQLite immediately.
    raw = await repo.get<T>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: query,
    );

    // Fire background sync so next invalidation has fresh data.
    if (policy != OfflineFirstGetPolicy.localOnly) {
      unawaited(
        repo
            .get<T>(policy: OfflineFirstGetPolicy.awaitRemote, query: query)
            .catchError((_) => <T>[]),
      );
    }
  }

  final deduped = <int, T>{};
  for (final item in raw) {
    deduped[idSelector(item)] = item;
  }
  return deduped.values.toList();
}

/// Builds a lookup map from Brick results, deduplicating by [idSelector].
Future<Map<int, T>> fetchLookup<T extends OfflineFirstWithSupabaseModel>({
  required int Function(T) idSelector,
  OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.localOnly,
  Query? query,
}) async {
  final raw = await Repository().get<T>(policy: policy, query: query);
  final map = <int, T>{};
  for (final item in raw) {
    map[idSelector(item)] = item;
  }
  return map;
}
