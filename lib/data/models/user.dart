import 'base_model.dart';

/// User model - represents the authenticated user
class User extends BaseModel {
  final int id;
  final String fullName;
  final String email;
  final String? placeOfBirth;
  final DateTime? dateOfBirth;
  final String? phone;
  final String? imageUrl;
  final String? token;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.placeOfBirth,
    this.dateOfBirth,
    this.phone,
    this.imageUrl,
    this.token,
    this.createdAt,
  });

  /// Create from JSON (supports both API and local JSON format)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']),
      fullName: json['full_name'] ?? json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      placeOfBirth: json['place_of_birth'] ?? json['placeOfBirth'],
      dateOfBirth: _parseDateTime(json['date_of_birth'] ?? json['dateOfBirth']),
      phone: json['phone'],
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? json['avatar'],
      token: json['token'],
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'place_of_birth': placeOfBirth,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'phone': phone,
        'image_url': imageUrl,
        'token': token,
        'created_at': createdAt?.toIso8601String(),
      };

  /// Create a copy with optional new values
  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    String? phone,
    String? imageUrl,
    String? token,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get first name
  String get firstName => fullName.split(' ').first;

  /// Get initials for avatar
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  /// Empty user for fallback
  static User empty() => User(
        id: 0,
        fullName: '',
        email: '',
      );

  bool get isEmpty => id == 0 && email.isEmpty;
  bool get isNotEmpty => !isEmpty;
  bool get isLoggedIn => token != null && token!.isNotEmpty;

  // ══════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════
  
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
