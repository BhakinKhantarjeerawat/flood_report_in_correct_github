import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static const LatLng _bangkokCenter = LatLng(13.7563, 100.5018);
  final Location _location = Location();

  /// Get the default Bangkok center location
  static LatLng get bangkokCenter => _bangkokCenter;

  /// Check if location service is enabled and request if needed
  Future<bool> isLocationServiceEnabled() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
    }
    return serviceEnabled;
  }

  /// Check location permissions and request if needed
  Future<bool> hasLocationPermission() async {
    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }
    return permissionGranted == PermissionStatus.granted;
  }

  /// Get current location with fallback to Bangkok
  Future<LatLng> getCurrentLocation() async {
    try {
      // Check location service
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _bangkokCenter;
      }

      // Check permissions
      bool hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        return _bangkokCenter;
      }

      // Get current location
      LocationData locationData = await _location.getLocation();
      return LatLng(locationData.latitude!, locationData.longitude!);
    } catch (e) {
      // Return Bangkok as fallback
      return _bangkokCenter;
    }
  }

  /// Initialize location with timeout fallback
  Future<LatLng> initializeLocation({Duration timeout = const Duration(seconds: 3)}) async {
    try {
      return await getCurrentLocation().timeout(timeout);
    } catch (e) {
      // Return Bangkok as fallback
      return _bangkokCenter;
    }
  }
}
