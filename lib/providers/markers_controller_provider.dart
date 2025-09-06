import 'package:flood_marker/global_functions.dart/get_marker_icon.dart';
import 'package:flood_marker/models/flood.dart';
import 'package:flood_marker/screeens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'markers_controller_provider.g.dart';

@riverpod
class MarkersController extends _$MarkersController {
  @override
  Future<List<Flood>> build() async {
    // ✅ Change to Flood
    final response = await Supabase.instance.client
        .from('flood_reports')
        .select('*')
        .order('created_at', ascending: false);

    return response.map<Flood>((data) => Flood.fromMap(data)).toList();
  }

  Future<void> deleteMarker(String markerId) async {
    try {
      // ✅ Now this works correctly
      state = AsyncValue.data(
          state.value?.where((flood) => flood.id != markerId).toList() ?? []);

      await Supabase.instance.client
          .from('flood_reports')
          .delete()
          .eq('id', markerId);
    } catch (e) {
      // Revert on error
      state = await AsyncValue.guard(() => build());
    }
  }
}

// / Convert Flood objects to clickable map markers
@riverpod
Future<List<Marker>> convertFloodsToMarkers(Ref ref) async {
  final floods = await ref.watch(markersControllerProvider.future);

  return floods.map((flood) {
    return Marker(
      point: LatLng(flood.lat, flood.lng),
      child: GestureDetector(
        onTap: () {
          // Set the selected marker for popup display
          ref.read(selectedMarkerProvider.notifier).state = flood;
        },
        child: getMarkerIcon(flood.severity),
      ),
    );
  }).toList();
}
