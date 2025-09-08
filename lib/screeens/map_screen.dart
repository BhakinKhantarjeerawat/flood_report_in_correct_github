import 'package:flood_marker/models/flood.dart';
import 'package:flood_marker/providers/floods_controller_provider.dart';
import 'package:flood_marker/providers/user_provider.dart';
import 'package:flood_marker/screeens/flood_report_screen1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../widgets/marker_popup.dart';

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
    final selectedMarker = ref.watch(selectedMarkerProvider);
    final convertFloodsToMarkers = ref.watch(convertFloodsToMarkersProvider);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              //* 1. debug display part
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 39),
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
              //* 2. flutter map part
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: ref.watch(initialCenterProvider),
                    initialZoom: ref.watch(initialZoomProvider),
                    onTap: (tapPosition, point) {
                      ref.read(tapPositionPointProvider.notifier).state = point;
                      // Close popup if tapping outside
                      if (selectedMarker != null) {
                        ref.read(selectedMarkerProvider.notifier).state = null;
                      }
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
                      if (mounted) {
                        ref.read(isMapReadyProvider.notifier).state = true;
                      }
                      debugPrint('✅ MAP READY!');
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.flood_marker',
                    ),
                    // MarkerLayer(markers: markersController.valueOrNull ?? []),
                    MarkerLayer(
                        markers: convertFloodsToMarkers.valueOrNull ?? []),
                  ],
                ),
              ),
            ],
          ),
          //* 3. Marker popup overlay
          if (selectedMarker != null)
            Positioned.fill(
              child: Center(
                child: MarkerPopup(
                  flood: selectedMarker,
                  onClose: () {
                    ref.read(selectedMarkerProvider.notifier).state = null;
                  },
                ),
              ),
            ),
          //* 4. Test button
          isFlutterMapReady
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        children: [
                          const SizedBox(height: 34),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FloodReportScreen1(),
                                  ),
                                );

                                // final currentUser = ref.read(userControllerProvider).requireValue;
                                // debugPrint(currentUser!.id);
                                // String id = const Uuid().v4();
                                // ref
                                //     .read(floodsControllerProvider.notifier)
                                //     .addFlood(// In your UI code:
                                //         Flood(
                                //       id: id,
                                //       userId: currentUser.id,
                                //       lat: 15.1341,
                                //       lng: 104.5134,
                                //       severity: 'blocked',
                                //       depthCm: 27,
                                //       note:
                                //           'Road completely flooded but just a short time',
                                //       // photoUrls: ['photo1.jpg', 'photo2.jpg'],
                                //       createdAt: DateTime.now(),
                                //       expiresAt: DateTime.now()
                                //           .add(const Duration(hours: 6)),
                                //     ));

                                // if (mounted) {
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     const SnackBar(
                                //       content: Text(
                                //           'Flood report added successfully'),
                                //       backgroundColor: Colors.green,
                                //     ),
                                //   );
                                // }
                              },
                              child: const Text('Add Marker')),
                          ElevatedButton(
                              onPressed: () {
                                if (selectedMarker != null) {
                                  ref
                                      .read(floodsControllerProvider.notifier)
                                      .updateFlood(selectedMarker.id,
                                          selectedMarker.copyWith(depthCm: 77));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'No flood marker selected (selected marker == null)'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: const Text('Update Flood')),
                          ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(userControllerProvider.notifier)
                                    .signOut();
                              },
                              child: const Text('Sign Out'))
                        ],
                      )),
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
  return 7.0;
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

final selectedMarkerProvider = StateProvider<Flood?>((ref) {
  return null;
});
