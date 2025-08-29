// Sample flood markers data - replace with your actual data
import 'package:flood_marker/models/flood.dart';


//todo:
/// Helper function to generate fake user IDs for testing
String generateFakeUserId(int index) {
  return 'fake-user-${index.toString().padLeft(3, '0')}';
}

final List<Flood> floodData = [
    // Downtown Bangkok - Siam area
    Flood(
      id: '1',
      userId: 'fake-user-001',
      lat: 13.7466,
      lng: 100.5347,
      severity: 'severe',
      depthCm: 50,
      note: 'Heavy flooding in Siam shopping district',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      expiresAt: DateTime.now().add(const Duration(hours: 4)),
      confirms: 5,
      flags: 0,
      status: 'active', 
    
    ),
    // Sukhumvit area
    Flood(
      id: '2',
      userId: 'fake-user-002',
      lat: 13.7383,
      lng: 100.5608,
      severity: 'blocked',
      depthCm: 30,
      note: 'Moderate flooding in Sukhumvit residential area',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      expiresAt: DateTime.now().add(const Duration(hours: 5)),
      confirms: 3,
      flags: 0,
      status: 'active',
    ),
    // Lumpini Park area
    Flood(
      id: '3',
      userId: 'fake-user-003',
      lat: 13.7310,
      lng: 100.5440,
      severity: 'passable',
      depthCm: 15,
      note: 'Minor flooding in Lumpini Park area',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      expiresAt: DateTime.now().add(const Duration(hours: 5, minutes: 30)),
      confirms: 1,
      flags: 0,
      status: 'active',
    ),
    // Silom area
    Flood(
      id: '4',
      userId: 'fake-user-004',
      lat: 13.7246,
      lng: 100.5270,
      severity: 'severe',
      depthCm: 60,
      note: 'Severe flooding in Silom business district',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      expiresAt: DateTime.now().add(const Duration(hours: 3)),
      confirms: 7,
      flags: 1,
      status: 'active',
    ),
    // Chinatown area
    Flood(
      id: '5',
      userId: 'fake-user-005',
      lat: 13.7414,
      lng: 100.5084,
      severity: 'blocked',
      depthCm: 35,
      note: 'Moderate flooding in Chinatown area',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      expiresAt: DateTime.now().add(const Duration(hours: 4, minutes: 30)),
      confirms: 4,
      flags: 0,
      status: 'active',
    ),
    // Victory Monument area
    Flood(
      id: '6',
      userId: 'fake-user-006',
      lat: 13.7587,
      lng: 100.5374,
      severity: 'passable',
      depthCm: 20,
      note: 'Minor flooding in Victory Monument area',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      expiresAt: DateTime.now().add(const Duration(hours: 5, minutes: 15)),
      confirms: 2,
      flags: 0,
      status: 'active',
    ),
    // Chatuchak area
    Flood(
      id: '7',
      userId: 'fake-user-007',
      lat: 13.8288,
      lng: 100.5564,
      severity: 'severe',
      depthCm: 70,
      note: 'Critical flooding in Chatuchak weekend market area',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      expiresAt: DateTime.now().add(const Duration(hours: 2)),
      confirms: 8,
      flags: 2,
      status: 'active',
    ),
    // Don Mueang area
    Flood(
      id: '8',
      userId: 'fake-user-008',
      lat: 13.9126,
      lng: 100.6068,
      severity: 'blocked',
      depthCm: 40,
      note: 'Moderate flooding in Don Mueang area',
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      expiresAt: DateTime.now().add(const Duration(hours: 3, minutes: 45)),
      confirms: 6,
      flags: 0,
      status: 'active',
    ),
    // Thonburi area (across Chao Phraya River)
    Flood(
      id: '9',
      userId: 'fake-user-009',
      lat: 13.7563,
      lng: 100.4848,
      severity: 'passable',
      depthCm: 18,
      note: 'Minor flooding in Thonburi residential area',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      expiresAt: DateTime.now().add(const Duration(hours: 5, minutes: 40)),
      confirms: 1,
      flags: 0,
      status: 'active',
    ),
    // Suvarnabhumi Airport area
    Flood(
      id: '10',
      userId: 'fake-user-010',
      lat: 13.6900,
      lng: 100.7501,
      severity: 'severe',
      depthCm: 55,
      note: 'Severe flooding in Suvarnabhumi Airport area',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      confirms: 9,
      flags: 1,
      status: 'active',
    ),
  ];