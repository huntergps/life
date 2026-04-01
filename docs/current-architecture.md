# Galapagos Wildlife App -- Architecture

> **See also**: `docs/architecture/current-state.md` for a concise structural overview
> and `docs/architecture/target-architecture.md` for the roadmap.

## App Overview

Galapagos Wildlife is an offline-first fauna guide for the Galapagos Islands. It provides species identification (photo and sound), an interactive map with trails and visit sites, sighting logging, gamification (badges and leaderboard), and a full admin/editorial system for managing content.

- **Flutter 3.38.4** / Dart 3.10.3
- **Supabase Cloud** (auth, storage, Postgres, Realtime)
- **Drift + drift_offline_first_with_supabase** for local-first persistence
- Platforms: iOS, Android, macOS, Linux, Windows, web (limited)

---

## Directory Structure

```
lib/
  main.dart                  # Entry point -- Bootstrap.init() then sync check
  bootstrap.dart             # All startup initialization (Supabase, Drift, FMTC, etc.)
  app.dart                   # GalapagosWildlifeApp root widget (theme, router, realtime)
  models/                    # 15 domain model classes (*.model.dart)
  drift/
    db/
      tables/                # 15 Drift table definitions
      app_database.dart      # AppDatabase (@DriftDatabase with all tables)
      converters.dart        # Drift type converters
      platform/              # native.dart, web.dart, platform.dart (DB connection)
    adapters/
      supabase_model_dictionary.dart  # Maps models <-> Supabase tables <-> Drift tables
    repository/
      wildlife_repository.dart        # WildlifeRepository singleton (OfflineFirstWithSupabase)
    drift.dart               # Barrel export
  core/
    constants/               # App constants, Supabase credentials
    data/                    # Bundled JSON seed data
    l10n/                    # slang 4.x translations (ES/EN)
    presentation/            # Shared screens (SyncScreen)
    providers/               # Connectivity, image preload providers
    router/                  # GoRouter config, route definitions, ScaffoldWithNav
    services/                # InitialSyncService, RealtimeService, SeedDataService, etc.
    theme/                   # AppTheme, AppColors
    utils/                   # Data helpers, brick helpers
    widgets/                 # Shared widgets (OfflineBanner, CachedSpeciesImage, etc.)
  features/
    admin/                   # Admin dashboard, CRUD screens, services
    ar_camera/               # AR camera with bounding-box overlay
    auth/                    # Login screen, auth provider
    badges/                  # Badge definitions, unlock dialog, badge screen
    daily_facts/             # Daily species fact provider
    editorial/               # Change proposals workflow (editor/curator/admin)
    favorites/               # Favorites screen and providers
    home/                    # Home screen, hero banner, category grid
    leaderboard/             # Leaderboard screen and provider
    map/                     # Interactive map, PMTiles, trails, field editing, GPS tracking
    onboarding/              # Onboarding carousel (first launch)
    profile/                 # User profile, birthday dialog, visit summary, badge progress
    search/                  # Global search screen
    settings/                # Settings screen, theme/locale/text-scale providers
    sightings/               # Sighting list, add sighting, CSV export
    sound_id/                # Sound identification screen, audio recorder
    species/                 # Species list, detail, compare, photo ID, TFLite provider
  watch/
    watch_connectivity_service.dart   # WCSession bridge via MethodChannel
    watch_data_sync_provider.dart     # Riverpod provider for Watch <-> iPhone sync
```

---

## Bootstrap Flow

`Bootstrap.init()` runs before anything else (called from `main()`):

