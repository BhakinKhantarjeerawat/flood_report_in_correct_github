import 'package:equatable/equatable.dart';

class Flood extends Equatable {
  @override
  List<Object?> get props => [id, lat, lng, severity, depthCm, note, photoUrls, createdAt, expiresAt, confirms, flags, status];

  final String id;
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
    'lat': lat,
    'lng': lng,
    'severity': severity,
    'depthCm': depthCm,
    'note': note,
    'photoUrls': photoUrls,
    'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
    'expiresAt': expiresAt.toUtc().millisecondsSinceEpoch,
    'confirms': confirms,
    'flags': flags,
    'status': status,
  };

  static Flood fromMap(Map<String, dynamic> m) => Flood(
    id: m['id'],
    lat: (m['lat'] as num).toDouble(),
    lng: (m['lng'] as num).toDouble(),
    severity: m['severity'],
    depthCm: m['depthCm'],
    note: m['note'],
    photoUrls: (m['photoUrls'] as List?)?.cast<String>() ?? const [],
    createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'], isUtc: true).toLocal(),
    expiresAt: DateTime.fromMillisecondsSinceEpoch(m['expiresAt'], isUtc: true).toLocal(),
    confirms: (m['confirms'] ?? 0) as int,
    flags: (m['flags'] ?? 0) as int,
    status: m['status'] ?? "active",
  );

  @override
  bool get stringify => true;

  Flood copyWith({
    String? id,
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
