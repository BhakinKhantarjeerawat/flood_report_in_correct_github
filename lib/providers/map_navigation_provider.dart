import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class for map navigation
class MapNavigationState {
  final bool isMapReady;
  final bool hasGoneToCurrentLocation;

  const MapNavigationState({
    this.isMapReady = false,
    this.hasGoneToCurrentLocation = false,
  });

  MapNavigationState copyWith({
    bool? isMapReady,
    bool? hasGoneToCurrentLocation,
  }) {
    return MapNavigationState(
      isMapReady: isMapReady ?? this.isMapReady,
      hasGoneToCurrentLocation: hasGoneToCurrentLocation ?? this.hasGoneToCurrentLocation,
    );
  }

  @override
  String toString() {
    return 'MapNavigationState(isMapReady: $isMapReady, hasGoneToCurrentLocation: $hasGoneToCurrentLocation)';
  }
}

/// Notifier for managing map navigation state
class MapNavigationNotifier extends StateNotifier<MapNavigationState> {
  MapNavigationNotifier() : super(const MapNavigationState());

  /// Set map as ready
  void setMapReady() {
    state = state.copyWith(isMapReady: true);
  }

  /// Toggle the location view state (zoom in/out)
  void toggleLocationView() {
    state = state.copyWith(
      hasGoneToCurrentLocation: !state.hasGoneToCurrentLocation,
    );
  }

  /// Reset the location state (when user manually interacts with map)
  void resetLocationState() {
    state = state.copyWith(hasGoneToCurrentLocation: false);
  }

  /// Get current location toggle state
  bool get hasGoneToCurrentLocation => state.hasGoneToCurrentLocation;

  /// Get current map ready state
  bool get isMapReady => state.isMapReady;
}

/// Provider for map navigation state
final mapNavigationProvider = StateNotifierProvider<MapNavigationNotifier, MapNavigationState>(
  (ref) => MapNavigationNotifier(),
);
