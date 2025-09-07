import 'package:equatable/equatable.dart';

class Flood extends Equatable {
  @override
  List<Object?> get props => [id, userId, lat, lng, severity, depthCm, note, photoUrls, createdAt, expiresAt, confirms, flags, status];

  final String id;
  final String userId; // ID of the user who created this report
  final double lat;
  final double lng;
  final String severity; // "passable" | "blocked" | "severe"
  final int? depthCm;    // optional
  final String? note;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime expiresAt; // e.g., createdAt + 6 hours
  final int confirms;
  final int flags;
  final String status;   // "active" | "resolved"

 const Flood({
    required this.id,
    required this.userId,
    required this.lat,
    required this.lng,
    required this.severity,
    this.depthCm,
    this.note,
    this.photoUrls = const [],
    required this.createdAt,
    required this.expiresAt,
    this.confirms = 0,
    this.flags = 0,
    this.status = "active",
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'lat': lat,
    'lng': lng,
    'severity': severity,
    'depth_cm': depthCm,
    'note': note,
    'photo_urls': photoUrls,
    'created_at': createdAt.toIso8601String(),
    'expires_at': expiresAt.toIso8601String(),
    'confirms': confirms,
    'flags': flags,
    'status': status,
  };

  static Flood fromMap(Map<String, dynamic> m) => Flood(
    id: m['id'] ?? '',
    userId: m['user_id'] ?? m['userId'] ?? 'unknown', // Handle both user_id and userId
    lat: (m['lat'] as num?)?.toDouble() ?? 0.0,
    lng: (m['lng'] as num?)?.toDouble() ?? 0.0,
    severity: m['severity'] ?? 'passable',
    depthCm: m['depth_cm'] ?? m['depthCm'], // Handle both depth_cm and depthCm
    note: m['note'],
    photoUrls: (m['photo_urls'] as List?)?.cast<String>() ?? 
               (m['photoUrls'] as List?)?.cast<String>() ?? 
               const [], // Handle both photo_urls and photoUrls
    createdAt: m['created_at'] != null 
        ? DateTime.parse(m['created_at']).toLocal()
        : DateTime.now(), // Handle ISO string format
    expiresAt: m['expires_at'] != null 
        ? DateTime.parse(m['expires_at']).toLocal()
        : DateTime.now().add(const Duration(hours: 6)), // Handle ISO string format
    confirms: (m['confirms'] ?? 0) as int,
    flags: (m['flags'] ?? 0) as int,
    status: m['status'] ?? "active",
  );

  @override
  bool get stringify => true;

  Flood copyWith({
    String? id,
    String? userId,
    double? lat,
    double? lng,
    String? severity,
    int? depthCm,
    String? note,
    List<String>? photoUrls,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? confirms,
    int? flags,
    String? status,
  }) {
    return Flood(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      severity: severity ?? this.severity,
      depthCm: depthCm ?? this.depthCm,
      note: note ?? this.note,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      confirms: confirms ?? this.confirms,
      flags: flags ?? this.flags,
      status: status ?? this.status,
    );
  }
}