1. **WidgetsFlutterBinding.ensureInitialized()** -- required for platform channel access.
2. **sqflite FFI init** -- only on Linux/Windows; macOS uses sqflite_darwin natively.
3. **SharedPreferences.getInstance()** -- loaded early so providers can read synchronously via `Bootstrap.prefs`.
4. **initializeDateFormatting()** -- intl locale data for DateFormat.
5. **FMTC init** (native only) -- ObjectBox backend for offline map tile caching. Creates three tile stores: `galapagosMap`, `satelliteCache`, `labelsCache`.
6. **Supabase.initialize()** -- connects to cloud project. Sets `supabaseConnected = true` on success; silently fails for offline mode.
7. **WildlifeRepository.configure()** -- initializes the Drift local database and Supabase remote adapter. On web, runs without a local DB (Supabase-direct). On native, also clears stuck offline queue requests (attempts > 10).
8. **Record sync timestamp** in SharedPreferences. If Supabase connected and there are pending trails from a previous offline session, starts uploading them in the background.
9. **FileDownloader config** (native only) -- background_downloader notifications for HD map downloads.
10. **PmTilesManager.ensureAvailable()** (native only) -- copies bundled PMTiles base map from assets to the file system if not already present.

---

## Initial Sync Flow

After bootstrap, `main()` checks whether an initial sync is needed (native platforms only):

1. **isSyncComplete()** -- queries `Species` with `localOnly` policy. Returns `false` if no species exist locally OR if none have `thumbnailUrl` set (stale data indicator).
2. If sync is needed, the app shows **SyncScreen** instead of the main app.
3. **SyncScreen** calls `syncAll()` which fetches 7 tables from Supabase in order:
   - Categories, Islands, Visit Sites, Species, Species Sites, Species Images, Trails
   - Each table uses `OfflineFirstGetPolicy.awaitRemote` with a 60-second timeout.
4. After table sync, **precacheImages()** downloads all species thumbnails into the HTTP cache.
5. A bundled seed data fallback (`SeedDataService`) can populate the local DB from JSON assets if the network sync fails.
6. Once complete, `_SyncWrapper` swaps in `GalapagosWildlifeApp`.

---

## Offline-First Data Architecture

### Local Database (Drift)

`AppDatabase` is a Drift database with **15 tables**:

| Table | Description |
|-------|-------------|
| `categories` | Fauna categories (reptiles, birds, mammals, etc.) |
| `islands` | Galapagos islands with coordinates and metadata |
| `visit_sites` | Official park visitor sites with capacity and classification |
| `species_rows` | Species master data (taxonomy, conservation, morphology) |
| `species_images` | Image URLs per species (hero + thumbnail) |
| `species_references` | Bibliography/source references per species |
| `species_sites` | Many-to-many: which species occur at which sites |
| `species_sounds` | Audio file URLs per species |
| `species_threats` | Conservation threats per species |
| `trails` | Admin-created hiking/snorkeling trails with GeoJSON |
| `sightings` | User-submitted wildlife sightings with photo and GPS |
| `user_favorites` | Per-user favorite species |
| `user_profiles` | User profile (display name, avatar, birthday) |
| `user_site_wishlists` | Per-user site wishlist |
| `user_species_checklists` | Per-user species life list |

### drift_offline_first_with_supabase Framework

The app uses the `drift_offline_first_with_supabase` package which provides:

- **WildlifeRepository** -- singleton extending `OfflineFirstWithSupabaseRepository`. Configured once during bootstrap via `WildlifeRepository.configure()`.
- **Supabase adapters** -- `supabase_model_dictionary.dart` maps each domain model to its Supabase table name and provides serialization/deserialization adapters.
- **QueryDriftTransformer** -- maps Dart field names to Drift column expressions for type-safe local queries.
- **Offline queue** -- `SupabaseRequestSqliteCacheManager` queues write operations when offline. On reconnection, queued requests are replayed. Stuck requests (>10 attempts) are cleared during bootstrap.

### GetPolicy Options

- `OfflineFirstGetPolicy.localOnly` -- read from Drift only (used for sync checks, instant UI).
- `OfflineFirstGetPolicy.awaitRemote` -- fetch from Supabase, update local cache, return merged result (used during initial sync and realtime refresh).
- `OfflineFirstGetPolicy.awaitRemoteWhenNoneExist` -- try local first; if empty, fetch remote.

