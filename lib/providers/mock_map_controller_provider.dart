import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'map_controller_provider.dart';

/// Mock Map Controller for testing and development
/// This allows you to override the real map controller in ProviderScope
class MockMapControllerNotifier extends MapControllerNotifier {
  MockMapControllerNotifier() : super() {
    debugPrint('🗺️ Mock Map Controller: Created - will move to Bangkok center');
    // Automatically move to Bangkok center when created
    Future.microtask(() {
      if (mounted) {
        moveToBangkok();
      }
    });
  }

  // Mock data for testing
  static const LatLng _mockBangkokCenter = LatLng(13.7563, 100.5018);
  static const double _mockZoom = 10.0;

  // Mock method that always returns to Bangkok center
  void moveToBangkok() {
    debugPrint('🗺️ Mock Map Controller: Moving to Bangkok center');
    state.move(_mockBangkokCenter, _mockZoom);
  }

  // Mock method that simulates location updates
  void simulateLocationUpdate(LatLng newLocation) {
    debugPrint('📍 Mock Map Controller: Simulating location update to $newLocation');
    state.move(newLocation, _mockZoom);
  }

  // Mock method that simulates zoom changes
  void simulateZoomChange(double newZoom) {
    debugPrint('🔍 Mock Map Controller: Simulating zoom change to $newZoom');
    state.move(_mockBangkokCenter, newZoom);
  }

  // Mock method that simulates map interactions
  void simulateMapInteraction(String interaction) {
    debugPrint('🎮 Mock Map Controller: Simulating $interaction');
    // You can add specific mock behavior here
  }

  // Get mock map state
  Map<String, dynamic> getMockMapState() {
    return {
      'center': _mockBangkokCenter,
      'zoom': _mockZoom,
      'isMock': true,
      'lastAction': 'Mock map controller initialized',
    };
  }

  @override
  void dispose() {
    debugPrint('🧹 Mock Map Controller: Disposing mock controller');
    super.dispose();
  }
}

// Mock provider that can be used to override the real one
final mockMapControllerProvider = StateNotifierProvider<MockMapControllerNotifier, MapController>(
  (ref) => MockMapControllerNotifier(),
);

// Provider that can switch between real and mock controllers
final configurableMapControllerProvider = StateNotifierProvider<StateNotifier<MapController>, MapController>(
  (ref) {
    // You can control this with environment variables or build flags
    const bool useMock = bool.fromEnvironment('USE_MOCK_MAP_CONTROLLER', defaultValue: false);
    
    if (useMock) {
      debugPrint('🔧 Using Mock Map Controller');
      return MockMapControllerNotifier();
    } else {
      debugPrint('🔧 Using Real Map Controller');
      return MapControllerNotifier();
    }
  },
);
