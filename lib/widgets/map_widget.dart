// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:flutter_map/flutter_map.dart';

// import '../models/flood.dart';
// import '../providers/map_controller_provider.dart';

// class MapWidget extends ConsumerStatefulWidget {
//   final LatLng center;
//   final List<Marker> markers;
//   final TapCallback? onMapTap;
//   final Function(Flood)? onMarkerTap;
//   final VoidCallback? onMapReady;

//   const MapWidget({
//     super.key,
//     required this.center,
//     required this.markers,
//     this.onMapTap,
//     this.onMarkerTap,
//     this.onMapReady,
//   });

//   @override
//   ConsumerState<MapWidget> createState() => _MapWidgetState();
// }

// class _MapWidgetState extends ConsumerState<MapWidget> {
//   MapController? _localController;
//   bool _isMapReady = false;
//   bool _isInteractiveViewerReady = false;

//   @override
//   void initState() {
//     super.initState();
//     _localController = MapController();
//   }

//   @override
//   void dispose() {
//     _localController?.dispose();
//     super.dispose();
//   }

//   void _onMapReady() {
//     if (!_isMapReady) {
//       setState(() {
//         _isMapReady = true;
//       });
      
//       // Initialize the controller in the provider
//       ref.read(mapControllerProvider.notifier).initializeController(_localController!);
      
//       // Mark InteractiveViewer as ready after a short delay
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         setState(() {
//           _isInteractiveViewerReady = true;
//         });
//         ref.read(mapControllerProvider.notifier).markInteractiveViewerReady();
        
//         // Notify parent that map is ready
//         widget.onMapReady?.call();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FlutterMap(
//       mapController: _localController,
//       options: MapOptions(
//         initialCenter: widget.center,
//         initialZoom: 6.0,
//         onTap: widget.onMapTap,
//         onMapReady: _onMapReady,
//       ),
//       children: [
//         TileLayer(
//           urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//           userAgentPackageName: 'com.example.flood_marker',
//         ),
//         MarkerLayer(
//           markers: widget.markers,
//         ),
//       ],
//     );
//   }
// }
