# Apple Watch Integration

## Architecture

The watch module lives under `lib/features/watch/` with two sub-directories:

- **`services/`** - Platform communication layer
  - `watch_connectivity_service.dart` - Singleton wrapping `flutter_watch_os_connectivity` (WCSession)
- **`sync/`** - Data synchronization orchestration
  - `watch_data_sync_provider.dart` - Riverpod provider that coordinates species push and sighting/trail reception

## Communication Flow (WCSession via MethodChannel)

The `flutter_watch_os_connectivity` package bridges Apple's WCSession to Flutter through a MethodChannel. All communication is bidirectional:

### iPhone to Watch: Species Data

1. On app startup, `WatchDataSync._init()` calls `syncSpeciesToWatch()`.
2. Species are fetched from the local Drift database (`WildlifeRepository`).
3. A JSON payload (id, names, category, conservation status) is sent via:
   - `updateApplicationContext` - persists for the next Watch app launch (background delivery).
   - `sendMessage` - immediate delivery if the Watch is reachable (foreground).
4. Retry logic: `updateApplicationContext` retries up to 3 times with 3-second delays.

### Watch to iPhone: Sightings

1. The Watch sends a message with `action: 'new_sighting'` containing species_id, lat/lng, notes, and observed_at.
2. Messages arrive via `messageReceived` (real-time, Watch foreground) or `userInfoReceived` (offline queue, guaranteed delivery).
3. `WatchDataSync._handleSighting()` persists the sighting via `SightingsService.createSighting()` and invalidates the `sightingsProvider`.

### Watch to iPhone: Trails

1. The Watch sends a message with `action: 'new_trail'` containing a name and coordinates array.
2. Currently logged only - **saving to database is not yet implemented** (pending trails table integration).

## Native Watch App

- SwiftUI target: `GalapagosWatch` in `ios/Runner.xcodeproj`
- Target setup script: `cd ios && ruby add_watch_target.rb`
- Deployment target: watchOS 10.0
- Product type: `:application` with `SDKROOT=watchos`

## Known Limitations and TODOs

- **Trail persistence**: `_handleTrail()` only logs received trails. Needs integration with the trails table once available.
- **Offline queue**: `transferUserInfo` guarantees delivery but there is no deduplication - a sighting sent multiple times could create duplicates.
- **Watch app installation check**: `sendSpeciesToWatch` skips sync if the Watch app is not installed, but `getPairedDeviceInfo()` can throw on non-iOS platforms.
- **No incremental sync**: The full species list is sent every time. For large catalogs, consider delta updates.
- **Platform guard**: The watch provider is initialized on all platforms; it should be guarded to iOS-only to avoid unnecessary errors on Android/web/desktop.
