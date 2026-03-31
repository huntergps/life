// ignore_for_file: lines_longer_than_80_chars

import 'package:drift/drift.dart' show GeneratedColumn, Value;
import 'package:drift_offline_first/drift_offline_first.dart'
    show Query, QueryDriftTransformer;
import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';
import 'package:drift_supabase/drift_supabase.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart' show DatabaseFactory;

import '../db/platform/platform.dart' as platform;

import '../adapters/supabase_model_dictionary.dart';

// Models — no prefix; these are the app-level domain types.
import '../../models/category.model.dart';
import '../../models/island.model.dart';
import '../../models/sighting.model.dart';
import '../../models/species.model.dart';
import '../../models/species_image.model.dart';
import '../../models/species_reference.model.dart';
import '../../models/species_site.model.dart';
import '../../models/species_sound.model.dart';
import '../../models/species_threat.model.dart';
import '../../models/trail.model.dart';
import '../../models/user_favorite.model.dart';
import '../../models/user_profile.model.dart';
import '../../models/user_site_wishlist.model.dart';
import '../../models/user_species_checklist.model.dart';
import '../../models/visit_site.model.dart';

// Drift DB with prefix to avoid data-class name collisions with the models above.
import '../db/app_database.dart' as db;

export '../db/app_database.dart' show AppDatabase;

