# flood_marker

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/flood.dart';

/// Provider for managing map markers from Supabase flood reports
class MarkersControllerNotifier extends StateNotifier<AsyncValue<List<Marker>>> {
  MarkersControllerNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;

  /// Load markers from Supabase flood reports
  Future<void> loadMarkersFromSupabase() async {
    try {
      state = const AsyncValue.loading();
      
      // Load flood reports from Supabase
      final response = await Supabase.instance.client
          .from('flood_reports')
          .select('*')
          .order('created_at', ascending: false);
      
      final List<Flood> floods = response.map<Flood>((data) {
        return Flood.fromMap(data);
      }).toList();
      
      // Convert floods to markers
      final markers = _convertFloodsToMarkers(floods);
      state = AsyncValue.data(markers);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Convert Flood objects to clickable map markers
  List<Marker> _convertFloodsToMarkers(List<Flood> floods) {
    return floods.map((flood) {
      return Marker(
        point: LatLng(flood.lat, flood.lng),
        child: GestureDetector(
          onTap: () {
            // Set the selected marker for popup display
            ref.read(selectedMarkerProvider.notifier).state = 
                LatLng(flood.lat, flood.lng);
          },
          child: _getMarkerIcon(flood.severity),
        ),
      );
    }).toList();
  }

  /// Get marker icon based on severity
  Widget _getMarkerIcon(String severity) {
    Color color;
    IconData icon;
    
    switch (severity.toLowerCase()) {
      case 'severe':
        color = Colors.red;
        icon = Icons.warning;
        break;
      case 'blocked':
        color = Colors.orange;
        icon = Icons.block;
        break;
      case 'passable':
      default:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: color,
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
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  /// Refresh markers from Supabase
  Future<void> refreshMarkers() async {
    await loadMarkersFromSupabase();
  }
}

/// Provider instance for markers controller
final markersControllerProvider = StateNotifierProvider<MarkersControllerNotifier, AsyncValue<List<Marker>>>(
  (ref) => MarkersControllerNotifier(ref),
);

/// Provider for selected marker coordinates
final selectedMarkerProvider = StateProvider<LatLng?>((ref) {
  return null;
});