import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class MapControllerNotifier extends StateNotifier<MapController?> {
  MapControllerNotifier() : super(null) {
    debugPrint('🗺️ MapControllerNotifier: Created new instance');
  }

  // Initialize the controller when map is ready
  void initializeController(MapController controller) {
    state = controller;
    debugPrint('🗺️ MapControllerNotifier: Controller initialized');
  }

  // Move to specific location
  void moveToLocation(LatLng location, {double? zoom}) {
    if (state != null) {
      state!.move(location, zoom ?? 10.0);
    } else {
      debugPrint('🗺️ MapControllerNotifier: Controller not initialized yet');
    }
  }

  // Reset map to default position
  void resetToDefault({LatLng? defaultCenter, double? defaultZoom}) {
    if (state != null) {
      final center = defaultCenter ?? const LatLng(13.7563, 100.5018); // Bangkok center
      final zoom = defaultZoom ?? 10.0;
      state!.move(center, zoom);
    } else {
      debugPrint('🗺️ MapControllerNotifier: Controller not initialized yet');
    }
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

// Provider for the map controller
final mapControllerProvider = StateNotifierProvider<MapControllerNotifier, MapController?>(
  (ref) {
    debugPrint('🗺️ mapControllerProvider: Creating new MapControllerNotifier');
    return MapControllerNotifier();
  },
);
