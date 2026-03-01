import 'package:flutter_riverpod/legacy.dart';

class SpeciesFormState {
  final int? selectedClassId;
  final int? selectedOrderId;
  final int? selectedFamilyId;
  final int? selectedGenusId;
  final String? selectedConservationStatus;
  final bool isLoading;
  final String? errorMessage;

  const SpeciesFormState({
    this.selectedClassId,
    this.selectedOrderId,
    this.selectedFamilyId,
    this.selectedGenusId,
    this.selectedConservationStatus,
    this.isLoading = false,
    this.errorMessage,
  });

  SpeciesFormState copyWith({
    int? selectedClassId,
    int? selectedOrderId,
    int? selectedFamilyId,
    int? selectedGenusId,
    String? selectedConservationStatus,
    bool? isLoading,
    String? errorMessage,
    bool clearClass = false,
    bool clearOrder = false,
    bool clearFamily = false,
    bool clearGenus = false,
    bool clearStatus = false,
    bool clearError = false,
  }) {
    return SpeciesFormState(
      selectedClassId: clearClass ? null : (selectedClassId ?? this.selectedClassId),
      selectedOrderId: clearOrder ? null : (selectedOrderId ?? this.selectedOrderId),
      selectedFamilyId: clearFamily ? null : (selectedFamilyId ?? this.selectedFamilyId),
      selectedGenusId: clearGenus ? null : (selectedGenusId ?? this.selectedGenusId),
      selectedConservationStatus: clearStatus ? null : (selectedConservationStatus ?? this.selectedConservationStatus),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SpeciesFormNotifier extends StateNotifier<SpeciesFormState> {
  SpeciesFormNotifier() : super(const SpeciesFormState());

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

  void setLoading(bool loading) =>
      state = state.copyWith(isLoading: loading);

  void setError(String? message) => state = state.copyWith(
        errorMessage: message,
        clearError: message == null,
      );

  void reset() => state = const SpeciesFormState();

  void loadFromSpecies({
    int? classId,
    int? orderId,
    int? familyId,
    int? genusId,
    String? conservationStatus,
  }) {
    state = SpeciesFormState(
      selectedClassId: classId,
      selectedOrderId: orderId,
      selectedFamilyId: familyId,
      selectedGenusId: genusId,
      selectedConservationStatus: conservationStatus,
    );
  }
}

final speciesFormProvider =
    StateNotifierProvider.autoDispose<SpeciesFormNotifier, SpeciesFormState>(
        (ref) => SpeciesFormNotifier());
