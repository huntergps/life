import 'package:flutter_map/flutter_map.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';

/// Safe zoom getter — returns default zoom if map controller is not ready.
double safeGetZoom(MapController controller) {
  try {
    return controller.camera.zoom;
  } catch (e) {
    return AppConstants.galapagosDefaultZoom;
  }
}

/// Safe rotation getter — returns 0 if map controller is not ready.
double safeGetRotation(MapController controller) {
  try {
    return controller.camera.rotation;
  } catch (e) {
    return 0.0;
  }
}

/// Returns `true` if the given lat/lng falls within (or near) the visible
/// viewport, with a 10 % buffer on each side.
bool isWithinViewport(MapController controller, double? lat, double? lng) {
  if (lat == null || lng == null) return false;
  try {
    final camera = controller.camera;
    final bounds = camera.visibleBounds;
    final latBuffer = (bounds.north - bounds.south) * 0.1;
    final lngBuffer = (bounds.east - bounds.west) * 0.1;
    return lat >= bounds.south - latBuffer &&
        lat <= bounds.north + latBuffer &&
        lng >= bounds.west - lngBuffer &&
        lng <= bounds.east + lngBuffer;
  } catch (e) {
    return true;
  }
}
