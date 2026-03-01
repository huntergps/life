import 'package:flutter_riverpod/legacy.dart';

class SpeciesFormState {
  // Taxonomy selectors
  final int? selectedClassId;
  final int? selectedOrderId;
  final int? selectedFamilyId;
  final int? selectedGenusId;

  // Conservation status (also stored in provider for external access)
  final String? selectedConservationStatus;

  // ── Text field string values (mirrors the TextEditingControllers) ──
  final String nameEs;
  final String nameEn;
  final String scientificName;
  final String weight;
  final String size;
  final String population;
  final String lifespan;
  final String descEs;
  final String descEn;
  final String habitatEs;
  final String habitatEn;
  final String distinguishingFeaturesEs;
  final String distinguishingFeaturesEn;
  final String primaryFoodSources;
  final String breedingSeason;
  final String clutchSize;
  final String reproductiveFrequency;
  final String altitudeMin;
  final String altitudeMax;
  final String depthMin;
  final String depthMax;

  // ── Non-text form state ──
  final int? selectedCategoryId;
  final bool isEndemic;
  final bool isNative;
  final bool isIntroduced;
  final String? endemismLevel;
  final String? populationTrend;
  final String? socialStructure;
  final String? activityPattern;
  final String? dietType;
  final bool sexualDimorphism;

  // ── UI state ──
  final bool isLoading;
  final bool hasUnsavedChanges;
  final bool initialized;
  final String? errorMessage;

  const SpeciesFormState({
    this.selectedClassId,
    this.selectedOrderId,
    this.selectedFamilyId,
    this.selectedGenusId,
    this.selectedConservationStatus,
    // Text fields
    this.nameEs = '',
    this.nameEn = '',
    this.scientificName = '',
    this.weight = '',
    this.size = '',
    this.population = '',
    this.lifespan = '',
    this.descEs = '',
    this.descEn = '',
    this.habitatEs = '',
    this.habitatEn = '',
    this.distinguishingFeaturesEs = '',
    this.distinguishingFeaturesEn = '',
    this.primaryFoodSources = '',
    this.breedingSeason = '',
    this.clutchSize = '',
    this.reproductiveFrequency = '',
    this.altitudeMin = '',
    this.altitudeMax = '',
    this.depthMin = '',
    this.depthMax = '',
    // Non-text form state
    this.selectedCategoryId,
    this.isEndemic = false,
    this.isNative = false,
    this.isIntroduced = false,
    this.endemismLevel,
    this.populationTrend,
    this.socialStructure,
    this.activityPattern,
    this.dietType,
    this.sexualDimorphism = false,
    // UI state
    this.isLoading = false,
    this.hasUnsavedChanges = false,
    this.initialized = false,
    this.errorMessage,
  });

