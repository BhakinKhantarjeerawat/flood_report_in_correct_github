import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

// State class to track map readiness
class MapState {
  final MapController? controller;
  final bool isMapReady;
  final bool isInteractiveViewerReady;

  const MapState({
    this.controller,
    this.isMapReady = false,
    this.isInteractiveViewerReady = false,
  });

  MapState copyWith({
    MapController? controller,
    bool? isMapReady,
    bool? isInteractiveViewerReady,
  }) {
    return MapState(
      controller: controller ?? this.controller,
      isMapReady: isMapReady ?? this.isMapReady,
      isInteractiveViewerReady: isInteractiveViewerReady ?? this.isInteractiveViewerReady,
    );
  }
}

class MapControllerNotifier extends StateNotifier<MapState> {
  MapControllerNotifier() : super(const MapState()) {
    debugPrint('🗺️ MapControllerNotifier: Created new instance');
  }

  // Initialize the controller when map is ready
  void initializeController(MapController controller) {
    state = state.copyWith(controller: controller, isMapReady: true);
    debugPrint('🗺️ MapControllerNotifier: Controller initialized');
  }

  // Mark InteractiveViewer as ready
  void markInteractiveViewerReady() {
    state = state.copyWith(isInteractiveViewerReady: true);
    debugPrint('🗺️ MapControllerNotifier: InteractiveViewer ready');
  }

  // Check if map is fully ready for operations
  bool get isReady => state.controller != null && state.isMapReady && state.isInteractiveViewerReady;

  // Move to specific location
  void moveToLocation(LatLng location, {double? zoom}) {
    if (!isReady) {
      debugPrint('🗺️ MapControllerNotifier: Map not ready yet. Controller: ${state.controller != null}, MapReady: ${state.isMapReady}, InteractiveReady: ${state.isInteractiveViewerReady}');
      return;
    }

    try {
      state.controller!.move(location, zoom ?? 10.0);
      debugPrint('🗺️ MapControllerNotifier: Moved to location $location');
    } catch (e) {
      debugPrint('🗺️ MapControllerNotifier: Error moving to location: $e');
    }
  }

  // Reset map to default position
  void resetToDefault({LatLng? defaultCenter, double? defaultZoom}) {
    if (!isReady) {
      debugPrint('🗺️ MapControllerNotifier: Map not ready yet for reset');
      return;
    }

    final center = defaultCenter ?? const LatLng(13.7563, 100.5018); // Bangkok center
    final zoom = defaultZoom ?? 10.0;
    
    try {
      state.controller!.move(center, zoom);
      debugPrint('🗺️ MapControllerNotifier: Reset to default position');
    } catch (e) {
      debugPrint('🗺️ MapControllerNotifier: Error resetting to default: $e');
    }
  }

  @override
  void dispose() {
    state.controller?.dispose();
    super.dispose();
  }
}

// Provider for the map controller state
final mapControllerProvider = StateNotifierProvider<MapControllerNotifier, MapState>(
  (ref) {
    debugPrint('🗺️ mapControllerProvider: Creating new MapControllerNotifier');
    return MapControllerNotifier();
  },
);
