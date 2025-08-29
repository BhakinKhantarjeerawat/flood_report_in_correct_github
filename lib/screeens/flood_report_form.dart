import 'package:flood_marker/fake_data/flood_data.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'dart:async';
import '../models/flood.dart';
import '../services/storage_service.dart';

// 🎛️ DEVELOPMENT TOGGLE: Easy switch between mock and real GPS
// Change this to false when you want to test with real GPS
const bool useMockLocation = false;


class FloodReportForm extends StatefulWidget {
  const FloodReportForm({super.key});

  @override
  State<FloodReportForm> createState() => _FloodReportFormState();
}

class _FloodReportFormState extends State<FloodReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  
  // Form controllers
  final _noteController = TextEditingController();
  final _depthController = TextEditingController();
  
  // Form state
  String _selectedSeverity = 'passable';
  List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _isLocationLoading = false;
  
  // Location data
  double? _latitude;
  double? _longitude;
  String _locationName = 'Getting location...';
  
  // Anti-spam protection
  DateTime? _lastSubmissionTime;
  
  // Storage service
  final StorageService _storageService = StorageService();
  
  // Severity options
  static const List<Map<String, dynamic>> _severityOptions = [
    {'value': 'passable', 'label': 'Passable', 'color': Colors.green, 'icon': Icons.check_circle},
    {'value': 'blocked', 'label': 'Blocked', 'color': Colors.orange, 'icon': Icons.block},
    {'value': 'severe', 'label': 'Severe', 'color': Colors.red, 'icon': Icons.warning},
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _depthController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    try {
      if (useMockLocation) {
        // 🎯 MOCK LOCATION: Using Bangkok location for development
        const double mockLatitude = 13.7563;  // Bangkok center
        const double mockLongitude = 100.5018;
        
        // Simulate a small delay to show loading state
        await Future.delayed(const Duration(milliseconds: 800));
        
        setState(() {
          _latitude = mockLatitude;
          _longitude = mockLongitude;
          _isLocationLoading = false;
        });

        // Get location name for the mock coordinates
        await _getLocationName();
        
        // Show success message
        _showSuccessSnackBar('📍 Mock location set: Bangkok, Thailand');
        
      } else {
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
              _showErrorSnackBar('Location service is disabled. Please enable GPS in device settings.');
              return;
            }
          }

          location_package.PermissionStatus permissionGranted = await location.hasPermission().timeout(
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
              _showErrorSnackBar('Location permission denied. Please grant location access in app settings.');
              return;
            }
          }

          // Get current location with timeout
          location_package.LocationData currentLocation = await location.getLocation().timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw TimeoutException('Getting location timed out. Please try again.');
            },
          );
          
          // Validate coordinates
          if (currentLocation.latitude == null || currentLocation.longitude == null) {
            throw Exception('Invalid location data received');
          }
          
          setState(() {
            _latitude = currentLocation.latitude;
            _longitude = currentLocation.longitude;
            _isLocationLoading = false;
          });

          // Get location name
          await _getLocationName();
          
        } on TimeoutException catch (e) {
          _showErrorSnackBar('Location timeout: ${e.message}');
          debugPrint('⏰ Location timeout: $e');
        } catch (e) {
          _showErrorSnackBar('Location error: ${_getUserFriendlyErrorMessage(e)}');
          debugPrint('📍 Location error: $e');
        }
      }
      
    } catch (e) {
      setState(() {
        _isLocationLoading = false;
      });
      if (useMockLocation) {
        _showErrorSnackBar('Error setting mock location: $e');
      } else {
        _showErrorSnackBar('Error getting location: $e');
      }
    }
  }

  Future<void> _getLocationName() async {
    if (_latitude == null || _longitude == null) return;
    
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(_latitude!, _longitude!);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _locationName = '${place.street ?? ''} ${place.subLocality ?? ''} ${place.locality ?? ''}'.trim();
          if (_locationName.isEmpty) {
            _locationName = '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}';
          }
        });
      }
    } catch (e) {
      setState(() {
        _locationName = '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}';
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _isLoading = true;
        });

        List<File> compressedImages = [];
        
        for (XFile image in images) {
          final compressedImage = await FlutterImageCompress.compressAndGetFile(
            image.path,
            '${image.path}_compressed.jpg',
            quality: 85,
            minWidth: 1024,
            minHeight: 1024,
          );
          
          if (compressedImage != null) {
            compressedImages.add(File(compressedImage.path));
          }
        }

        setState(() {
          _selectedImages.addAll(compressedImages);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error picking images: $e');
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      _selectedImages.removeAt(index);
    });
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

  void _showWarningSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String _getUserFriendlyErrorMessage(dynamic error) {
    if (error.toString().contains('permission')) {
      return 'Permission denied. Please check app permissions.';
    } else if (error.toString().contains('network') || error.toString().contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (error.toString().contains('storage') || error.toString().contains('disk')) {
      return 'Storage error. Please check available space.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  void _showClearPhotosDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Photos'),
          content: const Text('Are you sure you want to remove all photos? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedImages.clear();
                });
                Navigator.of(context).pop();
                _showSuccessSnackBar('All photos cleared');
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitReport() async {
    try {
      // Enhanced validation with better error messages
      if (!_formKey.currentState!.validate()) {
        _showErrorSnackBar('Please fix the form errors above before submitting.');
        return;
      }

      // Location validation with detailed feedback
      if (_latitude == null || _longitude == null) {
        _showErrorSnackBar('Location is required. Please wait for location to load or refresh.');
        return;
      }

      // Validate location coordinates are reasonable
      if (_latitude! < -90 || _latitude! > 90 || _longitude! < -180 || _longitude! > 180) {
        _showErrorSnackBar('Invalid location coordinates. Please refresh your location.');
        return;
      }

      // Photo validation with helpful guidance
      if (_selectedImages.isEmpty) {
        _showErrorSnackBar('Please add at least one photo to document the flooding situation.');
        return;
      }

      // Validate photo files still exist
      List<File> validImages = [];
      for (File image in _selectedImages) {
        if (await image.exists()) {
          validImages.add(image);
        } else {
          debugPrint('⚠️ Photo file no longer exists: ${image.path}');
        }
      }

      if (validImages.isEmpty) {
        _showErrorSnackBar('All selected photos are no longer available. Please select photos again.');
        return;
      }

      if (validImages.length != _selectedImages.length) {
        _showWarningSnackBar('Some photos are no longer available. Proceeding with ${validImages.length} valid photos.');
        setState(() {
          _selectedImages = validImages;
        });
      }

      // Enhanced depth validation
      int? depthCm;
      if (_depthController.text.isNotEmpty) {
        depthCm = int.tryParse(_depthController.text);
        if (depthCm == null) {
          _showErrorSnackBar('Depth must be a valid number. Please enter a whole number (e.g., 25).');
          return;
        }
        if (depthCm < 0) {
          _showErrorSnackBar('Depth cannot be negative. Please enter a positive number.');
          return;
        }
        if (depthCm > 1000) {
          _showErrorSnackBar('Depth seems too high (${depthCm} cm). Please verify the measurement.');
          return;
        }
      }

      // Note length validation
      String note = _noteController.text.trim();
      if (note.isNotEmpty && note.length > 500) {
        _showErrorSnackBar('Note is too long (${note.length} characters). Maximum 500 characters allowed.');
        return;
      }

      // Check if user is trying to submit too quickly (anti-spam)
      if (_lastSubmissionTime != null) {
        final timeSinceLastSubmission = DateTime.now().difference(_lastSubmissionTime!);
        if (timeSinceLastSubmission.inSeconds < 30) {
          _showErrorSnackBar('Please wait ${30 - timeSinceLastSubmission.inSeconds} seconds before submitting another report.');
          return;
        }
      }

      setState(() {
        _isLoading = true;
      });

      // Generate unique ID with timestamp
      String id = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create flood report with validation
      Flood floodReport = Flood(
        id: id,
        userId: generateFakeUserId(11),
        lat: _latitude!,
        lng: _longitude!,
        severity: _selectedSeverity,
        depthCm: depthCm,
        note: note.isEmpty ? null : note,
        photoUrls: validImages.map((file) => file.path).toList(),
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
        confirms: 0,
        flags: 0,
        status: 'active',
      );

      // Save to local storage
      debugPrint('💾 Attempting to save flood report: ${floodReport.id}');
      bool savedLocally = await _storageService.saveFloodReport(floodReport);
      debugPrint('💾 Save result: $savedLocally');
      
      if (!savedLocally) {
        _showWarningSnackBar('Report created but failed to save locally. Please check storage permissions.');
      } else {
        debugPrint('💾 Successfully saved report locally');
      }
      
      // Simulate API call with timeout
      await Future.delayed(const Duration(seconds: 1)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Submission timed out. Please check your connection and try again.');
        },
      );
      
      // Update last submission time
      _lastSubmissionTime = DateTime.now();
      
      String successMessage = 'Flood report submitted successfully! Report ID: ${id.substring(id.length - 6)}';
      if (savedLocally) {
        successMessage += ' (Saved locally)';
      }
      _showSuccessSnackBar(successMessage);
      
      // Navigate back to map
      if (mounted) {
        Navigator.of(context).pop(floodReport);
      }
      
    } on TimeoutException catch (e) {
      _showErrorSnackBar(e.message ?? 'Submission timed out. Please try again.');
    } catch (e) {
      debugPrint('❌ Error submitting flood report: $e');
      _showErrorSnackBar('Failed to submit report: ${_getUserFriendlyErrorMessage(e)}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Flood'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Section
              _buildSectionHeader('📍 Location', Icons.location_on),
              _buildLocationCard(),
              const SizedBox(height: 24),
              
              // Severity Section
              _buildSectionHeader('⚠️ Severity Level', Icons.warning),
              _buildSeveritySelector(),
              const SizedBox(height: 24),
              
              // Depth Section
              _buildSectionHeader('🌊 Water Depth (Optional)', Icons.height),
              _buildDepthInput(),
              const SizedBox(height: 24),
              
              // Description Section
              _buildSectionHeader('📝 Description (Optional)', Icons.description),
              _buildDescriptionInput(),
              const SizedBox(height: 24),
              
              // Photos Section
              _buildSectionHeader('📸 Photos', Icons.photo_camera),
              _buildPhotoSection(),
              const SizedBox(height: 32),
              
              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
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

  Widget _buildLocationCard() {
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
                  _isLocationLoading ? Icons.location_searching : Icons.my_location,
                  color: _isLocationLoading ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  _isLocationLoading ? 'Getting location...' : 'Current Location',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                // 🎛️ Development mode indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: useMockLocation 
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: useMockLocation 
                          ? Colors.orange.withOpacity(0.3)
                          : Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        useMockLocation ? Icons.smart_toy : Icons.gps_fixed,
                        size: 16,
                        color: useMockLocation ? Colors.orange[700] : Colors.green[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        useMockLocation ? 'MOCK' : 'GPS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: useMockLocation ? Colors.orange[700] : Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _locationName,
              style: const TextStyle(fontSize: 16),
            ),
            if (_latitude != null && _longitude != null) ...[
              const SizedBox(height: 8),
              Text(
                'Coordinates: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
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
                onPressed: _isLocationLoading ? null : _getCurrentLocation,
                icon: const Icon(Icons.refresh),
                label: const Text(useMockLocation ? 'Refresh Mock Location' : 'Refresh GPS Location'),
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
                if (value != null && value.isNotEmpty) {
                  int? depth = int.tryParse(value);
                  if (depth == null || depth < 0 || depth > 1000) {
                    return 'Please enter a valid depth between 0-1000 cm';
                  }
                }
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

  Widget _buildDescriptionInput() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _noteController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Additional Details',
                hintText: 'Describe the flooding situation, road conditions, etc.',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Optional: Provide additional context about the flooding',
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

  Widget _buildPhotoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Photos (${_selectedImages.length}/10)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_selectedImages.isNotEmpty)
                  TextButton.icon(
                    onPressed: _isLoading ? null : () => _showClearPhotosDialog(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Photo Grid
            if (_selectedImages.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
            
            // Add Photo Button
            if (_selectedImages.length < 10)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Photos'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            
            const SizedBox(height: 8),
            Text(
              'Add up to 10 photos to document the flooding situation',
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

  Widget _buildSubmitButton() {
    final bool canSubmit = !_isLoading && 
                           !_isLocationLoading && 
                           _latitude != null && 
                           _longitude != null &&
                           _selectedImages.isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit ? _submitReport : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSubmit ? const Color(0xFF1976D2) : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: canSubmit ? 3 : 0,
        ),
        child: _isLoading
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
                    canSubmit ? 'Submit Flood Report' : 'Complete Required Fields',
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
