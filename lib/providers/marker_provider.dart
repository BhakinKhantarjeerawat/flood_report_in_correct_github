import 'dart:math';
import 'package:flood_marker/providers/flood_reports_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import '../models/flood.dart';
import '../providers/location_provider.dart';
import '../providers/marker_popup_provider.dart';
import '../widgets/marker_filter_toggle.dart';

/// Provider for managing map markers
final markerProvider = StateNotifierProvider<MarkerNotifier, List<Marker>>((ref) {
  return MarkerNotifier(ref);
});

/// Calculate distance between two points in kilometers
double _calculateDistance(LatLng point1, LatLng point2) {
  const double earthRadius = 6371; // Earth's radius in kilometers
  
  final lat1Rad = point1.latitude * (pi / 180);
  final lat2Rad = point2.latitude * (pi / 180);
  final deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
  final deltaLonRad = (point2.longitude - point1.longitude) * (pi / 180);
  
  final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
      cos(lat1Rad) * cos(lat2Rad) * sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  
  return earthRadius * c;
}

/// Filter markers by distance from user location
List<Marker> _filterMarkersByDistance(List<Marker> markers, LatLng userLocation, {double maxDistanceKm = 200}) {
  return markers.where((marker) {
    // Extract coordinates from marker (this is a simplified approach)
    // In a real implementation, you might want to store the original flood data with markers
    final markerPoint = marker.point;
    final distance = _calculateDistance(userLocation, markerPoint);
    return distance <= maxDistanceKm;
  }).toList();
}

/// Provider for filtered markers within 200km of user location
final filteredMarkersProvider = Provider<List<Marker>>((ref) {
  final allMarkers = ref.watch(markerProvider);
  // final userLocation = ref.watch(currentLocationProvider);
  final userLocation = const LatLng(13.7563, 100.5018);

  
  return  _filterMarkersByDistance(allMarkers, userLocation, maxDistanceKm: 200);
});

/// Provider for markers based on user filter preference
final displayMarkersProvider = Provider<List<Marker>>((ref) {
  final isFiltered = ref.watch(markerFilterProvider);
  final allMarkers = ref.watch(markerProvider);
  final filteredMarkers = ref.watch(filteredMarkersProvider);
  
  return isFiltered ? filteredMarkers : allMarkers;
});

/// Notifier for managing marker state
class MarkerNotifier extends StateNotifier<List<Marker>> {
  final Ref _ref;

  MarkerNotifier(this._ref) : super([]) {
    _generateMarkers();
  }

  /// Generate markers from flood reports
  Future<void> _generateMarkers() async {
    try {
      // Get flood reports from the Supabase provider
      final reportsAsync = _ref.read(floodReportsProvider);
      
      if (reportsAsync.hasValue) {
        final reports = reportsAsync.value!;
        state = _createMarkersFromReports(reports);
      } else {
        // If provider doesn't have data yet, fetch it
        await _ref.read(floodReportsProvider.notifier).fetchAllReports();
        final currentReportsAsync = _ref.read(floodReportsProvider);
        if (currentReportsAsync.hasValue) {
          final reports = currentReportsAsync.value!;
          state = _createMarkersFromReports(reports);
        } else {
          state = [];
        }
      }
    } catch (e) {
      debugPrint('❌ MarkerNotifier: Error generating markers: $e');
      state = [];
    }
  }

  /// Create markers from flood reports
  List<Marker> _createMarkersFromReports(List<Flood> reports) {
    return reports.map((flood) {
      return Marker(
        point: LatLng(flood.lat, flood.lng),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _onMarkerTap(flood),
          child: _buildMarkerIcon(flood),
        ),
      );
    }).toList();
  }

  /// Build marker icon based on flood status and severity
  Widget _buildMarkerIcon(Flood flood) {
    Color markerColor;
    IconData iconData;

    // Check if report is expired or resolved
    if (flood.status == 'expired') {
      markerColor = Colors.grey.withOpacity(0.5);
      iconData = Icons.schedule;
    } else if (flood.status == 'resolved') {
      markerColor = Colors.grey;
      iconData = Icons.check_circle;
    } else if (flood.status == 'stale') {
      markerColor = Colors.orange.withOpacity(0.7);
      iconData = Icons.warning;
    } else {
      // Active report - use severity-based colors
      switch (flood.severity.toLowerCase()) {
        case 'severe':
          markerColor = Colors.red;
          iconData = Icons.warning;
          break;
        case 'blocked':
          markerColor = Colors.orange;
          iconData = Icons.block;
          break;
        case 'passable':
          markerColor = Colors.green;
          iconData = Icons.check_circle;
          break;
        default:
          markerColor = Colors.grey;
          iconData = Icons.place;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: markerColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  /// Handle marker tap
  void _onMarkerTap(Flood flood) {
    // Show popup with flood details
    _ref.read(markerPopupProvider.notifier).showPopup(flood);
    debugPrint('📍 Marker tapped: ${flood.id} at ${flood.lat}, ${flood.lng}');
  }

  /// Refresh markers
  Future<void> refreshMarkers() async {
    await _generateMarkers();
  }

  /// Add new marker
  void addMarker(Flood flood) {
    final newMarker = Marker(
      point: LatLng(flood.lat, flood.lng),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _onMarkerTap(flood),
        child: _buildMarkerIcon(flood),
      ),
    );
    state = [...state, newMarker];
  }

  /// Remove marker by flood ID
  void removeMarker(String floodId) {
    state = state.where((marker) {
      // Extract flood ID from marker (you might need to adjust this based on your marker structure)
      return true; // TODO: Implement proper marker identification
    }).toList();
  }

  /// Get markers count
  int get markersCount => state.length;

  /// Check if markers are loading
  bool get isLoading => state.isEmpty;
}
