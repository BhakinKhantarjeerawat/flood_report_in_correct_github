import 'package:flood_marker/fake_data/flood_data.dart';
import 'package:flood_marker/providers/map_controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../models/flood.dart';
import '../services/storage_service.dart';
import '../services/user_action_service.dart';
import '../services/data_lifecycle_service.dart';
import '../widgets/marker_search_filter.dart';
import '../widgets/enhanced_marker_popup.dart';
import '../config/app_config.dart';
import 'flood_report_form.dart';
import 'user_reports_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final Location _location = Location();
  final StorageService _storageService = StorageService();
  final UserActionService _userActionService = UserActionService();
  final DataLifecycleService _dataLifecycleService = DataLifecycleService();
  bool _isLoading = true;
  LatLng? _currentLocation;
  List<Marker> _markers = [];
  List<Marker> _filteredMarkers = [];
  List<Flood> _allFloodReports = [];
  OverlayEntry? _popupOverlay;
  Flood? _selectedFlood;

  @override
  void initState() {
    super.initState();
    _initializeMap();

    // Add a timeout to prevent infinite loading
    //todo: check the delay time
    Future.delayed(const Duration(seconds: 1), () async {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _currentLocation = const LatLng(13.7563, 100.5018); // Bangkok center
        });
        await _generateMarkers();
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
          await _generateMarkers();
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
          await _generateMarkers();
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Get current location
      LocationData locationData = await _location.getLocation();
      _currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);

      // Generate markers from flood data
      await _generateMarkers();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnackBar('Error getting location: $e');
      // Set default location if location fails - Center of Bangkok
      _currentLocation = const LatLng(13.7563, 100.5018); // Bangkok center
      await _generateMarkers();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateMarkers() async {
    try {
      // Load saved reports from local storage
      List<Flood> savedReports = await _storageService.loadFloodReports();
      debugPrint(
          '🗺️ Loaded ${savedReports.length} saved reports from local storage');

      // // Combine fake data with saved reports
      // _allFloodReports = [...floodData, ...savedReports];
      // debugPrint('🗺️ Total reports: ${_allFloodReports.length} (${floodData.length} fake + ${savedReports.length} saved)');

      // With this conditional logic:
      if (AppConfig.useFakeData) {
        // Development mode: Use fake data + saved reports
        _allFloodReports = [...floodData, ...savedReports];
        AppConfig.infoLog(
            '��️ Development mode: Total reports: ${_allFloodReports.length} (${floodData.length} fake + ${savedReports.length} saved)');
      } else {
        // Production mode: Use only real data (saved reports)
        _allFloodReports = List.from(savedReports);
        AppConfig.infoLog(
            '🗺️ Production mode: Total reports: ${_allFloodReports.length} (real data only)');
      }

      // Process lifecycle statuses (active, resolved, stale, expired)
      _allFloodReports = await _dataLifecycleService
          .processLifecycleStatuses(_allFloodReports);
      debugPrint(
          '🔄 Processed lifecycle statuses for ${_allFloodReports.length} reports');

      // Clean up expired reports
      _allFloodReports =
          await _dataLifecycleService.cleanupExpiredReports(_allFloodReports);
      debugPrint(
          '🧹 Cleaned up expired reports, remaining: ${_allFloodReports.length}');

      // Get statistics for debugging
      Map<String, int> stats =
          _dataLifecycleService.getReportStatistics(_allFloodReports);
      debugPrint('📊 Report statistics: $stats');

      // Generate markers from all reports
      _markers = _allFloodReports.map((flood) {
        return Marker(
          point: LatLng(flood.lat, flood.lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showMarkerInfo(flood),
            child: _buildMarkerIcon(flood),
          ),
        );
      }).toList();
      _filteredMarkers = List.from(_markers); // Initially show all markers

      setState(() {
        // Trigger rebuild to show new markers
      });
    } catch (e) {
      debugPrint('❌ Error loading saved reports: $e');
      // Fallback to fake data only
      _allFloodReports = List.from(floodData);
      _markers = _allFloodReports.map((flood) {
        return Marker(
          point: LatLng(flood.lat, flood.lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showMarkerInfo(flood),
            child: _buildMarkerIcon(flood),
          ),
        );
      }).toList();
      _filteredMarkers = List.from(_markers);
    }
  }

  Widget _buildMarkerIcon(Flood flood) {
    Color markerColor;
    IconData iconData;

    // Check if report is expired or resolved
    if (flood.status == 'expired') {
      markerColor = Colors.grey.withOpacity(0.5);
      iconData = Icons.schedule;
    } else if (flood.status == 'resolved') {
      markerColor = Colors.grey;
      iconData = Icons.check_circle;
    } else if (flood.status == 'stale') {
      markerColor = Colors.orange.withOpacity(0.7);
      iconData = Icons.warning;
    } else {
      // Active report - use severity-based colors
      switch (flood.severity.toLowerCase()) {
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

  void _showMarkerInfo(Flood flood) async {
    // Close any existing popup
    _closePopup();

    setState(() {
      _selectedFlood = flood;
    });

    // Check user action status
    bool userHasConfirmed =
        await _userActionService.hasConfirmedReport(flood.id);
    bool userHasFlagged = await _userActionService.hasFlaggedReport(flood.id);

    // Create overlay entry for the popup
    _popupOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: MediaQuery.of(context).size.width / 2 -
            160, // Center the popup (320 width / 2)
        top: MediaQuery.of(context).size.height / 2 -
            200, // Position above the marker
        child: EnhancedMarkerPopup(
          flood: flood,
          onClose: _closePopup,
          onConfirm: () => _confirmFloodReport(flood),
          onFlag: () => _flagFloodReport(flood),
          onMarkResolved: () => _markFloodResolved(flood),
          userHasConfirmed: userHasConfirmed,
          userHasFlagged: userHasFlagged,
        ),
      ),
    );

    // Insert the overlay
    Overlay.of(context).insert(_popupOverlay!);
  }

  void _closePopup() {
    if (_popupOverlay != null) {
      _popupOverlay!.remove();
      _popupOverlay = null;
    }
    setState(() {
      _selectedFlood = null;
    });
  }

  void _confirmFloodReport(Flood flood) async {
    try {
      // Check if user has already confirmed this report
      bool alreadyConfirmed =
          await _userActionService.hasConfirmedReport(flood.id);
      if (alreadyConfirmed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already confirmed this report'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Mark as confirmed by user
      bool userActionSaved =
          await _userActionService.markReportAsConfirmed(flood.id);
      if (!userActionSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save user action'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create updated flood report with incremented confirms
      Flood updatedFlood = flood.copyWith(
        confirms: flood.confirms + 1,
      );

      // Update in local storage
      bool saved = await _storageService.saveFloodReport(updatedFlood);
      if (saved) {
        // Update in local lists
        _updateFloodReportInLists(updatedFlood);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Confirmed flood report: ${flood.id}'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the popup to show new count
        _refreshPopup(updatedFlood);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save confirmation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error confirming flood report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _flagFloodReport(Flood flood) async {
    try {
      // Check if user has already flagged this report
      bool alreadyFlagged = await _userActionService.hasFlaggedReport(flood.id);
      if (alreadyFlagged) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already flagged this report'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Mark as flagged by user
      bool userActionSaved =
          await _userActionService.markReportAsFlagged(flood.id);
      if (!userActionSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save user action'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create updated flood report with incremented flags
      Flood updatedFlood = flood.copyWith(
        flags: flood.flags + 1,
      );

      // Update in local storage
      bool saved = await _storageService.saveFloodReport(updatedFlood);
      if (saved) {
        // Update in local lists
        _updateFloodReportInLists(updatedFlood);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Flagged flood report: ${flood.id}'),
            backgroundColor: Colors.orange,
          ),
        );

        // Refresh the popup to show new count
        _refreshPopup(updatedFlood);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save flag'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error flagging flood report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _markFloodResolved(Flood flood) async {
    try {
      // Create updated flood report with resolved status
      Flood updatedFlood = flood.copyWith(
        status: 'resolved',
      );

      // Update in local storage
      bool saved = await _storageService.saveFloodReport(updatedFlood);
      if (saved) {
        // Update in local lists
        _updateFloodReportInLists(updatedFlood);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked flood report as resolved: ${flood.id}'),
            backgroundColor: Colors.green,
          ),
        );

        // Close popup and refresh map
        _closePopup();
        await _generateMarkers(); // Refresh to show updated status
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to mark as resolved'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error marking flood report as resolved: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateFloodReportInLists(Flood updatedFlood) {
    // Update in _allFloodReports
    int index = _allFloodReports.indexWhere((f) => f.id == updatedFlood.id);
    if (index != -1) {
      _allFloodReports[index] = updatedFlood;
    }

    // Update in fake data if it exists there
    int fakeIndex = floodData.indexWhere((f) => f.id == updatedFlood.id);
    if (fakeIndex != -1) {
      floodData[fakeIndex] = updatedFlood;
    }

    // Regenerate markers to reflect changes
    _generateMarkers();
  }

  void _refreshPopup(Flood updatedFlood) async {
    // Close current popup
    _closePopup();

    // Show new popup with updated data
    setState(() {
      _selectedFlood = updatedFlood;
    });

    // Check user action status for updated flood
    bool userHasConfirmed =
        await _userActionService.hasConfirmedReport(updatedFlood.id);
    bool userHasFlagged =
        await _userActionService.hasFlaggedReport(updatedFlood.id);

    // Create new overlay entry
    _popupOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: MediaQuery.of(context).size.width / 2 - 160,
        top: MediaQuery.of(context).size.height / 2 - 200,
        child: EnhancedMarkerPopup(
          flood: updatedFlood,
          onClose: _closePopup,
          onConfirm: () => _confirmFloodReport(updatedFlood),
          onFlag: () => _flagFloodReport(updatedFlood),
          onMarkResolved: () => _markFloodResolved(updatedFlood),
          userHasConfirmed: userHasConfirmed,
          userHasFlagged: userHasFlagged,
        ),
      ),
    );

    // Insert the overlay
    Overlay.of(context).insert(_popupOverlay!);
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
    debugPrint(
        '🗺️ _addNewFloodReport called with: ${newFlood.id} at ${newFlood.lat}, ${newFlood.lng}');
    debugPrint('🗺️ Current markers count: ${_markers.length}');

    // Create a new marker for the flood report
    final newMarker = Marker(
      point: LatLng(newFlood.lat, newFlood.lng),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _showMarkerInfo(newFlood),
        child: _buildMarkerIcon(newFlood),
      ),
    );

    debugPrint('🗺️ Created new marker: ${newMarker.point}');

    // Add the new marker to all lists
    setState(() {
      _allFloodReports.add(newFlood);
      _markers.add(newMarker);
      _filteredMarkers.add(newMarker);
      debugPrint('🗺️ Added marker to lists. New count: ${_markers.length}');
    });

    // Move map to show the new marker
    final newLocation = LatLng(newFlood.lat, newFlood.lng);
    ref
        .read(mapControllerProvider.notifier)
        .moveToLocation(newLocation, zoom: 14.0);

    debugPrint('🗺️ Moved map to new location: $newLocation');
    debugPrint('🗺️ Final markers count: ${_markers.length}');
  }

  void _onFilterChanged(List<Flood> filteredReports) {
    setState(() {
      _filteredMarkers = filteredReports.map((flood) {
        return Marker(
          point: LatLng(flood.lat, flood.lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showMarkerInfo(flood),
            child: _buildMarkerIcon(flood),
          ),
        );
      }).toList();
    });
    debugPrint(
        '🔍 Filter applied: showing ${_filteredMarkers.length} of ${_markers.length} markers');
  }

  void _onClearFilters() {
    setState(() {
      _filteredMarkers = List.from(_markers);
    });
    debugPrint('🔍 Filters cleared: showing all ${_markers.length} markers');
  }

  void _goToCurrentLocation() {
    if (_currentLocation != null) {
      ref
          .read(mapControllerProvider.notifier)
          .moveToLocation(_currentLocation!, zoom: 10.0);
    } else {
      // If no current location, go to Bangkok center
      ref
          .read(mapControllerProvider.notifier)
          .moveToLocation(const LatLng(13.7563, 100.5018), zoom: 10.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🗺️ MapScreen: Building with loading: $_isLoading, location: $_currentLocation');
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Zoom In Button
          FloatingActionButton(
            onPressed: () {
              // Zoom in by moving to current location with higher zoom
              final currentLocation =
                  _currentLocation ?? const LatLng(13.7563, 100.5018);
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
              final currentLocation =
                  _currentLocation ?? const LatLng(13.7563, 100.5018);
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
                debugPrint(
                    '🗺️ Form returned Flood object: ${result.id} at ${result.lat}, ${result.lng}');
                _addNewFloodReport(result);
                _showSuccessSnackBar('New flood report added to map!');
              } else {
                debugPrint(
                    '🗺️ Form returned: $result (type: ${result.runtimeType})');
              }
            },
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_location),
            label: const Text('Report Flood'),
          ),
          const SizedBox(height: 16),
          // My Reports Button
          FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UserReportsScreen(),
                ),
              );
            },
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            heroTag: 'myReports',
            child: const Icon(Icons.history),
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
              initialCenter:
                  _currentLocation ?? const LatLng(13.7563, 100.5018),
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
                  markers: _filteredMarkers,
                  builder: (context, markers) {
                    debugPrint(
                        '🗺️ Rendering cluster with ${markers.length} markers');
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
                markers: _filteredMarkers,
              ),
            ],
          ),

          // Search and Filter Widget
          Positioned(
            top: MediaQuery.of(context).padding.top + 80, // Below the app bar
            left: 16,
            right: 16,
            child: MarkerSearchFilter(
              allMarkers: _allFloodReports,
              onFilterChanged: _onFilterChanged,
              onClearFilters: _onClearFilters,
            ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _filteredMarkers.length < _markers.length
                          ? Colors.orange
                          : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _filteredMarkers.length < _markers.length
                              ? Icons.filter_list
                              : Icons.location_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_filteredMarkers.length}/${_markers.length}',
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
          // TotalMarkersWidget(filteredMarkers: _filteredMarkers, markers: _markers),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up any open popup
    _closePopup();
    super.dispose();
  }
}
