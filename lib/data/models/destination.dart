import 'base_model.dart';

/// Destination model - represents a travel destination
class Destination extends BaseModel {
  final int id;
  final String title;
  final String type;
  final String location;
  final String imageUrl;
  final String description;
  final String? distance;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final int? reviewCount;

  Destination({
    required this.id,
    required this.title,
    this.type = '',
    required this.location,
    required this.imageUrl,
    required this.description,
    this.distance,
    this.latitude,
    this.longitude,
    this.rating,
    this.reviewCount,
  });

  /// Create from JSON (supports both API and local JSON format)
  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: _parseInt(json['id']),
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      distance: json['distance'],
      latitude: _parseDouble(json['latitude'] ?? json['lat']),
      longitude: _parseDouble(json['longitude'] ?? json['lng']),
      rating: _parseDouble(json['rating']),
      reviewCount: _parseIntOrNull(json['review_count'] ?? json['reviewCount']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'location': location,
        'image_url': imageUrl,
        'description': description,
        'distance': distance,
        'latitude': latitude,
        'longitude': longitude,
        'rating': rating,
        'review_count': reviewCount,
      };

  /// Create a copy with optional new values
  Destination copyWith({
    int? id,
    String? title,
    String? type,
    String? location,
    String? imageUrl,
    String? description,
    String? distance,
    double? latitude,
    double? longitude,
    double? rating,
    int? reviewCount,
  }) {
    return Destination(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      distance: distance ?? this.distance,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  /// Empty destination for fallback
  static Destination empty() => Destination(
        id: 0,
        title: '',
        type: '',
        location: '',
        imageUrl: '',
        description: '',
      );

  bool get isEmpty => id == 0 && title.isEmpty;
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

  static int? _parseIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
