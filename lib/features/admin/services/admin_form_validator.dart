import 'package:flutter/material.dart';

/// Result of form validation.
class AdminFormValidationResult {
  final bool isValid;
  final String? errorMessage;
  final int firstErrorTabIndex; // 0-based, for TabController.animateTo()

  const AdminFormValidationResult.valid()
      : isValid = true,
        errorMessage = null,
        firstErrorTabIndex = 0;

  const AdminFormValidationResult.invalid({
    required this.errorMessage,
    this.firstErrorTabIndex = 0,
  }) : isValid = false;
}

/// Reusable validation logic for admin forms.
class AdminFormValidator {
  /// Validates the species form.
  ///
  /// Runs Flutter's built-in [FormState.validate] first (which shows inline
  /// errors on required text fields), then checks that a category has been
  /// selected.  Returns a result with [firstErrorTabIndex] set to the tab that
  /// contains the first error so the caller can animate to it.
  ///
  /// Tab layout (3 tabs):
  ///   0 – General  (nameEs, nameEn, scientificName, category, physical, …)
  ///   1 – Description
  ///   2 – Details
  static AdminFormValidationResult validateSpecies({
    required GlobalKey<FormState> formKey,
    required String nameEs,
    required String nameEn,
    required String scientificName,
    required int? categoryId,
  }) {
    // Run Flutter inline validators (marks fields red, etc.)
    final formValid = formKey.currentState!.validate();

    if (!formValid) {
      // Determine which tab to navigate to based on which required fields
      // on the General tab are empty.  Descriptions / details are on tabs 1–2
      // but those fields are all optional, so any inline error is on tab 0.
      final basicHasError = nameEs.trim().isEmpty ||
          nameEn.trim().isEmpty ||
          scientificName.trim().isEmpty ||
          categoryId == null;
      final tabIndex = basicHasError ? 0 : 0;
      return AdminFormValidationResult.invalid(
        errorMessage: null, // Flutter shows inline errors
        firstErrorTabIndex: tabIndex,
      );
    }

    if (categoryId == null) {
      return const AdminFormValidationResult.invalid(
        errorMessage: 'Category is required', // caller uses i18n key instead
        firstErrorTabIndex: 0,
      );
    }

    return const AdminFormValidationResult.valid();
  }

  /// Validates the visit site form.
  ///
  /// Island is optional (the form shows a confirmation dialog if absent, which
  /// is handled by the screen itself).  This validator only checks the Flutter
  /// form fields and, if provided, that coordinates are present.
  ///
  /// The visit site form has no tab controller (single-page layout), so
  /// [firstErrorTabIndex] is always 0.
  static AdminFormValidationResult validateVisitSite({
    required GlobalKey<FormState> formKey,
    double? latitude,
    double? longitude,
  }) {
    if (!formKey.currentState!.validate()) {
      return const AdminFormValidationResult.invalid(
        errorMessage: null, // Flutter shows inline errors
        firstErrorTabIndex: 0,
      );
    }
    // Coordinates are optional for visit sites (may be null when not yet placed
    // on the map).  Callers may pass requireCoordinates logic separately.
    return const AdminFormValidationResult.valid();
  }
}
