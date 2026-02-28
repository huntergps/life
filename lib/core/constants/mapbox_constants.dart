/// Free satellite map tile providers (no API key required)
class SatelliteMapConstants {
  SatelliteMapConstants._();

  // ============================================================================
  // FREE PROVIDERS (No API key required)
  // ============================================================================

  /// ESRI World Imagery - Free satellite tiles from ArcGIS
  /// Coverage: Global, including Galápagos
  /// Max zoom: 19
  /// License: Free for non-commercial and commercial use
  /// Docs: https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer
  static const String esriSatelliteUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  /// ESRI World Topo - Topographic map with terrain
  static const String esriTopoUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';

  /// CartoDB Voyager - Clean base map for labels overlay
  static const String cartoLabelsUrl =
      'https://a.basemaps.cartocdn.com/rastertiles/voyager_only_labels/{z}/{x}/{y}.png';

  // ============================================================================
  // OPTIONAL: Mapbox (requires free API key)
  // ============================================================================
  // Uncomment if you want to use Mapbox instead of ESRI
  // Get free token at: https://account.mapbox.com (200k requests/month free)

  /*
  static const String _mapboxToken = 'YOUR_MAPBOX_TOKEN_HERE';

  static String get mapboxToken =>
      const String.fromEnvironment('MAPBOX_ACCESS_TOKEN', defaultValue: _mapboxToken);

  static bool get hasMapboxToken => mapboxToken.isNotEmpty && mapboxToken != 'YOUR_MAPBOX_TOKEN_HERE';

  static String mapboxSatelliteUrl(String token) =>
      'https://api.mapbox.com/v4/mapbox.satellite/{z}/{x}/{y}@2x.jpg90?access_token=$token';
  */
}
