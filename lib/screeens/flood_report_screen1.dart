import 'dart:async';
import 'package:flood_marker/screeens/flood_report_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as location_package;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flood_report_screen1.g.dart';

class FloodReportScreen1 extends ConsumerStatefulWidget {
  const FloodReportScreen1({super.key});

  @override
  ConsumerState<FloodReportScreen1> createState() => _FloodReportScreen1State();
}

class _FloodReportScreen1State extends ConsumerState<FloodReportScreen1> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _noteController = TextEditingController();
  final _depthController = TextEditingController();

  // Form state
  String _selectedSeverity = 'passable';

  // Severity options
  static const List<Map<String, dynamic>> _severityOptions = [
    {
      'value': 'passable',
      'label': 'Passable',
      'color': Colors.green,
      'icon': Icons.check_circle
    },
    {
      'value': 'blocked',
      'label': 'Blocked',
      'color': Colors.orange,
      'icon': Icons.block
    },
    {
      'value': 'severe',
      'label': 'Severe',
      'color': Colors.red,
      'icon': Icons.warning
    },
  ];


  @override
  void dispose() {
    _noteController.dispose();
    _depthController.dispose();
    super.dispose();
  }

  // todo: implement location methods
  Future<void> _getCurrentLocation() async {
    // todo: get current location
  }

  Future<void> _getLocationName() async {
    // todo: get location name from coordinates
  }

  // todo: implement form submission
  // Future<void> _submitReport() async {
  //   // todo: submit flood report
  // }

  String _getSeverityDescription(String severity) {
    switch (severity) {
      case 'passable':
        return 'Road is passable with caution';
      case 'blocked':
        return 'Road is blocked, use alternative route';
      case 'severe':
        return 'Dangerous flooding, avoid area';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = ref.watch(currentLocationControllerProvider(true)).value != null;
    final bool isLoading = ref.watch(currentLocationControllerProvider(true)).isLoading;
    final currentLocationController = ref.watch(currentLocationControllerProvider(true));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Flood'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: currentLocationController.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (data) =>    
      
      Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Section
              buildSectionHeader('📍 Location', Icons.location_on),
              buildLocationCard(
                isLoading, 
              'Current Location',
              data.latitude,
              data.longitude,
              ),
              const SizedBox(height: 24),

              // Severity Section
              buildSectionHeader('⚠️ Severity Level', Icons.warning),
              _buildSeveritySelector(),
              const SizedBox(height: 24),

              // Depth Section
              buildSectionHeader('🌊 Water Depth (Optional)', Icons.height),
              _buildDepthInput(),
              const SizedBox(height: 24),

              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(true, isLoading ),
            ],
          ),
        ),
      ),
    
      )
      
   
    );
  }

  Widget buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1976D2), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
      ],
    );
  }

  Widget buildLocationCard(bool isLocationLoading, String locationName,
      double? latitude, double? longitude) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isLocationLoading
                      ? Icons.location_searching
                      : Icons.my_location,
                  color: isLocationLoading ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  isLocationLoading
                      ? 'Getting location...'
                      : 'Current Location',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                // Development mode indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.gps_fixed,
                        size: 16,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'GPS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              locationName,
              style: const TextStyle(fontSize: 16),
            ),
            if (latitude != null && longitude != null) ...[
              const SizedBox(height: 8),
              Text(
                'Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                //todo:
                onPressed: isLocationLoading ? null : _getCurrentLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh GPS Location'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1976D2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeveritySelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: _severityOptions.map((option) {
            bool isSelected = _selectedSeverity == option['value'];
            return RadioListTile<String>(
              value: option['value'],
              groupValue: _selectedSeverity,
              onChanged: (value) {
                setState(() {
                  _selectedSeverity = value!;
                });
              },
              title: Row(
                children: [
                  Icon(
                    option['icon'],
                    color: option['color'],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    option['label'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? option['color'] : Colors.black87,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                _getSeverityDescription(option['value']),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              activeColor: option['color'],
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDepthInput() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _depthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Water Depth (cm)',
                hintText: 'e.g., 25',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.height),
              ),
              validator: (value) {
                // todo: implement validation
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Leave empty if depth is unknown',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool canSubmit, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit ? (){} : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSubmit ? const Color(0xFF1976D2) : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: canSubmit ? 3 : 0,
        ),
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Submitting Report...'),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(canSubmit ? Icons.send : Icons.info_outline),
                  const SizedBox(width: 8),
                  Text(
                    canSubmit
                        ? 'Submit Flood Report'
                        : 'Complete Required Fields',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Future<LatLng?> getCurrentLocation(
//     Ref ref, bool useMockLocation, context) async {
//   // setState(() {
//   //   _isLocationLoading = true;
//   // });

//   try {
//     if (useMockLocation) {

//       // 🎯 MOCK LOCATION: Using random Thailand location for development
//       state = const AsyncValue.loading();
//       final randomLocation = generateRandomThailandLocation();
//       final double mockLatitude = randomLocation.latitude;
//       final double mockLongitude = randomLocation.longitude;

//       // Simulate a small delay to show loading state
//       await Future.delayed(const Duration(milliseconds: 800));
//       state = AsyncValue.data(LatLng(mockLatitude, mockLongitude));

//       // setState(() {
//       //   _latitude = mockLatitude;
//       //   _longitude = mockLongitude;
//       //   _isLocationLoading = false;
//       // });

//       // // Get location name for the mock coordinates
//       // await _getLocationName();

//       // // Show success message with random location
//       // _showSuccessSnackBar('📍 Mock location set: Random location in Thailand (${mockLatitude.toStringAsFixed(4)}, ${mockLongitude.toStringAsFixed(4)})');
//     } else {
//       // 📍 REAL GPS: Using actual device location
//       location_package.Location location = location_package.Location();

//       try {
//         // Check permissions with timeout
//         bool serviceEnabled = await location.serviceEnabled().timeout(
//           const Duration(seconds: 10),
//           onTimeout: () {
//             throw TimeoutException('Location service check timed out');
//           },
//         );

//         if (!serviceEnabled) {
//           serviceEnabled = await location.requestService().timeout(
//             const Duration(seconds: 15),
//             onTimeout: () {
//               throw TimeoutException('Location service request timed out');
//             },
//           );
//           if (!serviceEnabled) {
//             _showErrorSnackBar(
//                 'Location service is disabled. Please enable GPS in device settings.',
//                 context);
//             return;
//           }
//         }

//         location_package.PermissionStatus permissionGranted =
//             await location.hasPermission().timeout(
//           const Duration(seconds: 10),
//           onTimeout: () {
//             throw TimeoutException('Permission check timed out');
//           },
//         );

//         if (permissionGranted == location_package.PermissionStatus.denied) {
//           permissionGranted = await location.requestPermission().timeout(
//             const Duration(seconds: 15),
//             onTimeout: () {
//               throw TimeoutException('Permission request timed out');
//             },
//           );
//           if (permissionGranted != location_package.PermissionStatus.granted) {
//             _showErrorSnackBar(
//                 'Location permission denied. Please grant location access in app settings.',
//                 context);
//             return;
//           }
//         }

//         // Get current location with timeout
//         location_package.LocationData currentLocation =
//             await location.getLocation().timeout(
//           const Duration(seconds: 20),
//           onTimeout: () {
//             throw TimeoutException(
//                 'Getting location timed out. Please try again.');
//           },
//         );

//         // Validate coordinates
//         if (currentLocation.latitude == null ||
//             currentLocation.longitude == null) {
//           throw Exception('Invalid location data received');
//         }

//         setState(() {
//           _latitude = currentLocation.latitude;
//           _longitude = currentLocation.longitude;
//           _isLocationLoading = false;
//         });

//         // Get location name
//         await _getLocationName();
//       } on TimeoutException catch (e) {
//         _showErrorSnackBar('Location timeout: ${e.message}', context);
//         debugPrint('⏰ Location timeout: $e');
//       } catch (e) {
//         _showErrorSnackBar(
//             'Location error: ${_getUserFriendlyErrorMessage(e)}', context);
//         debugPrint('📍 Location error: $e');
//       }
//     }
//   } catch (e) {
//     setState(() {
//       _isLocationLoading = false;
//     });
//     if (useMockLocation) {
//       _showErrorSnackBar('Error setting mock location: $e', context);
//     } else {
//       _showErrorSnackBar('Error getting location: $e', context);
//     }
//   }
// }

void _showErrorSnackBar(String message, context) {
  // if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
  // }
}

@Riverpod(keepAlive: true)
class CurrentLocationController extends _$CurrentLocationController {
  @override
  FutureOr<LatLng> build(bool useMockLocation) {
    return const LatLng(13.7563, 100.5018);
  }

  Future<void> getCurrentLocation(bool useMockLocation, context) async {

    if (useMockLocation) {
    // 🎯 MOCK LOCATION: Using random Thailand location for development
      state = const AsyncValue.loading();
      final randomLocation = generateRandomThailandLocation();
      final double mockLatitude = randomLocation.latitude;
      final double mockLongitude = randomLocation.longitude;

      // Simulate a small delay to show loading state
      await Future.delayed(const Duration(milliseconds: 800));
      state = AsyncValue.data(LatLng(mockLatitude, mockLongitude));
      return;
    }

    // 📍 REAL GPS: Using actual device location
    location_package.Location location = location_package.Location();
    try {
      // Check permissions with timeout
      bool serviceEnabled = await location.serviceEnabled().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Location service check timed out');
        },
      );

      if (!serviceEnabled) {
        serviceEnabled = await location.requestService().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Location service request timed out');
          },
        );
        if (!serviceEnabled) {
          _showErrorSnackBar(
              'Location service is disabled. Please enable GPS in device settings.',
              context);
          return;
        }
      }

      location_package.PermissionStatus permissionGranted =
          await location.hasPermission().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Permission check timed out');
        },
      );

      if (permissionGranted == location_package.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Permission request timed out');
          },
        );
        if (permissionGranted != location_package.PermissionStatus.granted) {
          _showErrorSnackBar(
              'Location permission denied. Please grant location access in app settings.',
              context);
          return;
        }
      }

      // Get current location with timeout
      location_package.LocationData currentLocation =
          await location.getLocation().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException(
              'Getting location timed out. Please try again.');
        },
      );

      // Validate coordinates
      if (currentLocation.latitude == null ||
          currentLocation.longitude == null) {
        // throw Exception('Invalid location data received');
        state = AsyncValue.error(
            Exception('Invalid location data received'), StackTrace.current);
      }
      state = AsyncValue.data(
          LatLng(currentLocation.latitude!, currentLocation.longitude!));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