---

## Navigation

### GoRouter with ShellRoute

The app uses `go_router` 17.x with a `ShellRoute` that wraps all main screens in `ScaffoldWithNav`.

**App navigation items** (beta testers get 6 items, regular users get 5):

| # | Route | Screen | Beta only |
|---|-------|--------|-----------|
| 1 | `/` | Home | No |
| 2 | `/species` | Species List | No |
| 3 | `/map` | Interactive Map | Yes |
| 4 | `/favorites` | Favorites | No |
| 5 | `/sightings` | Sightings | No |
| 6 | `/settings` | Settings | No |

Additional routes: `/badges`, `/leaderboard`, `/profile`, `/species/:id`, `/species/compare`, `/sightings/add`, `/photo-id`, `/field-camera`.

### Adaptive Layout

`ScaffoldWithNav` detects screen size:
- **Phone**: `NavigationBar` (bottom bar)
- **Tablet**: `NavigationRail` with labels
- **Desktop**: Extended `NavigationRail` with a top header bar (search, language toggle, theme toggle, profile avatar)

### Admin Routes

All under `/admin/*` with role-based guards in the router redirect:

- `/admin` -- Dashboard
- `/admin/species`, `/admin/categories`, `/admin/islands`, `/admin/visit-sites` -- CRUD lists + forms
- `/admin/species/:id/images`, `/admin/species/:id/edit` -- Species management
- `/admin/taxonomy`, `/admin/site-catalogs`, `/admin/users` -- Reference data
- `/admin/proposals` -- Admin proposal review
- `/admin/curator` -- Curator review screen
- `/admin/my-proposals` -- Editor's own proposals
- `/admin/ml-training` -- ML training data management

Admin routes require `is_admin` (cached in SharedPreferences). Curator and editor routes allow their respective roles.

### Beta Feature Gating

Routes in `betaRoutes` (`/map`, `/photo-id`, `/field-camera`) redirect to `/` unless `is_beta_tester` is `true` in SharedPreferences.

---

## State Management

**Riverpod 3.x** with manual providers (no riverpod_generator due to analyzer conflict with Brick build system).

Provider types in use:
- `Provider` -- singleton services (RealtimeService, WatchDataSync)
- `FutureProvider` -- async data loading (species lists, user roles, AI labels)
- `StateProvider` (from `flutter_riverpod/legacy.dart`) -- simple UI state (theme mode, locale, filters)
- `NotifierProvider` / `AsyncNotifierProvider` -- complex stateful logic (sightings, map state)
- `StreamProvider` -- auth state changes

Key patterns:
- `ref.watch(realtimeServiceProvider)` in the root widget activates realtime subscriptions.
- `ref.invalidate(provider)` used by RealtimeService to refresh data when Supabase Postgres changes arrive.
- `connectivityRefreshProvider` auto-refreshes providers when the device comes back online.

---

## Feature Modules

| Feature | Description |
|---------|-------------|
| **home** | Landing screen with hero banner, category grid, and featured species |
| **species** | Browsable species list with category filter, detail screen (taxonomy, gallery, sounds, threats, references), compare screen, photo ID screen |
| **map** | flutter_map with PMTiles base layer, ESRI satellite, CartoDB labels. Site markers, trail overlays, GPS tracking, field editing toolbar, offline tile caching via FMTC |
| **favorites** | User's favorited species list (requires auth) |
| **sightings** | Log wildlife sightings with photo, GPS, and species picker. List view with filters. CSV export |
| **settings** | Theme mode, language (ES/EN), text scale, cache management, about info |
| **auth** | Email/password login via `supabase_auth_ui` (SupaEmailAuth widget) |
| **admin** | Dashboard with stats, CRUD screens for all reference tables, user management, ML training data |
| **editorial** | Change proposal workflow: editors submit species edits, curators review, admins approve. JSONB diff viewer |
| **badges** | Gamification badges with progress tracking and unlock celebration dialogs |
| **leaderboard** | Community leaderboard based on sightings and checklist completions |
| **profile** | User profile with avatar, birthday celebration, visit summary, badge progress section |
| **onboarding** | First-launch carousel introducing app features |
| **search** | Global search across species, islands, and visit sites |
| **ar_camera** | Camera screen with bounding-box overlay for species detection |
| **sound_id** | Audio recording screen for bird/animal sound identification |
| **daily_facts** | Rotating daily species fact |

