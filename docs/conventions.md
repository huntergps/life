# Conventions -- Galapagos Wildlife

## File Naming

| Suffix / Pattern            | Purpose                        | Examples                                              |
|-----------------------------|--------------------------------|-------------------------------------------------------|
| `*_screen.dart`             | Full-page screens              | `home_screen.dart`, `login_screen.dart`               |
| `*_provider.dart`           | Riverpod providers             | `map_provider.dart`, `auth_provider.dart`              |
| `*_service.dart`            | Business-logic / data services | `initial_sync_service.dart`, `trail_edit_service.dart` |
| `*_sheet.dart`              | Bottom sheets / modal sheets   | `site_filter_sheet.dart`, `species_id_sheet.dart`      |
| `*.model.dart`              | Domain model classes           | `species.model.dart`, `island.model.dart`              |
| `*_helpers.dart` / `*_utils.dart` | Utility / helper functions | `data_helpers.dart`, `route_utils.dart`                |
| Descriptive name (no suffix)| Small widgets, painters, etc.  | `hero_banner.dart`, `conservation_badge.dart`          |

## Directory Structure

```
lib/
  main.dart                 -- Entry point
  app/                      -- Application shell
    bootstrap/              -- App initialization (Supabase, Drift, services)
    shell/                  -- Root widget (GalapagosWildlifeApp)
    theme/                  -- AppTheme, AppColors, AppSpacing
    router/                 -- go_router configuration
      routes/               -- Route definitions grouped by area
      navigation/           -- ScaffoldWithNav, bottom nav bar
  core/                     -- Shared infrastructure
    constants/              -- App-wide constants (URLs, keys, asset maps)
    l10n/                   -- Generated slang translations (strings.g.dart)
    presentation/screens/   -- App-level screens (e.g. SyncScreen)
    providers/              -- App-wide providers (connectivity, Supabase client)
    services/               -- Shared services (logger, cache, location)
    utils/                  -- Display helpers, responsive utils, error handler
    widgets/                -- Reusable widgets (species_card, offline_banner, etc.)
    data/                   -- Static seed data
  data/                     -- Data layer (persistence + sync)
    local/
      drift/                -- Drift database, adapters, tables, repository
        adapters/           -- Supabase model dictionary
        db/                 -- AppDatabase, converters, platform, tables
        repository/         -- WildlifeRepository
    mappers/                -- Data mapping / helpers between layers
    remote/                 -- (reserved for remote-only data sources)
    sync/                   -- Sync services (initial sync, realtime, image preload, seed)
  models/                   -- Domain model classes (*.model.dart)
  features/                 -- Feature modules (see below)
```

## Feature Module Structure

Each feature lives under `lib/features/<feature_name>/` and is self-contained.
Subdirectories are added as needed -- not every feature uses all of them.

```
features/<feature_name>/
  presentation/
    screens/        -- Full-page screen widgets (*_screen.dart)
    widgets/        -- Feature-specific widgets
    painters/       -- Custom painters (ar_camera)
    sheets/         -- Bottom sheets shown from this feature (*_sheet.dart)
  providers/        -- Riverpod providers for this feature
  services/         -- Feature-specific services
  models/           -- Feature-local model classes (rare)
  shared/           -- Widgets/providers shared within the feature
```

Some features use **page-oriented** subdirectories instead of the
`presentation/` wrapper when each page is small and self-contained:

```
features/species/
  list/             -- species_list_screen.dart + species_list_provider.dart
  detail/           -- species_detail_screen.dart + provider + helper widgets
  compare/          -- species_compare_screen.dart
  photo_id/         -- Photo identification sub-feature
    presentation/
    providers/
  shared/           -- species_checklist_provider.dart, species_id_sheet.dart
```

### Map feature (domain-specific subdirectories)

