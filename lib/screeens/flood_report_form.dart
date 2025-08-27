import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import '../models/flood.dart';

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
      location_package.Location location = location_package.Location();
      
      // Check permissions
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _showErrorSnackBar('Location service is disabled');
          return;
        }
      }

      location_package.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == location_package.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != location_package.PermissionStatus.granted) {
          _showErrorSnackBar('Location permission denied');
          return;
        }
      }

      // Get current location
      location_package.LocationData currentLocation = await location.getLocation();
      setState(() {
        _latitude = currentLocation.latitude;
        _longitude = currentLocation.longitude;
        _isLocationLoading = false;
      });

      // Get location name
      await _getLocationName();
      
    } catch (e) {
      setState(() {
        _isLocationLoading = false;
      });
      _showErrorSnackBar('Error getting location: $e');
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

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_latitude == null || _longitude == null) {
      _showErrorSnackBar('Location is required');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate unique ID
      String id = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Parse depth if provided
      int? depthCm;
      if (_depthController.text.isNotEmpty) {
        depthCm = int.tryParse(_depthController.text);
      }

      // Create flood report
      Flood floodReport = Flood(
        id: id,
        lat: _latitude!,
        lng: _longitude!,
        severity: _selectedSeverity,
        depthCm: depthCm,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        photoUrls: _selectedImages.map((file) => file.path).toList(),
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 6)), // 6 hours expiry
        confirms: 0,
        flags: 0,
        status: 'active',
      );

      // TODO: Save to database/backend
      // For now, just show success message
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      _showSuccessSnackBar('Flood report submitted successfully!');
      
      // Navigate back or to map
      if (mounted) {
        Navigator.of(context).pop(floodReport);
      }
      
    } catch (e) {
      _showErrorSnackBar('Error submitting report: $e');
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
                label: const Text('Refresh Location'),
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
                    onPressed: () {
                      setState(() {
                        _selectedImages.clear();
                      });
                    },
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isLoading || _isLocationLoading) ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
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
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send),
                  SizedBox(width: 8),
                  Text(
                    'Submit Flood Report',
                    style: TextStyle(
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
