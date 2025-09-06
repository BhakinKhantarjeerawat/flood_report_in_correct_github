import 'package:flood_marker/global_functions.dart/get_marker_icon.dart';
import 'package:flood_marker/models/flood.dart';
import 'package:flood_marker/screeens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'markers_controller_provider.g.dart';

@riverpod
class MarkersController extends _$MarkersController {

  @override
  Future<List<Marker>> build() async {
    final response = await Supabase.instance.client
        .from('flood_reports')
        .select('*')
        .order('created_at', ascending: false);

    final List<Flood> floods = response.map<Flood>((data) {
      return Flood.fromMap(data);
    }).toList();

      final markers = _convertFloodsToMarkers(floods);

      return markers;
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
            flood;
          },
          child: getMarkerIcon(flood.severity),
        ),
      );
    }).toList();
  }

  // * delelete
  Future<void> deleteMarker(String markerId) async {
  try {
    // Remove from local list immediately for UI responsiveness
 state = AsyncValue.data(
      state.value?.where((marker) => marker.id != markerId).toList() ?? []
    );

    
    // Delete from Supabase database
    await Supabase.instance.client
        .from('flood_reports')
        .delete()
        .eq('id', markerId);
    
    // Optional: Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Flood report deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    // Revert local change if database deletion fails
    await _loadMarkers(); // Reload from database
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete flood report: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
}

 

 