```
features/map/
  controls/         -- FABs, zoom controls, off-route banner
  layers/           -- Map layers (site markers, tile layers, field editing)
  sheets/           -- Map bottom sheets (island info, trail info, site filter)
  themes/           -- Protomaps theme definitions
  utils/            -- Route calculation utilities
  presentation/
    screens/
    widgets/
  providers/
  services/
```

### Current features

| Feature         | Description                                    |
|-----------------|------------------------------------------------|
| `admin`         | Admin dashboard, CRUD for species/sites/islands/users |
| `ar_camera`     | AR camera with YOLO detection                  |
| `auth`          | Login / authentication                         |
| `badges`        | Achievement badges and gamification            |
| `daily_facts`   | Daily wildlife facts                           |
| `editorial`     | Editorial workflow (proposals, curator review)  |
| `favorites`     | User favorite species                          |
| `home`          | Home screen, hero banner, category grid        |
| `leaderboard`   | User leaderboard                               |
| `map`           | Interactive map with offline tiles             |
| `onboarding`    | First-launch onboarding flow                   |
| `profile`       | User profile and stats                         |
| `search`        | Global search                                  |
| `settings`      | App settings                                   |
| `sightings`     | Log and browse wildlife sightings              |
| `sound_id`      | Sound-based species identification             |
| `species`       | Species list, detail, photo ID, comparison     |
| `watch`         | Apple Watch connectivity and data sync         |

## Import Conventions

All imports use the full package path. Relative imports are not used.

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 4. App imports (always package:galapagos_wildlife/...)
import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import 'package:galapagos_wildlife/models/species.model.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';
```

## State Management

- **Riverpod 3.x** with manual providers (no `riverpod_generator` codegen)
- `FutureProvider` / `FutureProvider.family` for async data fetching
- `StateProvider` (from `flutter_riverpod/legacy.dart`) for simple toggles and filters
- `NotifierProvider` / `AsyncNotifierProvider` for stateful logic
- `Provider` for computed / derived values
- Providers end with the `Provider` suffix; notifiers end with `Notifier`

## Naming

| Convention    | Usage                                 | Example                    |
|---------------|---------------------------------------|----------------------------|
| `camelCase`   | Variables, functions, provider names  | `speciesListProvider`      |
| `PascalCase`  | Classes, enums, typedefs              | `SpeciesDetailScreen`      |
| `snake_case`  | File names, database columns          | `species_detail_screen.dart` |
| `SCREAMING_SNAKE` | Compile-time constants (rare)     | `MAX_RETRY_COUNT`          |

- Provider names: `<thing>Provider` (e.g. `mapProvider`, `authProvider`)
- Notifier classes: `<Thing>Notifier` (e.g. `SettingsNotifier`)
- Screen classes: `<Feature>Screen` (e.g. `HomeScreen`, `LoginScreen`)
- Service classes: `<Purpose>Service` (e.g. `InitialSyncService`)

## Route Definitions

Routes are grouped by area in `lib/app/router/routes/`:

| File                  | Routes                           |
|-----------------------|----------------------------------|
| `app_routes.dart`     | Home, map, species, sightings    |
| `admin_routes.dart`   | Admin dashboard and CRUD screens |
| `auth_routes.dart`    | Login, registration              |
| `profile_routes.dart` | Profile, badges, leaderboard     |
| `search_routes.dart`  | Global search                    |

## Models

Domain models live in `lib/models/` and follow the `<name>.model.dart` naming
pattern. These are Drift-compatible model classes used throughout the app.

Database tables and generated code live in `lib/data/local/drift/db/tables/`.

## Generated Code

The following files are generated and must not be edited by hand:

- `lib/data/local/drift/db/app_database.g.dart` -- Drift database
- `lib/data/local/drift/adapters/*.dart` -- Supabase-Drift adapters
- `lib/core/l10n/strings*.g.dart` -- slang translations

Regenerate with:

```bash
dart run build_runner build --delete-conflicting-outputs
```
