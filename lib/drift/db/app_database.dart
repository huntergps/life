import 'package:drift/drift.dart';

import 'platform/platform.dart' as platform;

import 'converters.dart';
import 'tables/categories_table.dart';
import 'tables/islands_table.dart';
import 'tables/species_table.dart';
import 'tables/sightings_table.dart';
import 'tables/species_images_table.dart';
import 'tables/species_references_table.dart';
import 'tables/species_sites_table.dart';
import 'tables/species_sounds_table.dart';
import 'tables/species_threats_table.dart';
import 'tables/trails_table.dart';
import 'tables/user_favorites_table.dart';
import 'tables/user_profiles_table.dart';
import 'tables/user_site_wishlists_table.dart';
import 'tables/user_species_checklists_table.dart';
import 'tables/visit_sites_table.dart';

export 'converters.dart';
export 'tables/categories_table.dart';
export 'tables/islands_table.dart';
export 'tables/species_table.dart';
export 'tables/sightings_table.dart';
export 'tables/species_images_table.dart';
export 'tables/species_references_table.dart';
export 'tables/species_sites_table.dart';
export 'tables/species_sounds_table.dart';
export 'tables/species_threats_table.dart';
export 'tables/trails_table.dart';
export 'tables/user_favorites_table.dart';
export 'tables/user_profiles_table.dart';
export 'tables/user_site_wishlists_table.dart';
export 'tables/user_species_checklists_table.dart';
export 'tables/visit_sites_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Categories,
  Islands,
  SpeciesRows,
  Sightings,
  SpeciesImages,
  SpeciesReferences,
  SpeciesSites,
  SpeciesSounds,
  SpeciesThreats,
  Trails,
  UserFavorites,
  UserProfiles,
  UserSiteWishlists,
  UserSpeciesChecklists,
  VisitSites,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Open or create the database file at [dbPath].
  /// On web, [dbPath] is ignored — uses IndexedDB via [WebDatabase].
  static AppDatabase open(String dbPath) =>
      AppDatabase(platform.openAppDb(dbPath));

  @override
  int get schemaVersion => 1;
}
