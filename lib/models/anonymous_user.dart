import 'package:equatable/equatable.dart';

/// Represents an anonymous user in the app
class AnonymousUser extends Equatable {
  final String id;
  final DateTime createdAt;
  final String? displayName;
  final bool isAnonymous;

  const AnonymousUser({
    required this.id,
    required this.createdAt,
    this.displayName,
    this.isAnonymous = true,
  });

  /// Create AnonymousUser from Supabase AuthResponse
  factory AnonymousUser.fromSupabase(Map<String, dynamic> userData) {
    return AnonymousUser(
      id: userData['id'] ?? '',
      createdAt: DateTime.tryParse(userData['created_at'] ?? '') ?? DateTime.now(),
      displayName: userData['user_metadata']?['name'] ?? 'Anonymous User',
      isAnonymous: true,
    );
  }

  /// Convert to Map for storage/transmission
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'display_name': displayName,
      'is_anonymous': isAnonymous,
    };
  }

  /// Create from Map
  factory AnonymousUser.fromMap(Map<String, dynamic> map) {
    return AnonymousUser(
      id: map['id'] ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      displayName: map['display_name'] ?? 'Anonymous User',
      isAnonymous: map['is_anonymous'] ?? true,
    );
  }

  /// Create a copy with updated fields
  AnonymousUser copyWith({
    String? id,
    DateTime? createdAt,
    String? displayName,
    bool? isAnonymous,
  }) {
    return AnonymousUser(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      displayName: displayName ?? this.displayName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  List<Object?> get props => [id, createdAt, displayName, isAnonymous];

  @override
  String toString() {
    return 'AnonymousUser(id: $id, displayName: $displayName, isAnonymous: $isAnonymous)';
  }
}
