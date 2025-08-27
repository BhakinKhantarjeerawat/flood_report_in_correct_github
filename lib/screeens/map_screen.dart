import 'package:flood_marker/fake_data/flood_data.dart';
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
  
  @override
  void initState() {
    super.initState();
    _initializeMap();
    
    // Add a timeout to prevent infinite loading
    Future.delayed(const Duration(seconds: 10), () {
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
      _mapController.move(_currentLocation!, 10.0); // Zoom to show Bangkok area
    } else {
      // If no current location, go to Bangkok center
      _mapController.move(const LatLng(13.7563, 100.5018), 10.0);
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
