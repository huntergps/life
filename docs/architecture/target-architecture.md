# Target Architecture

## Last updated: 2026-03-31

## Vision

Fully modular offline-first wildlife app ready for package extraction. Each major
feature area should be extractable as an independent Dart/Flutter package with
minimal coupling to the main app.

## Current State Summary

The app is already well-structured with clear separation:
- `lib/app/` -- bootstrap, shell, router, theme (app infrastructure)
- `lib/data/` -- local/remote/sync (data layer)
- `lib/models/` -- domain models
- `lib/features/` -- 18 feature modules
- `lib/core/` -- shared constants, services, widgets

See `docs/architecture/current-state.md` for the full breakdown.

---

## Remaining Work

### Short-term

- [ ] Reduce `map_screen.dart` further (currently 598 lines, target: <350)
- [ ] Add integration tests for the data layer (Drift + sync)
- [ ] Add widget tests for key screens (home, species detail, sightings list)
- [ ] Empty `lib/data/remote/supabase/` directory -- either populate with Supabase-specific helpers or remove
- [ ] Remove legacy `lib/brick/` references from git (files are deleted but models still reference old paths)

### Medium-term

- [ ] Extract `wildlife_data` package (models, drift, sync)
- [ ] Extract `wildlife_admin` package (admin + editorial)
- [ ] Event bus for provider invalidation (replace direct provider imports in RealtimeService)
- [ ] Move `ImageProcessingService` from admin/ to core/ (shared by sightings and admin)
- [ ] Consolidate map layouts/ and shell/ directories (overlapping responsibility)

### Long-term

- [ ] Extract `wildlife_map` package (needs router decoupling first)
- [ ] Extract `wildlife_ai` package (needs species detail decoupling first)
- [ ] Monorepo with melos (if package count justifies it)
- [ ] Web platform support (Drift web adapter, map tile strategy)
- [ ] Custom TFLite model trained on Galapagos species (Colab pipeline ready)
- [ ] BirdNET-Lite sound identification integration
- [ ] YOLO-based AR multi-object detection

---

## Package Extraction Order

Ordered by readiness and dependency direction (most depended-on first):

### 1. `wildlife_data` (HIGH readiness)

- **Scope**: `lib/data/`, `lib/models/`
- **Contains**: Drift database, Supabase adapters, repository, sync services, 15 domain models
- **Why first**: Every feature depends on it; fewest outward dependencies
- **Blockers**: None significant -- already has its own directory tree

### 2. `wildlife_admin` (MEDIUM-HIGH readiness)

- **Scope**: `lib/features/admin/`, `lib/features/editorial/`
- **Contains**: Admin dashboard, CRUD screens/services, editorial workflow, proposal system
- **Why second**: Cleanest feature boundary; only consumed by the main app
- **Blockers**: `ImageProcessingService` should move to core first

### 3. `wildlife_map` (MEDIUM readiness)

- **Scope**: `lib/features/map/`
- **Contains**: Map screen, layers, controls, sheets, tracking, editing, PMTiles
- **Why third**: Large feature with many sub-modules already well-organized
- **Blockers**: `visitSitesProvider` and `trailProvider` are imported by other features; need interface extraction

### 4. `wildlife_ai` (LOW readiness)

- **Scope**: `lib/features/species/photo_id/`, `lib/features/ar_camera/`, `lib/features/sound_id/`
- **Contains**: TFLite inference, image preprocessing, AR camera, sound ID
- **Why last**: Most cross-cutting -- imported by ar_camera, sightings/add, species/shared, core/widgets
- **Blockers**: `species_identification_provider` needs interface decoupling from multiple consumers

See `docs/package-split-plan.md` for the detailed dependency analysis.

---

## Architecture Principles

These guide decisions as the codebase evolves:

1. **Offline-first** -- every read goes through the local Drift cache; writes queue when offline
2. **Feature isolation** -- features should not import from each other; shared code goes in core/
3. **Provider as glue** -- Riverpod providers are the integration layer between features
4. **No generated providers** -- manual Riverpod providers (riverpod_generator conflicts with Drift codegen)
5. **16:9 image standard** -- all species images stored as 1280x720 hero / 400x225 thumbnail
6. **Role-based gating** -- beta features behind `is_beta_tester`, admin routes behind role checks
7. **Seed data fallback** -- bundled JSON ensures the app works even on first launch without network
