// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_core/query.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/db.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_supabase/brick_supabase.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/brick_sqlite.dart';// GENERATED CODE DO NOT EDIT
// ignore: unused_import
import 'dart:convert';
import 'package:brick_sqlite/brick_sqlite.dart' show SqliteModel, SqliteAdapter, SqliteModelDictionary, RuntimeSqliteColumnDefinition, SqliteProvider;
import 'package:brick_supabase/brick_supabase.dart' show SupabaseProvider, SupabaseModel, SupabaseAdapter, SupabaseModelDictionary;
// ignore: unused_import, unused_shown_name
import 'package:brick_offline_first/brick_offline_first.dart' show RuntimeOfflineFirstDefinition;
// ignore: unused_import, unused_shown_name
import 'package:sqflite_common/sqlite_api.dart' show DatabaseExecutor;

import '../brick/models/category.model.dart';
import '../brick/models/island.model.dart';
import '../brick/models/sighting.model.dart';
import '../brick/models/species.model.dart';
import '../brick/models/species_image.model.dart';
import '../brick/models/species_reference.model.dart';
import '../brick/models/species_site.model.dart';
import '../brick/models/species_sound.model.dart';
import '../brick/models/species_threat.model.dart';
import '../brick/models/trail.model.dart';
import '../brick/models/user_favorite.model.dart';
import '../brick/models/user_profile.model.dart';
import '../brick/models/visit_site.model.dart';

part 'adapters/category_adapter.g.dart';
part 'adapters/island_adapter.g.dart';
part 'adapters/sighting_adapter.g.dart';
part 'adapters/species_adapter.g.dart';
part 'adapters/species_image_adapter.g.dart';
part 'adapters/species_reference_adapter.g.dart';
part 'adapters/species_site_adapter.g.dart';
part 'adapters/species_sound_adapter.g.dart';
part 'adapters/species_threat_adapter.g.dart';
part 'adapters/trail_adapter.g.dart';
part 'adapters/user_favorite_adapter.g.dart';
part 'adapters/user_profile_adapter.g.dart';
part 'adapters/visit_site_adapter.g.dart';

/// Supabase mappings should only be used when initializing a [SupabaseProvider]
final Map<Type, SupabaseAdapter<SupabaseModel>> supabaseMappings = {
  Category: CategoryAdapter(),
  Island: IslandAdapter(),
  Sighting: SightingAdapter(),
  Species: SpeciesAdapter(),
  SpeciesImage: SpeciesImageAdapter(),
  SpeciesReference: SpeciesReferenceAdapter(),
  SpeciesSite: SpeciesSiteAdapter(),
  SpeciesSound: SpeciesSoundAdapter(),
  SpeciesThreat: SpeciesThreatAdapter(),
  Trail: TrailAdapter(),
  UserFavorite: UserFavoriteAdapter(),
  UserProfile: UserProfileAdapter(),
  VisitSite: VisitSiteAdapter()
};
final supabaseModelDictionary = SupabaseModelDictionary(supabaseMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  Category: CategoryAdapter(),
  Island: IslandAdapter(),
  Sighting: SightingAdapter(),
  Species: SpeciesAdapter(),
  SpeciesImage: SpeciesImageAdapter(),
  SpeciesReference: SpeciesReferenceAdapter(),
  SpeciesSite: SpeciesSiteAdapter(),
  SpeciesSound: SpeciesSoundAdapter(),
  SpeciesThreat: SpeciesThreatAdapter(),
  Trail: TrailAdapter(),
  UserFavorite: UserFavoriteAdapter(),
  UserProfile: UserProfileAdapter(),
  VisitSite: VisitSiteAdapter()
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
