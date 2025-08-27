import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class MapControllerNotifier extends StateNotifier<MapController> {
  MapControllerNotifier() : super(MapController()) {
    debugPrint('🗺️ MapControllerNotifier: Created new instance');
  }

  // Move to specific location
  void moveToLocation(LatLng location, {double? zoom}) {
    state.move(location, zoom ?? 10.0);
  }

  // Reset map to default position
  void resetToDefault({LatLng? defaultCenter, double? defaultZoom}) {
    final center = defaultCenter ?? const LatLng(13.7563, 100.5018); // Bangkok center
    final zoom = defaultZoom ?? 10.0;
    state.move(center, zoom);
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
}

// Provider for the map controller
final mapControllerProvider = StateNotifierProvider<MapControllerNotifier, MapController>(
  (ref) {
    debugPrint('🗺️ mapControllerProvider: Creating new MapControllerNotifier');
    return MapControllerNotifier();
  },
);
