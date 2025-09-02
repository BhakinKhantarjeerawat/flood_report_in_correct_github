import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/map_controller_provider.dart';
import '../providers/location_provider.dart';
import '../providers/marker_provider.dart';
import '../services/location_service.dart';
import '../widgets/map_widget.dart';
import '../widgets/marker_filter_toggle.dart';
import '../widgets/map_app_bar.dart';
import '../widgets/map_floating_actions.dart';
import '../widgets/map_error_widget.dart';
import '../widgets/map_loading_widget.dart';
import '../services/map_navigation_service.dart';
import '../utils/snackbar_utils.dart';

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

  void _goToCurrentLocation() async {
    await MapNavigationService.navigateToLocation(
      mapNotifier: ref.read(mapControllerProvider.notifier),
      locationNotifier: ref.read(currentLocationProvider.notifier),
      isCurrentlyZoomed: _hasGoneToCurrentLocation,
      onStateChange: (isZoomed) => setState(() => _hasGoneToCurrentLocation = isZoomed),
      onError: (errorMessage) => SnackBarUtils.showError(context, errorMessage),
    );
  }

  void _onMapReady() {
    setState(() {
      _isMapReady = true;
    });
  }

  // Reset the toggle state when user manually interacts with map
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
      loading: () => const MapLoadingWidget(),
      error: (error, stack) => MapErrorWidget(error: error),
      data: (currentLocation) => Scaffold(
        appBar: const MapAppBar(),
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
          const  Positioned(
              top: 16,
              right: 16,
              child: MarkerFilterToggle(),
            ),
          ],
        ),
        floatingActionButton: MapFloatingActions(
          onGoToCurrentLocation: _goToCurrentLocation,
          hasGoneToCurrentLocation: _hasGoneToCurrentLocation,
        ),
      ),
    );
  }
}