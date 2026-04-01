# Feature Matrix — Galapagos Wildlife

| Feature | Audience | Status | Dependencies | Priority | Beta? |
|---------|----------|--------|-------------|----------|-------|
| Species Catalog | All | Stable | Drift, Supabase | P0 | No |
| Species Detail | All | Stable | Drift, Supabase, Images | P0 | No |
| Favorites | Users | Stable | Auth, Drift | P0 | No |
| Sighting Recording | Users | Stable | Auth, Camera, GPS | P0 | No |
| Home Screen | All | Stable | — | P0 | No |
| Settings | All | Stable | SharedPreferences | P0 | No |
| Onboarding | All | Stable | — | P1 | No |
| Badges & Achievements | Users | Stable | Auth, Sightings | P1 | No |
| User Profile | Users | Stable | Auth, Supabase | P1 | No |
| Leaderboard | Users | Stable | Auth, Sightings | P2 | No |
| Interactive Map | All | Beta | flutter_map, PMTiles | P1 | Yes |
| Visit Sites | All | Beta | Map, Supabase | P1 | Yes |
| Trail Tracking | Rangers | Beta | Map, GPS | P1 | Yes |
| Photo ID (AI) | All | Beta | TFLite, Camera | P1 | Yes |
| AR Camera (YOLO) | All | Planned | TFLite, Camera | P2 | Yes |
| Sound ID (BirdNET) | All | Planned | TFLite, Audio | P2 | Yes |
| Admin Dashboard | Admin | Stable | Auth, Roles | P1 | No |
| Species CRUD | Admin | Stable | Auth, Supabase | P1 | No |
| Image Management | Admin | Stable | Auth, Storage | P1 | No |
| User Management | Admin | Stable | Auth, RPC | P1 | No |
| Editorial Proposals | Editor | Stable | Auth, Roles | P2 | No |
| Curator Review | Curator | Stable | Auth, Roles | P2 | No |
| Apple Watch Sync | Users | Beta | WCSession | P2 | Yes |
| Daily Facts | All | Stable | — | P3 | No |
| Search | All | Stable | Drift | P1 | No |