/// Concrete offline-first repository backed by Drift (local) + Supabase (remote).
class WildlifeRepository
    extends OfflineFirstWithSupabaseRepository<OfflineFirstWithSupabaseModel> {
  final db.AppDatabase _db;

  /// Exposes the Drift database for raw SQL operations (e.g. seed data).
  db.AppDatabase get driftDb => _db;

  static WildlifeRepository? _instance;

  /// Global singleton — available after [configure] completes.
  static WildlifeRepository get instance => _instance!;
  static bool get initialized => _instance != null;

  // ---------------------------------------------------------------------------
  // Query transformers — map Dart field names -> Drift column expressions.
  // ---------------------------------------------------------------------------

  late final _categoryTransformer = QueryDriftTransformer({
    'id': _db.categories.id as GeneratedColumn<Object>,
    'slug': _db.categories.slug as GeneratedColumn<Object>,
    'nameEs': _db.categories.nameEs as GeneratedColumn<Object>,
    'nameEn': _db.categories.nameEn as GeneratedColumn<Object>,
    'sortOrder': _db.categories.sortOrder as GeneratedColumn<Object>,
  });

  late final _islandTransformer = QueryDriftTransformer({
    'id': _db.islands.id as GeneratedColumn<Object>,
    'nameEs': _db.islands.nameEs as GeneratedColumn<Object>,
    'nameEn': _db.islands.nameEn as GeneratedColumn<Object>,
    'parkId': _db.islands.parkId as GeneratedColumn<Object>,
  });

  late final _speciesTransformer = QueryDriftTransformer({
    'id': _db.speciesRows.id as GeneratedColumn<Object>,
    'categoryId': _db.speciesRows.categoryId as GeneratedColumn<Object>,
    'isEndemic': _db.speciesRows.isEndemic as GeneratedColumn<Object>,
    'isNative': _db.speciesRows.isNative as GeneratedColumn<Object>,
    'isIntroduced': _db.speciesRows.isIntroduced as GeneratedColumn<Object>,
    'commonNameEs': _db.speciesRows.commonNameEs as GeneratedColumn<Object>,
    'commonNameEn': _db.speciesRows.commonNameEn as GeneratedColumn<Object>,
    'scientificName': _db.speciesRows.scientificName as GeneratedColumn<Object>,
    'conservationStatus': _db.speciesRows.conservationStatus as GeneratedColumn<Object>,
    'endemismLevel': _db.speciesRows.endemismLevel as GeneratedColumn<Object>,
    'dietType': _db.speciesRows.dietType as GeneratedColumn<Object>,
    'activityPattern': _db.speciesRows.activityPattern as GeneratedColumn<Object>,
    'inaturalistTaxonId': _db.speciesRows.inaturalistTaxonId as GeneratedColumn<Object>,
  });

  late final _sightingTransformer = QueryDriftTransformer({
    'id': _db.sightings.id as GeneratedColumn<Object>,
    'userId': _db.sightings.userId as GeneratedColumn<Object>,
    'speciesId': _db.sightings.speciesId as GeneratedColumn<Object>,
    'visitSiteId': _db.sightings.visitSiteId as GeneratedColumn<Object>,
  });

  late final _speciesImageTransformer = QueryDriftTransformer({
    'id': _db.speciesImages.id as GeneratedColumn<Object>,
    'speciesId': _db.speciesImages.speciesId as GeneratedColumn<Object>,
    'isPrimary': _db.speciesImages.isPrimary as GeneratedColumn<Object>,
    'sortOrder': _db.speciesImages.sortOrder as GeneratedColumn<Object>,
  });

  late final _speciesReferenceTransformer = QueryDriftTransformer({
    'id': _db.speciesReferences.id as GeneratedColumn<Object>,
    'speciesId': _db.speciesReferences.speciesId as GeneratedColumn<Object>,
    'referenceType': _db.speciesReferences.referenceType as GeneratedColumn<Object>,
  });

  late final _speciesSiteTransformer = QueryDriftTransformer({
    'id': _db.speciesSites.id as GeneratedColumn<Object>,
    'speciesId': _db.speciesSites.speciesId as GeneratedColumn<Object>,
    'visitSiteId': _db.speciesSites.visitSiteId as GeneratedColumn<Object>,
  });

  late final _speciesSoundTransformer = QueryDriftTransformer({
    'id': _db.speciesSounds.id as GeneratedColumn<Object>,
    'speciesId': _db.speciesSounds.speciesId as GeneratedColumn<Object>,
    'soundType': _db.speciesSounds.soundType as GeneratedColumn<Object>,
  });

  late final _speciesThreatTransformer = QueryDriftTransformer({
    'id': _db.speciesThreats.id as GeneratedColumn<Object>,
    'speciesId': _db.speciesThreats.speciesId as GeneratedColumn<Object>,
    'threatType': _db.speciesThreats.threatType as GeneratedColumn<Object>,
  });

  late final _trailTransformer = QueryDriftTransformer({
    'id': _db.trails.id as GeneratedColumn<Object>,
    'userId': _db.trails.userId as GeneratedColumn<Object>,
    'islandId': _db.trails.islandId as GeneratedColumn<Object>,
    'visitSiteId': _db.trails.visitSiteId as GeneratedColumn<Object>,
    'difficulty': _db.trails.difficulty as GeneratedColumn<Object>,
  });

  late final _userFavoriteTransformer = QueryDriftTransformer({
    'id': _db.userFavorites.id as GeneratedColumn<Object>,
    'userId': _db.userFavorites.userId as GeneratedColumn<Object>,
    'speciesId': _db.userFavorites.speciesId as GeneratedColumn<Object>,
  });

  late final _userProfileTransformer = QueryDriftTransformer({
    'id': _db.userProfiles.id as GeneratedColumn<Object>,
  });

  late final _userSiteWishlistTransformer = QueryDriftTransformer({
    'id': _db.userSiteWishlists.id as GeneratedColumn<Object>,
    'userId': _db.userSiteWishlists.userId as GeneratedColumn<Object>,
    'visitSiteId': _db.userSiteWishlists.visitSiteId as GeneratedColumn<Object>,
  });

  late final _userSpeciesChecklistTransformer = QueryDriftTransformer({
    'id': _db.userSpeciesChecklists.id as GeneratedColumn<Object>,
    'userId': _db.userSpeciesChecklists.userId as GeneratedColumn<Object>,
    'speciesId': _db.userSpeciesChecklists.speciesId as GeneratedColumn<Object>,
  });

  late final _visitSiteTransformer = QueryDriftTransformer({
    'id': _db.visitSites.id as GeneratedColumn<Object>,
    'islandId': _db.visitSites.islandId as GeneratedColumn<Object>,
    'nameEs': _db.visitSites.nameEs as GeneratedColumn<Object>,
    'nameEn': _db.visitSites.nameEn as GeneratedColumn<Object>,
    'status': _db.visitSites.status as GeneratedColumn<Object>,
    'monitoringType': _db.visitSites.monitoringType as GeneratedColumn<Object>,
  });

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  WildlifeRepository._({
    required super.supabaseProvider,
    required super.offlineQueueClient,
    required db.AppDatabase database,
  }) : _db = database;

  // ---------------------------------------------------------------------------
  // Model dictionary
  // ---------------------------------------------------------------------------

  @override
  SupabaseModelDictionary get modelDictionary => supabaseModelDictionary;

  // ---------------------------------------------------------------------------
  // Factory / lifecycle
  // ---------------------------------------------------------------------------

  /// Initialize the repository. Call once in bootstrap before using [instance].
  static Future<void> configure({
    required String supabaseUrl,
    required String supabaseKey,
    DatabaseFactory? databaseFactory,
  }) async {
    final String dbPath;
    final String queuePath;
    final DatabaseFactory queueFactory;

    if (kIsWeb) {
      dbPath = 'wildlife.db';
      queuePath = 'wildlife_queue.db';
      queueFactory = await platform.webQueueFactory();
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      dbPath = '${appDir.path}/wildlife.db';
      queuePath = '${appDir.path}/wildlife_queue.db';
      queueFactory = databaseFactory!;
    }

    final database = db.AppDatabase.open(dbPath);

    final requestManager = SupabaseRequestSqliteCacheManager(
      queuePath,
      openDatabase: queueFactory,
    );

    _instance = await OfflineFirstWithSupabaseRepository.clientQueue(
      supabaseUrl: supabaseUrl,
      supabaseKey: supabaseKey,
      requestManager: requestManager,
      modelDictionary: supabaseModelDictionary,
      buildRepository: (provider, queueClient) => WildlifeRepository._(
        supabaseProvider: provider,
        offlineQueueClient: queueClient,
        database: database,
      ),
    );
    await _instance!.initialize();
  }

  /// Write only to local Drift — no Supabase sync.
  /// Equivalent to Brick's upsertSqlite.
  Future<void> upsertDriftOnly<T extends OfflineFirstWithSupabaseModel>(
    T instance,
  ) =>
      upsertLocal<T>(instance);

  // ---------------------------------------------------------------------------
  // getLocal
  // ---------------------------------------------------------------------------

  @override
  Future<List<T>> getLocal<T extends OfflineFirstWithSupabaseModel>({
    Query? query,
  }) async {
    if (T == Category) {
      final stmt = _db.select(_db.categories);
      _categoryTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToCategory).toList().cast<T>();
    }
    if (T == Island) {
      final stmt = _db.select(_db.islands);
      _islandTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToIsland).toList().cast<T>();
    }
    if (T == Species) {
      final stmt = _db.select(_db.speciesRows);
      _speciesTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToSpecies).toList().cast<T>();
    }
    if (T == Sighting) {
      final stmt = _db.select(_db.sightings);
      _sightingTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToSighting).toList().cast<T>();
    }
    if (T == SpeciesImage) {
      final stmt = _db.select(_db.speciesImages);
      _speciesImageTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToSpeciesImage).toList().cast<T>();
    }
    if (T == SpeciesReference) {
      final stmt = _db.select(_db.speciesReferences);
      _speciesReferenceTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToSpeciesReference).toList().cast<T>();
    }
    if (T == SpeciesSite) {
      final stmt = _db.select(_db.speciesSites);
      _speciesSiteTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToSpeciesSite).toList().cast<T>();
    }
    if (T == SpeciesSound) {
      final stmt = _db.select(_db.speciesSounds);
      _speciesSoundTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToSpeciesSound).toList().cast<T>();
    }
    if (T == SpeciesThreat) {
      final stmt = _db.select(_db.speciesThreats);
      _speciesThreatTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToSpeciesThreat).toList().cast<T>();
    }
    if (T == Trail) {
      final stmt = _db.select(_db.trails);
      _trailTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToTrail).toList().cast<T>();
    }
    if (T == UserFavorite) {
      final stmt = _db.select(_db.userFavorites);
      _userFavoriteTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToUserFavorite).toList().cast<T>();
    }
    if (T == UserProfile) {
      final stmt = _db.select(_db.userProfiles);
      _userProfileTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToUserProfile).toList().cast<T>();
    }
    if (T == UserSiteWishlist) {
      final stmt = _db.select(_db.userSiteWishlists);
      _userSiteWishlistTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToUserSiteWishlist).toList().cast<T>();
    }
    if (T == UserSpeciesChecklist) {
      final stmt = _db.select(_db.userSpeciesChecklists);
      _userSpeciesChecklistTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToUserSpeciesChecklist).toList().cast<T>();
    }
    if (T == VisitSite) {
      final stmt = _db.select(_db.visitSites);
      _visitSiteTransformer.applyToSelect(stmt, query);
      return (await stmt.get()).map(_rowToVisitSite).toList().cast<T>();
    }
    throw UnsupportedError('getLocal: no handler for $T');
  }

  // ---------------------------------------------------------------------------
  // existsLocal
  // ---------------------------------------------------------------------------

  @override
  Future<bool> existsLocal<T extends OfflineFirstWithSupabaseModel>({
    Query? query,
  }) async {
    final results = await getLocal<T>(query: query);
    return results.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // upsertLocal
  // ---------------------------------------------------------------------------

  @override
  Future<int?> upsertLocal<T extends OfflineFirstWithSupabaseModel>(
    T instance,
  ) async {
    if (instance is Category) {
      await _db.into(_db.categories).insertOnConflictUpdate(
            db.CategoriesCompanion(
              id: Value(instance.id),
              slug: Value(instance.slug),
              nameEs: Value(instance.nameEs),
              nameEn: Value(instance.nameEn),
              iconName: Value(instance.iconName),
              sortOrder: Value(instance.sortOrder),
            ),
          );
      return null;
    }
    if (instance is Island) {
      await _db.into(_db.islands).insertOnConflictUpdate(
            db.IslandsCompanion(
              id: Value(instance.id),
              nameEs: Value(instance.nameEs),
              nameEn: Value(instance.nameEn),
              latitude: Value(instance.latitude),
              longitude: Value(instance.longitude),
              areaKm2: Value(instance.areaKm2),
              areaHa: Value(instance.areaHa),
              descriptionEs: Value(instance.descriptionEs),
              descriptionEn: Value(instance.descriptionEn),
              parkId: Value(instance.parkId),
              islandType: Value(instance.islandType),
              classification: Value(instance.classification),
              isPopulated: Value(instance.isPopulated),
            ),
          );
      return null;
    }
    if (instance is Species) {
      await _db.into(_db.speciesRows).insertOnConflictUpdate(
            db.SpeciesRowsCompanion(
              id: Value(instance.id),
              categoryId: Value(instance.categoryId),
              commonNameEs: Value(instance.commonNameEs),
              commonNameEn: Value(instance.commonNameEn),
              scientificName: Value(instance.scientificName),
              conservationStatus: Value(instance.conservationStatus),
              weightKg: Value(instance.weightKg),
              sizeCm: Value(instance.sizeCm),
              populationEstimate: Value(instance.populationEstimate),
              lifespanYears: Value(instance.lifespanYears),
              descriptionEs: Value(instance.descriptionEs),
              descriptionEn: Value(instance.descriptionEn),
              habitatEs: Value(instance.habitatEs),
              habitatEn: Value(instance.habitatEn),
              heroImageUrl: Value(instance.heroImageUrl),
              thumbnailUrl: Value(instance.thumbnailUrl),
              isEndemic: Value(instance.isEndemic),
              taxonomyKingdom: Value(instance.taxonomyKingdom),
              taxonomyPhylum: Value(instance.taxonomyPhylum),
              taxonomyClass: Value(instance.taxonomyClass),
              taxonomyOrder: Value(instance.taxonomyOrder),
              taxonomyFamily: Value(instance.taxonomyFamily),
              taxonomyGenus: Value(instance.taxonomyGenus),
              isNative: Value(instance.isNative),
              isIntroduced: Value(instance.isIntroduced),
              endemismLevel: Value(instance.endemismLevel),
              populationTrend: Value(instance.populationTrend),
              breedingSeason: Value(instance.breedingSeason),
              clutchSize: Value(instance.clutchSize),
              reproductiveFrequency: Value(instance.reproductiveFrequency),
              socialStructure: Value(instance.socialStructure),
              activityPattern: Value(instance.activityPattern),
              dietType: Value(instance.dietType),
              // NullableStringListConverter handles List<String>? <-> JSON text
              primaryFoodSources: Value(instance.primaryFoodSources),
              altitudeMinM: Value(instance.altitudeMinM),
              altitudeMaxM: Value(instance.altitudeMaxM),
              depthMinM: Value(instance.depthMinM),
              depthMaxM: Value(instance.depthMaxM),
              scientificNameAuthorship: Value(instance.scientificNameAuthorship),
              distinguishingFeaturesEs: Value(instance.distinguishingFeaturesEs),
              distinguishingFeaturesEn: Value(instance.distinguishingFeaturesEn),
              sexualDimorphism: Value(instance.sexualDimorphism),
              gbifTaxonId: Value(instance.gbifTaxonId),
              eolPageId: Value(instance.eolPageId),
              iucnAssessmentUrl: Value(instance.iucnAssessmentUrl),
              soundRecordingUrl: Value(instance.soundRecordingUrl),
              videoUrl: Value(instance.videoUrl),
              sizeMmFemaleMin: Value(instance.sizeMmFemaleMin),
              sizeMmFemaleMax: Value(instance.sizeMmFemaleMax),
              sizeMmMaleMin: Value(instance.sizeMmMaleMin),
              sizeMmMaleMax: Value(instance.sizeMmMaleMax),
              buildsWeb: Value(instance.buildsWeb),
              webType: Value(instance.webType),
              venomousToHumans: Value(instance.venomousToHumans),
              inaturalistTaxonId: Value(instance.inaturalistTaxonId),
              datazoneId: Value(instance.datazoneId),
            ),
          );
      return null;
    }
    if (instance is Sighting) {
      await _db.into(_db.sightings).insertOnConflictUpdate(
            db.SightingsCompanion(
              id: Value(instance.id),
              userId: Value(instance.userId),
              speciesId: Value(instance.speciesId),
              visitSiteId: Value(instance.visitSiteId),
              observedAt: Value(instance.observedAt),
              notes: Value(instance.notes),
              latitude: Value(instance.latitude),
              longitude: Value(instance.longitude),
              photoUrl: Value(instance.photoUrl),
            ),
          );
      return null;
    }
    if (instance is SpeciesImage) {
      await _db.into(_db.speciesImages).insertOnConflictUpdate(
            db.SpeciesImagesCompanion(
              id: Value(instance.id),
              speciesId: Value(instance.speciesId),
              imageUrl: Value(instance.imageUrl),
              captionEs: Value(instance.captionEs),
              captionEn: Value(instance.captionEn),
              sortOrder: Value(instance.sortOrder),
              isPrimary: Value(instance.isPrimary),
              thumbnailUrl: Value(instance.thumbnailUrl),
              cardThumbnailUrl: Value(instance.cardThumbnailUrl),
            ),
          );
      return null;
    }
    if (instance is SpeciesReference) {
      await _db.into(_db.speciesReferences).insertOnConflictUpdate(
            db.SpeciesReferencesCompanion(
              id: Value(instance.id),
              speciesId: Value(instance.speciesId),
              citation: Value(instance.citation),
              url: Value(instance.url),
              doi: Value(instance.doi),
              referenceType: Value(instance.referenceType),
            ),
          );
      return null;
    }
    if (instance is SpeciesSite) {
      await _db.into(_db.speciesSites).insertOnConflictUpdate(
            db.SpeciesSitesCompanion(
              id: Value(instance.id),
              speciesId: Value(instance.speciesId),
              visitSiteId: Value(instance.visitSiteId),
              frequency: Value(instance.frequency),
            ),
          );
      return null;
    }
    if (instance is SpeciesSound) {
      await _db.into(_db.speciesSounds).insertOnConflictUpdate(
            db.SpeciesSoundsCompanion(
              id: Value(instance.id),
              speciesId: Value(instance.speciesId),
              soundUrl: Value(instance.soundUrl),
              soundType: Value(instance.soundType),
              descriptionEs: Value(instance.descriptionEs),
              descriptionEn: Value(instance.descriptionEn),
              recordedBy: Value(instance.recordedBy),
              recordedDate: Value(instance.recordedDate),
            ),
          );
      return null;
    }
    if (instance is SpeciesThreat) {
      await _db.into(_db.speciesThreats).insertOnConflictUpdate(
            db.SpeciesThreatsCompanion(
              id: Value(instance.id),
              speciesId: Value(instance.speciesId),
              threatType: Value(instance.threatType),
              severity: Value(instance.severity ?? ''),
              descriptionEs: Value(instance.descriptionEs),
              descriptionEn: Value(instance.descriptionEn),
            ),
          );
      return null;
    }
    if (instance is Trail) {
      await _db.into(_db.trails).insertOnConflictUpdate(
            db.TrailsCompanion(
              id: Value(instance.id),
              nameEn: Value(instance.nameEn),
              nameEs: Value(instance.nameEs),
              descriptionEn: Value(instance.descriptionEn),
              descriptionEs: Value(instance.descriptionEs),
              islandId: Value(instance.islandId),
              visitSiteId: Value(instance.visitSiteId),
              difficulty: Value(instance.difficulty),
              distanceKm: Value(instance.distanceKm),
              estimatedMinutes: Value(instance.estimatedMinutes),
              coordinates: Value(instance.coordinates),
              elevationGainM: Value(instance.elevationGainM),
              userId: Value(instance.userId),
            ),
          );
      return null;
    }
    if (instance is UserFavorite) {
      await _db.into(_db.userFavorites).insertOnConflictUpdate(
            db.UserFavoritesCompanion(
              id: Value(instance.id),
              userId: Value(instance.userId),
              speciesId: Value(instance.speciesId),
            ),
          );
      return null;
    }
    if (instance is UserProfile) {
      await _db.into(_db.userProfiles).insertOnConflictUpdate(
            db.UserProfilesCompanion(
              id: Value(instance.id),
              displayName: Value(instance.displayName),
              bio: Value(instance.bio),
              birthDate: Value(instance.birthDate),
              country: Value(instance.country),
              countryCode: Value(instance.countryCode),
              avatarUrl: Value(instance.avatarUrl),
              createdAt: Value(instance.createdAt),
              updatedAt: Value(instance.updatedAt),
            ),
          );
      return null;
    }
    if (instance is UserSiteWishlist) {
      await _db.into(_db.userSiteWishlists).insertOnConflictUpdate(
            db.UserSiteWishlistsCompanion(
              id: Value(instance.id),
              userId: Value(instance.userId),
              visitSiteId: Value(instance.visitSiteId),
              createdAt: Value(instance.createdAt),
            ),
          );
      return null;
    }
    if (instance is UserSpeciesChecklist) {
      await _db.into(_db.userSpeciesChecklists).insertOnConflictUpdate(
            db.UserSpeciesChecklistsCompanion(
              id: Value(instance.id),
              userId: Value(instance.userId),
              speciesId: Value(instance.speciesId),
              seenAt: Value(instance.seenAt),
            ),
          );
      return null;
    }
    if (instance is VisitSite) {
      await _db.into(_db.visitSites).insertOnConflictUpdate(
            db.VisitSitesCompanion(
              id: Value(instance.id),
              islandId: Value(instance.islandId),
              nameEs: Value(instance.nameEs),
              nameEn: Value(instance.nameEn),
              latitude: Value(instance.latitude),
              longitude: Value(instance.longitude),
              descriptionEs: Value(instance.descriptionEs),
              descriptionEn: Value(instance.descriptionEn),
              monitoringType: Value(instance.monitoringType),
              difficulty: Value(instance.difficulty),
              conservationZone: Value(instance.conservationZone),
              publicUseZone: Value(instance.publicUseZone),
              capacity: Value(instance.capacity),
              status: Value(instance.status),
              attractionEs: Value(instance.attractionEs),
              abbreviation: Value(instance.abbreviation),
              parkId: Value(instance.parkId),
            ),
          );
      return null;
    }
    throw UnsupportedError('upsertLocal: no handler for ${instance.runtimeType}');
  }

  // ---------------------------------------------------------------------------
  // deleteLocal
  // ---------------------------------------------------------------------------

  @override
  Future<void> deleteLocal<T extends OfflineFirstWithSupabaseModel>(
    T instance,
  ) async {
    if (instance is Category) {
      await (_db.delete(_db.categories)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    if (instance is Island) {
      await (_db.delete(_db.islands)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    if (instance is Species) {
      await (_db.delete(_db.speciesRows)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    if (instance is Sighting) {
      await (_db.delete(_db.sightings)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    if (instance is SpeciesImage) {
      await (_db.delete(_db.speciesImages)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    if (instance is SpeciesReference) {
      await (_db.delete(_db.speciesReferences)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    if (instance is SpeciesSite) {
      await (_db.delete(_db.speciesSites)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    if (instance is SpeciesSound) {
      await (_db.delete(_db.speciesSounds)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    if (instance is SpeciesThreat) {
      await (_db.delete(_db.speciesThreats)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    if (instance is Trail) {
      await (_db.delete(_db.trails)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    if (instance is UserFavorite) {
      await (_db.delete(_db.userFavorites)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    if (instance is UserProfile) {
      // UserProfile.id is String — t.id.equals() handles String correctly.
      await (_db.delete(_db.userProfiles)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    if (instance is UserSiteWishlist) {
      await (_db.delete(_db.userSiteWishlists)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    if (instance is UserSpeciesChecklist) {
      await (_db.delete(_db.userSpeciesChecklists)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    if (instance is VisitSite) {
      await (_db.delete(_db.visitSites)
            ..where((t) => t.id.equals(instance.id)))
          .go();
      return;
    }
    throw UnsupportedError('deleteLocal: no handler for ${instance.runtimeType}');
  }

  // ---------------------------------------------------------------------------
  // watchLocal
  // ---------------------------------------------------------------------------

  @override
  Stream<List<T>> watchLocal<T extends OfflineFirstWithSupabaseModel>({
    Query? query,
  }) {
    if (T == Category) {
      return _categoryTransformer
          .applyToWatch(_db.select(_db.categories), query)
          .map((rows) => rows.map(_rowToCategory).toList().cast<T>());
    }
    if (T == Island) {
      return _islandTransformer
          .applyToWatch(_db.select(_db.islands), query)
          .map((rows) => rows.map(_rowToIsland).toList().cast<T>());
    }
    if (T == Species) {
      return _speciesTransformer
          .applyToWatch(_db.select(_db.speciesRows), query)
          .map((rows) => rows.map(_rowToSpecies).toList().cast<T>());
    }
    if (T == Sighting) {
      return _sightingTransformer
          .applyToWatch(_db.select(_db.sightings), query)
          .map((rows) => rows.map(_rowToSighting).toList().cast<T>());
    }
    if (T == SpeciesImage) {
      return _speciesImageTransformer
          .applyToWatch(_db.select(_db.speciesImages), query)
          .map((rows) => rows.map(_rowToSpeciesImage).toList().cast<T>());
    }
    if (T == SpeciesReference) {
      return _speciesReferenceTransformer
          .applyToWatch(_db.select(_db.speciesReferences), query)
          .map((rows) => rows.map(_rowToSpeciesReference).toList().cast<T>());
    }
    if (T == SpeciesSite) {
      return _speciesSiteTransformer
          .applyToWatch(_db.select(_db.speciesSites), query)
          .map((rows) => rows.map(_rowToSpeciesSite).toList().cast<T>());
    }
    if (T == SpeciesSound) {
      return _speciesSoundTransformer
          .applyToWatch(_db.select(_db.speciesSounds), query)
          .map((rows) => rows.map(_rowToSpeciesSound).toList().cast<T>());
    }
    if (T == SpeciesThreat) {
      return _speciesThreatTransformer
          .applyToWatch(_db.select(_db.speciesThreats), query)
          .map((rows) => rows.map(_rowToSpeciesThreat).toList().cast<T>());
    }
    if (T == Trail) {
      return _trailTransformer
          .applyToWatch(_db.select(_db.trails), query)
          .map((rows) => rows.map(_rowToTrail).toList().cast<T>());
    }
    if (T == UserFavorite) {
      return _userFavoriteTransformer
          .applyToWatch(_db.select(_db.userFavorites), query)
          .map((rows) => rows.map(_rowToUserFavorite).toList().cast<T>());
    }
    if (T == UserProfile) {
      return _userProfileTransformer
          .applyToWatch(_db.select(_db.userProfiles), query)
          .map((rows) => rows.map(_rowToUserProfile).toList().cast<T>());
    }
    if (T == UserSiteWishlist) {
      return _userSiteWishlistTransformer
          .applyToWatch(_db.select(_db.userSiteWishlists), query)
          .map((rows) => rows.map(_rowToUserSiteWishlist).toList().cast<T>());
    }
    if (T == UserSpeciesChecklist) {
      return _userSpeciesChecklistTransformer
          .applyToWatch(_db.select(_db.userSpeciesChecklists), query)
          .map((rows) => rows.map(_rowToUserSpeciesChecklist).toList().cast<T>());
    }
    if (T == VisitSite) {
      return _visitSiteTransformer
          .applyToWatch(_db.select(_db.visitSites), query)
          .map((rows) => rows.map(_rowToVisitSite).toList().cast<T>());
    }
    return super.watchLocal<T>(query: query);
  }

  // ---------------------------------------------------------------------------
  // Row -> Model helpers (Drift data class -> app model)
  //
  // Drift generates data classes whose names collide with our model names.
  // The `db.` prefix selects the Drift-generated row type; the return type
  // (no prefix) is the app model.
  // ---------------------------------------------------------------------------

  Category _rowToCategory(db.Category r) => Category(
        id: r.id,
        slug: r.slug,
        nameEs: r.nameEs,
        nameEn: r.nameEn,
        iconName: r.iconName,
        sortOrder: r.sortOrder,
      );

  Island _rowToIsland(db.Island r) => Island(
        id: r.id,
        nameEs: r.nameEs,
        nameEn: r.nameEn,
        latitude: r.latitude,
        longitude: r.longitude,
        areaKm2: r.areaKm2,
        areaHa: r.areaHa,
        descriptionEs: r.descriptionEs,
        descriptionEn: r.descriptionEn,
        parkId: r.parkId,
        islandType: r.islandType,
        classification: r.classification,
        isPopulated: r.isPopulated,
      );

  /// [db.SpeciesRow] is the Drift data class generated from [SpeciesRows]
  /// (which has `@DataClassName('SpeciesRow')`).
  Species _rowToSpecies(db.SpeciesRow r) => Species(
        id: r.id,
        categoryId: r.categoryId,
        commonNameEs: r.commonNameEs,
        commonNameEn: r.commonNameEn,
        scientificName: r.scientificName,
        conservationStatus: r.conservationStatus,
        weightKg: r.weightKg,
        sizeCm: r.sizeCm,
        populationEstimate: r.populationEstimate,
        lifespanYears: r.lifespanYears,
        descriptionEs: r.descriptionEs,
        descriptionEn: r.descriptionEn,
        habitatEs: r.habitatEs,
        habitatEn: r.habitatEn,
        heroImageUrl: r.heroImageUrl,
        thumbnailUrl: r.thumbnailUrl,
        isEndemic: r.isEndemic,
        taxonomyKingdom: r.taxonomyKingdom,
        taxonomyPhylum: r.taxonomyPhylum,
        taxonomyClass: r.taxonomyClass,
        taxonomyOrder: r.taxonomyOrder,
        taxonomyFamily: r.taxonomyFamily,
        taxonomyGenus: r.taxonomyGenus,
        isNative: r.isNative,
        isIntroduced: r.isIntroduced,
        endemismLevel: r.endemismLevel,
        populationTrend: r.populationTrend,
        breedingSeason: r.breedingSeason,
        clutchSize: r.clutchSize,
        reproductiveFrequency: r.reproductiveFrequency,
        socialStructure: r.socialStructure,
        activityPattern: r.activityPattern,
        dietType: r.dietType,
        // NullableStringListConverter already decoded JSON -> List<String>?
        primaryFoodSources: r.primaryFoodSources,
        altitudeMinM: r.altitudeMinM,
        altitudeMaxM: r.altitudeMaxM,
        depthMinM: r.depthMinM,
        depthMaxM: r.depthMaxM,
        scientificNameAuthorship: r.scientificNameAuthorship,
        distinguishingFeaturesEs: r.distinguishingFeaturesEs,
        distinguishingFeaturesEn: r.distinguishingFeaturesEn,
        sexualDimorphism: r.sexualDimorphism,
        gbifTaxonId: r.gbifTaxonId,
        eolPageId: r.eolPageId,
        iucnAssessmentUrl: r.iucnAssessmentUrl,
        soundRecordingUrl: r.soundRecordingUrl,
        videoUrl: r.videoUrl,
        sizeMmFemaleMin: r.sizeMmFemaleMin,
        sizeMmFemaleMax: r.sizeMmFemaleMax,
        sizeMmMaleMin: r.sizeMmMaleMin,
        sizeMmMaleMax: r.sizeMmMaleMax,
        buildsWeb: r.buildsWeb,
        webType: r.webType,
        venomousToHumans: r.venomousToHumans,
        inaturalistTaxonId: r.inaturalistTaxonId,
        datazoneId: r.datazoneId,
      );

  Sighting _rowToSighting(db.Sighting r) => Sighting(
        id: r.id,
        userId: r.userId,
        speciesId: r.speciesId,
        visitSiteId: r.visitSiteId,
        observedAt: r.observedAt,
        notes: r.notes,
        latitude: r.latitude,
        longitude: r.longitude,
        photoUrl: r.photoUrl,
      );

  SpeciesImage _rowToSpeciesImage(db.SpeciesImage r) => SpeciesImage(
        id: r.id,
        speciesId: r.speciesId,
        imageUrl: r.imageUrl,
        captionEs: r.captionEs,
        captionEn: r.captionEn,
        sortOrder: r.sortOrder,
        isPrimary: r.isPrimary,
        thumbnailUrl: r.thumbnailUrl,
        cardThumbnailUrl: r.cardThumbnailUrl,
      );

  SpeciesReference _rowToSpeciesReference(db.SpeciesReference r) =>
      SpeciesReference(
        id: r.id,
        speciesId: r.speciesId,
        citation: r.citation,
        url: r.url,
        doi: r.doi,
        referenceType: r.referenceType,
      );

  SpeciesSite _rowToSpeciesSite(db.SpeciesSite r) => SpeciesSite(
        id: r.id,
        speciesId: r.speciesId,
        visitSiteId: r.visitSiteId,
        frequency: r.frequency,
      );

  SpeciesSound _rowToSpeciesSound(db.SpeciesSound r) => SpeciesSound(
        id: r.id,
        speciesId: r.speciesId,
        soundUrl: r.soundUrl,
        soundType: r.soundType,
        descriptionEs: r.descriptionEs,
        descriptionEn: r.descriptionEn,
        recordedBy: r.recordedBy,
        recordedDate: r.recordedDate,
      );

  SpeciesThreat _rowToSpeciesThreat(db.SpeciesThreat r) => SpeciesThreat(
        id: r.id,
        speciesId: r.speciesId,
        threatType: r.threatType,
        severity: r.severity,
        descriptionEs: r.descriptionEs,
        descriptionEn: r.descriptionEn,
      );

  Trail _rowToTrail(db.Trail r) => Trail(
        id: r.id,
        nameEn: r.nameEn,
        nameEs: r.nameEs,
        descriptionEn: r.descriptionEn,
        descriptionEs: r.descriptionEs,
        islandId: r.islandId,
        visitSiteId: r.visitSiteId,
        difficulty: r.difficulty,
        distanceKm: r.distanceKm,
        estimatedMinutes: r.estimatedMinutes,
        coordinates: r.coordinates,
        elevationGainM: r.elevationGainM,
        userId: r.userId,
      );

  UserFavorite _rowToUserFavorite(db.UserFavorite r) => UserFavorite(
        id: r.id,
        userId: r.userId,
        speciesId: r.speciesId,
      );

  UserProfile _rowToUserProfile(db.UserProfile r) => UserProfile(
        id: r.id,
        displayName: r.displayName,
        bio: r.bio,
        birthDate: r.birthDate,
        country: r.country,
        countryCode: r.countryCode,
        avatarUrl: r.avatarUrl,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  UserSiteWishlist _rowToUserSiteWishlist(db.UserSiteWishlist r) =>
      UserSiteWishlist(
        id: r.id,
        userId: r.userId,
        visitSiteId: r.visitSiteId,
        createdAt: r.createdAt,
      );

  UserSpeciesChecklist _rowToUserSpeciesChecklist(
    db.UserSpeciesChecklist r,
  ) =>
      UserSpeciesChecklist(
        id: r.id,
        userId: r.userId,
        speciesId: r.speciesId,
        seenAt: r.seenAt,
      );

  VisitSite _rowToVisitSite(db.VisitSite r) => VisitSite(
        id: r.id,
        islandId: r.islandId,
        nameEs: r.nameEs,
        nameEn: r.nameEn,
        latitude: r.latitude,
        longitude: r.longitude,
        descriptionEs: r.descriptionEs,
        descriptionEn: r.descriptionEn,
        monitoringType: r.monitoringType,
        difficulty: r.difficulty,
        conservationZone: r.conservationZone,
        publicUseZone: r.publicUseZone,
        capacity: r.capacity,
        status: r.status,
        attractionEs: r.attractionEs,
        abbreviation: r.abbreviation,
        parkId: r.parkId,
      );
}
