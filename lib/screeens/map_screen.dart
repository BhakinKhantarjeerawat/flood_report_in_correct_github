import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/map_controller_provider.dart';
import '../providers/location_provider.dart';
import '../providers/marker_provider.dart';
import '../widgets/map_widget.dart';
import '../widgets/marker_filter_toggle.dart';
import '../widgets/map_app_bar.dart';
import '../widgets/map_floating_actions.dart';
import '../widgets/map_error_widget.dart';
import '../widgets/map_loading_widget.dart';
import '../services/map_navigation_service.dart';
import '../utils/snackbar_utils.dart';
import '../providers/map_navigation_provider.dart';
import '../providers/marker_popup_provider.dart';
import '../widgets/flood_marker_popup.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  
  @override
  void initState() {
    super.initState();
    // Markers are now handled by the provider
  }

  void _goToCurrentLocation() async {
    final navigationNotifier = ref.read(mapNavigationProvider.notifier);
    
    await MapNavigationService.navigateToLocation(
      mapNotifier: ref.read(mapControllerProvider.notifier),
      locationNotifier: ref.read(currentLocationProvider.notifier),
      isCurrentlyZoomed: navigationNotifier.hasGoneToCurrentLocation,
      onStateChange: () => navigationNotifier.toggleLocationView(),
      onError: (errorMessage) => SnackBarUtils.showError(context, errorMessage),
    );
  }

  void _onMapReady() {
    ref.read(mapNavigationProvider.notifier).setMapReady();
  }

  // Reset the toggle state when user manually interacts with map
  void _resetCurrentLocationState() {
    ref.read(mapNavigationProvider.notifier).resetLocationState();
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
                // Hide popup when tapping on map
                ref.read(markerPopupProvider.notifier).hidePopup();
              },
              onMapReady: _onMapReady,
            ),
            // Marker filter toggle positioned at top-right
            const Positioned(
              top: 16,
              right: 16,
              child: MarkerFilterToggle(),
            ),
            // Marker popup overlay
            Consumer(
              builder: (context, ref, child) {
                final popupState = ref.watch(markerPopupProvider);
                if (popupState.isVisible && popupState.selectedFlood != null) {
                  return Positioned.fill(
                    child: Center(
                      child: FloodMarkerPopup(
                        flood: popupState.selectedFlood!,
                        onClose: () => ref.read(markerPopupProvider.notifier).hidePopup(),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        floatingActionButton: Consumer(
          builder: (context, ref, child) {
            final navigationState = ref.watch(mapNavigationProvider);
            return MapFloatingActions(
              onGoToCurrentLocation: _goToCurrentLocation,
              hasGoneToCurrentLocation: navigationState.hasGoneToCurrentLocation,
            );
          },
        ),
      ),
    );
  }
}