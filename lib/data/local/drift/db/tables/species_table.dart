import 'package:drift/drift.dart';
import '../converters.dart';

@DataClassName('SpeciesRow')
class SpeciesRows extends Table {
  @override
  String get tableName => 'species';

  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get categoryId => integer()();
  TextColumn get commonNameEs => text()();
  TextColumn get commonNameEn => text()();
  TextColumn get scientificName => text()();
  TextColumn get conservationStatus => text().nullable()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get sizeCm => real().nullable()();
  IntColumn get populationEstimate => integer().nullable()();
  IntColumn get lifespanYears => integer().nullable()();
  TextColumn get descriptionEs => text().nullable()();
  TextColumn get descriptionEn => text().nullable()();
  TextColumn get habitatEs => text().nullable()();
  TextColumn get habitatEn => text().nullable()();
  TextColumn get heroImageUrl => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  BoolColumn get isEndemic =>
      boolean().withDefault(const Constant(false))();
  TextColumn get taxonomyKingdom => text().nullable()();
  TextColumn get taxonomyPhylum => text().nullable()();
  TextColumn get taxonomyClass => text().nullable()();
  TextColumn get taxonomyOrder => text().nullable()();
  TextColumn get taxonomyFamily => text().nullable()();
  TextColumn get taxonomyGenus => text().nullable()();
  BoolColumn get isNative => boolean().nullable()();
  BoolColumn get isIntroduced => boolean().nullable()();
  TextColumn get endemismLevel => text().nullable()();
  TextColumn get populationTrend => text().nullable()();
  TextColumn get breedingSeason => text().nullable()();
  TextColumn get clutchSize => text().nullable()();
  TextColumn get reproductiveFrequency => text().nullable()();
  TextColumn get socialStructure => text().nullable()();
  TextColumn get activityPattern => text().nullable()();
  TextColumn get dietType => text().nullable()();
  TextColumn get primaryFoodSources =>
      text().nullable().map(const NullableStringListConverter())();
  IntColumn get altitudeMinM => integer().nullable()();
  IntColumn get altitudeMaxM => integer().nullable()();
  IntColumn get depthMinM => integer().nullable()();
  IntColumn get depthMaxM => integer().nullable()();
  TextColumn get scientificNameAuthorship => text().nullable()();
  TextColumn get distinguishingFeaturesEs => text().nullable()();
  TextColumn get distinguishingFeaturesEn => text().nullable()();
  TextColumn get sexualDimorphism => text().nullable()();
  TextColumn get gbifTaxonId => text().nullable()();
  TextColumn get eolPageId => text().nullable()();
  TextColumn get iucnAssessmentUrl => text().nullable()();
  TextColumn get soundRecordingUrl => text().nullable()();
  TextColumn get videoUrl => text().nullable()();
  RealColumn get sizeMmFemaleMin => real().nullable()();
  RealColumn get sizeMmFemaleMax => real().nullable()();
  RealColumn get sizeMmMaleMin => real().nullable()();
  RealColumn get sizeMmMaleMax => real().nullable()();
  BoolColumn get buildsWeb => boolean().nullable()();
  TextColumn get webType => text().nullable()();
  BoolColumn get venomousToHumans => boolean().nullable()();
  IntColumn get inaturalistTaxonId => integer().nullable()();
  IntColumn get datazoneId => integer().nullable()();
}
