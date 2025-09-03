import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFlutterMapReady = ref.watch(isMapReadyProvider);
    final tapPositionPoint = ref.watch(tapPositionPointProvider);
    final mapCamara = ref.watch(mapCameraProvider);
    final initialCenter = ref.watch(initialCenterProvider);
    final initialZoom = ref.watch(initialZoomProvider);
    final markers = ref.watch(markersProvider);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          _mapController.move(
                              const LatLng(15.7563, 108.7025), 6.0);
                        },
                        icon: const Icon(Icons.location_on)),
                    Text(tapPositionPoint.toString()),
                    if (mapCamara != null) Text(mapCamara.center.toString()),
                    Text(initialCenter.latitude.toString()),
                    Text(initialZoom.toString())
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height  * 0.8,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: ref.watch(initialCenterProvider),
                    initialZoom: ref.watch(initialZoomProvider),
                    onTap: (tapPosition, point) {
                      ref.read(tapPositionPointProvider.notifier).state =
                          point;
                      debugPrint(
                          '🎯 MAP TAP: ${point.latitude}, ${point.longitude}');
                    },
                    onPositionChanged: (position, hasGesture) {
                      ref.read(mapCameraProvider.notifier).state = position;
                      debugPrint(
                          '📍 POSITION CHANGED: ${position.center}, zoom: ${position.zoom}');
                    },
                    onMapReady: () async {
                      //todo:
                      await Future.delayed(const Duration(seconds: 2));
                      ref.read(isMapReadyProvider.notifier).state = true;
                      debugPrint('✅ MAP READY!');
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.flood_marker',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
              ),
            ],
          ),
          isFlutterMapReady
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                          onPressed: () {
                            ref.read(markersProvider.notifier).state = [
                              const Marker(
                                point: LatLng(13.7563, 100.5018),
                                child: Icon(Icons.location_on),
                              ),
                              const Marker(
                                point: LatLng(13.74607, 100.79339),
                                child: Icon(Icons.location_on),
                              ),
                            ];
                          },
                          child: const Text('test markers'))),
                )
              : const Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

final initialCenterProvider = StateProvider<LatLng>((ref) {
  return const LatLng(13.7563, 100.5018);
});

final initialZoomProvider = StateProvider<double>((ref) {
  return 9.0;
});

///////////
////////////////
final tapPositionPointProvider = StateProvider<LatLng?>((ref) {
  return null;
});

final mapCameraProvider = StateProvider<MapCamera?>((ref) {
  return null;
});

final isMapReadyProvider = StateProvider<bool>((ref) {
  return false;
});
//////////
//////////

final markersProvider = StateProvider<List<Marker>>((ref) {
  return [];
});
