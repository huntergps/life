import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemma_species_service.dart';

/// Current status of the Gemma 4 E2B model
final gemmaModelStatusProvider = FutureProvider<GemmaModelStatus>((ref) async {
  return GemmaSpeciesService.checkStatus();
});

/// Whether Gemma is available for identification
final gemmaAvailableProvider = FutureProvider<bool>((ref) async {
  final status = await ref.watch(gemmaModelStatusProvider.future);
  return status == GemmaModelStatus.ready;
});