  SpeciesFormState copyWith({
    int? selectedClassId,
    int? selectedOrderId,
    int? selectedFamilyId,
    int? selectedGenusId,
    String? selectedConservationStatus,
    // Text fields
    String? nameEs,
    String? nameEn,
    String? scientificName,
    String? weight,
    String? size,
    String? population,
    String? lifespan,
    String? descEs,
    String? descEn,
    String? habitatEs,
    String? habitatEn,
    String? distinguishingFeaturesEs,
    String? distinguishingFeaturesEn,
    String? primaryFoodSources,
    String? breedingSeason,
    String? clutchSize,
    String? reproductiveFrequency,
    String? altitudeMin,
    String? altitudeMax,
    String? depthMin,
    String? depthMax,
    // Non-text form state
    int? selectedCategoryId,
    bool? isEndemic,
    bool? isNative,
    bool? isIntroduced,
    String? endemismLevel,
    String? populationTrend,
    String? socialStructure,
    String? activityPattern,
    String? dietType,
    bool? sexualDimorphism,
    // UI state
    bool? isLoading,
    bool? hasUnsavedChanges,
    bool? initialized,
    String? errorMessage,
    // Clear flags for nullable fields
    bool clearClass = false,
    bool clearOrder = false,
    bool clearFamily = false,
    bool clearGenus = false,
    bool clearStatus = false,
    bool clearError = false,
    bool clearCategory = false,
    bool clearEndemismLevel = false,
    bool clearPopulationTrend = false,
    bool clearSocialStructure = false,
    bool clearActivityPattern = false,
    bool clearDietType = false,
  }) {
    return SpeciesFormState(
      selectedClassId: clearClass ? null : (selectedClassId ?? this.selectedClassId),
      selectedOrderId: clearOrder ? null : (selectedOrderId ?? this.selectedOrderId),
      selectedFamilyId: clearFamily ? null : (selectedFamilyId ?? this.selectedFamilyId),
      selectedGenusId: clearGenus ? null : (selectedGenusId ?? this.selectedGenusId),
      selectedConservationStatus: clearStatus ? null : (selectedConservationStatus ?? this.selectedConservationStatus),
      // Text fields
      nameEs: nameEs ?? this.nameEs,
      nameEn: nameEn ?? this.nameEn,
      scientificName: scientificName ?? this.scientificName,
      weight: weight ?? this.weight,
      size: size ?? this.size,
      population: population ?? this.population,
      lifespan: lifespan ?? this.lifespan,
      descEs: descEs ?? this.descEs,
      descEn: descEn ?? this.descEn,
      habitatEs: habitatEs ?? this.habitatEs,
      habitatEn: habitatEn ?? this.habitatEn,
      distinguishingFeaturesEs: distinguishingFeaturesEs ?? this.distinguishingFeaturesEs,
      distinguishingFeaturesEn: distinguishingFeaturesEn ?? this.distinguishingFeaturesEn,
      primaryFoodSources: primaryFoodSources ?? this.primaryFoodSources,
      breedingSeason: breedingSeason ?? this.breedingSeason,
      clutchSize: clutchSize ?? this.clutchSize,
      reproductiveFrequency: reproductiveFrequency ?? this.reproductiveFrequency,
      altitudeMin: altitudeMin ?? this.altitudeMin,
      altitudeMax: altitudeMax ?? this.altitudeMax,
      depthMin: depthMin ?? this.depthMin,
      depthMax: depthMax ?? this.depthMax,
      // Non-text form state
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      isEndemic: isEndemic ?? this.isEndemic,
      isNative: isNative ?? this.isNative,
      isIntroduced: isIntroduced ?? this.isIntroduced,
      endemismLevel: clearEndemismLevel ? null : (endemismLevel ?? this.endemismLevel),
      populationTrend: clearPopulationTrend ? null : (populationTrend ?? this.populationTrend),
      socialStructure: clearSocialStructure ? null : (socialStructure ?? this.socialStructure),
      activityPattern: clearActivityPattern ? null : (activityPattern ?? this.activityPattern),
      dietType: clearDietType ? null : (dietType ?? this.dietType),
      sexualDimorphism: sexualDimorphism ?? this.sexualDimorphism,
      // UI state
      isLoading: isLoading ?? this.isLoading,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      initialized: initialized ?? this.initialized,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SpeciesFormNotifier extends StateNotifier<SpeciesFormState> {
  SpeciesFormNotifier() : super(const SpeciesFormState());

  // ── Taxonomy selectors ──

  void setClass(int? id) => state = state.copyWith(
        selectedClassId: id,
        clearClass: id == null,
        clearOrder: true,
        clearFamily: true,
        clearGenus: true,
      );

  void setOrder(int? id) => state = state.copyWith(
        selectedOrderId: id,
        clearOrder: id == null,
        clearFamily: true,
        clearGenus: true,
      );

  void setFamily(int? id) => state = state.copyWith(
        selectedFamilyId: id,
        clearFamily: id == null,
        clearGenus: true,
      );

  void setGenus(int? id) => state = state.copyWith(
        selectedGenusId: id,
        clearGenus: id == null,
      );

  void setConservationStatus(String? status) => state = state.copyWith(
        selectedConservationStatus: status,
        clearStatus: status == null,
      );

  // ── Text field updater ──

  /// Update a single text field value in the provider state.
  /// [fieldName] matches the field names used in [loadFromSpecies].
  void updateField(String fieldName, String value) {
    state = switch (fieldName) {
      'nameEs' => state.copyWith(nameEs: value),
      'nameEn' => state.copyWith(nameEn: value),
      'scientificName' => state.copyWith(scientificName: value),
      'weight' => state.copyWith(weight: value),
      'size' => state.copyWith(size: value),
      'population' => state.copyWith(population: value),
      'lifespan' => state.copyWith(lifespan: value),
      'descEs' => state.copyWith(descEs: value),
      'descEn' => state.copyWith(descEn: value),
      'habitatEs' => state.copyWith(habitatEs: value),
      'habitatEn' => state.copyWith(habitatEn: value),
      'distinguishingFeaturesEs' => state.copyWith(distinguishingFeaturesEs: value),
      'distinguishingFeaturesEn' => state.copyWith(distinguishingFeaturesEn: value),
      'primaryFoodSources' => state.copyWith(primaryFoodSources: value),
      'breedingSeason' => state.copyWith(breedingSeason: value),
      'clutchSize' => state.copyWith(clutchSize: value),
      'reproductiveFrequency' => state.copyWith(reproductiveFrequency: value),
      'altitudeMin' => state.copyWith(altitudeMin: value),
      'altitudeMax' => state.copyWith(altitudeMax: value),
      'depthMin' => state.copyWith(depthMin: value),
      'depthMax' => state.copyWith(depthMax: value),
      _ => state,
    };
  }

  // ── Non-text form state setters ──

  void setCategory(int? id) => state = state.copyWith(
        selectedCategoryId: id,
        clearCategory: id == null,
      );

  void setIsEndemic(bool v) => state = state.copyWith(isEndemic: v);
  void setIsNative(bool v) => state = state.copyWith(isNative: v);
  void setIsIntroduced(bool v) => state = state.copyWith(isIntroduced: v);
  void setEndemismLevel(String? v) => state = state.copyWith(
        endemismLevel: v,
        clearEndemismLevel: v == null,
      );
  void setPopulationTrend(String? v) => state = state.copyWith(
        populationTrend: v,
        clearPopulationTrend: v == null,
      );
  void setSocialStructure(String? v) => state = state.copyWith(
        socialStructure: v,
        clearSocialStructure: v == null,
      );
  void setActivityPattern(String? v) => state = state.copyWith(
        activityPattern: v,
        clearActivityPattern: v == null,
      );
  void setDietType(String? v) => state = state.copyWith(
        dietType: v,
        clearDietType: v == null,
      );
  void setSexualDimorphism(bool v) => state = state.copyWith(sexualDimorphism: v);

  // ── UI state ──

  void setLoading(bool loading) =>
      state = state.copyWith(isLoading: loading);

  void setUnsaved(bool v) => state = state.copyWith(hasUnsavedChanges: v);

  void setInitialized(bool v) => state = state.copyWith(initialized: v);

  void setError(String? message) => state = state.copyWith(
        errorMessage: message,
        clearError: message == null,
      );

  // ── Bulk load ──

  /// Populate ALL fields from a raw Supabase data map (same map used by
  /// [_populateFields] in the form screen).
  void loadFromSpecies({
    // Taxonomy ids (legacy positional params kept for compatibility)
    int? classId,
    int? orderId,
    int? familyId,
    int? genusId,
    String? conservationStatus,
    // Extended fields from raw data map
    Map<String, dynamic>? data,
  }) {
    final d = data;
    state = SpeciesFormState(
      // Taxonomy
      selectedClassId: classId ?? (d != null ? null : null),
      selectedOrderId: orderId,
      selectedFamilyId: familyId,
      selectedGenusId: genusId ?? (d?['genus_id'] as int?),
      selectedConservationStatus: conservationStatus ?? (d?['conservation_status'] as String?),
      // Text fields
      nameEs: d?['common_name_es'] as String? ?? '',
      nameEn: d?['common_name_en'] as String? ?? '',
      scientificName: d?['scientific_name'] as String? ?? '',
      weight: _numToStr(d?['weight_kg']),
      size: _numToStr(d?['size_cm']),
      population: _numToStr(d?['population_estimate']),
      lifespan: _numToStr(d?['lifespan_years']),
      descEs: d?['description_es'] as String? ?? '',
      descEn: d?['description_en'] as String? ?? '',
      habitatEs: d?['habitat_es'] as String? ?? '',
      habitatEn: d?['habitat_en'] as String? ?? '',
      distinguishingFeaturesEs: d?['distinguishing_features_es'] as String? ?? '',
      distinguishingFeaturesEn: d?['distinguishing_features_en'] as String? ?? '',
      primaryFoodSources: d?['primary_food_sources'] as String? ?? '',
      breedingSeason: d?['breeding_season'] as String? ?? '',
      clutchSize: _numToStr(d?['clutch_size']),
      reproductiveFrequency: d?['reproductive_frequency'] as String? ?? '',
      altitudeMin: _numToStr(d?['altitude_min_m']),
      altitudeMax: _numToStr(d?['altitude_max_m']),
      depthMin: _numToStr(d?['depth_min_m']),
      depthMax: _numToStr(d?['depth_max_m']),
      // Non-text form state
      selectedCategoryId: d?['category_id'] as int?,
      isEndemic: d?['is_endemic'] as bool? ?? false,
      isNative: d?['is_native'] as bool? ?? false,
      isIntroduced: d?['is_introduced'] as bool? ?? false,
      endemismLevel: d?['endemism_level'] as String?,
      populationTrend: d?['population_trend'] as String?,
      socialStructure: d?['social_structure'] as String?,
      activityPattern: d?['activity_pattern'] as String?,
      dietType: d?['diet_type'] as String?,
      sexualDimorphism: d?['sexual_dimorphism'] as bool? ?? false,
      // UI state — mark as initialized, no unsaved changes yet
      initialized: d != null ? true : false,
      hasUnsavedChanges: false,
      isLoading: false,
    );
  }

  void reset() => state = const SpeciesFormState();
}

/// Convert a numeric (or null) DB value to an empty-string-friendly string.
String _numToStr(dynamic v) {
  if (v == null) return '';
  final s = '$v';
  // Strip trailing ".0" for cleaner display (e.g. "2.0" → "2.0" is fine,
  // but "null" should never reach here).
  return s == 'null' ? '' : s;
}

final speciesFormProvider =
    StateNotifierProvider.autoDispose<SpeciesFormNotifier, SpeciesFormState>(
        (ref) => SpeciesFormNotifier());
