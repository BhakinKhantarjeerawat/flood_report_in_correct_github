import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../providers/map_controller_provider.dart';
import '../providers/location_provider.dart';
import '../services/location_service.dart';

class MapNavigationService {
  /// Navigates to current location with toggle functionality
  /// 
  /// [mapNotifier] - The map controller notifier
  /// [locationNotifier] - The location notifier
  /// [isCurrentlyZoomed] - Whether the map is currently zoomed in
  /// [onStateChange] - Callback to update the UI state
  /// [onError] - Callback to handle errors
  static Future<void> navigateToLocation({
    required MapControllerNotifier mapNotifier,
    required LocationNotifier locationNotifier,
    required bool isCurrentlyZoomed,
    required VoidCallback onStateChange,
    required Function(String) onError,
  }) async {
    try {
      // Check if map is ready
      if (!mapNotifier.isReady) {
        onError('Map not ready yet. Please wait...');
        return;
      }

      // Get current location
      final currentLocation = locationNotifier.currentLocation;
      final targetLocation = currentLocation ?? LocationService.bangkokCenter;
      
      // Determine zoom level based on current state
      final zoomLevel = isCurrentlyZoomed ? 6.0 : 10.0;
      
      // Navigate to location
      mapNotifier.moveToLocation(targetLocation, zoom: zoomLevel);
      
      // Update state (toggle the zoom state)
      onStateChange();
      
    } catch (e) {
      onError('Failed to navigate to location: $e');
    }
  }

  /// Validates if map navigation is possible
  static bool canNavigate({
    required bool isMapReady,
    required MapControllerNotifier mapNotifier,
  }) {
    if (!isMapReady) {
      return false;
    }
    
    if (!mapNotifier.isReady) {
      return false;
    }
    
    return true;
  }

  /// Gets the appropriate error message for navigation issues
  static String getNavigationErrorMessage({
    required bool isMapReady,
    required MapControllerNotifier mapNotifier,
  }) {
    if (!isMapReady) {
      return 'Map is still loading, please wait...';
    }
    
    if (!mapNotifier.isReady) {
      return 'Map not ready yet. Please wait...';
    }
    
    return 'Unknown navigation error';
  }
}
