# Package Split Plan -- Galapagos Wildlife

This document outlines the plan for extracting self-contained packages from the
monolithic `galapagos_wildlife` Flutter app.  The goal is to reduce build times,
enforce architectural boundaries, and enable reuse (e.g. a standalone field-data
tool that shares the data layer).

---

## Candidate Packages

### 1. `wildlife_data`

- **Scope**: `lib/data/`, `lib/models/`
- **Contains**: Drift database (tables, converters, generated code), Supabase
  remote adapters, repository, sync services (initial sync, realtime, image
  preload, seed data), mappers, and 15 domain model files.
- **Dependencies**: `drift`, `supabase_flutter`, `riverpod` (providers for
  sync/realtime only)
- **Consumers**: Every feature in the app
- **Readiness**: HIGH -- the data layer already lives under its own directory
  tree with clear local/remote/sync separation.

### 2. `wildlife_map`

- **Scope**: `lib/features/map/`
- **Contains**: Map screen, layer builders, controls/FABs, bottom sheets
  (trail info, nearby species), editing services (field, site, trail), PMTiles
  manager, download provider.
- **Dependencies**: `flutter_map`, `pmtiles`, `wildlife_data`
- **Consumers**: Main app, settings screen (cache clear), sightings (visit
  sites provider).
- **Readiness**: MEDIUM -- mostly self-contained but `visitSitesProvider` and
  `trailProvider` are imported by other features and by core.

### 3. `wildlife_ai`

- **Scope**: `lib/features/species/photo_id/`, `lib/features/ar_camera/`,
  `lib/features/sound_id/`
- **Contains**: TFLite inference, image preprocessing, species identification
  provider, recognition feedback service, AR camera screen/provider, sound ID
  (future BirdNET integration).
- **Dependencies**: `tflite_flutter`, `camera`, `wildlife_data`
- **Consumers**: Main app (sighting add, species detail, AR camera)
- **Readiness**: LOW -- `species_identification_provider` is imported by
  `ar_camera`, `sightings/add`, `species/shared`, and even `core/widgets`.

### 4. `wildlife_admin`

- **Scope**: `lib/features/admin/`, `lib/features/editorial/`
- **Contains**: Admin dashboard, CRUD screens, editorial workflow (proposals,
  curator review), image processing service, admin auth/role providers.
- **Dependencies**: `wildlife_data`, `supabase_flutter`
- **Consumers**: Main app (nav scaffold checks `admin_auth_provider`), species
  detail (editorial proposal sheet), settings screen.
- **Readiness**: MEDIUM -- boundaries are clean for CRUD, but
  `admin_auth_provider` leaks into nav scaffold and species detail, and
  `image_processing_service` is used by sightings and profile.

---

## Current Cross-Feature Dependencies

The following imports cross feature boundaries (excluding self-imports):

### `lib/data/` imports from features (violation -- data should be leaf)

| File | Imports from |
|------|-------------|
| `data/sync/realtime_service.dart` | `admin/providers/` (5 providers), `home/providers/`, `species/list/`, `species/detail/`, `map/providers/` (2), `favorites/providers/`, `sightings/providers/` |

This is the single worst violation: the realtime service invalidates feature
providers after receiving Supabase realtime events.

### `lib/core/` imports from features

| File | Imports from |
|------|-------------|
| `core/providers/connectivity_provider.dart` | `species/list/`, `home/providers/`, `favorites/providers/`, `map/services/`, `map/providers/` |
| `core/widgets/species_list_card.dart` | `settings/providers/`, `species/photo_id/providers/` |
| `core/widgets/species_card.dart` | `species/photo_id/providers/` |
| `core/widgets/favorite_heart_button.dart` | `favorites/providers/` |
| `core/widgets/celebration_overlay.dart` | `profile/providers/` |

### Feature-to-feature imports (outside own boundary)

| Source feature | Depends on |
|----------------|-----------|
| `sightings` | `species` (list provider, ID sheet, identification provider), `home` (home provider), `admin` (image processing), `map` (visit sites provider), `favorites` (for filters) |
| `ar_camera` | `species` (identification provider), `sightings` (sightings service) |
| `species/detail` | `admin` (auth provider), `editorial` (proposal sheet, proposal service), `species/shared` (checklist) |
| `settings` | `admin` (auth provider), `species` (list provider), `home` (home provider), `map` (map + trail providers) |
| `profile` | `sightings` (provider), `species` (checklist provider), `admin` (image processing) |
| `badges` | `sightings` (provider), `favorites` (provider) |
| `daily_facts` | `sightings` (provider) |
| `search` | `species` (list provider) |
| `home` | `species` (list provider) |
| `admin` | `species` (list + detail providers), `home` (home provider) |
| `watch` | `sightings` (service + provider) |

