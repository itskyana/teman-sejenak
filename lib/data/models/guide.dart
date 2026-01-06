import 'base_model.dart';

/// Guide model - represents a travel companion/guide
class Guide extends BaseModel {
  final int id;
  final String name;
  final String gender;
  final int age;
  final String location;
  final List<String> languages;
  final List<String> available;
  final List<String> interests;
  final String imageUrl;
  final bool verified;
  final double rating;
  final int ordersHandled;
  final List<String> gallery;
  final String? description;
  final double? latitude;
  final double? longitude;

  Guide({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.location,
    required this.languages,
    required this.available,
    required this.interests,
    required this.imageUrl,
    required this.verified,
    required this.rating,
    required this.ordersHandled,
    required this.gallery,
    this.description,
    this.latitude,
    this.longitude,
  });

  /// Create from JSON (supports both API and local JSON format)
  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      age: _parseInt(json['age']),
      location: json['location'] ?? '',
      languages: _parseStringList(json['languages']),
      available: _parseStringList(json['available']),
      interests: _parseStringList(json['interests']),
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      verified: json['verified'] ?? false,
      rating: _parseDouble(json['rating']) ?? 0.0,
      ordersHandled: _parseInt(json['orders_handled'] ?? json['ordersHandled']),
      gallery: _parseStringList(json['gallery']),
      description: json['description'],
      latitude: _parseDouble(json['latitude'] ?? json['lat']),
      longitude: _parseDouble(json['longitude'] ?? json['lng']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'age': age,
        'location': location,
        'languages': languages,
        'available': available,
        'interests': interests,
        'image_url': imageUrl,
        'verified': verified,
        'rating': rating,
        'orders_handled': ordersHandled,
        'gallery': gallery,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
      };

  /// Create a copy with optional new values
  Guide copyWith({
    int? id,
    String? name,
    String? gender,
    int? age,
    String? location,
    List<String>? languages,
    List<String>? available,
    List<String>? interests,
    String? imageUrl,
    bool? verified,
    double? rating,
    int? ordersHandled,
    List<String>? gallery,
    String? description,
    double? latitude,
    double? longitude,
  }) {
    return Guide(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      location: location ?? this.location,
      languages: languages ?? this.languages,
      available: available ?? this.available,
      interests: interests ?? this.interests,
      imageUrl: imageUrl ?? this.imageUrl,
      verified: verified ?? this.verified,
      rating: rating ?? this.rating,
      ordersHandled: ordersHandled ?? this.ordersHandled,
      gallery: gallery ?? this.gallery,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  /// Display text for gender and age
  String get genderAgeText => '$gender, $age tahun';

  /// Display text for languages
  String get languagesText => languages.join(', ');

  /// Empty guide for fallback
  static Guide empty() => Guide(
        id: 0,
        name: '',
        gender: '',
        age: 0,
        location: '',
        languages: [],
        available: [],
        interests: [],
        imageUrl: '',
        verified: false,
        rating: 0,
        ordersHandled: 0,
        gallery: [],
      );

  bool get isEmpty => id == 0 && name.isEmpty;
  bool get isNotEmpty => !isEmpty;

  // ══════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════
  
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }
}
