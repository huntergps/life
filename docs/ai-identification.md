# AI Species Identification Pipeline

## Overview

The app identifies Galapagos species from photos using an on-device TFLite
classifier. All inference runs offline -- no network required after the model
asset is bundled.

## TFLite Model Loading

- Asset path: `assets/ml/galapagos_classifier.tflite`
- Labels: `assets/ml/labels.txt` (one `scientific_name|common_name` per line)
- Loaded lazily on first identification request via `Interpreter.fromAsset()`
- Web platform uses a stub (`_tflite_stub.dart`) so dart2js compiles cleanly;
  inference is guarded by `kIsWeb` at runtime.

## Image Preprocessing

1. Raw photo bytes are decoded with `package:image`.
2. Resized to the model's expected input dimensions (224x224 for MobileNetV3).
3. Pixel values normalised to `[0, 1]` float32.
4. Packed into a `Float32List` input tensor shaped `[1, 224, 224, 3]`.

## Inference Flow

1. `speciesIdProvider` receives `Uint8List` photo bytes + optional `LatLng`.
2. Preprocessing runs in a `compute()` isolate to avoid UI jank.
3. `Interpreter.run()` produces a probability vector over all label classes.
4. Top-N results are mapped back to label names and sorted by confidence.

## Location-Based Fallback

When confidence is low or the model is unavailable:

1. The user's GPS coordinates are matched against `species_site` / `visit_site`
   data stored locally.
2. Species known to inhabit nearby sites are returned as suggestions, ranked by
   geographic proximity.

## Feedback Upload for Training Data

`RecognitionFeedbackService` saves user corrections to the
`species_recognition_feedback` table in Supabase:

- **Confirmed** (AI was correct): `is_correction = false` -- positive training
  example.
- **Corrected** (AI was wrong): `is_correction = true` -- hard negative for the
  predicted species + hard positive for the corrected species.
- Photos are uploaded to the `feedback-photos` storage bucket using a SHA-256
  content hash as the filename (deduplicates identical uploads).

This feedback loop provides labelled data for future model retraining.

## File Locations

| Component | Path |
|---|---|
| TFLite provider | `lib/features/species/photo_id/providers/species_identification_provider.dart` |
| Web stub | `lib/features/species/photo_id/providers/_tflite_stub.dart` |
| Feedback service | `lib/features/species/photo_id/providers/recognition_feedback_service.dart` |
| Photo ID screen | `lib/features/species/photo_id/presentation/photo_id_screen.dart` |
| ID result sheet | `lib/features/species/shared/species_id_sheet.dart` |
| Model asset | `assets/ml/galapagos_classifier.tflite` |
| Labels asset | `assets/ml/labels.txt` |
