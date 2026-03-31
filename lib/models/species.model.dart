import 'package:drift_offline_first_with_supabase/drift_offline_first_with_supabase.dart';

class Species extends OfflineFirstWithSupabaseModel {
  final int id;

  final int categoryId;

  final String commonNameEs;

  final String commonNameEn;

  final String scientificName;

  final String? conservationStatus;

  final double? weightKg;

  final double? sizeCm;

  final int? populationEstimate;

  final int? lifespanYears;

  final String? descriptionEs;

  final String? descriptionEn;

  final String? habitatEs;

  final String? habitatEn;

  final String? heroImageUrl;

  final String? thumbnailUrl;

  final bool isEndemic;

  final String? taxonomyKingdom;

  final String? taxonomyPhylum;

  final String? taxonomyClass;

  final String? taxonomyOrder;

  final String? taxonomyFamily;

  final String? taxonomyGenus;

  // Endemismo
  final bool? isNative;

  final bool? isIntroduced;

  final String? endemismLevel;

  // Tendencia y Reproduccion
  final String? populationTrend;

  final String? breedingSeason;

  final String? clutchSize;

  final String? reproductiveFrequency;

  // Comportamiento
  final String? socialStructure;

  final String? activityPattern;

  final String? dietType;

  final List<String>? primaryFoodSources;

  // Rangos
  final int? altitudeMinM;

  final int? altitudeMaxM;

  final int? depthMinM;

  final int? depthMaxM;

  // Caracteristicas
  final String? scientificNameAuthorship;

  final String? distinguishingFeaturesEs;

  final String? distinguishingFeaturesEn;

  final String? sexualDimorphism;

  // IDs externos
  final String? gbifTaxonId;

  final String? eolPageId;

  final String? iucnAssessmentUrl;

  // Multimedia
  final String? soundRecordingUrl;

  final String? videoUrl;

  // Aracnidos — tamanos por sexo (mm)
  final double? sizeMmFemaleMin;

  final double? sizeMmFemaleMax;

  final double? sizeMmMaleMin;

  final double? sizeMmMaleMax;

  // Aracnidos — comportamiento
  final bool? buildsWeb;

  final String? webType;

  final bool? venomousToHumans;

  // IDs externos adicionales
  final int? inaturalistTaxonId;

  final int? datazoneId;

  @override
  Object? get primaryKey => id;

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
    // Tendencia y Reproduccion
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
    // Caracteristicas
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
    // Aracnidos
    this.sizeMmFemaleMin,
    this.sizeMmFemaleMax,
    this.sizeMmMaleMin,
    this.sizeMmMaleMax,
    this.buildsWeb,
    this.webType,
    this.venomousToHumans,
    this.inaturalistTaxonId,
    this.datazoneId,
  });
}
