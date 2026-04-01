# Galapagos Wildlife 🦎

## About

Offline-first mobile guide for the fauna of the Galapagos Islands. Built for tourists, naturalists, and park rangers.

## Features

- Species catalog (reptiles, birds, mammals, marine life, invertebrates, spiders)
- Offline-first — works without internet
- On-device AI species identification (TFLite)
- Interactive map with visit sites, trails, and species locations
- Species sighting recording with photos and GPS
- Sound identification (BirdNET-Lite)
- Achievement badges and leaderboard
- Multi-language (English/Spanish)
- Apple Watch companion
- Admin panel for data management
- Editorial workflow (proposals, curator review)

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.38 / Dart 3.10 |
| State | Riverpod 3.x |
| Routing | go_router 17.x |
| Local DB | Drift (SQLite) via drift_offline_first |
| Backend | Supabase (Auth, Storage, Realtime, Postgres) |
| Maps | flutter_map + PMTiles |
| ML | tflite_flutter (MobileNetV3) |
| i18n | Slang (ES/EN) |
| Watch | WatchKit + WCSession |

## Architecture

- Offline-first with local SQLite + Supabase sync
- Feature-based module structure
- 15 domain models with Drift adapters
- Role-based access control (admin, editor, curator, beta_tester)

## Getting Started

```bash
# Clone
git clone https://github.com/huntergps/life.git
cd life

# Install dependencies
flutter pub get

# Run
flutter run
```

## Environment

Create a `.env` file with:

```
SUPABASE_URL=your_url
SUPABASE_ANON_KEY=your_key
```

## Project Structure

```
lib/
  models/          — 15 domain model classes
  drift/           — Drift database, tables, adapters, repository
  core/            — Theme, router, services, widgets, utils
  features/        — Feature modules (home, species, map, sightings, etc.)
  watch/           — Apple Watch connectivity and data sync
```

## Beta Features

Map, Photo ID, and AR Camera are gated behind a `beta_tester` role in Supabase.

## Roadmap

- [ ] Custom TFLite species classifier trained on Galapagos data
- [ ] BirdNET-Lite sound identification
- [ ] YOLO multi-object AR detection
- [ ] Offline map tile caching improvements
- [ ] Web platform support

## License

Private repository.
