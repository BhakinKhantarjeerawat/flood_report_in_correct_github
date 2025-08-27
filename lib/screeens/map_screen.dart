import 'package:flood_marker/fake_data/flood_data.dart';
import 'package:flood_marker/providers/map_controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../models/flood.dart';
import 'flood_report_form.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final Location _location = Location();
  bool _isLoading = true;
  LatLng? _currentLocation;
  List<Marker> _markers = [];
  
  @override
  void initState() {
    super.initState();
    _initializeMap();
    
    // Add a timeout to prevent infinite loading
    //todo: check the delay time
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _currentLocation = const LatLng(13.7563, 100.5018); // Bangkok center
        });
        _generateMarkers();
        _showErrorSnackBar('Location timeout - showing Bangkok area');
      }
    });
  }

  Future<void> _initializeMap() async {
    try {
      // Request location permissions
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _showErrorSnackBar('Location service is disabled');
          // Continue with default location
          _currentLocation = const LatLng(13.7563, 100.5018); // Bangkok center
          _generateMarkers();
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          _showErrorSnackBar('Location permission denied');
          // Continue with default location
          _currentLocation = const LatLng(13.7563, 100.5018); // Bangkok center
          _generateMarkers();
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Get current location
      LocationData locationData = await _location.getLocation();
      _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      
      // Generate markers from flood data
      _generateMarkers();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnackBar('Error getting location: $e');
      // Set default location if location fails - Center of Bangkok
      _currentLocation = const LatLng(13.7563, 100.5018); // Bangkok center
      _generateMarkers();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generateMarkers() {
    _markers = floodData.map((flood) {
      return Marker(
        point: LatLng(flood.lat, flood.lng),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showMarkerInfo(flood),
          child: _buildMarkerIcon(flood.severity),
        ),
      );
    }).toList();
  }

  Widget _buildMarkerIcon(String severity) {
    Color markerColor;
    IconData iconData;
    
    switch (severity.toLowerCase()) {
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

    return Container(
      decoration: BoxDecoration(
        color: markerColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
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

  void _showMarkerInfo(Flood flood) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
                             // Title
               Text(
                 'Flood Alert - ${_getLocationName(flood.lat, flood.lng)}',
                 style: const TextStyle(
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                 ),
               ),
               const SizedBox(height: 8),
               
               // Severity badge
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                 decoration: BoxDecoration(
                   color: _getSeverityColor(flood.severity),
                   borderRadius: BorderRadius.circular(20),
                 ),
                 child: Text(
                   _getSeverityDisplayName(flood.severity),
                   style: const TextStyle(
                     color: Colors.white,
                     fontWeight: FontWeight.bold,
                     fontSize: 12,
                   ),
                 ),
               ),
               const SizedBox(height: 16),
               
               // Description
               Text(
                 'Description:',
                 style: TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.w600,
                   color: Colors.grey[700],
                 ),
               ),
               const SizedBox(height: 4),
               Text(
                 flood.note ?? 'No description provided',
                 style: TextStyle(
                   fontSize: 14,
                   color: Colors.grey[600],
                 ),
               ),
               const SizedBox(height: 16),
               
               // Additional info
               if (flood.depthCm != null) ...[
                 Text(
                   'Depth: ${flood.depthCm} cm',
                   style: TextStyle(
                     fontSize: 14,
                     color: Colors.grey[600],
                   ),
                 ),
                 const SizedBox(height: 8),
               ],
               
               // Timestamp
               Text(
                 'Reported: ${_formatTimestamp(flood.createdAt)}',
                 style: TextStyle(
                   fontSize: 12,
                   color: Colors.grey[500],
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLocationName(double lat, double lng) {
    // Bangkok area location naming - you can replace this with reverse geocoding
    if (lat == 13.7466 && lng == 100.5347) return 'Siam';
    if (lat == 13.7383 && lng == 100.5608) return 'Sukhumvit';
    if (lat == 13.7310 && lng == 100.5440) return 'Lumpini Park';
    if (lat == 13.7246 && lng == 100.5270) return 'Silom';
    if (lat == 13.7414 && lng == 100.5084) return 'Chinatown';
    if (lat == 13.7587 && lng == 100.5374) return 'Victory Monument';
    if (lat == 13.8288 && lng == 100.5564) return 'Chatuchak';
    if (lat == 13.9126 && lng == 100.6068) return 'Don Mueang';
    if (lat == 13.7563 && lng == 100.4848) return 'Thonburi';
    if (lat == 13.6900 && lng == 100.7501) return 'Suvarnabhumi Airport';
    
    // Default for other locations
    return 'Bangkok Area';
  }

  String _getSeverityDisplayName(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return 'High Risk';
      case 'blocked':
        return 'Medium Risk';
      case 'passable':
        return 'Low Risk';
      default:
        return severity;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return Colors.red;
      case 'blocked':
        return Colors.orange;
      case 'passable':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _addNewFloodReport(Flood newFlood) {
    debugPrint('🗺️ _addNewFloodReport called with: ${newFlood.id} at ${newFlood.lat}, ${newFlood.lng}');
    debugPrint('🗺️ Current markers count: ${_markers.length}');
    
    // Create a new marker for the flood report
    final newMarker = Marker(
      point: LatLng(newFlood.lat, newFlood.lng),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _showMarkerInfo(newFlood),
        child: _buildMarkerIcon(newFlood.severity),
      ),
    );
    
    debugPrint('🗺️ Created new marker: ${newMarker.point}');
    
    // Add the new marker to the markers list
    setState(() {
      _markers.add(newMarker);
      debugPrint('🗺️ Added marker to list. New count: ${_markers.length}');
    });
    
    // Move map to show the new marker
    final newLocation = LatLng(newFlood.lat, newFlood.lng);
    ref.read(mapControllerProvider.notifier).moveToLocation(newLocation, zoom: 14.0);
    
    debugPrint('🗺️ Moved map to new location: $newLocation');
    debugPrint('🗺️ Final markers count: ${_markers.length}');
  }

  void _goToCurrentLocation() {
    if (_currentLocation != null) {
      ref.read(mapControllerProvider.notifier).moveToLocation(_currentLocation!, zoom: 10.0);
    } else {
      // If no current location, go to Bangkok center
      ref.read(mapControllerProvider.notifier).moveToLocation(const LatLng(13.7563, 100.5018), zoom: 10.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🗺️ MapScreen: Building with loading: $_isLoading, location: $_currentLocation');
    debugPrint('🗺️ MapScreen: Current markers count: ${_markers.length}');
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Zoom In Button
          FloatingActionButton(
            onPressed: () {
              // Zoom in by moving to current location with higher zoom
              final currentLocation = _currentLocation ?? const LatLng(13.7563, 100.5018);
              ref.read(mapControllerProvider.notifier).moveToLocation(
                currentLocation,
                zoom: 15.0, // Zoom in to street level
              );
            },
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            heroTag: 'zoomIn',
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 16),
          // Zoom Out Button
          FloatingActionButton(
            onPressed: () {
              // Zoom out by moving to current location with lower zoom
              final currentLocation = _currentLocation ?? const LatLng(13.7563, 100.5018);
              ref.read(mapControllerProvider.notifier).moveToLocation(
                currentLocation,
                zoom: 8.0, // Zoom out to city level
              );
            },
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            heroTag: 'zoomOut',
            child: const Icon(Icons.zoom_out),
          ),
          const SizedBox(height: 16),
          // Report Flood Button
          FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FloodReportForm(),
                ),
              );
              if (result != null && result is Flood) {
                // ✅ Add the new flood report to the map
                debugPrint('🗺️ Form returned Flood object: ${result.id} at ${result.lat}, ${result.lng}');
                _addNewFloodReport(result);
                _showSuccessSnackBar('New flood report added to map!');
              } else {
                debugPrint('🗺️ Form returned: $result (type: ${result.runtimeType})');
              }
            },
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_location),
            label: const Text('Report Flood'),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map with marker clustering
          // Note: mapControllerProvider is overridden in main.dart with MockMapControllerNotifier
          FlutterMap(
            mapController: ref.watch(mapControllerProvider),
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(13.7563, 100.5018),
              initialZoom: 10.0, // Better zoom level to show Bangkok area
              minZoom: 5.0,
              maxZoom: 18.0,
              onMapReady: () {
                // Map is ready
              },
            ),
            children: [
              // OpenStreetMap tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flood_marker',
                maxZoom: 19,
              ),
              
                             // Marker cluster layer
                               MarkerClusterLayerWidget(
                                 options: MarkerClusterLayerOptions(
                                   markers: _markers,
                                   builder: (context, markers) {
                                     debugPrint('🗺️ Rendering cluster with ${markers.length} markers');
                                     return Container(
                                       decoration: BoxDecoration(
                                         color: Colors.blue,
                                         shape: BoxShape.circle,
                                         border: Border.all(color: Colors.white, width: 2),
                                         boxShadow: [
                                           BoxShadow(
                                             color: Colors.black.withOpacity(0.3),
                                             blurRadius: 6,
                                             offset: const Offset(0, 3),
                                           ),
                                         ],
                                       ),
                                       child: Center(
                                         child: Text(
                                           markers.length.toString(),
                                           style: const TextStyle(
                                             color: Colors.white,
                                             fontWeight: FontWeight.bold,
                                             fontSize: 16,
                                           ),
                                         ),
                                       ),
                                     );
                                   },
                                   maxClusterRadius: 120,
                                   size: const Size(40, 40),
                                 ),
                               ),
                               
                               // 🧪 TEMPORARY: Regular marker layer to debug clustering issues
                               MarkerLayer(
                                 markers: _markers,
                               ),
                             ],
                           ),
          
          // App bar overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Flood Marker Map',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Marker count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_markers.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _goToCurrentLocation,
                    icon: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                    ),
                    tooltip: 'Go to current location',
                  ),
                ],
              ),
            ),
          ),
          
          // LegendOverlayWidget
        //  const LegendOverlayWidget(),
          
          // Marker count widget (bottom left)
          Positioned(
            bottom: 100, // Above the floating action buttons
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total Reports',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${_markers.length}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  @override
  void dispose() {
    // Map controller is managed by Riverpod, no need to dispose here
    super.dispose();
  }
}






