import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/flood.dart';
import '../providers/map_controller_provider.dart';
import '../providers/location_provider.dart';
import '../providers/marker_provider.dart';
import '../services/location_service.dart';
import '../widgets/map_widget.dart';
import '../widgets/marker_filter_toggle.dart';
import 'flood_report_form.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  // State variables
  bool _isMapReady = false;
  bool _hasGoneToCurrentLocation = false;
  
  @override
  void initState() {
    super.initState();
    // Markers are now handled by the provider
  }



  void _goToCurrentLocation() {
    if (!_isMapReady) {
      // Show a snackbar if map is not ready
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Map is still loading, please wait...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final locationNotifier = ref.read(currentLocationProvider.notifier);
    final currentLocation = locationNotifier.currentLocation;
    
    // Check if map is ready using the notifier's isReady getter
    final mapNotifier = ref.read(mapControllerProvider.notifier);
    if (!mapNotifier.isReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Map not ready yet. Please wait...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    if (currentLocation != null) {
      ref
          .read(mapControllerProvider.notifier)
          .moveToLocation(currentLocation, zoom: 10.0);
    } else {
      // If no current location, go to Bangkok center
      ref
          .read(mapControllerProvider.notifier)
          .moveToLocation(LocationService.bangkokCenter, zoom: 10.0);
    }
    
    // Update state to show we've gone to current location
    setState(() {
      _hasGoneToCurrentLocation = true;
    });
  }

  void _onMapReady() {
    setState(() {
      _isMapReady = true;
    });
  }

  void _resetCurrentLocationState() {
    setState(() {
      _hasGoneToCurrentLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentLocationProvider);
    final markers = ref.watch(displayMarkersProvider);
    
    return locationAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading map: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(currentLocationProvider.notifier).refreshLocation(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (currentLocation) => Scaffold(
        appBar: AppBar(
          title: Consumer(
            builder: (context, ref, child) {
              final allMarkers = ref.watch(markerProvider);
              final displayMarkers = ref.watch(displayMarkersProvider);
              final isFiltered = ref.watch(markerFilterProvider);
              final filterText = isFiltered ? '200km' : 'All';
              return Text('Markers: ${displayMarkers.length}/${allMarkers.length} ($filterText)');
            },
          ),
        ),
        body: Stack(
          children: [
            MapWidget(
              center: currentLocation,
              markers: markers,
              onMapTap: (tapPosition, point) {
                // Reset current location state when user manually moves map
                _resetCurrentLocationState();
                // TODO: Handle map tap in Phase 3
              },
              onMapReady: _onMapReady,
            ),
            // Marker filter toggle positioned at top-right
            Positioned(
              top: 16,
              right: 16,
              child: const MarkerFilterToggle(),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Go to Current Location Button
            FloatingActionButton(
              onPressed: _goToCurrentLocation,
              backgroundColor: _hasGoneToCurrentLocation ? Colors.green : Colors.white,
              foregroundColor: _hasGoneToCurrentLocation ? Colors.white : Colors.blue,
              heroTag: 'currentLocation',
              child: Icon(
                _hasGoneToCurrentLocation ? Icons.check_circle : Icons.my_location,
              ),
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
                // Add new flood report to map
                ref.read(markerProvider.notifier).addMarker(result);
                _showSuccessSnackBar('New flood report added to map!');
              }
              },
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_location),
              label: const Text('Report Flood'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}