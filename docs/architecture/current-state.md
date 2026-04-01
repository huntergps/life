# Current Architecture State

## Last updated: 2026-03-31

## Project Structure

```
lib/
  main.dart                  -- Entry point: Bootstrap.init() then sync check

  app/
    bootstrap/               -- Modular init (5 init_*.dart files + orchestrator)
      bootstrap.dart         -- Bootstrap orchestrator (calls init steps in order)
      init_storage.dart      -- SharedPreferences, sqflite FFI, date formatting
      init_maps.dart         -- FMTC tile cache stores
      init_supabase.dart     -- Supabase auth/storage connection
      init_repository.dart   -- Drift DB + offline queue
      init_background.dart   -- FileDownloader, PMTiles
    shell/                   -- App widget, startup coordinator, dialogs, offline banner
      galapagos_wildlife_app.dart
      app_startup_coordinator.dart
      app_dialogs.dart
      offline_banner_wrapper.dart
    router/                  -- GoRouter config, routes, navigation scaffold
      app_router.dart
      router_keys.dart
      navigation/            -- scaffold_with_nav.dart (adaptive phone/tablet/desktop)
      routes/                -- admin_routes, app_routes, auth_routes, profile_routes, search_routes
    theme/                   -- AppTheme, AppColors, AppSpacing

  core/
    constants/               -- App constants, Supabase config, species assets
    data/                    -- Bundled JSON seed data
    l10n/                    -- Slang i18n (EN/ES)
    presentation/screens/    -- Shared screens (SyncScreen)
    providers/               -- Core providers (connectivity)
    services/                -- Location services, logging, cache
      location/              -- GPS/location services
    utils/                   -- Data helpers, brick helpers
    widgets/                 -- Shared widgets (species card, search bar, cached image, etc.)

  data/
    local/drift/             -- Drift (SQLite) offline-first layer
      db/
        app_database.dart    -- @DriftDatabase with all 15 tables
        converters.dart      -- Drift type converters
        platform/            -- native.dart, web.dart (DB connection per platform)
        tables/              -- 15 table definitions (one per file)
      adapters/              -- Supabase model dictionary, JSON adapters
      repository/            -- WildlifeRepository singleton (OfflineFirstWithSupabase)
    mappers/                 -- JSON-to-model converters (data_helpers.dart)
    remote/supabase/         -- (placeholder, currently empty)
    sync/                    -- Initial sync, realtime, seed, image preload
      initial_sync_service.dart
      realtime_service.dart
      seed_data_service.dart
      image_preload_service.dart
      image_preload_provider.dart

  models/                    -- 15 domain model classes (*.model.dart)

  features/
    admin/                   -- Dashboard, CRUD screens, role management
      presentation/screens/  -- categories/, islands/, site_catalogs/, species/, taxonomy/, users/, visit_sites/
      presentation/widgets/  -- Shared admin widgets
      providers/             -- Admin auth, species form providers
      services/              -- AdminSupabaseService, AdminSpeciesService, etc.
    ar_camera/               -- YOLO detection + AR overlay
      presentation/painters/ -- Bounding box painter
      presentation/screens/  -- AR camera screen
      providers/             -- AR camera provider
    auth/                    -- Login/signup
      presentation/screens/  -- Auth screen
      providers/             -- Auth provider
    badges/                  -- Achievement system
      models/                -- Badge definitions
      presentation/screens/  -- Badge grid, detail
      presentation/widgets/  -- Badge card, unlock dialog
      providers/             -- Badge progress provider
    daily_facts/             -- Random species facts
      models/                -- Fact model
      providers/             -- Daily fact provider
    editorial/               -- Proposals, curator review
      presentation/screens/  -- My proposals, curator screen, admin proposals
      presentation/sheets/   -- Proposal form sheet
      presentation/widgets/  -- Diff viewer widgets
      services/              -- ProposalService
    favorites/               -- Species favorites
      presentation/screens/  -- Favorites list
      providers/             -- Favorites provider
    home/                    -- Home screen, category grid, hero banner
      presentation/screens/
      presentation/widgets/
      providers/
    leaderboard/             -- Sighting leaderboard
      presentation/screens/
      providers/
    map/                     -- Interactive map (flutter_map + PMTiles)
      controls/              -- Zoom, off-route banner, FABs
      editing/               -- Field tap handler
      layers/                -- Tile, site markers, island markers, field editing
      layouts/               -- Phone/tablet responsive layouts
      presentation/screens/  -- map_screen.dart (598 lines)
      presentation/widgets/
      providers/             -- Map state providers
      services/              -- Trail, site, field edit services
      sheets/                -- Trail info, sighting info, island info, site filter, nearby species
      shell/                 -- Phone/tablet shell layouts
      themes/                -- Map color themes
      tracking/              -- GPS tracking controller
      utils/                 -- Viewport helpers, route utils
    onboarding/              -- First-time flow
      presentation/screens/
    profile/                 -- User profile, celebrations
      presentation/screens/
      presentation/widgets/
      providers/
    search/                  -- Global search
      presentation/screens/
      providers/
    settings/                -- Preferences, beta tester display
      presentation/screens/
      presentation/widgets/
      providers/
    sightings/               -- Wildlife sighting logging
      add/                   -- Add sighting, species picker
      list/                  -- Sighting list, filters, detail
      providers/             -- Sightings state
      services/              -- SightingsService, CSV export
    sound_id/                -- Audio identification
      presentation/screens/
      providers/
    species/                 -- Species catalog
      compare/               -- Species comparison screen
      detail/                -- Species detail, sounds, facts, gallery, taxonomy
      list/                  -- Species catalog list
      photo_id/
        presentation/        -- Photo ID screen
        providers/           -- Identification orchestrator
        services/            -- label_parser, image_preprocessor, tflite_classifier, location_fallback
      shared/                -- Species ID sheet, checklist provider
    watch/                   -- Apple Watch integration
      services/              -- WatchConnectivityService (WCSession bridge)
      sync/                  -- WatchDataSyncProvider
```