---

## AI Identification Flow

### TFLite On-Device Classifier

- Model asset: `assets/ml/galapagos_classifier.tflite` (MobileNetV3Small, fine-tuned on Galapagos species)
- Labels asset: `assets/ml/labels.txt` (scientific names mapped to common names)
- Provider: `species_identification_provider.dart`

### Photo ID Screen Flow

1. User opens `/photo-id` (beta-only route).
2. Captures or picks a photo.
3. Image is resized to 224x224 and preprocessed.
4. TFLite interpreter runs inference, producing confidence scores per label.
5. Results are matched against the local species database.
6. If TFLite model is unavailable, falls back to **location-based suggestions**: queries `SpeciesSite` and `VisitSite` by proximity to the user's GPS coordinates.
7. Suggestions are displayed as `SpeciesIdSuggestion` objects with `source: 'model'` or `source: 'location'`.

### AI Badge

`aiRecognizedSpeciesProvider` loads `labels.txt` to build a set of scientific names the model can recognize. Species cards show an "AI" badge when their scientific name is in this set.

---

## Admin / Editorial System

### Roles

Four roles stored in `admin_users` table (multi-role, UNIQUE(user_id, role)):

| Role | Capabilities |
|------|-------------|
| `admin` | Full CRUD on all reference data, approve/reject proposals, manage users |
| `editor` | Submit change proposals for species data |
| `curator` | Review and validate proposals and AI recognition feedback |
| `beta_tester` | Access to beta features (map, photo-id, field-camera) |

### Role Resolution

- Supabase RPC: `get_user_roles()` returns `text[]` of roles for the current user (SECURITY DEFINER).
- Helper functions: `is_admin()`, `is_editor()`, `is_curator()`, `is_staff()`.
- Flutter side: `userRolesProvider` (AsyncValue<Set<String>>) cached for 30 minutes in SharedPreferences.
- Derived providers: `isAdminProvider`, `isEditorProvider`, `isCuratorProvider`, `isStaffProvider`.

### Editorial Workflow

1. **Editor** opens a species detail screen, taps the edit icon, fills the proposal form.
2. Proposal is inserted into `species_change_proposals` with `status: 'pending'`.
3. **Curator** reviews on the curator screen (`/admin/curator`). Can approve (`curator_approved`) or flag (`curator_flagged`).
4. **Admin** makes the final decision on `/admin/proposals`: approve (applies changes to species table) or reject.
5. All changes are audited in `audit.record_version` (INSERT/UPDATE/DELETE triggers on species and related tables).

---

## Realtime

`RealtimeService` subscribes to Supabase Realtime Postgres Changes on two channels:

### General Channel (all users)

Listens for changes on: `categories`, `islands`, `visit_sites`, `species`, `species_images`, `species_sites`, `trails`.

On each change:
1. Re-fetches the full table from Supabase using `awaitRemote` to update the local Drift cache.
2. Invalidates the relevant Riverpod providers so the UI rebuilds.

### User Channel (authenticated users)

Filtered by `user_id`:
- `user_favorites` changes invalidate `favoritesProvider`.
- `sightings` changes invalidate `sightingsProvider`.

Auth state changes trigger subscribe/unsubscribe of the user channel.

---

