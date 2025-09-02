import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import '../models/flood.dart';
import '../providers/map_controller_provider.dart';

class MapWidget extends ConsumerWidget {
  final LatLng center;
  final List<Marker> markers;
  final TapCallback? onMapTap;
  final Function(Flood)? onMarkerTap;
  final VoidCallback? onMapReady;

  const MapWidget({
    super.key,
    required this.center,
    required this.markers,
    this.onMapTap,
    this.onMarkerTap,
    this.onMapReady,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapController = ref.watch(mapControllerProvider);
    
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 6.0,
        onTap: onMapTap,
        onMapReady: () {
          // Initialize the controller when map is ready
          if (mapController == null) {
            ref.read(mapControllerProvider.notifier).initializeController(MapController());
          }
          // Add a small delay to ensure everything is ready
          Future.delayed(const Duration(milliseconds: 200), () {
            // Notify that the map is ready
            onMapReady?.call();
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.flood_marker',
        ),
        MarkerLayer(
          markers: markers,
        ),
      ],
    );
  }
}
