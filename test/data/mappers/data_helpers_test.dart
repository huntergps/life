import 'package:flutter_test/flutter_test.dart';
import 'package:galapagos_wildlife/data/mappers/data_helpers.dart';

void main() {
  group('categoryFromRow', () {
    test('parses valid category JSON', () {
      final json = {
        'id': 1,
        'slug': 'birds',
        'name_es': 'Aves',
        'name_en': 'Birds',
        'icon_name': 'bird',
        'sort_order': 2,
      };
      final cat = categoryFromRow(json);
      expect(cat.id, 1);
      expect(cat.slug, 'birds');
      expect(cat.nameEs, 'Aves');
      expect(cat.nameEn, 'Birds');
      expect(cat.iconName, 'bird');
      expect(cat.sortOrder, 2);
    });

    test('handles null sort_order with default 0', () {
      final json = {
        'id': 1,
        'slug': 'x',
        'name_es': 'X',
        'name_en': 'X',
        'icon_name': null,
        'sort_order': null,
      };
      final cat = categoryFromRow(json);
      expect(cat.sortOrder, 0);
      expect(cat.iconName, isNull);
    });

    test('primaryKey returns id', () {
      final cat = categoryFromRow({
        'id': 7,
        'slug': 's',
        'name_es': 'S',
        'name_en': 'S',
        'icon_name': null,
        'sort_order': null,
      });
      expect(cat.primaryKey, 7);
    });
  });

  group('speciesFromRow', () {
    Map<String, dynamic> _minimalSpeciesJson({
      Object? weightKg,
      Object? sizeCm,
      bool? isEndemic,
    }) =>
        {
          'id': 1,
          'category_id': 1,
          'common_name_es': 'X',
          'common_name_en': 'X',
          'scientific_name': 'X x',
          'conservation_status': null,
          'weight_kg': weightKg,
          'size_cm': sizeCm,
          'population_estimate': null,
          'lifespan_years': null,
          'description_es': null,
          'description_en': null,
          'habitat_es': null,
          'habitat_en': null,
          'hero_image_url': null,
          'thumbnail_url': null,
          'is_endemic': isEndemic,
          'taxonomy_kingdom': null,
          'taxonomy_phylum': null,
          'taxonomy_class': null,
          'taxonomy_order': null,
          'taxonomy_family': null,
          'taxonomy_genus': null,
          'is_native': null,
          'is_introduced': null,
          'endemism_level': null,
          'population_trend': null,
          'breeding_season': null,
          'clutch_size': null,
          'reproductive_frequency': null,
          'social_structure': null,
          'activity_pattern': null,
          'diet_type': null,
          'primary_food_sources': null,
          'altitude_min_m': null,
          'altitude_max_m': null,
          'depth_min_m': null,
          'depth_max_m': null,
          'scientific_name_authorship': null,
          'distinguishing_features_es': null,
          'distinguishing_features_en': null,
          'sexual_dimorphism': null,
          'gbif_taxon_id': null,
          'eol_page_id': null,
          'iucn_assessment_url': null,
          'sound_recording_url': null,
          'video_url': null,
        };

    test('parses full species JSON', () {
      final json = {
        'id': 42,
        'category_id': 1,
        'common_name_es': 'Tortuga',
        'common_name_en': 'Tortoise',
        'scientific_name': 'Chelonoidis nigra',
        'conservation_status': 'VU',
        'weight_kg': 250.0,
        'size_cm': 120.5,
        'population_estimate': 20000,
        'lifespan_years': 100,
        'description_es': 'Desc ES',
        'description_en': 'Desc EN',
        'habitat_es': null,
        'habitat_en': null,
        'hero_image_url': null,
        'thumbnail_url': null,
        'is_endemic': true,
        'taxonomy_kingdom': 'Animalia',
        'taxonomy_phylum': 'Chordata',
        'taxonomy_class': 'Reptilia',
        'taxonomy_order': 'Testudines',
        'taxonomy_family': 'Testudinidae',
        'taxonomy_genus': 'Chelonoidis',
        'is_native': null,
        'is_introduced': null,
        'endemism_level': 'endemic_galapagos',
        'population_trend': null,
        'breeding_season': null,
        'clutch_size': null,
        'reproductive_frequency': null,
        'social_structure': null,
        'activity_pattern': null,
        'diet_type': null,
        'primary_food_sources': null,
        'altitude_min_m': null,
        'altitude_max_m': null,
        'depth_min_m': null,
        'depth_max_m': null,
        'scientific_name_authorship': null,
        'distinguishing_features_es': null,
        'distinguishing_features_en': null,
        'sexual_dimorphism': null,
        'gbif_taxon_id': null,
        'eol_page_id': null,
        'iucn_assessment_url': null,
        'sound_recording_url': null,
        'video_url': null,
      };
      final s = speciesFromRow(json);
      expect(s.id, 42);
      expect(s.commonNameEn, 'Tortoise');
      expect(s.scientificName, 'Chelonoidis nigra');
      expect(s.isEndemic, true);
      expect(s.weightKg, 250.0);
      expect(s.sizeCm, 120.5);
      expect(s.conservationStatus, 'VU');
      expect(s.populationEstimate, 20000);
      expect(s.lifespanYears, 100);
      expect(s.endemismLevel, 'endemic_galapagos');
    });

    test('handles weight_kg and size_cm as int (Supabase JSON quirk)', () {
      final s = speciesFromRow(_minimalSpeciesJson(weightKg: 2, sizeCm: 10));
      expect(s.weightKg, 2.0);
      expect(s.sizeCm, 10.0);
    });

    test('handles null weight_kg and size_cm', () {
      final s = speciesFromRow(_minimalSpeciesJson());
      expect(s.weightKg, isNull);
      expect(s.sizeCm, isNull);
    });

    test('isEndemic defaults to false when null', () {
      final s = speciesFromRow(_minimalSpeciesJson(isEndemic: null));
      expect(s.isEndemic, false);
    });

    test('parses primary_food_sources list', () {
      final json = _minimalSpeciesJson();
      json['primary_food_sources'] = ['fish', 'squid'];
      final s = speciesFromRow(json);
      expect(s.primaryFoodSources, ['fish', 'squid']);
    });
  });

  group('islandFromRow', () {
    test('parses island with coordinates', () {
      final json = {
        'id': 1,
        'name_es': 'Santa Cruz',
        'name_en': 'Santa Cruz',
        'latitude': -0.6238,
        'longitude': -90.3684,
        'area_km2': 986.0,
        'area_ha': null,
        'description_es': null,
        'description_en': null,
        'park_id': null,
        'island_type': null,
        'classification': null,
        'is_populated': true,
      };
      final i = islandFromRow(json);
      expect(i.id, 1);
      expect(i.nameEn, 'Santa Cruz');
      expect(i.latitude, -0.6238);
      expect(i.longitude, -90.3684);
      expect(i.areaKm2, 986.0);
      expect(i.isPopulated, true);
    });

    test('handles coordinates as int (Supabase JSON quirk)', () {
      final json = {
        'id': 2,
        'name_es': 'Isla X',
        'name_en': 'Island X',
        'latitude': 0,
        'longitude': -90,
        'area_km2': 5,
        'area_ha': 500,
        'description_es': null,
        'description_en': null,
        'park_id': null,
        'island_type': null,
        'classification': null,
        'is_populated': false,
      };
      final i = islandFromRow(json);
      expect(i.latitude, 0.0);
      expect(i.longitude, -90.0);
      expect(i.areaKm2, 5.0);
      expect(i.areaHa, 500.0);
    });
  });

  group('visitSiteFromRow', () {
    test('parses visit site with nullable name_en', () {
      final json = {
        'id': 1,
        'island_id': 1,
        'name_es': 'Tortuga Bay',
        'name_en': null,
        'latitude': -0.77,
        'longitude': -90.33,
        'description_es': null,
        'description_en': null,
        'monitoring_type': 'tourist',
        'difficulty': 'easy',
        'conservation_zone': null,
        'public_use_zone': null,
        'capacity': 100,
        'status': 'active',
        'attraction_es': null,
        'abbreviation': null,
        'park_id': null,
      };
      final vs = visitSiteFromRow(json);
      expect(vs.id, 1);
      expect(vs.nameEn, isNull);
      expect(vs.nameEs, 'Tortuga Bay');
      expect(vs.islandId, 1);
      expect(vs.monitoringType, 'tourist');
      expect(vs.capacity, 100);
    });

    test('handles null island_id', () {
      final json = {
        'id': 2,
        'island_id': null,
        'name_es': 'Sitio X',
        'name_en': 'Site X',
        'latitude': null,
        'longitude': null,
        'description_es': null,
        'description_en': null,
        'monitoring_type': null,
        'difficulty': null,
        'conservation_zone': null,
        'public_use_zone': null,
        'capacity': null,
        'status': null,
        'attraction_es': null,
        'abbreviation': null,
        'park_id': null,
      };
      final vs = visitSiteFromRow(json);
      expect(vs.islandId, isNull);
      expect(vs.latitude, isNull);
    });
  });

  group('sightingFromRow', () {
    test('parses sighting with datetime', () {
      final json = {
        'id': 1,
        'user_id': 'abc-123',
        'species_id': 42,
        'visit_site_id': null,
        'observed_at': '2026-03-15T10:30:00Z',
        'notes': 'Seen near trail',
        'latitude': -0.75,
        'longitude': -90.31,
        'photo_url': null,
      };
      final s = sightingFromRow(json);
      expect(s.id, 1);
      expect(s.userId, 'abc-123');
      expect(s.speciesId, 42);
      expect(s.observedAt, isA<DateTime>());
      expect(s.observedAt!.year, 2026);
      expect(s.observedAt!.month, 3);
      expect(s.observedAt!.day, 15);
      expect(s.notes, 'Seen near trail');
    });

    test('handles null observed_at', () {
      final json = {
        'id': 2,
        'user_id': 'def-456',
        'species_id': 10,
        'visit_site_id': 5,
        'observed_at': null,
        'notes': null,
        'latitude': null,
        'longitude': null,
        'photo_url': null,
      };
      final s = sightingFromRow(json);
      expect(s.observedAt, isNull);
      expect(s.visitSiteId, 5);
    });

    test('handles coordinates as int', () {
      final json = {
        'id': 3,
        'user_id': 'x',
        'species_id': 1,
        'visit_site_id': null,
        'observed_at': null,
        'notes': null,
        'latitude': 0,
        'longitude': -90,
        'photo_url': null,
      };
      final s = sightingFromRow(json);
      expect(s.latitude, 0.0);
      expect(s.longitude, -90.0);
    });
  });

  group('userProfileFromRow', () {
    test('parses user profile with dates', () {
      final json = {
        'id': 'user-abc',
        'display_name': 'Elmer',
        'bio': 'Wildlife lover',
        'birth_date': '1990-06-15',
        'country': 'Ecuador',
        'country_code': 'EC',
        'avatar_url': 'https://example.com/avatar.jpg',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-03-01T12:00:00Z',
      };
      final p = userProfileFromRow(json);
      expect(p.id, 'user-abc');
      expect(p.displayName, 'Elmer');
      expect(p.birthDate, isA<DateTime>());
      expect(p.birthDate!.year, 1990);
      expect(p.country, 'Ecuador');
      expect(p.countryCode, 'EC');
      expect(p.createdAt, isA<DateTime>());
    });

    test('handles all null optional fields', () {
      final json = {
        'id': 'user-xyz',
        'display_name': null,
        'bio': null,
        'birth_date': null,
        'country': null,
        'country_code': null,
        'avatar_url': null,
        'created_at': null,
        'updated_at': null,
      };
      final p = userProfileFromRow(json);
      expect(p.id, 'user-xyz');
      expect(p.displayName, isNull);
      expect(p.birthDate, isNull);
      expect(p.createdAt, isNull);
    });
  });

  group('speciesImageFromRow', () {
    test('parses species image', () {
      final json = {
        'id': 10,
        'species_id': 42,
        'image_url': 'https://example.com/img.jpg',
        'caption_es': 'Foto principal',
        'caption_en': 'Main photo',
        'sort_order': 1,
        'is_primary': true,
        'thumbnail_url': 'https://example.com/thumb.jpg',
        'card_thumbnail_url': null,
      };
      final img = speciesImageFromRow(json);
      expect(img.id, 10);
      expect(img.speciesId, 42);
      expect(img.isPrimary, true);
      expect(img.sortOrder, 1);
    });

    test('defaults sort_order to 0 and is_primary to false', () {
      final json = {
        'id': 11,
        'species_id': 1,
        'image_url': 'https://example.com/img2.jpg',
        'caption_es': null,
        'caption_en': null,
        'sort_order': null,
        'is_primary': null,
        'thumbnail_url': null,
        'card_thumbnail_url': null,
      };
      final img = speciesImageFromRow(json);
      expect(img.sortOrder, 0);
      expect(img.isPrimary, false);
    });
  });
}