## Apple Watch

### Architecture

- **Swift side**: `WatchConnectivityService.swift` using `WCSession` (watchOS 10.0+).
- **Flutter side**: `WatchConnectivityService` (`lib/watch/watch_connectivity_service.dart`) communicates via Flutter MethodChannel.
- **Provider**: `watchDataSyncProvider` orchestrates sync, activated in the root widget on native platforms.

### Data Flow

- **iPhone to Watch**: Species list is sent on app startup via `syncSpeciesToWatch()`.
- **Watch to iPhone**: Sightings received via `onSightingReceived` stream, saved to Supabase through `SightingsService`.
- **Watch to iPhone**: Trail data received via `onTrailReceived` stream (logged).

---

## Domain Models

15 model classes in `lib/models/`:

| Model | Supabase Table | Description |
|-------|---------------|-------------|
| `Category` | `categories` | Fauna group (birds, reptiles, mammals, spiders, etc.) |
| `Island` | `islands` | Galapagos island with coordinates, area, classification |
| `VisitSite` | `visit_sites` | Official park visitor site with capacity and metadata |
| `Species` | `species` | Species master record (taxonomy, conservation, morphology) |
| `SpeciesImage` | `species_images` | Hero image + thumbnail URL per species |
| `SpeciesReference` | `species_references` | Bibliographic reference per species |
| `SpeciesSite` | `species_sites` | Species-to-site occurrence relationship |
| `SpeciesSound` | `species_sounds` | Audio recording URL per species |
| `SpeciesThreat` | `species_threats` | Conservation threat per species |
| `Trail` | `trails` | Hiking/snorkeling trail with GeoJSON geometry |
| `Sighting` | `sightings` | User wildlife sighting with photo and GPS |
| `UserFavorite` | `user_favorites` | User's favorited species |
| `UserProfile` | `user_profiles` | Display name, avatar URL, birthday |
| `UserSiteWishlist` | `user_site_wishlists` | User's site wishlist |
| `UserSpeciesChecklist` | `user_species_checklists` | User's species life list |

---

## Key Services

### Core Services (`lib/core/services/`)

| Service | Purpose |
|---------|---------|
| `InitialSyncService` | Orchestrates first-launch data sync (7 tables + image precache) |
| `RealtimeService` | Supabase Realtime subscriptions, provider invalidation |
| `SeedDataService` | Populates local DB from bundled JSON assets (offline fallback) |
| `ImagePreloadService` | Downloads species thumbnails into HTTP cache for offline use |
| `SpeciesCacheManager` | Manages species image cache lifecycle |
| `AppLogger` | Centralized logging utility |

### Feature Services

| Service | Feature | Purpose |
|---------|---------|---------|
| `SightingsService` | sightings | CRUD for sightings via Supabase |
| `SightingsCsvExport` | sightings | Export sightings to CSV |
| `RecognitionFeedbackService` | species | Submit AI recognition corrections |
| `ProposalService` | editorial | CRUD for species change proposals |
| `AdminSupabaseService` | admin | Direct Supabase queries for admin CRUD |
| `AdminSpeciesService` | admin | Species-specific admin operations |
| `AdminImagesService` | admin | Image upload, processing, and management |
| `AdminCategoriesService` | admin | Category CRUD |
| `AdminIslandsService` | admin | Island CRUD |
| `AdminVisitSitesService` | admin | Visit site CRUD |
| `AdminStatsService` | admin | Dashboard statistics |
| `AdminFormValidator` | admin | Form validation rules |
| `ImageProcessingService` | admin | Resize and crop images to 16:9 standard |
| `DriveExportService` | admin | Export data to Google Drive |
| `FieldEditService` | map | In-field trail recording with offline queue |
| `SiteEditService` | map | Edit visit site data from the map |
| `TrailEditService` | map | Trail CRUD operations |
| `PmTilesManager` | map | PMTiles base map asset management |