## Key Metrics

| Metric | Value |
|--------|-------|
| Total Dart files | ~266 |
| Domain models | 15 |
| Drift tables | 15 |
| Feature modules | 18 |
| Bootstrap init steps | 5 (storage, maps, supabase, repository, background) |
| Platforms | iOS, Android, macOS, Linux, Windows, web (limited) |

## Bootstrap Flow

`Bootstrap.init()` runs before anything else (called from `main()`):

1. **InitStorage** -- SharedPreferences, sqflite FFI (Linux/Windows), date formatting
2. **InitMaps** -- FMTC ObjectBox tile cache (3 stores: galapagosMap, satelliteCache, labelsCache)
3. **InitSupabase** -- Supabase auth/storage connection (silently fails for offline mode)
4. **InitRepository** -- Drift local DB + Supabase remote adapter; clears stuck offline queue (>10 attempts)
5. **InitBackground** -- FileDownloader notifications, PMTiles base map asset

## Data Flow

```
 User Action
      |
      v
 Riverpod Provider  --->  WildlifeRepository (OfflineFirstWithSupabase)
      |                         |                    |
      v                         v                    v
   UI rebuild           Drift (SQLite)         Supabase (Postgres)
                        local cache            remote source of truth
                              |
                              v
                        Offline Queue
                        (replay on reconnect)
```

- **Local**: Drift (SQLite) via `drift_offline_first_with_supabase`
- **Remote**: Supabase Cloud (Postgres, Auth, Storage, Realtime)
- **Sync**: Offline queue with retry, realtime subscriptions for live updates
- **Policies**: `localOnly`, `awaitRemote`, `awaitRemoteWhenNoneExist`

## Initial Sync

After bootstrap, `main()` checks if initial sync is needed (native only):
1. Query `Species` with `localOnly` -- if empty or no thumbnails, sync is needed
2. Show `SyncScreen` which fetches 7 tables in order: Categories, Islands, Visit Sites, Species, Species Sites, Species Images, Trails
3. Precache all species thumbnail images into HTTP cache
4. Bundled seed data (`SeedDataService`) as offline fallback
5. Once complete, swap to `GalapagosWildlifeApp`

## Access Control

| Role | Capabilities |
|------|-------------|
| `admin` | Full CRUD on all reference data, approve/reject proposals, manage users |
| `editor` | Submit change proposals for species data |
| `curator` | Review and validate proposals and AI recognition feedback |
| `beta_tester` | Access to beta features (map, photo-id, field-camera) |

- Roles stored in `admin_users` table (multi-role, UNIQUE(user_id, role))
- Supabase RPCs: `get_user_roles()`, `is_admin()`, `is_editor()`, `is_curator()`, `is_staff()`
- Flutter: `userRolesProvider` cached 30min in SharedPreferences
- Beta routes (`/map`, `/photo-id`, `/field-camera`) redirect to `/` unless `is_beta_tester`

## State Management

**Riverpod 3.x** with manual providers (no riverpod_generator due to analyzer conflict with Drift build system).

- `Provider` -- singleton services (RealtimeService, WatchDataSync)
- `FutureProvider` -- async data loading (species lists, user roles, AI labels)
- `StateProvider` (from `flutter_riverpod/legacy.dart`) -- simple UI state (theme, locale, filters)
- `NotifierProvider` / `AsyncNotifierProvider` -- complex stateful logic (sightings, map state)
- `StreamProvider` -- auth state changes

## Realtime

`RealtimeService` subscribes to two Supabase Realtime channels:
- **General**: categories, islands, visit_sites, species, species_images, species_sites, trails -- re-fetches full table on change, invalidates providers
- **User** (filtered by user_id): user_favorites, sightings -- invalidates corresponding providers

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.38.4 / Dart 3.10.3 |
| State | flutter_riverpod 3.x |
| Routing | go_router 17.x |
| Maps | flutter_map 8.x + PMTiles |
| i18n | slang 4.x (EN/ES) |
| Local DB | Drift (SQLite) via drift_offline_first_with_supabase 2.1.0 |
| Backend | Supabase Cloud (Postgres, Auth, Storage, Realtime) |
| Auth UI | supabase_auth_ui (SupaEmailAuth widget) |
| ML | tflite_flutter 0.10.4 (MobileNetV3Small) |
| Watch | WCSession via MethodChannel (watchOS 10.0+) |
