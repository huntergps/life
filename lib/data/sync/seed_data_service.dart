import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:galapagos_wildlife/data/local/drift/db/app_database.dart';
import 'package:galapagos_wildlife/data/local/drift/drift.dart';
import '../../core/data/seed_data.dart';

/// Inserts bundled seed data directly into Drift's local SQLite database.
/// This enables the app to work fully offline on first launch.
class SeedDataService {
  Future<void> seed({
    void Function(int step, int total, String table)? onProgress,
  }) async {
    final db = WildlifeRepository.instance.driftDb;

    final count = await db
        .customSelect('SELECT COUNT(*) AS c FROM species')
        .getSingle();
    if (count.read<int>('c') > 0) {
      debugPrint('Database already seeded, skipping');
      return;
    }

    const total = 5;

    await db.transaction(() async {
      onProgress?.call(1, total, 'Categories');
      for (final row in seedCategories) {
        await db.into(db.categories).insertOnConflictUpdate(_catRow(row));
      }

      onProgress?.call(2, total, 'Islands');
      for (final row in seedIslands) {
        await db.into(db.islands).insertOnConflictUpdate(_islandRow(row));
      }

      onProgress?.call(3, total, 'Visit Sites');
      for (final row in seedVisitSites) {
        await db.into(db.visitSites).insertOnConflictUpdate(_siteRow(row));
      }

      onProgress?.call(4, total, 'Species');
      for (final row in seedSpecies) {
        await db.into(db.speciesRows).insertOnConflictUpdate(_speciesRow(row));
      }

      onProgress?.call(5, total, 'Species Sites');
      for (final row in seedSpeciesSites) {
        await db
            .into(db.speciesSites)
            .insertOnConflictUpdate(_speciesSiteRow(row));
      }
    });

    debugPrint('Local database seeded with ${seedSpecies.length} species');
  }
}

// ---------------------------------------------------------------------------
// Map<String, Object?> → Drift Companion converters
// ---------------------------------------------------------------------------

CategoriesCompanion _catRow(Map<String, Object?> m) => CategoriesCompanion(
      id: Value(m['id'] as int),
      slug: Value(m['slug'] as String),
      nameEs: Value(m['name_es'] as String),
      nameEn: Value(m['name_en'] as String),
      iconName: Value(m['icon_name'] as String?),
      sortOrder: Value(m['sort_order'] as int? ?? 0),
    );

IslandsCompanion _islandRow(Map<String, Object?> m) => IslandsCompanion(
      id: Value(m['id'] as int),
      nameEs: Value(m['name_es'] as String),
      nameEn: Value(m['name_en'] as String),
      latitude: Value(m['latitude'] as double?),
      longitude: Value(m['longitude'] as double?),
      areaKm2: Value(m['area_km2'] as double?),
      descriptionEs: Value(m['description_es'] as String?),
      descriptionEn: Value(m['description_en'] as String?),
    );

VisitSitesCompanion _siteRow(Map<String, Object?> m) => VisitSitesCompanion(
      id: Value(m['id'] as int),
      islandId: Value(m['island_id'] as int?),
      nameEs: Value(m['name_es'] as String),
      nameEn: Value(m['name_en'] as String?),
      latitude: Value(m['latitude'] as double?),
      longitude: Value(m['longitude'] as double?),
      descriptionEs: Value(m['description_es'] as String?),
      descriptionEn: Value(m['description_en'] as String?),
    );

SpeciesRowsCompanion _speciesRow(Map<String, Object?> m) =>
    SpeciesRowsCompanion(
      id: Value(m['id'] as int),
      categoryId: Value(m['category_id'] as int),
      commonNameEs: Value(m['common_name_es'] as String),
      commonNameEn: Value(m['common_name_en'] as String),
      scientificName: Value(m['scientific_name'] as String),
      conservationStatus: Value(m['conservation_status'] as String?),
      weightKg: Value(m['weight_kg'] as double?),
      sizeCm: Value(m['size_cm'] as double?),
      populationEstimate: Value(m['population_estimate'] as int?),
      lifespanYears: Value(m['lifespan_years'] as int?),
      descriptionEs: Value(m['description_es'] as String?),
      descriptionEn: Value(m['description_en'] as String?),
      habitatEs: Value(m['habitat_es'] as String?),
      habitatEn: Value(m['habitat_en'] as String?),
      heroImageUrl: Value(m['hero_image_url'] as String?),
      thumbnailUrl: Value(m['thumbnail_url'] as String?),
      isEndemic: Value((m['is_endemic'] as int?) == 1),
      taxonomyKingdom: Value(m['taxonomy_kingdom'] as String?),
      taxonomyPhylum: Value(m['taxonomy_phylum'] as String?),
      taxonomyClass: Value(m['taxonomy_class'] as String?),
      taxonomyOrder: Value(m['taxonomy_order'] as String?),
      taxonomyFamily: Value(m['taxonomy_family'] as String?),
      taxonomyGenus: Value(m['taxonomy_genus'] as String?),
    );

SpeciesSitesCompanion _speciesSiteRow(Map<String, Object?> m) =>
    SpeciesSitesCompanion(
      id: Value(m['id'] as int),
      speciesId: Value(m['species_id'] as int),
      visitSiteId: Value(m['visit_site_id'] as int),
      frequency: Value(m['frequency'] as String?),
    );
