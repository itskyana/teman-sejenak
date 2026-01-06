class Destination {
  final int id;
  final String title;
  final String type;
  final String location;
  final String imageUrl;
  final String description;
  final String? distance;

  Destination({
    required this.id,
    required this.title,
    this.type = '',
    required this.location,
    required this.imageUrl,
    required this.description,
    this.distance,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    // Support both 'imageUrl' (local JSON) and 'image_url' (API)
    final imageUrl = json['imageUrl'] ?? json['image_url'] ?? '';
    // Generate ID if not present
    final id = json['id'] != null 
        ? int.parse(json['id'].toString()) 
        : json.hashCode;
    
    return Destination(
      id: id,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      location: json['location'] ?? '',
      imageUrl: imageUrl,
      description: json['description'] ?? '',
    );
  }

  Destination copyWith({String? distance, String? type}) {
    return Destination(
      id: id,
      title: title,
      type: type ?? this.type,
      location: location,
      imageUrl: imageUrl,
      description: description,
      distance: distance ?? this.distance,
    );
  }
}
