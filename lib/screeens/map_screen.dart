import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../models/flood.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  bool _isLoading = true;
  LatLng? _currentLocation;
  List<Marker> _markers = [];
  
  // Sample flood markers data - replace with your actual data
  final List<Flood> _floodData = [
    Flood(
      id: '1',
      lat: 13.7563,
      lng: 100.5018,
      severity: 'severe',
      depthCm: 50,
      note: 'Heavy flooding in downtown area',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      expiresAt: DateTime.now().add(const Duration(hours: 4)),
      confirms: 5,
      flags: 0,
      status: 'active',
    ),
    Flood(
      id: '2',
      lat: 13.7563,
      lng: 100.5018,
      severity: 'blocked',
      depthCm: 30,
      note: 'Moderate flooding in residential area',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      expiresAt: DateTime.now().add(const Duration(hours: 5)),
      confirms: 3,
      flags: 0,
      status: 'active',
    ),
    Flood(
      id: '3',
      lat: 13.7563,
      lng: 100.5018,
      severity: 'passable',
      depthCm: 15,
      note: 'Minor flooding in park area',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      expiresAt: DateTime.now().add(const Duration(hours: 5, minutes: 30)),
      confirms: 1,
      flags: 0,
      status: 'active',
    ),
    Flood(
      id: '4',
      lat: 13.7563,
      lng: 100.5018,
      severity: 'severe',
      depthCm: 60,
      note: 'Severe flooding in industrial zone',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      expiresAt: DateTime.now().add(const Duration(hours: 3)),
      confirms: 7,
      flags: 1,
      status: 'active',
    ),
    Flood(
      id: '5',
      lat: 13.7563,
      lng: 100.5018,
      severity: 'blocked',
      depthCm: 35,
      note: 'Moderate flooding in shopping district',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      expiresAt: DateTime.now().add(const Duration(hours: 4, minutes: 30)),
      confirms: 4,
      flags: 0,
      status: 'active',
    ),
    Flood(
      id: '6',
      lat: 13.7563,
      lng: 100.5018,
      severity: 'passable',
      depthCm: 20,
      note: 'Minor flooding in residential area',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      expiresAt: DateTime.now().add(const Duration(hours: 5, minutes: 15)),
      confirms: 2,
      flags: 0,
      status: 'active',
    ),
    Flood(
      id: '7',
      lat: 13.7563,
      lng: 100.5018,
      severity: 'severe',
      depthCm: 70,
      note: 'Critical flooding in hospital area',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      expiresAt: DateTime.now().add(const Duration(hours: 2)),
      confirms: 8,
      flags: 2,
      status: 'active',
    ),
    Flood(
      id: '8',
      lat: 13.7563,
      lng: 100.5018,
      severity: 'blocked',
      depthCm: 40,
      note: 'Moderate flooding in school area',
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      expiresAt: DateTime.now().add(const Duration(hours: 3, minutes: 45)),
      confirms: 6,
      flags: 0,
      status: 'active',
    ),
    Flood(
      id: '9',
      lat: 13.7563,
      lng: 100.5018,
      severity: 'passable',
      depthCm: 18,
      note: 'Minor flooding in park area',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      expiresAt: DateTime.now().add(const Duration(hours: 5, minutes: 40)),
      confirms: 1,
      flags: 0,
      status: 'active',
    ),
    Flood(
      id: '10',
      lat: 13.7563,
      lng: 100.5018,
      severity: 'severe',
      depthCm: 55,
      note: 'Severe flooding in airport area',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      confirms: 9,
      flags: 1,
      status: 'active',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Request location permissions
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _showErrorSnackBar('Location service is disabled');
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          _showErrorSnackBar('Location permission denied');
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
      // Set default location if location fails
      _currentLocation = const LatLng(13.7563, 100.5018); // Bangkok
      _generateMarkers();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generateMarkers() {
    _markers = _floodData.map((flood) {
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
      case 'high':
        markerColor = Colors.red;
        iconData = Icons.warning;
        break;
      case 'medium':
        markerColor = Colors.orange;
        iconData = Icons.info;
        break;
      case 'low':
        markerColor = Colors.yellow;
        iconData = Icons.info_outline;
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
    // Simple location naming - you can replace this with reverse geocoding
    if (lat == 13.7563 && lng == 100.5018) {
      return 'Bangkok';
    }
    return 'Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
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
        return Colors.yellow;
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

  void _goToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Map with marker clustering
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(13.7563, 100.5018),
              initialZoom: 12.0,
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
          
          // Legend overlay
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Legend',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLegendItem('High Risk (Severe)', Colors.red),
                  _buildLegendItem('Medium Risk (Blocked)', Colors.orange),
                  _buildLegendItem('Low Risk (Passable)', Colors.yellow),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