### `lib/app/` (router + shell)

The router and shell import screens/providers from every feature.  This is
expected for the composition root but must be addressed if features become
separate packages (the app package becomes the sole orchestrator).

---

## Blocking Issues

1. **`realtime_service.dart` invalidates feature providers directly.**
   The data layer reaches up into 12 feature providers to call
   `ref.invalidate()`.  This must be replaced with an event bus or callback
   registry so `wildlife_data` has zero feature imports.

2. **`admin_auth_provider` used by nav scaffold.**
   The bottom navigation bar checks `isStaffProvider` to show/hide the admin
   tab.  This role information needs to move to a core auth/role abstraction.

3. **`image_processing_service` lives in admin but is used by sightings and
   profile.**
   Should move to `core/services/` or into `wildlife_data`.

4. **`species_identification_provider` used by core widgets.**
   `species_card.dart` and `species_list_card.dart` reference the AI provider
   for confidence scores.  This couples core to the AI feature.

5. **`connectivity_provider` in core invalidates feature providers.**
   Same pattern as realtime -- core reaching into features to refresh data on
   reconnect.

6. **Route definitions coupled to `app_router.dart`.**
   All feature screens are imported by the router.  Extracting a feature
   package means the app package must depend on it, not the reverse.

7. **Shared theme, constants, and l10n.**
   `lib/core/` contains theme, constants, and generated i18n strings used
   everywhere.  These must either stay in the app or become their own tiny
   `wildlife_theme` package.

---

## Recommended Extraction Order

### Phase 1: `wildlife_data`

Extract first because all other packages depend on it.

**Steps:**
1. Replace provider invalidation in `realtime_service.dart` with a stream-based
   event bus (e.g. `StreamController<DataChangeEvent>`).  Features subscribe to
   the stream in their own providers.
2. Do the same for `connectivity_provider.dart`.
3. Move `image_processing_service` from `admin/services/` to `core/services/`
   (it belongs to the data/utility layer).
4. Verify `lib/data/` and `lib/models/` have zero imports from `lib/features/`.
5. Extract as a Dart package under `packages/wildlife_data/`.

### Phase 2: `wildlife_admin`

Cleanest feature boundary after data is extracted.

**Steps:**
1. Create an abstract `RoleProvider` interface in core; have `admin_auth_provider`
   implement it.  Nav scaffold and species detail depend on the interface.
2. Move editorial into the admin package (already tightly coupled).
3. Extract as `packages/wildlife_admin/`.

### Phase 3: `wildlife_map`

**Steps:**
1. Move `visitSitesProvider` and `trailProvider` into `wildlife_data` (they are
   data providers, not map UI).
2. Decouple `field_edit_service` from the connectivity provider (use the event
   bus from Phase 1).
3. Extract as `packages/wildlife_map/`.

### Phase 4: `wildlife_ai`

Extract last because it has the most tangled dependencies.

**Steps:**
1. Remove AI confidence references from `core/widgets/species_card.dart` and
   `species_list_card.dart` (pass scores as parameters or use a callback).
2. Define an `IdentificationResult` interface in core; the AI package provides
   the implementation.
3. Decouple `photo_id_screen` and `ar_camera_screen` from direct
   `sightings_service` imports (use a callback or service locator).
4. Extract as `packages/wildlife_ai/`.

---

## Target Dependency Graph

```
wildlife_app (composition root)
  |-- wildlife_data      (Drift, Supabase, sync, models)
  |-- wildlife_admin     (admin CRUD, editorial)  --> wildlife_data
  |-- wildlife_map       (flutter_map, PMTiles)   --> wildlife_data
  |-- wildlife_ai        (TFLite, camera, BirdNET) --> wildlife_data
```

No feature package depends on another feature package.  The app package is the
only one that imports all four.

---

## Prerequisites

- All current refactoring phases completed
- Event bus replaces direct provider invalidation in data and core layers
- Test coverage on the data layer (repository, sync, mappers)
- Router decoupled from feature-specific screen imports (use deferred loading
  or a feature-registration pattern)
- CI pipeline validates that each extracted package builds independently
