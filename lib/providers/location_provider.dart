// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:latlong2/latlong.dart';

// import '../services/location_service.dart';

// /// Provider for the location service
// final locationServiceProvider = Provider<LocationService>((ref) {
//   return LocationService();
// });

// /// Provider for current location state
// final currentLocationProvider = StateNotifierProvider<LocationNotifier, AsyncValue<LatLng>>((ref) {
//   return LocationNotifier(ref.read(locationServiceProvider));
// });

// /// Notifier for managing location state
// class LocationNotifier extends StateNotifier<AsyncValue<LatLng>> {
//   final LocationService _locationService;

//   LocationNotifier(this._locationService) : super(const AsyncValue.loading()) {
//     _initializeLocation();
//   }

//   /// Initialize location with timeout fallback
//   Future<void> _initializeLocation() async {
//     try {
//       state = const AsyncValue.loading();
//       final location = await _locationService.initializeLocation();
//       state = AsyncValue.data(location);
//     } catch (e) {
//       state = AsyncValue.error(e, StackTrace.current);
//     }
//   }

//   /// Refresh current location
//   Future<void> refreshLocation() async {
//     try {
//       state = const AsyncValue.loading();
//       final location = await _locationService.getCurrentLocation();
//       state = AsyncValue.data(location);
//     } catch (e) {
//       state = AsyncValue.error(e, StackTrace.current);
//     }
//   }

//   /// Set location to Bangkok center
//   void setBangkokCenter() {
//     state = AsyncValue.data(LocationService.bangkokCenter);
//   }

//   /// Get current location value (synchronous)
//   // LatLng? get currentLocation {
//   //   return state.when(
//   //     data: (location) => location,
//   //     loading: () => null,
//   //     error: (_, __) => null,
//   //   );
//   // }

//   // /// Check if location is loading
//   // bool get isLoading => state.isLoading;

//   // /// Check if location has error
//   // bool get hasError => state.hasError;
// }
