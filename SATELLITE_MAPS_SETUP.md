# Mapbox Satellite Maps Setup

The app now supports 4 map modes, including high-resolution satellite imagery from Mapbox (available only to registered users).

## Map Modes

1. **Street Map** (always available)
   - OpenStreetMap tiles with offline caching
   - Works without internet after download

2. **Vector Map** (always available after download)
   - Lightweight offline vector tiles (3 MB)
   - Download via the map download sheet

3. **Satellite** (requires login + Mapbox token)
   - High-resolution satellite imagery
   - Best for wildlife observation and terrain viewing

4. **Hybrid** (requires login + Mapbox token)
   - Satellite imagery with street labels overlay
   - Ideal for navigation with satellite context

## Getting a Free Mapbox Access Token

Mapbox offers a **generous free tier** (200,000 tile requests/month, enough for most users):

### 1. Create a Mapbox Account
- Go to: https://account.mapbox.com/auth/signup/
- Sign up with email or GitHub

### 2. Get Your Access Token
- After signup, you'll see your **default public token** on the dashboard
- Copy the token (starts with `pk.`)

### 3. Add Token to Your Project

**Option A: Compile-time (Recommended for development)**
```bash
flutter run --dart-define=MAPBOX_ACCESS_TOKEN=pk.your_token_here
```

**Option B: Update .env file (for reference, NOT read at runtime)**
```
MAPBOX_ACCESS_TOKEN=pk.your_actual_token_here
```

**Option C: Hardcode in MapboxConstants (NOT recommended for production)**

Edit `lib/core/constants/mapbox_constants.dart`:
```dart
static const String _placeholderToken = 'pk.your_actual_token_here';
```

### 4. For Production Builds

Add to your build commands:

**Android:**
```bash
flutter build apk --dart-define=MAPBOX_ACCESS_TOKEN=pk.your_token
```

**iOS:**
```bash
flutter build ios --dart-define=MAPBOX_ACCESS_TOKEN=pk.your_token
```

**macOS:**
```bash
flutter build macos --dart-define=MAPBOX_ACCESS_TOKEN=pk.your_token
```

## Free Tier Limits

Mapbox free tier includes:
- ✅ 200,000 tile requests/month
- ✅ Satellite imagery at zoom levels 0-14 (native)
- ✅ Streets overlay for hybrid mode
- ✅ Commercial use allowed

This is more than enough for:
- ~1,000 users viewing maps daily
- Extended use in Galápagos area
- App development and testing

## Testing Satellite Maps

1. **Run the app with token**:
   ```bash
   flutter run -d macos --dart-define=MAPBOX_ACCESS_TOKEN=pk.your_token
   ```

2. **Login to the app** (satellite maps require authentication)

3. **Open the map screen**

4. **Tap the map mode icon** (top right in app bar)

5. **Select "Satellite" or "Hybrid"** from the bottom sheet

## Features

### Authentication Gate
- Satellite and Hybrid modes show a lock icon 🔒
- Non-logged users see a message: "Login required for satellite maps"
- Street and Vector modes work for everyone

### Map Quality
- **Max zoom: 18** (for satellite/hybrid)
- **Native zoom: 14** (tiles are crisp up to zoom 14, then upscaled)
- **Tile format**: JPEG90 at 2x resolution (512px tiles)
- **Coverage**: Global, including Galápagos Islands

### Performance Optimizations
- `maxNativeZoom: 14` reduces storage (no redundant tiles beyond zoom 14)
- Retina tiles (`@2x`) for crisp display on high-DPI screens
- JPEG90 compression for faster loading

## Troubleshooting

### "Login required for satellite maps" appears even when logged in
- Check that Supabase auth is working: `Supabase.instance.client.auth.currentUser`
- Verify you're using a registered account

### Satellite tiles don't load
1. Check token is valid: Run `flutter run --dart-define=MAPBOX_ACCESS_TOKEN=pk.your_token`
2. Check internet connection (satellite tiles are NOT cached offline)
3. Verify token in Mapbox dashboard: https://account.mapbox.com/access-tokens/

### Map shows street view instead of satellite
- Ensure you have a valid token configured
- Check `MapboxConstants.hasToken` returns `true`
- Fallback to street map is expected if token is missing

## Privacy & Security

**⚠️ IMPORTANT**:
- NEVER commit your Mapbox token to git
- `.env` is already in `.gitignore`
- Use `--dart-define` for builds
- For CI/CD: use environment variables or secrets

## Alternative: OpenStreetMap Only

If you prefer NOT to use Mapbox:
- The app works perfectly with just Street + Vector modes
- No Mapbox account needed
- Simply don't configure `MAPBOX_ACCESS_TOKEN`
- Satellite/Hybrid options will be hidden from logged-in users (or shown as disabled)

## Cost Monitoring

Monitor your usage at: https://account.mapbox.com/statistics/

Typical usage for Galápagos Wildlife app:
- ~50-200 tile requests per user session
- ~1,000-5,000 requests/day with 50 active users
- Well within the 200,000/month free limit

---

**Questions?** See Mapbox docs: https://docs.mapbox.com/api/maps/raster-tiles/
