import 'package:flood_marker/global_functions.dart/get_marker_icon.dart';
import 'package:flood_marker/models/flood.dart';
import 'package:flood_marker/screeens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'floods_controller_provider.g.dart';

@riverpod
class FloodsController extends _$FloodsController {
  @override
  Future<List<Flood>> build() async {
    // ✅ Change to Flood
    final response = await Supabase.instance.client
        .from('flood_reports')
        .select('*')
        .order('created_at', ascending: false);

    return response.map<Flood>((data) => Flood.fromMap(data)).toList();
  }

  Future<void> deleteFlood(String floodId) async {
    try {
      state = AsyncValue.data(
          state.value?.where((flood) => flood.id != floodId).toList() ?? []);

      await Supabase.instance.client
          .from('flood_reports')
          .delete()
          .eq('id', floodId);
    } catch (e) {
      debugPrint('error deleteFlood: $e');
      state = await AsyncValue.guard(() => build());
    }
  }

   Future<void> addFlood(Flood newFlood) async {
    try {
    state = AsyncValue.data([
      ...(state.value ?? []),
      newFlood,
    ]);

    await Supabase.instance.client
        .from('flood_reports')
        .insert(newFlood.toMap());

    } catch (e) {
      debugPrint('error addFlood: $e');
      state = await AsyncValue.guard(() => build());
    }
  }

     Future<void> updateFlood(String floodId, Flood updatedFlood) async {
    try {

     // Optimistic update - replace the flood in local list
    state = AsyncValue.data(
      (state.value ?? []).map((flood) {
        return flood.id == floodId ? updatedFlood : flood;
      }).toList()
    );

    // Update in Supabase database
    await Supabase.instance.client
        .from('flood_reports')
        .update(updatedFlood.toMap())
        .eq('id', floodId);

    } catch (e) {
      debugPrint('error addFlood: $e');
      state = await AsyncValue.guard(() => build());
    }
  }

  //   Future<void> emptyAllFloods() async {
  //   try {
  //     // ✅ Now this works correctly
  //     // state = AsyncValue.data(
  //     //     state.value?.where((flood) => flood.id != markerId).toList() ?? []);
  //     print('throw test');
  //     throw Exception('test');
  //     state = const  AsyncData([]);

  //     // await Supabase.instance.client
  //     //     .from('flood_reports')
  //     //     .delete()
  //     //     .eq('id', markerId);
  //   } catch (e) {
  //     // Revert on error
  //     state = await AsyncValue.guard(() => build());
  //   }
  // }

}

// / Convert Flood objects to clickable map markers
@riverpod
Future<List<Marker>> convertFloodsToMarkers(Ref ref) async {
  final floods = await ref.watch(floodsControllerProvider.future);

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
