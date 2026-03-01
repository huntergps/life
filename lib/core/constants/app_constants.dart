class AppConstants {
  AppConstants._();

  static const String appName = 'Galápagos Wildlife';
  static const String appVersion = '1.0.0';

  // Galápagos bounding box
  static const double galapagosMinLat = -2.0;
  static const double galapagosMaxLat = 1.5;
  static const double galapagosMinLng = -92.5;
  static const double galapagosMaxLng = -89.0;
  static const double galapagosDefaultLat = -0.7;
  static const double galapagosDefaultLng = -90.5;
  static const double galapagosDefaultZoom = 8.0;

  // Breakpoints
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1200.0;

  // Cache
  static const Duration cacheMaxAge = Duration(days: 7);
  static const int maxCachedTiles = 150000;

  // GPS & location
  static const double offRouteThresholdMeters = 50.0;
  static const int gpsDistanceFilterMeters = 5;

  // Layout
  static const double mapSidebarWidthFraction = 0.22;
  static const double adminTabletBreakpoint = 700.0;
}
