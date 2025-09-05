import 'package:flood_marker/models/flood.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'markers_controller_provider.g.dart';

@riverpod
class MarkersController extends _$MarkersController {
  @override
  Future<List<Marker>> build() async {
    // final markers = await Supabase.instance.client.from('markers').select('*');
    final response = await Supabase.instance.client
        .from('flood_reports')
        .select('*')
        .order('created_at', ascending: false);

    final List<Flood> floods = response.map<Flood>((data) {
      return Flood.fromMap(data);
    }).toList();

    // return floods;

      // Convert floods to markers
      final markers = _convertFloodsToMarkers(floods);
      // state = AsyncValue.data(markers);
      return markers;
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
            // ref.read(selectedMarkerProvider.notifier).state = 
            //     LatLng(flood.lat, flood.lng);
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
