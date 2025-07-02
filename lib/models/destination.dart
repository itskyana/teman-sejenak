class Destination {
  final String title;
  final String location;
  final String imageUrl;
  final String description;
  final String? distance;

  Destination({
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.description,
    this.distance,
  });

  factory Destination.fromJson(Map<String, dynamic> j) => Destination(
        title: j['title'],
        location: j['location'],
        imageUrl: j['imageUrl'],
        description: j['description'] ?? '',
        distance: j['distance'],
      );

  Destination copyWith({String? distance}) => Destination(
        title: title,
        location: location,
        imageUrl: imageUrl,
        description: description,
        distance: distance ?? this.distance,
      );
}
